//! Control Flow in Zig
//! This file demonstrates:
//! - Conditional statements (if/else)
//! - Switch expressions
//! - Loops (while, for)
//! - Loop control (break, continue)
//! - Optional and error handling in control flow

const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    print("=== Zig Control Flow Demo ===\n\n");
    
    conditionalStatements();
    switchExpressions();
    whileLoops();
    forLoops();
    loopControl();
    optionalHandling();
}

fn conditionalStatements() void {
    print("1. Conditional Statements (if/else):\n");
    
    const temperature = 25;
    const humidity = 60;
    const is_sunny = true;
    
    // Basic if/else
    if (temperature > 20) {
        print("  It's warm outside ({} degrees)\n", .{temperature});
    } else {
        print("  It's cool outside ({} degrees)\n", .{temperature});
    }
    
    // if/else if/else chain
    if (temperature < 0) {
        print("  Weather: Freezing\n");
    } else if (temperature < 10) {
        print("  Weather: Cold\n");
    } else if (temperature < 20) {
        print("  Weather: Cool\n");
    } else if (temperature < 30) {
        print("  Weather: Warm\n");
    } else {
        print("  Weather: Hot\n");
    }
    
    // Multiple conditions with logical operators
    if (temperature > 20 and humidity < 70) {
        print("  Perfect conditions for a walk!\n");
    } else if (temperature > 15 or is_sunny) {
        print("  Good conditions for outdoor activities\n");
    } else {
        print("  Maybe stay indoors today\n");
    }
    
    // Ternary-like expression using if
    const weather_description = if (is_sunny) "sunny" else "cloudy";
    print("  It's a {} day\n", .{weather_description});
    
    // if with optional unwrapping
    const maybe_rain: ?f32 = null;
    if (maybe_rain) |rain_amount| {
        print("  Rain expected: {d:.1}mm\n", .{rain_amount});
    } else {
        print("  No rain expected\n");
    }
    
    print("\n");
}

fn switchExpressions() void {
    print("2. Switch Expressions:\n");
    
    // Basic switch on integers
    const day_number = 3;
    const day_name = switch (day_number) {
        1 => "Monday",
        2 => "Tuesday", 
        3 => "Wednesday",
        4 => "Thursday",
        5 => "Friday",
        6, 7 => "Weekend!", // Multiple values
        else => "Invalid day",
    };
    print("  Day {}: {s}\n", .{ day_number, day_name });
    
    // Switch with ranges
    const grade = 85;
    const letter_grade = switch (grade) {
        90...100 => "A",
        80...89 => "B", 
        70...79 => "C",
        60...69 => "D",
        else => "F",
    };
    print("  Grade {} = {s}\n", .{ grade, letter_grade });
    
    // Switch with enums
    const Color = enum { red, green, blue, yellow, purple };
    const current_color = Color.blue;
    
    const color_info = switch (current_color) {
        .red => "Primary color, wavelength ~700nm",
        .green => "Primary color, wavelength ~550nm", 
        .blue => "Primary color, wavelength ~450nm",
        .yellow => "Secondary color, mix of red and green",
        .purple => "Secondary color, mix of red and blue",
    };
    print("  Color {s}: {s}\n", .{ @tagName(current_color), color_info });
    
    // Switch with capture (destructuring)
    const Point = struct { x: i32, y: i32 };
    const point = Point{ .x = 5, .y = 0 };
    
    const quadrant = switch (point) {
        .{ .x = 0, .y = 0 } => "Origin",
        .{ .x = 0, .y = _ } => "Y-axis", 
        .{ .x = _, .y = 0 } => "X-axis",
        .{ .x = var x, .y = var y } => blk: {
            if (x > 0 and y > 0) break :blk "First quadrant";
            if (x < 0 and y > 0) break :blk "Second quadrant";
            if (x < 0 and y < 0) break :blk "Third quadrant";
            break :blk "Fourth quadrant";
        },
    };
    print("  Point ({}, {}) is on: {s}\n", .{ point.x, point.y, quadrant });
    
    print("\n");
}

fn whileLoops() void {
    print("3. While Loops:\n");
    
    // Basic while loop
    print("  Counting up: ");
    var i: i32 = 1;
    while (i <= 5) {
        print("{} ", .{i});
        i += 1;
    }
    print("\n");
    
    // While loop with condition check after iteration
    print("  Counting down: ");
    var j: i32 = 5;
    while (j > 0) : (j -= 1) {  // Post-iteration expression
        print("{} ", .{j});
    }
    print("\n");
    
    // While loop with optional
    var maybe_value: ?i32 = 10;
    print("  Processing optional values: ");
    while (maybe_value) |value| {
        print("{} ", .{value});
        maybe_value = if (value > 1) value - 2 else null;
    }
    print("\n");
    
    // Infinite loop with break
    print("  Finding first multiple of 7 > 50: ");
    var number: i32 = 51;
    while (true) {
        if (number % 7 == 0) {
            print("{}\n", .{number});
            break;
        }
        number += 1;
    }
    
    print("\n");
}

fn forLoops() void {
    print("4. For Loops:\n");
    
    // For loop over array
    const fruits = [_][]const u8{ "apple", "banana", "cherry", "date" };
    print("  Fruits: ");
    for (fruits) |fruit| {
        print("{s} ", .{fruit});
    }
    print("\n");
    
    // For loop with index
    print("  Fruits with index:\n");
    for (fruits, 0..) |fruit, index| {
        print("    {}: {s}\n", .{ index, fruit });
    }
    
    // For loop over range
    print("  Range loop (0 to 4): ");
    for (0..5) |num| {
        print("{} ", .{num});
    }
    print("\n");
    
    // For loop over slice
    const numbers = [_]i32{ 10, 20, 30, 40, 50 };
    const slice = numbers[1..4]; // Elements at index 1, 2, 3
    print("  Slice iteration: ");
    for (slice) |num| {
        print("{} ", .{num});
    }
    print("\n");
    
    // Nested for loops (multiplication table)
    print("  Small multiplication table:\n");
    for (1..4) |row| {
        print("    ");
        for (1..4) |col| {
            print("{:2} ", .{row * col});
        }
        print("\n");
    }
    
    print("\n");
}

fn loopControl() void {
    print("5. Loop Control (break, continue):\n");
    
    // Using continue to skip iterations
    print("  Even numbers from 1 to 10: ");
    for (1..11) |num| {
        if (num % 2 != 0) continue; // Skip odd numbers
        print("{} ", .{num});
    }
    print("\n");
    
    // Using break to exit early
    print("  Numbers until we find 7: ");
    for (1..20) |num| {
        if (num == 7) break;
        print("{} ", .{num});
    }
    print("\n");
    
    // Labeled breaks for nested loops
    print("  Finding first pair that sums to 10:\n");
    outer: for (1..6) |i| {
        for (1..6) |j| {
            if (i + j == 10) {
                print("    Found: {} + {} = 10\n", .{ i, j });
                break :outer; // Break out of both loops
            }
        }
    }
    
    // While loop with break and continue
    print("  Processing numbers 1-15 (skip multiples of 3, stop at 13):\n");
    var num: i32 = 1;
    while (num <= 15) : (num += 1) {
        if (num == 13) break;
        if (num % 3 == 0) continue;
        print("    Processing: {}\n", .{num});
    }
    
    print("\n");
}

fn optionalHandling() void {
    print("6. Optional and Error Handling in Control Flow:\n");
    
    // Array of optional values
    const optional_numbers = [_]?i32{ 1, null, 3, null, 5 };
    
    print("  Processing optional array:\n");
    for (optional_numbers, 0..) |maybe_num, index| {
        if (maybe_num) |num| {
            print("    Index {}: {}\n", .{ index, num });
        } else {
            print("    Index {}: null\n", .{index});
        }
    }
    
    // Optional with default value using orelse
    const user_input: ?[]const u8 = null;
    const name = user_input orelse "Anonymous";
    print("  Welcome, {s}!\n", .{name});
    
    // Chaining optionals
    const maybe_x: ?i32 = 5;
    const maybe_y: ?i32 = 3;
    
    if (maybe_x) |x| {
        if (maybe_y) |y| {
            print("  Sum of optionals: {} + {} = {}\n", .{ x, y, x + y });
        }
    }
    
    // Switch on optional
    const optional_score: ?i32 = 85;
    const result = switch (optional_score) {
        null => "No score available",
        0...59 => "Failing grade",
        60...79 => "Passing grade", 
        80...100 => "Good grade",
        else => "Invalid score",
    };
    print("  Score evaluation: {s}\n", .{result});
    
    print("\n");
}