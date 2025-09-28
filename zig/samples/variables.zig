//! Variables, Constants, and Basic Types
//! This file demonstrates:
//! - Variable declarations (var vs const)
//! - Basic data types (integers, floats, booleans)
//! - Type inference
//! - Optionals and null values
//! - Arrays and slices

const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    print("=== Zig Variables and Types Demo ===\n\n");
    
    demonstrateVariables();
    demonstrateTypes();
    demonstrateOptionals();
    demonstrateArraysAndSlices();
}

fn demonstrateVariables() void {
    print("1. Variables and Constants:\n");
    
    // Constants are immutable and must be known at compile time
    const pi = 3.14159;
    const message = "Hello from Zig!";
    
    // Variables are mutable and can be changed at runtime
    var counter: i32 = 0;
    var temperature: f32 = 20.5;
    
    print("  Constant pi: {d:.5}\n", .{pi});
    print("  Constant message: {s}\n", .{message});
    print("  Initial counter: {}\n", .{counter});
    print("  Initial temperature: {d:.1}°C\n", .{temperature});
    
    // Modify variables
    counter += 1;
    temperature = 25.0;
    
    print("  After modification:\n");
    print("    Counter: {}\n", .{counter});
    print("    Temperature: {d:.1}°C\n", .{temperature});
    
    // Type inference - Zig can often infer the type
    const inferred_int = 42;          // i32 (default int type)
    const inferred_float = 3.14;      // f64 (default float type)
    const inferred_string = "text";   // []const u8 (string literal)
    
    print("  Type-inferred values:\n");
    print("    Integer: {} (type: {})\n", .{ inferred_int, @TypeOf(inferred_int) });
    print("    Float: {d:.2} (type: {})\n", .{ inferred_float, @TypeOf(inferred_float) });
    print("    String: {s} (type: {})\n", .{ inferred_string, @TypeOf(inferred_string) });
    
    print("\n");
}

fn demonstrateTypes() void {
    print("2. Basic Data Types:\n");
    
    // Integer types - signed and unsigned, various sizes
    const small_int: i8 = 127;        // 8-bit signed integer (-128 to 127)
    const large_int: i64 = 1234567890; // 64-bit signed integer
    const unsigned_int: u32 = 4294967295; // 32-bit unsigned integer
    
    // Floating-point types
    const small_float: f32 = 3.14159;  // 32-bit float
    const large_float: f64 = 2.718281828459045; // 64-bit float
    
    // Boolean type
    const is_true: bool = true;
    const is_false: bool = false;
    
    // Character type (single Unicode code point)
    const letter: u8 = 'A';
    const unicode_char: u21 = '🦎'; // Zig's mascot!
    
    print("  Integer types:\n");
    print("    i8: {} (range: -128 to 127)\n", .{small_int});
    print("    i64: {}\n", .{large_int});
    print("    u32: {}\n", .{unsigned_int});
    
    print("  Floating-point types:\n");
    print("    f32: {d:.5}\n", .{small_float});
    print("    f64: {d:.15}\n", .{large_float});
    
    print("  Boolean and character types:\n");
    print("    bool (true): {}\n", .{is_true});
    print("    bool (false): {}\n", .{is_false});
    print("    u8 char: {c} (ASCII value: {})\n", .{ letter, letter });
    print("    u21 unicode: {u}\n", .{unicode_char});
    
    // Demonstrate type limits
    print("  Type limits:\n");
    print("    i8 max: {}\n", .{std.math.maxInt(i8)});
    print("    u8 max: {}\n", .{std.math.maxInt(u8)});
    print("    f32 max: {e}\n", .{std.math.floatMax(f32)});
    
    print("\n");
}

fn demonstrateOptionals() void {
    print("3. Optional Types (nullable values):\n");
    
    // Optional types use ? syntax and can hold null or a value
    var maybe_number: ?i32 = 42;
    var maybe_string: ?[]const u8 = "Hello";
    var nothing: ?i32 = null;
    
    print("  Optional with value: ");
    if (maybe_number) |value| {
        print("{}\n", .{value});
    } else {
        print("null\n");
    }
    
    print("  Optional string: ");
    if (maybe_string) |value| {
        print("{s}\n", .{value});
    } else {
        print("null\n");
    }
    
    print("  Null optional: ");
    if (nothing) |value| {
        print("{}\n", .{value});
    } else {
        print("null\n");
    }
    
    // Change values to demonstrate mutability
    maybe_number = null;
    maybe_string = null;
    nothing = 100;
    
    print("  After modification:\n");
    print("    maybe_number is now: {?}\n", .{maybe_number});
    print("    maybe_string is now: {?s}\n", .{maybe_string});
    print("    nothing is now: {?}\n", .{nothing});
    
    print("\n");
}

fn demonstrateArraysAndSlices() void {
    print("4. Arrays and Slices:\n");
    
    // Arrays have fixed size known at compile time
    const fixed_array = [5]i32{ 1, 2, 3, 4, 5 };
    var mutable_array = [_]i32{ 10, 20, 30 }; // Size inferred from initializer
    
    print("  Fixed array: ");
    for (fixed_array) |item| {
        print("{} ", .{item});
    }
    print("\n");
    
    print("  Mutable array (before): ");
    for (mutable_array) |item| {
        print("{} ", .{item});
    }
    print("\n");
    
    // Modify array elements
    mutable_array[1] = 99;
    
    print("  Mutable array (after): ");
    for (mutable_array) |item| {
        print("{} ", .{item});
    }
    print("\n");
    
    // Slices are views into arrays
    const full_slice = fixed_array[0..]; // Full slice
    const partial_slice = fixed_array[1..4]; // Partial slice
    
    print("  Full slice: ");
    for (full_slice) |item| {
        print("{} ", .{item});
    }
    print("\n");
    
    print("  Partial slice [1..4]: ");
    for (partial_slice) |item| {
        print("{} ", .{item});
    }
    print("\n");
    
    // String literals are slices of u8
    const string_literal = "Zig strings are slices!";
    print("  String as slice: {s} (length: {})\n", .{ string_literal, string_literal.len });
    
    // Multi-dimensional arrays
    const matrix = [3][3]i32{
        [_]i32{ 1, 2, 3 },
        [_]i32{ 4, 5, 6 },
        [_]i32{ 7, 8, 9 },
    };
    
    print("  2D Array (3x3 matrix):\n");
    for (matrix, 0..) |row, i| {
        print("    Row {}: ", .{i});
        for (row) |item| {
            print("{:2} ", .{item});
        }
        print("\n");
    }
}