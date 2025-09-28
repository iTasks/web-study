//! Memory Management in Zig
//! This file demonstrates:
//! - Stack vs heap allocation
//! - Allocators and memory allocation
//! - Manual memory management
//! - Memory safety patterns
//! - Custom allocators
//! - RAII and defer for cleanup

const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const HashMap = std.HashMap;

pub fn main() !void {
    print("=== Zig Memory Management Demo ===\n\n");
    
    stackVsHeap();
    try basicAllocators();
    try memoryOwnership();
    try customAllocator();
    try memoryPatterns();
    try realWorldExample();
}

fn stackVsHeap() void {
    print("1. Stack vs Heap Allocation:\n");
    
    // Stack allocation - automatic cleanup
    {
        const stack_array = [_]i32{ 1, 2, 3, 4, 5 };
        print("  Stack array: ");
        for (stack_array) |item| {
            print("{} ", .{item});
        }
        print("(allocated on stack)\n");
        
        // Large stack allocation (be careful with stack size)
        const large_stack_array = [1000]u8{0} ** 1;
        print("  Large stack array size: {} bytes\n", .{large_stack_array.len});
    } // stack_array automatically deallocated here
    
    print("  Stack variables are automatically cleaned up\n");
    print("\n");
}

fn basicAllocators() !void {
    print("2. Basic Allocators:\n");
    
    // General Purpose Allocator (recommended for most use cases)
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit(); // Clean up allocator
    const allocator = gpa.allocator();
    
    // Allocate single value
    const single_int = try allocator.create(i32);
    defer allocator.destroy(single_int); // Manual cleanup required
    single_int.* = 42;
    print("  Allocated single integer: {}\n", .{single_int.*});
    
    // Allocate array
    const heap_array = try allocator.alloc(i32, 10);
    defer allocator.free(heap_array); // Manual cleanup required
    
    // Initialize array
    for (heap_array, 0..) |*item, i| {
        item.* = @as(i32, @intCast(i * i));
    }
    
    print("  Heap array (squares): ");
    for (heap_array) |item| {
        print("{} ", .{item});
    }
    print("\n");
    
    // Dynamic string allocation
    const message = try std.fmt.allocPrint(allocator, "Hello from heap! Number: {}", .{123});
    defer allocator.free(message);
    print("  Dynamic string: {s}\n", .{message});
    
    // Page allocator (for large allocations)
    const page_allocator = std.heap.page_allocator;
    const large_buffer = try page_allocator.alloc(u8, 4096); // 4KB
    defer page_allocator.free(large_buffer);
    print("  Allocated large buffer: {} bytes\n", .{large_buffer.len});
    
    print("\n");
}

fn memoryOwnership() !void {
    print("3. Memory Ownership Patterns:\n");
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    // RAII-style struct that manages its own memory
    const ManagedString = struct {
        data: []u8,
        allocator: std.mem.Allocator,
        
        const Self = @This();
        
        pub fn init(allocator: std.mem.Allocator, content: []const u8) !Self {
            const data = try allocator.dupe(u8, content);
            return Self{
                .data = data,
                .allocator = allocator,
            };
        }
        
        pub fn deinit(self: Self) void {
            self.allocator.free(self.data);
        }
        
        pub fn append(self: *Self, suffix: []const u8) !void {
            const new_data = try std.fmt.allocPrint(self.allocator, "{s}{s}", .{ self.data, suffix });
            self.allocator.free(self.data);
            self.data = new_data;
        }
    };
    
    // Use RAII pattern
    var managed_str = try ManagedString.init(allocator, "Hello");
    defer managed_str.deinit(); // Automatic cleanup
    
    try managed_str.append(", World!");
    print("  Managed string: {s}\n", .{managed_str.data});
    
    // Smart pointer pattern
    const SmartPointer = struct {
        data: *i32,
        allocator: std.mem.Allocator,
        
        const Self = @This();
        
        pub fn init(allocator: std.mem.Allocator, value: i32) !Self {
            const data = try allocator.create(i32);
            data.* = value;
            return Self{
                .data = data,
                .allocator = allocator,
            };
        }
        
        pub fn deinit(self: Self) void {
            self.allocator.destroy(self.data);
        }
        
        pub fn get(self: Self) i32 {
            return self.data.*;
        }
        
        pub fn set(self: Self, value: i32) void {
            self.data.* = value;
        }
    };
    
    var smart_ptr = try SmartPointer.init(allocator, 100);
    defer smart_ptr.deinit();
    
    print("  Smart pointer value: {}\n", .{smart_ptr.get()});
    smart_ptr.set(200);
    print("  After modification: {}\n", .{smart_ptr.get()});
    
    print("\n");
}

fn customAllocator() !void {
    print("4. Custom Allocator Example:\n");
    
    // Fixed buffer allocator - allocates from a fixed buffer
    var buffer: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const fixed_allocator = fba.allocator();
    
    // Allocate from fixed buffer
    const numbers = try fixed_allocator.alloc(i32, 5);
    for (numbers, 0..) |*num, i| {
        num.* = @as(i32, @intCast(i + 1));
    }
    
    print("  Fixed buffer allocation: ");
    for (numbers) |num| {
        print("{} ", .{num});
    }
    print("\n");
    
    const message = try std.fmt.allocPrint(fixed_allocator, "Buffer remaining: {} bytes", .{buffer.len - fba.end_index});
    print("  {s}\n", .{message});
    
    // Arena allocator - fast allocation, bulk deallocation
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit(); // Frees all arena allocations at once
    const arena_allocator = arena.allocator();
    
    // Multiple allocations in arena
    const strings = try arena_allocator.alloc([]u8, 3);
    strings[0] = try std.fmt.allocPrint(arena_allocator, "String {}", .{1});
    strings[1] = try std.fmt.allocPrint(arena_allocator, "String {}", .{2});
    strings[2] = try std.fmt.allocPrint(arena_allocator, "String {}", .{3});
    
    print("  Arena allocations:\n");
    for (strings, 0..) |str, i| {
        print("    {}: {s}\n", .{ i, str });
    }
    
    print("\n");
}

fn memoryPatterns() !void {
    print("5. Memory Safety Patterns:\n");
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    // Safe array operations
    print("  Safe dynamic array operations:\n");
    var dynamic_array = ArrayList(i32).init(allocator);
    defer dynamic_array.deinit(); // Automatic cleanup
    
    // Add elements safely
    try dynamic_array.append(10);
    try dynamic_array.append(20);
    try dynamic_array.append(30);
    
    print("    Array contents: ");
    for (dynamic_array.items) |item| {
        print("{} ", .{item});
    }
    print("\n");
    
    // Safe bounds checking
    const index: usize = 1;
    if (index < dynamic_array.items.len) {
        print("    Element at index {}: {}\n", .{ index, dynamic_array.items[index] });
    }
    
    // Memory leak detection with testing allocator
    if (std.testing.allocator_instance.deinit() == .leak) {
        print("  Memory leaks detected!\n");
    } else {
        print("  No memory leaks in testing\n");
    }
    
    // Defer for guaranteed cleanup
    {
        const temp_data = try allocator.alloc(u8, 100);
        defer allocator.free(temp_data); // This will always execute
        
        // Use temp_data...
        std.mem.set(u8, temp_data, 42);
        print("    Temporary buffer initialized with value: {}\n", .{temp_data[0]});
        
        // Even if we return early, defer ensures cleanup
        if (temp_data.len > 50) {
            print("    Large buffer detected, cleaning up...\n");
            return;
        }
    } // temp_data is automatically freed here
    
    print("\n");
}

fn realWorldExample() !void {
    print("6. Real-world Example - Dynamic String Buffer:\n");
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    // Dynamic string buffer that grows as needed
    const StringBuffer = struct {
        buffer: ArrayList(u8),
        
        const Self = @This();
        
        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .buffer = ArrayList(u8).init(allocator),
            };
        }
        
        pub fn deinit(self: *Self) void {
            self.buffer.deinit();
        }
        
        pub fn append(self: *Self, text: []const u8) !void {
            try self.buffer.appendSlice(text);
        }
        
        pub fn appendFmt(self: *Self, comptime fmt: []const u8, args: anytype) !void {
            const writer = self.buffer.writer();
            try writer.print(fmt, args);
        }
        
        pub fn clear(self: *Self) void {
            self.buffer.clearRetainingCapacity();
        }
        
        pub fn getSlice(self: Self) []const u8 {
            return self.buffer.items;
        }
        
        pub fn getCapacity(self: Self) usize {
            return self.buffer.capacity;
        }
    };
    
    // Use the string buffer
    var str_buffer = StringBuffer.init(allocator);
    defer str_buffer.deinit();
    
    try str_buffer.append("Hello");
    try str_buffer.append(", ");
    try str_buffer.appendFmt("World! The answer is {}.", .{42});
    
    print("  String buffer content: {s}\n", .{str_buffer.getSlice()});
    print("  Buffer capacity: {} bytes\n", .{str_buffer.getCapacity()});
    
    // Demonstrate memory efficiency
    str_buffer.clear();
    try str_buffer.append("Reusing buffer");
    print("  After clear and reuse: {s}\n", .{str_buffer.getSlice()});
    print("  Capacity retained: {} bytes\n", .{str_buffer.getCapacity()});
    
    // Hash map example with proper memory management
    const MyHashMap = HashMap([]const u8, i32, StringContext, std.hash_map.default_max_load_percentage);
    const StringContext = struct {
        pub fn hash(self: @This(), s: []const u8) u64 {
            _ = self;
            return std.hash_map.hashString(s);
        }
        
        pub fn eql(self: @This(), a: []const u8, b: []const u8) bool {
            _ = self;
            return std.mem.eql(u8, a, b);
        }
    };
    
    var map = MyHashMap.init(allocator);
    defer map.deinit();
    
    try map.put("one", 1);
    try map.put("two", 2);
    try map.put("three", 3);
    
    print("  Hash map entries:\n");
    var iterator = map.iterator();
    while (iterator.next()) |entry| {
        print("    {s} -> {}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
    
    print("\n");
}