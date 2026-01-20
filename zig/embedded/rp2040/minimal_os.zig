//! Minimal OS for RP2040 (Raspberry Pi Pico)
//! 
//! This file implements a minimal real-time operating system for the RP2040 microcontroller.
//! It provides:
//! - Hardware initialization
//! - Basic task scheduler
//! - Interrupt handling
//! - Hardware abstraction layer
//!
//! Target: ARM Cortex-M0+ (RP2040)
//! Build: zig build-exe -target thumb-freestanding-eabi -mcpu cortex_m0plus -O ReleaseSafe minimal_os.zig

// RP2040 Memory Map Constants
const RESETS_BASE = 0x4000c000;
const CLOCKS_BASE = 0x40008000;
const XOSC_BASE = 0x40024000;
const PLL_SYS_BASE = 0x40028000;
const WATCHDOG_BASE = 0x40058000;
const TIMER_BASE = 0x40054000;
const PPB_BASE = 0xe0000000;

// Peripheral addresses
const SIO_BASE = 0xd0000000;
const GPIO_OUT_SET = SIO_BASE + 0x014;
const GPIO_OUT_CLR = SIO_BASE + 0x018;
const GPIO_OE_SET = SIO_BASE + 0x024;
const GPIO_OE_CLR = SIO_BASE + 0x028;

// System clock frequency (133 MHz)
const SYSTEM_CLOCK_HZ = 133_000_000;

/// Vector table for Cortex-M0+
export const vector_table linksection(".vector_table") = [_]u32{
    @as(u32, 0x20042000), // Initial stack pointer (264KB SRAM)
    @intFromPtr(&reset_handler), // Reset handler
    @intFromPtr(&nmi_handler), // NMI handler
    @intFromPtr(&hardfault_handler), // HardFault handler
    0, // Reserved
    0, // Reserved
    0, // Reserved
    0, // Reserved
    0, // Reserved
    0, // Reserved
    0, // Reserved
    @intFromPtr(&svc_handler), // SVCall handler
    0, // Reserved
    0, // Reserved
    @intFromPtr(&pendsv_handler), // PendSV handler
    @intFromPtr(&systick_handler), // SysTick handler
    // External interrupts would follow here
};

/// Task structure for simple cooperative scheduler
const Task = struct {
    func: *const fn () void,
    priority: u8,
    period_ms: u32,
    last_run: u32,
    enabled: bool,
};

/// Maximum number of tasks
const MAX_TASKS = 8;
var tasks: [MAX_TASKS]Task = undefined;
var task_count: u8 = 0;
var system_ticks: u32 = 0;

/// Reset handler - Entry point after reset
export fn reset_handler() callconv(.C) noreturn {
    // Initialize hardware
    init_clocks();
    init_gpio();
    init_timer();
    
    // Initialize OS
    init_scheduler();
    
    // Call main
    main();
    
    // Should never reach here
    while (true) {
        asm volatile ("wfi"); // Wait for interrupt
    }
}

/// NMI handler
export fn nmi_handler() callconv(.C) void {
    while (true) {}
}

/// HardFault handler
export fn hardfault_handler() callconv(.C) void {
    // Blink LED rapidly on hardfault
    while (true) {
        gpio_set(25); // LED on
        busy_wait_us(100_000);
        gpio_clear(25); // LED off
        busy_wait_us(100_000);
    }
}

/// SVCall handler
export fn svc_handler() callconv(.C) void {}

/// PendSV handler
export fn pendsv_handler() callconv(.C) void {}

/// SysTick handler - Called every 1ms
export fn systick_handler() callconv(.C) void {
    system_ticks +%= 1;
}

/// Initialize system clocks to 133 MHz
fn init_clocks() void {
    // Reset all peripherals except QSPI (needed for flash)
    const resets = @as(*volatile u32, @ptrFromInt(RESETS_BASE));
    resets.* = 0x01ffffff;
    
    // Wait for resets to complete
    busy_wait_us(10);
    
    // Release resets
    const resets_done = @as(*volatile u32, @ptrFromInt(RESETS_BASE + 0x08));
    resets_done.* = 0x01ffffff;
    
    // Configure system clock to 133 MHz
    // This is simplified - full implementation would configure XOSC and PLL
}

/// Initialize GPIO
fn init_gpio() void {
    // Enable GPIO for LED (GPIO 25)
    gpio_init(25);
    gpio_set_dir(25, true); // Set as output
}

/// Initialize system timer
fn init_timer() void {
    // Configure SysTick for 1ms interrupts
    const systick_csr = @as(*volatile u32, @ptrFromInt(PPB_BASE + 0xe010));
    const systick_rvr = @as(*volatile u32, @ptrFromInt(PPB_BASE + 0xe014));
    
    // Set reload value for 1ms (assuming 133 MHz clock)
    systick_rvr.* = (SYSTEM_CLOCK_HZ / 1000) - 1;
    
    // Enable SysTick with interrupt
    systick_csr.* = 0x07; // Enable, interrupt enable, use processor clock
}

/// Initialize task scheduler
fn init_scheduler() void {
    task_count = 0;
    system_ticks = 0;
}

/// Add task to scheduler
pub fn add_task(func: *const fn () void, priority: u8, period_ms: u32) void {
    if (task_count >= MAX_TASKS) return;
    
    tasks[task_count] = Task{
        .func = func,
        .priority = priority,
        .period_ms = period_ms,
        .last_run = 0,
        .enabled = true,
    };
    task_count += 1;
}

/// Run scheduler - cooperative multitasking
pub fn run_scheduler() noreturn {
    while (true) {
        const current_time = system_ticks;
        
        // Find highest priority task that is ready to run
        var i: u8 = 0;
        var highest_priority: u8 = 255;
        var task_to_run: ?u8 = null;
        
        while (i < task_count) : (i += 1) {
            if (!tasks[i].enabled) continue;
            
            // Check if task period has elapsed
            if (current_time -% tasks[i].last_run >= tasks[i].period_ms) {
                if (tasks[i].priority < highest_priority) {
                    highest_priority = tasks[i].priority;
                    task_to_run = i;
                }
            }
        }
        
        // Run the selected task
        if (task_to_run) |idx| {
            tasks[idx].func();
            tasks[idx].last_run = current_time;
        }
        
        // Yield CPU
        asm volatile ("wfi"); // Wait for interrupt
    }
}

/// GPIO initialization
fn gpio_init(pin: u8) void {
    // Enable GPIO function on pin
    const io_bank0_base = 0x40014000;
    const gpio_ctrl = @as(*volatile u32, @ptrFromInt(io_bank0_base + 0x04 + (pin * 8)));
    gpio_ctrl.* = 5; // Function 5 = SIO (software controlled I/O)
}

/// Set GPIO direction (true = output, false = input)
fn gpio_set_dir(pin: u8, is_output: bool) void {
    const gpio_oe = if (is_output)
        @as(*volatile u32, @ptrFromInt(GPIO_OE_SET))
    else
        @as(*volatile u32, @ptrFromInt(GPIO_OE_CLR));
    
    gpio_oe.* = @as(u32, 1) << @intCast(pin);
}

/// Set GPIO high
pub fn gpio_set(pin: u8) void {
    const gpio_out_set = @as(*volatile u32, @ptrFromInt(GPIO_OUT_SET));
    gpio_out_set.* = @as(u32, 1) << @intCast(pin);
}

/// Set GPIO low
pub fn gpio_clear(pin: u8) void {
    const gpio_out_clr = @as(*volatile u32, @ptrFromInt(GPIO_OUT_CLR));
    gpio_out_clr.* = @as(u32, 1) << @intCast(pin);
}

/// Busy wait for microseconds (approximate)
pub fn busy_wait_us(us: u32) void {
    // Assuming 133 MHz clock, rough approximation
    const cycles = us * 133;
    var i: u32 = 0;
    while (i < cycles) : (i += 1) {
        asm volatile ("nop");
    }
}

/// Get current system time in milliseconds
pub fn get_time_ms() u32 {
    return system_ticks;
}

/// Example heartbeat task
fn heartbeat_task() void {
    const led_pin = 25;
    gpio_set(led_pin);
    busy_wait_us(50_000); // 50ms on
    gpio_clear(led_pin);
}

/// Main function
pub fn main() void {
    // Add heartbeat task (priority 1, runs every 1000ms)
    add_task(heartbeat_task, 1, 1000);
    
    // Run scheduler (never returns)
    run_scheduler();
}

/// Panic handler
pub fn panic(msg: []const u8, error_return_trace: ?*@import("builtin").StackTrace, ret_addr: ?usize) noreturn {
    _ = msg;
    _ = error_return_trace;
    _ = ret_addr;
    
    // Rapid blink on panic
    while (true) {
        gpio_set(25);
        busy_wait_us(50_000);
        gpio_clear(25);
        busy_wait_us(50_000);
    }
}
