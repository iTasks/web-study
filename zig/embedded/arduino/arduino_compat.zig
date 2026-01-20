//! Arduino-style API wrapper for embedded Zig
//!
//! This provides Arduino-like functions for easier portability and familiarity.
//! While Zig's embedded capabilities are more powerful, this wrapper can help
//! developers transition from Arduino to Zig.

const os = @import("../rp2040/minimal_os.zig");
const pwm_module = @import("../rp2040/pwm.zig");
const i2c_module = @import("../rp2040/i2c.zig");

// Pin modes
pub const PinMode = enum {
    INPUT,
    OUTPUT,
    INPUT_PULLUP,
};

// Digital states
pub const HIGH: u1 = 1;
pub const LOW: u1 = 0;

/// Arduino-style pinMode
pub fn pinMode(pin: u8, mode: PinMode) void {
    os.gpio_init(pin);
    switch (mode) {
        .OUTPUT => os.gpio_set_dir(pin, true),
        .INPUT, .INPUT_PULLUP => os.gpio_set_dir(pin, false),
    }
}

/// Arduino-style digitalWrite
pub fn digitalWrite(pin: u8, value: u1) void {
    if (value == HIGH) {
        os.gpio_set(pin);
    } else {
        os.gpio_clear(pin);
    }
}

/// Arduino-style digitalRead (simplified)
pub fn digitalRead(pin: u8) u1 {
    // Read GPIO input value
    const sio_base = 0xd0000000;
    const gpio_in = @as(*volatile u32, @ptrFromInt(sio_base + 0x004));
    const value = gpio_in.*;
    return @truncate((value >> @intCast(pin)) & 1);
}

/// Arduino-style delay (milliseconds)
pub fn delay(ms: u32) void {
    os.busy_wait_us(ms * 1000);
}

/// Arduino-style delayMicroseconds
pub fn delayMicroseconds(us: u32) void {
    os.busy_wait_us(us);
}

/// Arduino-style millis
pub fn millis() u32 {
    return os.get_time_ms();
}

/// Arduino-style micros (approximate)
pub fn micros() u32 {
    return os.get_time_ms() * 1000;
}

/// Arduino-style analogWrite (PWM)
pub fn analogWrite(pin: u8, value: u8) void {
    // Set up PWM if not already configured
    pwm_module.gpio_set_function_pwm(pin);
    const slice = pwm_module.gpio_to_slice(pin);
    const channel = pwm_module.gpio_to_channel(pin);
    
    // Configure for standard PWM (490 Hz)
    const config = pwm_module.Config{
        .div = 100,
        .top = 2720,
        .phase_correct = false,
    };
    pwm_module.init(slice, config);
    
    // Map 0-255 to duty cycle
    const duty = (@as(u16, value) * 2720) / 255;
    pwm_module.set_duty(slice, channel, duty);
}

/// Servo library-style attach
pub fn servoAttach(pin: u8) void {
    pwm_module.init_servo(pin);
}

/// Servo library-style write (angle in degrees, 0-180)
pub fn servoWrite(pin: u8, angle: u8) void {
    // Convert angle (0-180) to pulse width (1000-2000 us)
    const pulse_us = 1000 + (@as(u16, @min(angle, 180)) * 1000) / 180;
    const slice = pwm_module.gpio_to_slice(pin);
    const channel = pwm_module.gpio_to_channel(pin);
    pwm_module.set_servo_us(slice, channel, pulse_us);
}

/// Servo library-style writeMicroseconds
pub fn servoWriteMicroseconds(pin: u8, us: u16) void {
    const slice = pwm_module.gpio_to_slice(pin);
    const channel = pwm_module.gpio_to_channel(pin);
    pwm_module.set_servo_us(slice, channel, us);
}

/// Wire library-style begin
pub fn wireBegin() void {
    i2c_module.gpio_set_function_i2c(2, 3); // Default I2C pins
    i2c_module.init(.I2C0, .Standard);
}

/// Wire library-style beginTransmission
var i2c_target_addr: u7 = 0;
var i2c_tx_buffer: [32]u8 = undefined;
var i2c_tx_len: u8 = 0;

pub fn wireBeginTransmission(addr: u7) void {
    i2c_target_addr = addr;
    i2c_tx_len = 0;
}

/// Wire library-style write
pub fn wireWrite(data: u8) void {
    if (i2c_tx_len < 32) {
        i2c_tx_buffer[i2c_tx_len] = data;
        i2c_tx_len += 1;
    }
}

/// Wire library-style endTransmission
pub fn wireEndTransmission() bool {
    const result = i2c_module.write(.I2C0, i2c_target_addr, i2c_tx_buffer[0..i2c_tx_len]);
    i2c_tx_len = 0;
    return result;
}

/// Wire library-style requestFrom
pub fn wireRequestFrom(addr: u7, count: u8) bool {
    i2c_target_addr = addr;
    return i2c_module.read(.I2C0, addr, i2c_tx_buffer[0..count]);
}

/// Wire library-style available
pub fn wireAvailable() u8 {
    return i2c_tx_len;
}

/// Wire library-style read
pub fn wireRead() u8 {
    if (i2c_tx_len > 0) {
        i2c_tx_len -= 1;
        return i2c_tx_buffer[i2c_tx_len];
    }
    return 0;
}

// Example Arduino-style sketch
pub fn setup() void {
    // User initialization code
}

pub fn loop() void {
    // User main loop code
}
