//! Error Handling in Zig
//! This file demonstrates:
//! - Error unions and error sets
//! - Error handling with try, catch, and if
//! - Custom error types
//! - Error propagation
//! - Defer statements for cleanup

const std = @import("std");
const print = std.debug.print;

// Define custom error sets
const MathError = error{
    DivisionByZero,
    NegativeSquareRoot,
    Overflow,
};

const FileError = error{
    FileNotFound,
    PermissionDenied,
    DiskFull,
};

// Union of error sets
const AllErrors = MathError || FileError || std.mem.Allocator.Error;

pub fn main() void {
    print("=== Zig Error Handling Demo ===\n\n");
    
    basicErrorHandling();
    errorPropagation();
    customErrors();
    deferStatements();
    errorSwitching();
    errorWithCleanup();
}

fn basicErrorHandling() void {
    print("1. Basic Error Handling:\n");
    
    // Using try - will propagate error if function returned error
    // Since we're in main(), we'll use catch instead
    const result1 = divide(10, 2) catch |err| {
        print("  Error in division: {}\n", .{err});
        return;
    };
    print("  10 / 2 = {d:.2}\n", .{result1});
    
    // Using if to handle errors explicitly
    if (divide(10, 0)) |result| {
        print("  10 / 0 = {d:.2}\n", .{result});
    } else |err| {
        print("  Error dividing 10 by 0: {}\n", .{err});
    }
    
    // Using catch with default value
    const safe_result = divide(15, 0) catch 0.0;
    print("  15 / 0 with default: {d:.2}\n", .{safe_result});
    
    // Multiple operations with error handling
    const numbers = [_]struct { a: f32, b: f32 }{
        .{ .a = 12, .b = 4 },
        .{ .a = 8, .b = 0 },   // This will cause an error
        .{ .a = 20, .b = 5 },
    };
    
    for (numbers, 0..) |pair, i| {
        const result = divide(pair.a, pair.b) catch |err| {
            print("  Operation {}: Error - {}\n", .{ i, err });
            continue;
        };
        print("  Operation {}: {d:.1} / {d:.1} = {d:.2}\n", .{ i, pair.a, pair.b, result });
    }
    
    print("\n");
}

/// Function that can return an error
fn divide(a: f32, b: f32) MathError!f32 {
    if (b == 0.0) {
        return MathError.DivisionByZero;
    }
    return a / b;
}

fn errorPropagation() void {
    print("2. Error Propagation:\n");
    
    // Functions can propagate errors using try
    const calculation_result = performComplexMath(5, 2) catch |err| {
        print("  Complex math failed: {}\n", .{err});
        return;
    };
    print("  Complex math result: {d:.2}\n", .{calculation_result});
    
    // Try with invalid input
    const invalid_result = performComplexMath(-4, 0) catch |err| {
        print("  Complex math with invalid input failed: {}\n", .{err});
        return;
    };
    print("  This shouldn't print: {d:.2}\n", .{invalid_result});
    
    print("\n");
}

/// Function that demonstrates error propagation
fn performComplexMath(x: f32, y: f32) MathError!f32 {
    // These operations can fail and errors will be propagated
    const division = try divide(x * 2, y);  // Will propagate DivisionByZero
    const square_root = try calculateSquareRoot(x);  // Will propagate NegativeSquareRoot
    return division + square_root;
}

fn calculateSquareRoot(x: f32) MathError!f32 {
    if (x < 0) {
        return MathError.NegativeSquareRoot;
    }
    return std.math.sqrt(x);
}

fn customErrors() void {
    print("3. Custom Error Types:\n");
    
    // Working with custom error types
    const user_ages = [_]i32{ 25, -5, 150, 30 };
    
    for (user_ages, 0..) |age, i| {
        const validation_result = validateAge(age) catch |err| {
            print("  User {}: Invalid age {} - {}\n", .{ i, age, err });
            continue;
        };
        print("  User {}: Age {} is valid - {s}\n", .{ i, age, validation_result });
    }
    
    // File operations simulation
    const filenames = [_][]const u8{ "document.txt", "secret.txt", "large_file.txt" };
    
    for (filenames) |filename| {
        const file_result = simulateFileOperation(filename) catch |err| {
            print("  Failed to process {s}: {}\n", .{ filename, err });
            continue;
        };
        print("  Successfully processed {s}: {s}\n", .{ filename, file_result });
    }
    
    print("\n");
}

const AgeError = error{
    TooYoung,
    TooOld,
    InvalidAge,
};

fn validateAge(age: i32) AgeError![]const u8 {
    if (age < 0) {
        return AgeError.InvalidAge;
    }
    if (age < 18) {
        return AgeError.TooYoung;
    }
    if (age > 120) {
        return AgeError.TooOld;
    }
    return "Valid adult age";
}

fn simulateFileOperation(filename: []const u8) FileError![]const u8 {
    // Simulate different file errors based on filename
    if (std.mem.eql(u8, filename, "secret.txt")) {
        return FileError.PermissionDenied;
    }
    if (std.mem.eql(u8, filename, "large_file.txt")) {
        return FileError.DiskFull;
    }
    if (std.mem.eql(u8, filename, "missing.txt")) {
        return FileError.FileNotFound;
    }
    return "File processed successfully";
}

fn deferStatements() void {
    print("4. Defer Statements (Cleanup):\n");
    
    // Defer ensures code runs when leaving scope
    print("  Starting resource allocation demo...\n");
    defer print("  Cleanup completed!\n");
    
    // Multiple defer statements execute in reverse order
    defer print("  Third cleanup task\n");
    defer print("  Second cleanup task\n");
    defer print("  First cleanup task\n");
    
    // Simulate resource allocation and cleanup
    const result = allocateAndProcess() catch |err| {
        print("  Resource allocation failed: {}\n", .{err});
        return;
    };
    print("  Resource allocation result: {s}\n", .{result});
    
    print("\n");
}

fn allocateAndProcess() std.mem.Allocator.Error![]const u8 {
    print("    Allocating resource 1...\n");
    defer print("    Cleaning up resource 1\n");
    
    print("    Allocating resource 2...\n");
    defer print("    Cleaning up resource 2\n");
    
    // Simulate some processing
    print("    Processing data...\n");
    
    // Both defer statements will execute even if we return early
    return "Processing completed";
}

fn errorSwitching() void {
    print("5. Error Switching:\n");
    
    const operations = [_]struct { x: f32, y: f32 }{
        .{ .x = 10, .y = 2 },
        .{ .x = -4, .y = 1 },
        .{ .x = 8, .y = 0 },
    };
    
    for (operations, 0..) |op, i| {
        // Switch on error types for different handling
        const result = advancedMathOperation(op.x, op.y) catch |err| switch (err) {
            MathError.DivisionByZero => {
                print("  Operation {}: Division by zero, using infinity\n", .{i});
                continue;
            },
            MathError.NegativeSquareRoot => {
                print("  Operation {}: Negative square root, using absolute value\n", .{i});
                // Retry with absolute value
                const retry_result = advancedMathOperation(std.math.fabs(op.x), op.y) catch {
                    print("  Operation {}: Retry failed\n", .{i});
                    continue;
                };
                print("  Operation {}: Retry successful: {d:.2}\n", .{ i, retry_result });
                continue;
            },
            else => {
                print("  Operation {}: Unexpected error: {}\n", .{ i, err });
                continue;
            },
        };
        print("  Operation {}: Success: {d:.2}\n", .{ i, result });
    }
    
    print("\n");
}

fn advancedMathOperation(x: f32, y: f32) MathError!f32 {
    const sqrt_x = try calculateSquareRoot(x);
    const division = try divide(sqrt_x, y);
    return division;
}

fn errorWithCleanup() void {
    print("6. Error Handling with Resource Cleanup:\n");
    
    // Demonstrate proper cleanup even when errors occur
    const test_cases = [_]bool{ true, false };
    
    for (test_cases, 0..) |should_succeed, i| {
        print("  Test case {}: ", .{i});
        
        const result = resourceIntensiveOperation(should_succeed) catch |err| {
            print("Failed with error: {}\n", .{err});
            continue;
        };
        print("Success: {s}\n", .{result});
    }
    
    print("\n");
}

const ProcessingError = error{
    ProcessingFailed,
    ResourceUnavailable,
};

fn resourceIntensiveOperation(should_succeed: bool) ProcessingError![]const u8 {
    // Simulate acquiring resources
    print("acquiring resources... ");
    defer print("resources released ");
    
    // Simulate processing
    print("processing... ");
    defer print("processing cleanup ");
    
    if (!should_succeed) {
        return ProcessingError.ProcessingFailed;
    }
    
    return "operation completed";
}