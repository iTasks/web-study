//! Fixed-Wing Drone Controller for RP2040
//!
//! This implements a minimal flight controller for a small fixed-wing drone.
//! Features:
//! - Sensor reading (IMU, GPS, Barometer)
//! - Attitude estimation using complementary filter
//! - PID control for roll, pitch, yaw
//! - Motor and servo control
//! - Safety and failsafe mechanisms
//!
//! Build: zig build-exe -target thumb-freestanding-eabi -mcpu cortex_m0plus -O ReleaseSafe drone_controller.zig

const os = @import("../rp2040/minimal_os.zig");
const pwm = @import("../rp2040/pwm.zig");
const i2c = @import("../rp2040/i2c.zig");

// Pin definitions
const PIN_LED = 25;
const PIN_MOTOR = 4; // ESC PWM
const PIN_SERVO_AILERON = 5;
const PIN_SERVO_ELEVATOR = 6;
const PIN_SERVO_RUDDER = 7;
const PIN_I2C_SDA = 2;
const PIN_I2C_SCL = 3;

// IMU I2C address (MPU6050)
const IMU_ADDR = 0x68;

// Control constants
const CONTROL_RATE_HZ = 1000; // 1kHz control loop
const CONTROL_PERIOD_MS = 1;
const ACCEL_SAFETY_THRESHOLD: f32 = 0.01; // Minimum value to prevent division by zero

/// 3D vector for sensor data
const Vec3 = struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
    z: f32 = 0.0,
    
    pub fn scale(self: Vec3, s: f32) Vec3 {
        return Vec3{
            .x = self.x * s,
            .y = self.y * s,
            .z = self.z * s,
        };
    }
    
    pub fn add(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }
};

/// Attitude (orientation)
const Attitude = struct {
    roll: f32 = 0.0, // degrees
    pitch: f32 = 0.0, // degrees
    yaw: f32 = 0.0, // degrees
};

/// PID controller
const PID = struct {
    kp: f32,
    ki: f32,
    kd: f32,
    integral: f32 = 0.0,
    previous_error: f32 = 0.0,
    
    pub fn update(self: *PID, error: f32, dt: f32) f32 {
        // Proportional
        const p = self.kp * error;
        
        // Integral with anti-windup
        self.integral += error * dt;
        if (self.integral > 100.0) self.integral = 100.0;
        if (self.integral < -100.0) self.integral = -100.0;
        const i = self.ki * self.integral;
        
        // Derivative
        const d = self.kd * (error - self.previous_error) / dt;
        self.previous_error = error;
        
        return p + i + d;
    }
    
    pub fn reset(self: *PID) void {
        self.integral = 0.0;
        self.previous_error = 0.0;
    }
};

/// Flight controller state
var flight_state = struct {
    // Sensor data
    gyro: Vec3 = .{},
    accel: Vec3 = .{},
    
    // Attitude estimate
    attitude: Attitude = .{},
    
    // PID controllers
    roll_pid: PID = .{ .kp = 1.5, .ki = 0.1, .kd = 0.05 },
    pitch_pid: PID = .{ .kp = 1.2, .ki = 0.08, .kd = 0.04 },
    yaw_pid: PID = .{ .kp = 2.0, .ki = 0.15, .kd = 0.1 },
    
    // Target attitude (from RC or autopilot)
    target_roll: f32 = 0.0,
    target_pitch: f32 = 0.0,
    target_yaw: f32 = 0.0,
    
    // Motor/servo outputs
    throttle: u8 = 0,
    
    // Safety
    armed: bool = false,
    failsafe: bool = false,
}{};

/// Initialize hardware
fn init_hardware() void {
    // Initialize I2C for sensors
    i2c.gpio_set_function_i2c(PIN_I2C_SDA, PIN_I2C_SCL);
    i2c.init(.I2C0, .Fast);
    
    // Initialize PWM for motor and servos
    pwm.init_esc(PIN_MOTOR);
    pwm.init_servo(PIN_SERVO_AILERON);
    pwm.init_servo(PIN_SERVO_ELEVATOR);
    pwm.init_servo(PIN_SERVO_RUDDER);
    
    // Center all servos
    pwm.servo_center(PIN_SERVO_AILERON);
    pwm.servo_center(PIN_SERVO_ELEVATOR);
    pwm.servo_center(PIN_SERVO_RUDDER);
    
    // Initialize IMU
    init_imu();
}

/// Initialize IMU (MPU6050)
fn init_imu() void {
    // Wake up MPU6050 (write 0 to PWR_MGMT_1 register)
    const wake_cmd = [_]u8{ 0x6B, 0x00 };
    _ = i2c.write(.I2C0, IMU_ADDR, &wake_cmd);
    
    os.busy_wait_us(100);
    
    // Configure gyro range (±250 deg/s)
    const gyro_config = [_]u8{ 0x1B, 0x00 };
    _ = i2c.write(.I2C0, IMU_ADDR, &gyro_config);
    
    // Configure accel range (±2g)
    const accel_config = [_]u8{ 0x1C, 0x00 };
    _ = i2c.write(.I2C0, IMU_ADDR, &accel_config);
}

/// Read IMU data
fn read_imu() void {
    var buffer: [14]u8 = undefined;
    
    // Read all sensor data at once (registers 0x3B to 0x48)
    if (!i2c.write_read(.I2C0, IMU_ADDR, 0x3B, &buffer)) {
        return;
    }
    
    // Parse accelerometer data (raw values)
    const accel_x = @as(i16, @bitCast(@as(u16, buffer[0]) << 8 | buffer[1]));
    const accel_y = @as(i16, @bitCast(@as(u16, buffer[2]) << 8 | buffer[3]));
    const accel_z = @as(i16, @bitCast(@as(u16, buffer[4]) << 8 | buffer[5]));
    
    // Parse gyroscope data (raw values)
    const gyro_x = @as(i16, @bitCast(@as(u16, buffer[8]) << 8 | buffer[9]));
    const gyro_y = @as(i16, @bitCast(@as(u16, buffer[10]) << 8 | buffer[11]));
    const gyro_z = @as(i16, @bitCast(@as(u16, buffer[12]) << 8 | buffer[13]));
    
    // Convert to physical units
    // Gyro: ±250 deg/s range, 16-bit signed
    const gyro_scale = 250.0 / 32768.0;
    flight_state.gyro.x = @as(f32, @floatFromInt(gyro_x)) * gyro_scale;
    flight_state.gyro.y = @as(f32, @floatFromInt(gyro_y)) * gyro_scale;
    flight_state.gyro.z = @as(f32, @floatFromInt(gyro_z)) * gyro_scale;
    
    // Accel: ±2g range, 16-bit signed
    const accel_scale = 2.0 / 32768.0;
    flight_state.accel.x = @as(f32, @floatFromInt(accel_x)) * accel_scale;
    flight_state.accel.y = @as(f32, @floatFromInt(accel_y)) * accel_scale;
    flight_state.accel.z = @as(f32, @floatFromInt(accel_z)) * accel_scale;
}

/// Update attitude estimate using complementary filter
fn update_attitude(dt: f32) void {
    // Integrate gyroscope (high-pass)
    flight_state.attitude.roll += flight_state.gyro.x * dt;
    flight_state.attitude.pitch += flight_state.gyro.y * dt;
    flight_state.attitude.yaw += flight_state.gyro.z * dt;
    
    // Calculate angles from accelerometer (low-pass) with safety checks
    const accel_z_safe = if (@abs(flight_state.accel.z) < ACCEL_SAFETY_THRESHOLD) 
        ACCEL_SAFETY_THRESHOLD else flight_state.accel.z;
    const accel_roll = @atan(@as(f64, flight_state.accel.y) / @as(f64, accel_z_safe)) * 57.2958;
    
    const denominator = @sqrt(@as(f64, flight_state.accel.y) * @as(f64, flight_state.accel.y) + 
                              @as(f64, flight_state.accel.z) * @as(f64, flight_state.accel.z));
    const denominator_safe = if (denominator < ACCEL_SAFETY_THRESHOLD) 
        ACCEL_SAFETY_THRESHOLD else denominator;
    const accel_pitch = @atan(@as(f64, -flight_state.accel.x) / denominator_safe) * 57.2958;
    
    // Complementary filter (98% gyro, 2% accel)
    const alpha: f32 = 0.98;
    flight_state.attitude.roll = alpha * flight_state.attitude.roll + (1.0 - alpha) * @as(f32, @floatCast(accel_roll));
    flight_state.attitude.pitch = alpha * flight_state.attitude.pitch + (1.0 - alpha) * @as(f32, @floatCast(accel_pitch));
}

/// Run PID control and update outputs
fn run_control(dt: f32) void {
    if (!flight_state.armed) {
        // Keep servos centered when disarmed
        pwm.servo_center(PIN_SERVO_AILERON);
        pwm.servo_center(PIN_SERVO_ELEVATOR);
        pwm.servo_center(PIN_SERVO_RUDDER);
        pwm.set_esc_throttle(pwm.gpio_to_slice(PIN_MOTOR), pwm.gpio_to_channel(PIN_MOTOR), 0);
        return;
    }
    
    // Calculate errors
    const roll_error = flight_state.target_roll - flight_state.attitude.roll;
    const pitch_error = flight_state.target_pitch - flight_state.attitude.pitch;
    const yaw_error = flight_state.target_yaw - flight_state.attitude.yaw;
    
    // PID updates
    const roll_output = flight_state.roll_pid.update(roll_error, dt);
    const pitch_output = flight_state.pitch_pid.update(pitch_error, dt);
    const yaw_output = flight_state.yaw_pid.update(yaw_error, dt);
    
    // Convert to servo positions (1000-2000 us)
    const aileron_us = @as(u16, @intFromFloat(@max(1000, @min(2000, 1500 + roll_output * 10))));
    const elevator_us = @as(u16, @intFromFloat(@max(1000, @min(2000, 1500 + pitch_output * 10))));
    const rudder_us = @as(u16, @intFromFloat(@max(1000, @min(2000, 1500 + yaw_output * 10))));
    
    // Apply outputs
    pwm.set_servo_us(pwm.gpio_to_slice(PIN_SERVO_AILERON), pwm.gpio_to_channel(PIN_SERVO_AILERON), aileron_us);
    pwm.set_servo_us(pwm.gpio_to_slice(PIN_SERVO_ELEVATOR), pwm.gpio_to_channel(PIN_SERVO_ELEVATOR), elevator_us);
    pwm.set_servo_us(pwm.gpio_to_slice(PIN_SERVO_RUDDER), pwm.gpio_to_channel(PIN_SERVO_RUDDER), rudder_us);
    
    // Set motor throttle
    pwm.set_esc_throttle(pwm.gpio_to_slice(PIN_MOTOR), pwm.gpio_to_channel(PIN_MOTOR), flight_state.throttle);
}

/// Safety checks and failsafe
fn check_safety() void {
    // Check for extreme attitudes (over 60 degrees)
    if (@abs(flight_state.attitude.roll) > 60.0 or @abs(flight_state.attitude.pitch) > 60.0) {
        flight_state.failsafe = true;
    }
    
    // Failsafe mode: level wings, reduce throttle
    if (flight_state.failsafe) {
        flight_state.target_roll = 0.0;
        flight_state.target_pitch = 0.0;
        if (flight_state.throttle > 30) {
            flight_state.throttle = 30;
        }
        
        // Blink LED rapidly
        os.gpio_set(PIN_LED);
    } else {
        os.gpio_clear(PIN_LED);
    }
}

/// Main control loop task (1kHz)
fn control_loop_task() void {
    const dt: f32 = 0.001; // 1ms
    
    // Read sensors
    read_imu();
    
    // Update attitude estimate
    update_attitude(dt);
    
    // Run control
    run_control(dt);
    
    // Safety checks
    check_safety();
}

/// Heartbeat task for status LED
fn heartbeat_task() void {
    if (!flight_state.failsafe) {
        os.gpio_set(PIN_LED);
        os.busy_wait_us(50_000);
        os.gpio_clear(PIN_LED);
    }
}

/// Main function
pub fn main() void {
    // Initialize hardware
    init_hardware();
    
    // Add control loop task (highest priority, 1ms period)
    os.add_task(control_loop_task, 0, CONTROL_PERIOD_MS);
    
    // Add heartbeat task (low priority, 1s period)
    os.add_task(heartbeat_task, 10, 1000);
    
    // SAFETY: For testing only - in production, use proper arming sequence
    // TODO: Replace with RC input or button-based arming
    // Example: wait for specific RC command or safety switch
    os.busy_wait_us(3_000_000);
    flight_state.armed = true;
    
    // Run scheduler
    os.run_scheduler();
}
