//! Functions in Zig
//! This file demonstrates:
//! - Function definitions and calling
//! - Parameters and return types
//! - Function overloading (generic functions)
//! - Recursion
//! - Function pointers
//! - Inline functions

const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    print("=== Zig Functions Demo ===\n\n");
    
    basicFunctions();
    parameterExamples();
    recursionExample();
    genericFunctions();
    functionPointers();
    inlineFunctions();
}

/// Basic function examples
fn basicFunctions() void {
    print("1. Basic Functions:\n");
    
    // Call functions with no parameters
    greetWorld();
    
    // Call functions with parameters
    const result = add(15, 27);
    print("  15 + 27 = {}\n", .{result});
    
    // Call function that returns optional
    const division_result = safeDivide(10, 3);
    if (division_result) |value| {
        print("  10 / 3 = {d:.2}\n", .{value});
    } else {
        print("  Division by zero!\n");
    }
    
    // Call function with multiple return values
    const math_results = mathOperations(8, 3);
    print("  Math operations on 8 and 3:\n");
    print("    Sum: {}, Difference: {}, Product: {}, Quotient: {d:.2}\n", 
          .{ math_results.sum, math_results.diff, math_results.product, math_results.quotient });
    
    print("\n");
}

/// Function with no parameters
fn greetWorld() void {
    print("  Hello from a function!\n");
}

/// Function with parameters and return value
fn add(a: i32, b: i32) i32 {
    return a + b;
}

/// Function that returns an optional (nullable) value
fn safeDivide(a: f32, b: f32) ?f32 {
    if (b == 0.0) {
        return null; // Return null for division by zero
    }
    return a / b;
}

/// Function with multiple return values using a struct
fn mathOperations(a: i32, b: i32) struct { sum: i32, diff: i32, product: i32, quotient: f32 } {
    return .{
        .sum = a + b,
        .diff = a - b,
        .product = a * b,
        .quotient = @as(f32, @floatFromInt(a)) / @as(f32, @floatFromInt(b)),
    };
}

fn parameterExamples() void {
    print("2. Parameter Examples:\n");
    
    // Demonstrate different parameter types
    processArray(&[_]i32{ 1, 2, 3, 4, 5 });
    
    // Mutable parameters
    var my_value: i32 = 10;
    print("  Before modification: {}\n", .{my_value});
    modifyValue(&my_value);
    print("  After modification: {}\n", .{my_value});
    
    // Default parameter values (using optional parameters)
    print("  Power with default exponent: {}\n", .{power(2, null)});
    print("  Power with custom exponent: {}\n", .{power(2, 4)});
    
    print("\n");
}

/// Function that takes a slice (array view)
fn processArray(arr: []const i32) void {
    print("  Processing array: ");
    for (arr) |item| {
        print("{} ", .{item});
    }
    print("(sum: {})\n", .{calculateSum(arr)});
}

/// Function that calculates sum of array elements
fn calculateSum(arr: []const i32) i32 {
    var sum: i32 = 0;
    for (arr) |item| {
        sum += item;
    }
    return sum;
}

/// Function that modifies a value through pointer
fn modifyValue(value: *i32) void {
    value.* *= 2; // Multiply by 2
}

/// Function with optional parameter (simulating default values)
fn power(base: i32, exponent: ?u32) i32 {
    const exp = exponent orelse 2; // Default to 2 if null
    var result: i32 = 1;
    var i: u32 = 0;
    while (i < exp) : (i += 1) {
        result *= base;
    }
    return result;
}

fn recursionExample() void {
    print("3. Recursion Examples:\n");
    
    // Factorial using recursion
    const n = 5;
    print("  {}! = {}\n", .{ n, factorial(n) });
    
    // Fibonacci sequence
    print("  Fibonacci sequence (first 10 numbers): ");
    var i: u32 = 0;
    while (i < 10) : (i += 1) {
        print("{} ", .{fibonacci(i)});
    }
    print("\n");
    
    // Binary search example
    const sorted_array = [_]i32{ 1, 3, 5, 7, 9, 11, 13, 15, 17, 19 };
    const target = 7;
    const index = binarySearch(i32, &sorted_array, target);
    if (index) |idx| {
        print("  Found {} at index {}\n", .{ target, idx });
    } else {
        print("  {} not found in array\n", .{target});
    }
    
    print("\n");
}

/// Recursive factorial function
fn factorial(n: u32) u32 {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}

/// Recursive Fibonacci function
fn fibonacci(n: u32) u32 {
    if (n <= 1) {
        return n;
    }
    return fibonacci(n - 1) + fibonacci(n - 2);
}

/// Generic binary search function
fn binarySearch(comptime T: type, arr: []const T, target: T) ?usize {
    var left: usize = 0;
    var right: usize = arr.len;
    
    while (left < right) {
        const mid = left + (right - left) / 2;
        if (arr[mid] == target) {
            return mid;
        } else if (arr[mid] < target) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }
    return null;
}

fn genericFunctions() void {
    print("4. Generic Functions:\n");
    
    // Generic functions work with different types
    print("  Max of integers: {}\n", .{max(i32, 10, 5)});
    print("  Max of floats: {d:.2}\n", .{max(f32, 3.14, 2.71)});
    
    // Generic swap function
    var a: i32 = 100;
    var b: i32 = 200;
    print("  Before swap: a={}, b={}\n", .{ a, b });
    swap(i32, &a, &b);
    print("  After swap: a={}, b={}\n", .{ a, b });
    
    // Array processing with generics
    const int_array = [_]i32{ 5, 2, 8, 1, 9 };
    const float_array = [_]f32{ 3.14, 2.71, 1.41, 1.73 };
    
    print("  Sum of integers: {}\n", .{sumArray(i32, &int_array)});
    print("  Sum of floats: {d:.2}\n", .{sumArray(f32, &float_array)});
    
    print("\n");
}

/// Generic function to find maximum of two values
fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

/// Generic swap function
fn swap(comptime T: type, a: *T, b: *T) void {
    const temp = a.*;
    a.* = b.*;
    b.* = temp;
}

/// Generic function to sum array elements
fn sumArray(comptime T: type, arr: []const T) T {
    var sum: T = 0;
    for (arr) |item| {
        sum += item;
    }
    return sum;
}

fn functionPointers() void {
    print("5. Function Pointers:\n");
    
    // Function pointers allow storing functions in variables
    const operations = [_]*const fn (i32, i32) i32{ addNumbers, multiplyNumbers, subtractNumbers };
    const names = [_][]const u8{ "Addition", "Multiplication", "Subtraction" };
    
    const x = 12;
    const y = 4;
    
    for (operations, names) |op, name| {
        const result = op(x, y);
        print("  {s}: {} and {} = {}\n", .{ name, x, y, result });
    }
    
    // Higher-order function example
    print("  Applying function to array:\n");
    const numbers = [_]i32{ 1, 2, 3, 4, 5 };
    applyToArray(&numbers, square);
    
    print("\n");
}

fn addNumbers(a: i32, b: i32) i32 {
    return a + b;
}

fn multiplyNumbers(a: i32, b: i32) i32 {
    return a * b;
}

fn subtractNumbers(a: i32, b: i32) i32 {
    return a - b;
}

fn square(x: i32) i32 {
    return x * x;
}

/// Higher-order function that applies a function to each array element
fn applyToArray(arr: []const i32, func: *const fn (i32) i32) void {
    print("    Original: ");
    for (arr) |item| {
        print("{} ", .{item});
    }
    print("\n    Transformed: ");
    for (arr) |item| {
        print("{} ", .{func(item)});
    }
    print("\n");
}

fn inlineFunctions() void {
    print("6. Inline Functions:\n");
    
    // Inline functions are expanded at compile time
    const result1 = fastMultiply(7, 8);
    const result2 = complexCalculation(5);
    
    print("  Fast multiply: 7 * 8 = {}\n", .{result1});
    print("  Complex calculation: {}\n", .{result2});
    
    print("\n");
}

/// Inline function for performance-critical code
inline fn fastMultiply(a: i32, b: i32) i32 {
    return a * b;
}

/// Inline function with complex logic that benefits from inlining
inline fn complexCalculation(x: i32) i32 {
    return (x * x + 2 * x + 1) / (x + 1);
}