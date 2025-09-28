//! C Interoperability in Zig
//! This file demonstrates:
//! - Calling C functions from Zig
//! - Exporting Zig functions to C
//! - Working with C types and pointers
//! - String conversion between C and Zig
//! - Interfacing with C libraries

const std = @import("std");
const print = std.debug.print;
const c = std.c;

// Import C library functions
extern "c" fn strlen(str: [*:0]const u8) usize;
extern "c" fn strcmp(str1: [*:0]const u8, str2: [*:0]const u8) c_int;
extern "c" fn malloc(size: usize) ?*anyopaque;
extern "c" fn free(ptr: ?*anyopaque) void;
extern "c" fn strcpy(dest: [*:0]u8, src: [*:0]const u8) [*:0]u8;

// Math functions from libm
extern "c" fn sin(x: f64) f64;
extern "c" fn cos(x: f64) f64;
extern "c" fn sqrt(x: f64) f64;
extern "c" fn pow(base: f64, exponent: f64) f64;

pub fn main() void {
    print("=== Zig C Interoperability Demo ===\n\n");
    
    basicCFunctions();
    stringInterop();
    memoryInterop();
    mathLibrary();
    cStructs();
    exportingToC();
}

fn basicCFunctions() void {
    print("1. Basic C Function Calls:\n");
    
    // Using C string functions
    const c_string = "Hello from C!";
    const c_str_ptr: [*:0]const u8 = c_string.ptr;
    
    const len = strlen(c_str_ptr);
    print("  C string: {s}\n", .{c_string});
    print("  Length (from strlen): {}\n", .{len});
    
    // String comparison
    const str1 = "apple";
    const str2 = "banana";
    const str3 = "apple";
    
    const cmp1 = strcmp(str1.ptr, str2.ptr);
    const cmp2 = strcmp(str1.ptr, str3.ptr);
    
    print("  Comparing '{s}' and '{s}': {}\n", .{ str1, str2, cmp1 });
    print("  Comparing '{s}' and '{s}': {}\n", .{ str1, str3, cmp2 });
    
    print("\n");
}

fn stringInterop() void {
    print("2. String Interoperability:\n");
    
    // Convert Zig string to C string
    const zig_string = "Hello, Zig!";
    const c_string_buf = std.heap.c_allocator.dupeZ(u8, zig_string) catch {
        print("  Failed to allocate C string\n");
        return;
    };
    defer std.heap.c_allocator.free(c_string_buf);
    
    print("  Original Zig string: {s}\n", .{zig_string});
    print("  As C string (length): {}\n", .{strlen(c_string_buf.ptr)});
    
    // Working with C string literals
    const c_literal: [*:0]const u8 = "This is a C string literal";
    const c_len = strlen(c_literal);
    
    // Convert C string to Zig slice
    const zig_slice = c_literal[0..c_len];
    print("  C literal as Zig slice: {s}\n", .{zig_slice});
    
    // Null-terminated string handling
    var buffer: [100:0]u8 = undefined;
    const source = "Copy this!";
    const source_z = std.heap.c_allocator.dupeZ(u8, source) catch return;
    defer std.heap.c_allocator.free(source_z);
    
    _ = strcpy(&buffer, source_z.ptr);
    const copied_len = strlen(&buffer);
    print("  Copied string: {s} (length: {})\n", .{ buffer[0..copied_len], copied_len });
    
    print("\n");
}

fn memoryInterop() void {
    print("3. Memory Management Interoperability:\n");
    
    // Using C malloc/free
    const size = 1024;
    const c_ptr = malloc(size);
    
    if (c_ptr) |ptr| {
        print("  Allocated {} bytes using C malloc\n", .{size});
        
        // Cast to appropriate type and use
        const byte_ptr: [*]u8 = @ptrCast(ptr);
        const byte_slice = byte_ptr[0..size];
        
        // Initialize memory
        std.mem.set(u8, byte_slice, 42);
        print("  Initialized memory with value: {}\n", .{byte_slice[0]});
        
        // Free C memory
        free(ptr);
        print("  Memory freed using C free\n");
    } else {
        print("  C malloc failed\n");
    }
    
    // Mixing Zig and C allocators (be careful!)
    const zig_data = std.heap.c_allocator.alloc(i32, 10) catch {
        print("  Zig allocation failed\n");
        return;
    };
    defer std.heap.c_allocator.free(zig_data);
    
    for (zig_data, 0..) |*item, i| {
        item.* = @as(i32, @intCast(i * 2));
    }
    
    print("  Zig-allocated array: ");
    for (zig_data) |item| {
        print("{} ", .{item});
    }
    print("\n");
    
    print("\n");
}

fn mathLibrary() void {
    print("4. Math Library Interoperability:\n");
    
    const angle = std.math.pi / 4.0; // 45 degrees
    const number = 16.0;
    
    // Use C math functions
    const sin_result = sin(angle);
    const cos_result = cos(angle);
    const sqrt_result = sqrt(number);
    const pow_result = pow(2.0, 8.0);
    
    print("  sin(π/4) = {d:.6}\n", .{sin_result});
    print("  cos(π/4) = {d:.6}\n", .{cos_result});
    print("  sqrt(16) = {d:.1}\n", .{sqrt_result});
    print("  2^8 = {d:.0}\n", .{pow_result});
    
    // Compare with Zig's math functions
    const zig_sin = std.math.sin(angle);
    const zig_sqrt = std.math.sqrt(number);
    
    print("  Zig sin(π/4) = {d:.6}\n", .{zig_sin});
    print("  Zig sqrt(16) = {d:.1}\n", .{zig_sqrt});
    print("  Results match: sin={}, sqrt={}\n", .{
        std.math.fabs(sin_result - zig_sin) < 1e-10,
        std.math.fabs(sqrt_result - zig_sqrt) < 1e-10,
    });
    
    print("\n");
}

fn cStructs() void {
    print("5. C Struct Interoperability:\n");
    
    // Define C-compatible struct
    const CPoint = extern struct {
        x: f64,
        y: f64,
    };
    
    // Create and use C-compatible struct
    var point = CPoint{ .x = 3.0, .y = 4.0 };
    const distance = std.math.sqrt(point.x * point.x + point.y * point.y);
    
    print("  C-compatible point: ({d:.1}, {d:.1})\n", .{ point.x, point.y });
    print("  Distance from origin: {d:.2}\n", .{distance});
    
    // Packed struct for exact memory layout
    const PackedData = packed struct {
        flag1: bool,
        flag2: bool,
        value: u14,
    };
    
    var packed_data = PackedData{
        .flag1 = true,
        .flag2 = false,
        .value = 1234,
    };
    
    print("  Packed struct size: {} bytes\n", .{@sizeOf(PackedData)});
    print("  Packed data: flag1={}, flag2={}, value={}\n", .{
        packed_data.flag1,
        packed_data.flag2,
        packed_data.value,
    });
    
    // Union for C compatibility
    const CUnion = extern union {
        as_int: c_int,
        as_float: f32,
        as_bytes: [4]u8,
    };
    
    var c_union = CUnion{ .as_int = 0x41200000 };
    print("  Union as int: {}\n", .{c_union.as_int});
    print("  Union as float: {d:.1}\n", .{c_union.as_float});
    print("  Union as bytes: {} {} {} {}\n", .{
        c_union.as_bytes[0],
        c_union.as_bytes[1],
        c_union.as_bytes[2],
        c_union.as_bytes[3],
    });
    
    print("\n");
}

fn exportingToC() void {
    print("6. Exporting Zig Functions to C:\n");
    
    // These functions can be called from C code
    // (In a real scenario, you'd compile this to a library)
    
    print("  Calling exported functions:\n");
    
    const result1 = zigAdd(15, 27);
    print("    zigAdd(15, 27) = {}\n", .{result1});
    
    const numbers = [_]i32{ 1, 2, 3, 4, 5 };
    const result2 = zigSum(numbers.ptr, numbers.len);
    print("    zigSum([1,2,3,4,5]) = {}\n", .{result2});
    
    var buffer: [50]u8 = undefined;
    const written = zigFormatNumber(&buffer, buffer.len, 42);
    print("    zigFormatNumber(42) = {s} (wrote {} chars)\n", .{ buffer[0..written], written });
    
    print("\n");
}

// Export Zig functions for C consumption
export fn zigAdd(a: c_int, b: c_int) c_int {
    return a + b;
}

export fn zigSum(numbers: [*]const c_int, count: usize) c_int {
    var sum: c_int = 0;
    var i: usize = 0;
    while (i < count) : (i += 1) {
        sum += numbers[i];
    }
    return sum;
}

export fn zigFormatNumber(buffer: [*]u8, buffer_size: usize, number: c_int) usize {
    const slice = buffer[0..buffer_size];
    const formatted = std.fmt.bufPrint(slice, "Number: {}", .{number}) catch return 0;
    return formatted.len;
}

// Callback function type for C interop
const CallbackFn = *const fn (c_int) c_int;

export fn zigProcessArray(numbers: [*]c_int, count: usize, callback: CallbackFn) void {
    var i: usize = 0;
    while (i < count) : (i += 1) {
        numbers[i] = callback(numbers[i]);
    }
}

// Example callback function
export fn zigDouble(x: c_int) c_int {
    return x * 2;
}