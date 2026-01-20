//! PWM (Pulse Width Modulation) driver for RP2040
//!
//! This module provides PWM functionality for controlling:
//! - ESC (Electronic Speed Controller) for motor
//! - Servos for control surfaces
//!
//! RP2040 has 8 PWM slices, each with 2 channels (A and B)

const gpio = @import("minimal_os.zig");

// PWM peripheral base address
const PWM_BASE = 0x40050000;

// PWM registers for each slice
const PWM_CSR_OFFSET = 0x00;
const PWM_DIV_OFFSET = 0x04;
const PWM_CTR_OFFSET = 0x08;
const PWM_CC_OFFSET = 0x0c;
const PWM_TOP_OFFSET = 0x10;

/// PWM slice (0-7)
pub const Slice = u8;

/// PWM channel (A or B)
pub const Channel = enum {
    A,
    B,
};

/// PWM configuration
pub const Config = struct {
    /// Clock divider (8.4 fixed point, 1-255.9375)
    div: u16 = 100,
    /// Counter wrap value (determines frequency)
    top: u16 = 20000,
    /// Enable phase-correct mode
    phase_correct: bool = false,
};

/// Initialize PWM slice
pub fn init(slice: Slice, config: Config) void {
    const base = PWM_BASE + (@as(u32, slice) * 0x14);
    
    // Set clock divider
    const div_reg = @as(*volatile u32, @ptrFromInt(base + PWM_DIV_OFFSET));
    div_reg.* = (@as(u32, config.div) << 4);
    
    // Set TOP (wrap value)
    const top_reg = @as(*volatile u32, @ptrFromInt(base + PWM_TOP_OFFSET));
    top_reg.* = config.top;
    
    // Configure CSR
    const csr_reg = @as(*volatile u32, @ptrFromInt(base + PWM_CSR_OFFSET));
    var csr: u32 = 0;
    csr |= 1; // Enable PWM
    if (config.phase_correct) {
        csr |= (1 << 1); // Phase correct mode
    }
    csr_reg.* = csr;
}

/// Set duty cycle for a channel
/// duty: 0-65535 (0% to 100% mapped to full range)
pub fn set_duty(slice: Slice, channel: Channel, duty: u16) void {
    const base = PWM_BASE + (@as(u32, slice) * 0x14);
    const cc_reg = @as(*volatile u32, @ptrFromInt(base + PWM_CC_OFFSET));
    
    const shift: u5 = switch (channel) {
        .A => 0,
        .B => 16,
    };
    
    // Read-modify-write to preserve other channel
    const current = cc_reg.*;
    const mask = @as(u32, 0xFFFF) << shift;
    const value = (@as(u32, duty) << shift);
    cc_reg.* = (current & ~mask) | value;
}

/// Configure GPIO pin for PWM
pub fn gpio_set_function_pwm(pin: u8) void {
    const io_bank0_base = 0x40014000;
    const gpio_ctrl = @as(*volatile u32, @ptrFromInt(io_bank0_base + 0x04 + (pin * 8)));
    gpio_ctrl.* = 4; // Function 4 = PWM
}

/// Get PWM slice for a GPIO pin
pub fn gpio_to_slice(pin: u8) Slice {
    return @truncate((pin >> 1) & 7);
}

/// Get PWM channel for a GPIO pin
pub fn gpio_to_channel(pin: u8) Channel {
    return if (pin & 1 == 0) .A else .B;
}

/// Servo control - set position in microseconds (typically 1000-2000)
pub fn set_servo_us(slice: Slice, channel: Channel, pulse_us: u16) void {
    // Assuming 50Hz servo signal (20ms period = 20000us)
    // With TOP=20000 and div=100, we get 50Hz at 133MHz system clock
    // The duty cycle maps microseconds to counter ticks
    // Since TOP=20000 represents 20ms (20000us), duty = pulse_us directly
    const duty = pulse_us;
    set_duty(slice, channel, duty);
}

/// ESC control - set throttle percentage (0-100)
pub fn set_esc_throttle(slice: Slice, channel: Channel, throttle: u8) void {
    // ESC typically uses 1000-2000us pulse width
    // 0% = 1000us, 100% = 2000us
    const pulse_us = 1000 + (@as(u16, throttle) * 10);
    set_servo_us(slice, channel, pulse_us);
}

/// Initialize PWM for standard servo (50Hz)
pub fn init_servo(pin: u8) void {
    gpio_set_function_pwm(pin);
    const slice = gpio_to_slice(pin);
    
    // 50Hz servo configuration
    // System clock: 133MHz
    // div = 100, TOP = 20000
    // Frequency = 133MHz / (100 * 20000) = 66.5Hz (close to 50Hz)
    const config = Config{
        .div = 100,
        .top = 20000,
        .phase_correct = false,
    };
    init(slice, config);
}

/// Initialize PWM for ESC (50Hz)
pub fn init_esc(pin: u8) void {
    // ESC uses same timing as servo
    init_servo(pin);
}

/// Set servo to center position (1500us)
pub fn servo_center(pin: u8) void {
    const slice = gpio_to_slice(pin);
    const channel = gpio_to_channel(pin);
    set_servo_us(slice, channel, 1500);
}

/// Set servo to minimum position (1000us)
pub fn servo_min(pin: u8) void {
    const slice = gpio_to_slice(pin);
    const channel = gpio_to_channel(pin);
    set_servo_us(slice, channel, 1000);
}

/// Set servo to maximum position (2000us)
pub fn servo_max(pin: u8) void {
    const slice = gpio_to_slice(pin);
    const channel = gpio_to_channel(pin);
    set_servo_us(slice, channel, 2000);
}
