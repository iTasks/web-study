//! I2C driver for RP2040
//!
//! This module provides I2C functionality for communicating with sensors like IMU.
//! RP2040 has 2 I2C controllers.

const gpio = @import("minimal_os.zig");

// I2C peripheral base addresses
const I2C0_BASE = 0x40044000;
const I2C1_BASE = 0x40048000;

// I2C register offsets
const IC_CON = 0x00;
const IC_TAR = 0x04;
const IC_DATA_CMD = 0x10;
const IC_SS_SCL_HCNT = 0x14;
const IC_SS_SCL_LCNT = 0x18;
const IC_FS_SCL_HCNT = 0x1c;
const IC_FS_SCL_LCNT = 0x20;
const IC_INTR_STAT = 0x2c;
const IC_INTR_MASK = 0x30;
const IC_CLR_INTR = 0x40;
const IC_ENABLE = 0x6c;
const IC_STATUS = 0x70;
const IC_TXFLR = 0x74;
const IC_RXFLR = 0x78;

/// I2C instance
pub const Instance = enum {
    I2C0,
    I2C1,
    
    fn base(self: Instance) u32 {
        return switch (self) {
            .I2C0 => I2C0_BASE,
            .I2C1 => I2C1_BASE,
        };
    }
};

/// I2C speed mode
pub const Speed = enum {
    Standard, // 100 kHz
    Fast, // 400 kHz
};

/// Initialize I2C
pub fn init(instance: Instance, speed: Speed) void {
    const base = instance.base();
    
    // Disable I2C during configuration
    disable(instance);
    
    // Configure as master, 7-bit addressing
    const ic_con = @as(*volatile u32, @ptrFromInt(base + IC_CON));
    ic_con.* = 0x65; // Master mode, restart enabled, 7-bit addr
    
    // Set speed
    switch (speed) {
        .Standard => {
            // 100 kHz: 133MHz / (hcnt + lcnt) = 100kHz
            const ic_ss_scl_hcnt = @as(*volatile u32, @ptrFromInt(base + IC_SS_SCL_HCNT));
            const ic_ss_scl_lcnt = @as(*volatile u32, @ptrFromInt(base + IC_SS_SCL_LCNT));
            ic_ss_scl_hcnt.* = 665;
            ic_ss_scl_lcnt.* = 665;
        },
        .Fast => {
            // 400 kHz
            const ic_fs_scl_hcnt = @as(*volatile u32, @ptrFromInt(base + IC_FS_SCL_HCNT));
            const ic_fs_scl_lcnt = @as(*volatile u32, @ptrFromInt(base + IC_FS_SCL_LCNT));
            ic_fs_scl_hcnt.* = 166;
            ic_fs_scl_lcnt.* = 166;
        },
    }
    
    // Enable I2C
    enable(instance);
}

/// Enable I2C
fn enable(instance: Instance) void {
    const base = instance.base();
    const ic_enable = @as(*volatile u32, @ptrFromInt(base + IC_ENABLE));
    ic_enable.* = 1;
}

/// Disable I2C
fn disable(instance: Instance) void {
    const base = instance.base();
    const ic_enable = @as(*volatile u32, @ptrFromInt(base + IC_ENABLE));
    ic_enable.* = 0;
}

/// Set target address
fn set_target(instance: Instance, addr: u7) void {
    const base = instance.base();
    const ic_tar = @as(*volatile u32, @ptrFromInt(base + IC_TAR));
    ic_tar.* = addr;
}

/// Write data to I2C device
pub fn write(instance: Instance, addr: u7, data: []const u8) bool {
    const base = instance.base();
    set_target(instance, addr);
    
    const ic_data_cmd = @as(*volatile u32, @ptrFromInt(base + IC_DATA_CMD));
    
    for (data, 0..) |byte, i| {
        // Wait for TX FIFO to have space
        if (!wait_tx_ready(instance)) return false;
        
        // Send byte, STOP on last byte
        const cmd: u32 = if (i == data.len - 1)
            @as(u32, byte) | 0x200 // STOP bit
        else
            @as(u32, byte);
        
        ic_data_cmd.* = cmd;
    }
    
    return true;
}

/// Read data from I2C device
pub fn read(instance: Instance, addr: u7, buffer: []u8) bool {
    const base = instance.base();
    set_target(instance, addr);
    
    const ic_data_cmd = @as(*volatile u32, @ptrFromInt(base + IC_DATA_CMD));
    
    // Queue read commands
    for (0..buffer.len) |i| {
        if (!wait_tx_ready(instance)) return false;
        
        // Send read command, STOP on last byte
        const cmd: u32 = if (i == buffer.len - 1)
            0x100 | 0x200 // READ + STOP
        else
            0x100; // READ
        
        ic_data_cmd.* = cmd;
    }
    
    // Read data from RX FIFO
    for (buffer) |*byte| {
        if (!wait_rx_ready(instance)) return false;
        byte.* = @truncate(ic_data_cmd.* & 0xFF);
    }
    
    return true;
}

/// Write to register and read response
pub fn write_read(instance: Instance, addr: u7, reg: u8, buffer: []u8) bool {
    const base = instance.base();
    set_target(instance, addr);
    
    const ic_data_cmd = @as(*volatile u32, @ptrFromInt(base + IC_DATA_CMD));
    
    // Write register address (with restart, no stop)
    if (!wait_tx_ready(instance)) return false;
    ic_data_cmd.* = reg;
    
    // Queue read commands
    for (0..buffer.len) |i| {
        if (!wait_tx_ready(instance)) return false;
        
        const cmd: u32 = if (i == buffer.len - 1)
            0x100 | 0x200 // READ + STOP
        else
            0x100; // READ
        
        ic_data_cmd.* = cmd;
    }
    
    // Read data
    for (buffer) |*byte| {
        if (!wait_rx_ready(instance)) return false;
        byte.* = @truncate(ic_data_cmd.* & 0xFF);
    }
    
    return true;
}

/// Wait for TX FIFO ready
fn wait_tx_ready(instance: Instance) bool {
    const base = instance.base();
    const ic_status = @as(*volatile u32, @ptrFromInt(base + IC_STATUS));
    
    var timeout: u32 = 100000;
    while (timeout > 0) : (timeout -= 1) {
        if ((ic_status.* & 0x02) != 0) { // TFNF (TX FIFO not full)
            return true;
        }
    }
    return false;
}

/// Wait for RX FIFO ready
fn wait_rx_ready(instance: Instance) bool {
    const base = instance.base();
    const ic_status = @as(*volatile u32, @ptrFromInt(base + IC_STATUS));
    
    var timeout: u32 = 100000;
    while (timeout > 0) : (timeout -= 1) {
        if ((ic_status.* & 0x08) != 0) { // RFNE (RX FIFO not empty)
            return true;
        }
    }
    return false;
}

/// Configure GPIO pins for I2C
pub fn gpio_set_function_i2c(sda_pin: u8, scl_pin: u8) void {
    const io_bank0_base = 0x40014000;
    
    // Set SDA pin to I2C function
    const sda_ctrl = @as(*volatile u32, @ptrFromInt(io_bank0_base + 0x04 + (sda_pin * 8)));
    sda_ctrl.* = 3; // Function 3 = I2C
    
    // Set SCL pin to I2C function
    const scl_ctrl = @as(*volatile u32, @ptrFromInt(io_bank0_base + 0x04 + (scl_pin * 8)));
    scl_ctrl.* = 3; // Function 3 = I2C
}
