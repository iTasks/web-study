//! Arduino-style Fixed-Wing Drone Controller
//!
//! This demonstrates using Arduino-compatible API for drone control in Zig.
//! Easier for developers familiar with Arduino ecosystem.

const arduino = @import("arduino_compat.zig");

// Pin definitions
const LED_PIN = 25;
const MOTOR_PIN = 4;
const AILERON_PIN = 5;
const ELEVATOR_PIN = 6;
const RUDDER_PIN = 7;

// Global state
var armed = false;
var throttle: u8 = 0;
var roll_setpoint: i16 = 0;
var pitch_setpoint: i16 = 0;

// Sensor data
var gyro_x: i16 = 0;
var gyro_y: i16 = 0;
var gyro_z: i16 = 0;
var accel_x: i16 = 0;
var accel_y: i16 = 0;
var accel_z: i16 = 0;

// Attitude
var roll: f32 = 0.0;
var pitch: f32 = 0.0;
var yaw: f32 = 0.0;

// PID terms
var roll_integral: f32 = 0.0;
var pitch_integral: f32 = 0.0;
var last_roll_error: f32 = 0.0;
var last_pitch_error: f32 = 0.0;

// PID gains
const KP_ROLL: f32 = 1.5;
const KI_ROLL: f32 = 0.1;
const KD_ROLL: f32 = 0.05;
const KP_PITCH: f32 = 1.2;
const KI_PITCH: f32 = 0.08;
const KD_PITCH: f32 = 0.04;

/// Arduino setup function
pub fn setup() void {
    // Initialize LED
    arduino.pinMode(LED_PIN, .OUTPUT);
    
    // Initialize servos
    arduino.servoAttach(AILERON_PIN);
    arduino.servoAttach(ELEVATOR_PIN);
    arduino.servoAttach(RUDDER_PIN);
    arduino.servoAttach(MOTOR_PIN);
    
    // Center all servos
    arduino.servoWrite(AILERON_PIN, 90);
    arduino.servoWrite(ELEVATOR_PIN, 90);
    arduino.servoWrite(RUDDER_PIN, 90);
    arduino.servoWriteMicroseconds(MOTOR_PIN, 1000); // Motor off
    
    // Initialize I2C for sensors
    arduino.wireBegin();
    
    // Initialize MPU6050
    initMPU6050();
    
    // Startup indication
    for (0..5) |_| {
        arduino.digitalWrite(LED_PIN, arduino.HIGH);
        arduino.delay(100);
        arduino.digitalWrite(LED_PIN, arduino.LOW);
        arduino.delay(100);
    }
    
    // Arm after 3 seconds
    arduino.delay(3000);
    armed = true;
    throttle = 20; // Low throttle for testing
}

/// Initialize MPU6050 IMU
fn initMPU6050() void {
    const MPU6050_ADDR: u7 = 0x68;
    
    // Wake up MPU6050
    arduino.wireBeginTransmission(MPU6050_ADDR);
    arduino.wireWrite(0x6B); // PWR_MGMT_1 register
    arduino.wireWrite(0x00); // Wake up
    _ = arduino.wireEndTransmission();
    
    arduino.delay(10);
    
    // Configure gyro (±250 deg/s)
    arduino.wireBeginTransmission(MPU6050_ADDR);
    arduino.wireWrite(0x1B); // GYRO_CONFIG
    arduino.wireWrite(0x00);
    _ = arduino.wireEndTransmission();
    
    // Configure accelerometer (±2g)
    arduino.wireBeginTransmission(MPU6050_ADDR);
    arduino.wireWrite(0x1C); // ACCEL_CONFIG
    arduino.wireWrite(0x00);
    _ = arduino.wireEndTransmission();
}

/// Read IMU data
fn readIMU() void {
    const MPU6050_ADDR: u7 = 0x68;
    
    // Request 14 bytes starting from ACCEL_XOUT_H
    arduino.wireBeginTransmission(MPU6050_ADDR);
    arduino.wireWrite(0x3B);
    _ = arduino.wireEndTransmission();
    
    if (arduino.wireRequestFrom(MPU6050_ADDR, 14)) {
        // Read accelerometer
        const accel_xh = arduino.wireRead();
        const accel_xl = arduino.wireRead();
        const accel_yh = arduino.wireRead();
        const accel_yl = arduino.wireRead();
        const accel_zh = arduino.wireRead();
        const accel_zl = arduino.wireRead();
        
        // Skip temperature
        _ = arduino.wireRead();
        _ = arduino.wireRead();
        
        // Read gyroscope
        const gyro_xh = arduino.wireRead();
        const gyro_xl = arduino.wireRead();
        const gyro_yh = arduino.wireRead();
        const gyro_yl = arduino.wireRead();
        const gyro_zh = arduino.wireRead();
        const gyro_zl = arduino.wireRead();
        
        // Combine bytes
        accel_x = @as(i16, @bitCast((@as(u16, accel_xh) << 8) | accel_xl));
        accel_y = @as(i16, @bitCast((@as(u16, accel_yh) << 8) | accel_yl));
        accel_z = @as(i16, @bitCast((@as(u16, accel_zh) << 8) | accel_zl));
        gyro_x = @as(i16, @bitCast((@as(u16, gyro_xh) << 8) | gyro_xl));
        gyro_y = @as(i16, @bitCast((@as(u16, gyro_yh) << 8) | gyro_yl));
        gyro_z = @as(i16, @bitCast((@as(u16, gyro_zh) << 8) | gyro_zl));
    }
}

/// Update attitude estimate
fn updateAttitude(dt: f32) void {
    // Convert gyro to deg/s
    const gyro_scale: f32 = 250.0 / 32768.0;
    const gyro_roll: f32 = @as(f32, @floatFromInt(gyro_x)) * gyro_scale;
    const gyro_pitch: f32 = @as(f32, @floatFromInt(gyro_y)) * gyro_scale;
    const gyro_yaw: f32 = @as(f32, @floatFromInt(gyro_z)) * gyro_scale;
    
    // Integrate gyro
    roll += gyro_roll * dt;
    pitch += gyro_pitch * dt;
    yaw += gyro_yaw * dt;
    
    // Calculate angles from accelerometer
    const accel_scale: f32 = 2.0 / 32768.0;
    const ax: f32 = @as(f32, @floatFromInt(accel_x)) * accel_scale;
    const ay: f32 = @as(f32, @floatFromInt(accel_y)) * accel_scale;
    const az: f32 = @as(f32, @floatFromInt(accel_z)) * accel_scale;
    
    const accel_roll = @atan(ay / az) * 57.2958;
    const accel_pitch = @atan(-ax / @sqrt(ay * ay + az * az)) * 57.2958;
    
    // Complementary filter
    const alpha: f32 = 0.98;
    roll = alpha * roll + (1.0 - alpha) * @as(f32, @floatCast(accel_roll));
    pitch = alpha * pitch + (1.0 - alpha) * @as(f32, @floatCast(accel_pitch));
}

/// PID control
fn pidControl() void {
    const dt: f32 = 0.01; // 10ms loop time
    
    // Calculate errors
    const roll_error: f32 = @as(f32, @floatFromInt(roll_setpoint)) - roll;
    const pitch_error: f32 = @as(f32, @floatFromInt(pitch_setpoint)) - pitch;
    
    // Roll PID
    roll_integral += roll_error * dt;
    roll_integral = @max(-100.0, @min(100.0, roll_integral));
    const roll_derivative = (roll_error - last_roll_error) / dt;
    const roll_output = KP_ROLL * roll_error + KI_ROLL * roll_integral + KD_ROLL * roll_derivative;
    last_roll_error = roll_error;
    
    // Pitch PID
    pitch_integral += pitch_error * dt;
    pitch_integral = @max(-100.0, @min(100.0, pitch_integral));
    const pitch_derivative = (pitch_error - last_pitch_error) / dt;
    const pitch_output = KP_PITCH * pitch_error + KI_PITCH * pitch_integral + KD_PITCH * pitch_derivative;
    last_pitch_error = pitch_error;
    
    // Convert to servo positions (0-180 degrees)
    const aileron_angle: u8 = @intFromFloat(@max(0, @min(180, 90 + roll_output)));
    const elevator_angle: u8 = @intFromFloat(@max(0, @min(180, 90 + pitch_output)));
    
    // Apply outputs
    arduino.servoWrite(AILERON_PIN, aileron_angle);
    arduino.servoWrite(ELEVATOR_PIN, elevator_angle);
    arduino.servoWrite(RUDDER_PIN, 90); // Keep rudder centered
    
    // Set motor throttle (1000-2000 us)
    const motor_us: u16 = 1000 + (@as(u16, throttle) * 10);
    arduino.servoWriteMicroseconds(MOTOR_PIN, motor_us);
}

/// Arduino loop function
pub fn loop() void {
    const loop_start = arduino.millis();
    
    if (armed) {
        // Read sensors
        readIMU();
        
        // Update attitude (10ms = 0.01s)
        updateAttitude(0.01);
        
        // Run PID control
        pidControl();
        
        // Heartbeat LED
        if ((loop_start / 1000) % 2 == 0) {
            arduino.digitalWrite(LED_PIN, arduino.HIGH);
        } else {
            arduino.digitalWrite(LED_PIN, arduino.LOW);
        }
    } else {
        // Keep everything centered when disarmed
        arduino.servoWrite(AILERON_PIN, 90);
        arduino.servoWrite(ELEVATOR_PIN, 90);
        arduino.servoWrite(RUDDER_PIN, 90);
        arduino.servoWriteMicroseconds(MOTOR_PIN, 1000);
        
        // Fast LED blink when disarmed
        arduino.digitalWrite(LED_PIN, if ((loop_start / 200) % 2 == 0) arduino.HIGH else arduino.LOW);
    }
    
    // Maintain 10ms loop time (100Hz)
    const elapsed = arduino.millis() - loop_start;
    if (elapsed < 10) {
        arduino.delay(10 - elapsed);
    }
}

/// Main entry point - Arduino wrapper
pub fn main() void {
    setup();
    while (true) {
        loop();
    }
}
