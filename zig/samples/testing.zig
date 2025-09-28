//! Testing in Zig
//! This file demonstrates:
//! - Unit testing with built-in test framework
//! - Test assertions and expectations
//! - Testing memory allocations
//! - Parameterized tests
//! - Testing error conditions
//! - Documentation tests

const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
const expect = testing.expect;
const expectEqual = testing.expectEqual;
const expectError = testing.expectError;

pub fn main() void {
    print("=== Zig Testing Demo ===\n\n");
    print("This file contains test examples.\n");
    print("Run with: zig test testing.zig\n");
    print("Or run specific tests: zig test testing.zig --test-filter \"test name\"\n\n");
}

// Simple functions to test
fn add(a: i32, b: i32) i32 {
    return a + b;
}

fn multiply(a: i32, b: i32) i32 {
    return a * b;
}

fn divide(a: f32, b: f32) !f32 {
    if (b == 0.0) {
        return error.DivisionByZero;
    }
    return a / b;
}

fn factorial(n: u32) u32 {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}

fn isPrime(n: u32) bool {
    if (n < 2) return false;
    if (n == 2) return true;
    if (n % 2 == 0) return false;
    
    var i: u32 = 3;
    while (i * i <= n) : (i += 2) {
        if (n % i == 0) return false;
    }
    return true;
}

// Data structure to test
const Stack = struct {
    items: std.ArrayList(i32),
    
    const Self = @This();
    
    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .items = std.ArrayList(i32).init(allocator),
        };
    }
    
    pub fn deinit(self: *Self) void {
        self.items.deinit();
    }
    
    pub fn push(self: *Self, value: i32) !void {
        try self.items.append(value);
    }
    
    pub fn pop(self: *Self) ?i32 {
        return self.items.popOrNull();
    }
    
    pub fn peek(self: Self) ?i32 {
        if (self.items.items.len == 0) return null;
        return self.items.items[self.items.items.len - 1];
    }
    
    pub fn isEmpty(self: Self) bool {
        return self.items.items.len == 0;
    }
    
    pub fn size(self: Self) usize {
        return self.items.items.len;
    }
};

// Basic unit tests
test "basic arithmetic operations" {
    // Test addition
    try expectEqual(@as(i32, 5), add(2, 3));
    try expectEqual(@as(i32, -1), add(2, -3));
    try expectEqual(@as(i32, 0), add(5, -5));
    
    // Test multiplication
    try expectEqual(@as(i32, 6), multiply(2, 3));
    try expectEqual(@as(i32, -6), multiply(2, -3));
    try expectEqual(@as(i32, 0), multiply(0, 100));
}

test "division with error handling" {
    // Test successful division
    try expectEqual(@as(f32, 2.0), try divide(6.0, 3.0));
    try expectEqual(@as(f32, -2.0), try divide(6.0, -3.0));
    
    // Test division by zero error
    try expectError(error.DivisionByZero, divide(10.0, 0.0));
}

test "factorial calculation" {
    try expectEqual(@as(u32, 1), factorial(0));
    try expectEqual(@as(u32, 1), factorial(1));
    try expectEqual(@as(u32, 2), factorial(2));
    try expectEqual(@as(u32, 6), factorial(3));
    try expectEqual(@as(u32, 24), factorial(4));
    try expectEqual(@as(u32, 120), factorial(5));
}

test "prime number detection" {
    // Test non-primes
    try expect(!isPrime(0));
    try expect(!isPrime(1));
    try expect(!isPrime(4));
    try expect(!isPrime(6));
    try expect(!isPrime(8));
    try expect(!isPrime(9));
    try expect(!isPrime(10));
    
    // Test primes
    try expect(isPrime(2));
    try expect(isPrime(3));
    try expect(isPrime(5));
    try expect(isPrime(7));
    try expect(isPrime(11));
    try expect(isPrime(13));
    try expect(isPrime(17));
    try expect(isPrime(19));
}

// Test data structures with memory allocation
test "stack operations" {
    var stack = Stack.init(testing.allocator);
    defer stack.deinit();
    
    // Test empty stack
    try expect(stack.isEmpty());
    try expectEqual(@as(usize, 0), stack.size());
    try expectEqual(@as(?i32, null), stack.peek());
    try expectEqual(@as(?i32, null), stack.pop());
    
    // Test push operations
    try stack.push(10);
    try expect(!stack.isEmpty());
    try expectEqual(@as(usize, 1), stack.size());
    try expectEqual(@as(?i32, 10), stack.peek());
    
    try stack.push(20);
    try stack.push(30);
    try expectEqual(@as(usize, 3), stack.size());
    try expectEqual(@as(?i32, 30), stack.peek());
    
    // Test pop operations
    try expectEqual(@as(?i32, 30), stack.pop());
    try expectEqual(@as(?i32, 20), stack.pop());
    try expectEqual(@as(?i32, 10), stack.pop());
    try expectEqual(@as(?i32, null), stack.pop());
    
    try expect(stack.isEmpty());
}

// Parameterized test using array of test cases
test "parameterized factorial tests" {
    const test_cases = [_]struct { input: u32, expected: u32 }{
        .{ .input = 0, .expected = 1 },
        .{ .input = 1, .expected = 1 },
        .{ .input = 2, .expected = 2 },
        .{ .input = 3, .expected = 6 },
        .{ .input = 4, .expected = 24 },
        .{ .input = 5, .expected = 120 },
    };
    
    for (test_cases) |case| {
        try expectEqual(case.expected, factorial(case.input));
    }
}

// Test for memory leaks
test "memory allocation and deallocation" {
    const allocator = testing.allocator;
    
    // Allocate and free memory
    const memory = try allocator.alloc(i32, 100);
    defer allocator.free(memory);
    
    // Initialize memory
    for (memory, 0..) |*item, i| {
        item.* = @as(i32, @intCast(i));
    }
    
    // Verify memory contents
    try expectEqual(@as(i32, 0), memory[0]);
    try expectEqual(@as(i32, 50), memory[50]);
    try expectEqual(@as(i32, 99), memory[99]);
}

// Test error propagation
test "error propagation in nested functions" {
    const NestedError = error{
        Level1Error,
        Level2Error,
        Level3Error,
    };
    
    const level3 = struct {
        fn func() NestedError!i32 {
            return NestedError.Level3Error;
        }
    }.func;
    
    const level2 = struct {
        fn func() NestedError!i32 {
            return try level3();
        }
    }.func;
    
    const level1 = struct {
        fn func() NestedError!i32 {
            return try level2();
        }
    }.func;
    
    try expectError(NestedError.Level3Error, level1());
}

// Test with floating point comparisons
test "floating point arithmetic" {
    const epsilon = 1e-6;
    
    const result1 = 0.1 + 0.2;
    const expected1 = 0.3;
    try expect(std.math.fabs(result1 - expected1) < epsilon);
    
    const result2 = std.math.sqrt(16.0);
    const expected2 = 4.0;
    try expect(std.math.fabs(result2 - expected2) < epsilon);
}

// Test string operations
test "string manipulation" {
    const allocator = testing.allocator;
    
    // String concatenation
    const str1 = "Hello, ";
    const str2 = "World!";
    const result = try std.fmt.allocPrint(allocator, "{s}{s}", .{ str1, str2 });
    defer allocator.free(result);
    
    try expect(std.mem.eql(u8, result, "Hello, World!"));
    
    // String comparison
    try expect(std.mem.eql(u8, "test", "test"));
    try expect(!std.mem.eql(u8, "test", "Test"));
}

// Test optional values
test "optional value handling" {
    var maybe_value: ?i32 = 42;
    
    // Test with value
    if (maybe_value) |value| {
        try expectEqual(@as(i32, 42), value);
    } else {
        try expect(false); // This shouldn't execute
    }
    
    // Test with null
    maybe_value = null;
    try expectEqual(@as(?i32, null), maybe_value);
    
    // Test orelse
    const default_value = maybe_value orelse 100;
    try expectEqual(@as(i32, 100), default_value);
}

// Test array operations
test "array and slice operations" {
    const original = [_]i32{ 1, 2, 3, 4, 5 };
    const slice = original[1..4]; // Elements 2, 3, 4
    
    try expectEqual(@as(usize, 3), slice.len);
    try expectEqual(@as(i32, 2), slice[0]);
    try expectEqual(@as(i32, 3), slice[1]);
    try expectEqual(@as(i32, 4), slice[2]);
    
    // Test array equality
    const array1 = [_]i32{ 1, 2, 3 };
    const array2 = [_]i32{ 1, 2, 3 };
    const array3 = [_]i32{ 1, 2, 4 };
    
    try expect(std.mem.eql(i32, &array1, &array2));
    try expect(!std.mem.eql(i32, &array1, &array3));
}

// Test struct initialization and methods
test "struct operations" {
    const Point = struct {
        x: f32,
        y: f32,
        
        pub fn distance(self: @This()) f32 {
            return std.math.sqrt(self.x * self.x + self.y * self.y);
        }
        
        pub fn add(self: @This(), other: @This()) @This() {
            return @This(){
                .x = self.x + other.x,
                .y = self.y + other.y,
            };
        }
    };
    
    const p1 = Point{ .x = 3.0, .y = 4.0 };
    const p2 = Point{ .x = 1.0, .y = 2.0 };
    
    const distance = p1.distance();
    try expect(std.math.fabs(distance - 5.0) < 1e-6);
    
    const sum = p1.add(p2);
    try expectEqual(@as(f32, 4.0), sum.x);
    try expectEqual(@as(f32, 6.0), sum.y);
}

// Test enum operations
test "enum operations" {
    const Color = enum {
        red,
        green,
        blue,
        
        pub fn isWarm(self: @This()) bool {
            return switch (self) {
                .red => true,
                .green, .blue => false,
            };
        }
    };
    
    try expect(Color.red.isWarm());
    try expect(!Color.green.isWarm());
    try expect(!Color.blue.isWarm());
    
    // Test enum comparison
    try expectEqual(Color.red, Color.red);
    try expect(Color.red != Color.blue);
}

// Test union operations
test "union operations" {
    const Value = union(enum) {
        int: i32,
        float: f32,
        string: []const u8,
        
        pub fn getType(self: @This()) []const u8 {
            return switch (self) {
                .int => "integer",
                .float => "float",
                .string => "string",
            };
        }
    };
    
    const int_value = Value{ .int = 42 };
    const float_value = Value{ .float = 3.14 };
    const string_value = Value{ .string = "hello" };
    
    try expect(std.mem.eql(u8, int_value.getType(), "integer"));
    try expect(std.mem.eql(u8, float_value.getType(), "float"));
    try expect(std.mem.eql(u8, string_value.getType(), "string"));
    
    // Test union value access
    switch (int_value) {
        .int => |value| try expectEqual(@as(i32, 42), value),
        else => try expect(false),
    }
}

// Performance benchmark example (not a real benchmark, just demonstration)
test "performance comparison example" {
    const iterations = 10000;
    
    // Time a simple operation
    var timer = try std.time.Timer.start();
    
    var sum: u64 = 0;
    var i: u32 = 0;
    while (i < iterations) : (i += 1) {
        sum += i;
    }
    
    const elapsed = timer.read();
    
    // Just verify the calculation is correct
    const expected_sum = (iterations * (iterations - 1)) / 2;
    try expectEqual(expected_sum, sum);
    
    // Note: In real tests, you'd compare elapsed times or use proper benchmarking tools
    try expect(elapsed > 0); // Just ensure timer worked
}