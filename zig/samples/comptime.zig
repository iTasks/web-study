//! Compile-time Programming (comptime) in Zig
//! This file demonstrates:
//! - Compile-time evaluation (comptime)
//! - Generic programming with comptime
//! - Compile-time reflection
//! - Type manipulation at compile time
//! - Code generation with comptime

const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    print("=== Zig Comptime Demo ===\n\n");
    
    basicComptime();
    comptimeGenerics();
    typeReflection();
    codeGeneration();
    comptimeControl();
    metaprogramming();
}

fn basicComptime() void {
    print("1. Basic Compile-time Evaluation:\n");
    
    // Comptime variables are evaluated at compile time
    comptime var x = 5;
    comptime var y = 10;
    comptime var result = x * y;
    
    print("  Compile-time calculation: {} * {} = {}\n", .{ x, y, result });
    
    // Comptime can be used with complex calculations
    comptime {
        var factorial_5 = 1;
        var i = 1;
        while (i <= 5) : (i += 1) {
            factorial_5 *= i;
        }
        print("  5! calculated at compile time: {}\n", .{factorial_5});
    }
    
    // Comptime string operations
    const compile_time_string = comptime blk: {
        var buffer: [100]u8 = undefined;
        const msg = std.fmt.bufPrint(buffer[0..], "Generated at compile time: {}", .{42}) catch unreachable;
        break :blk msg;
    };
    print("  {s}\n", .{compile_time_string});
    
    // Arrays can be generated at compile time
    const powers_of_two = comptime generatePowersOfTwo(8);
    print("  Powers of 2: ");
    for (powers_of_two) |power| {
        print("{} ", .{power});
    }
    print("\n");
    
    print("\n");
}

fn generatePowersOfTwo(comptime count: usize) [count]u32 {
    var result: [count]u32 = undefined;
    var i: usize = 0;
    while (i < count) : (i += 1) {
        result[i] = @as(u32, 1) << @intCast(i);
    }
    return result;
}

fn comptimeGenerics() void {
    print("2. Generic Programming with Comptime:\n");
    
    // Generic functions using comptime parameters
    print("  Max of integers: {}\n", .{max(i32, 15, 23)});
    print("  Max of floats: {d:.2}\n", .{max(f32, 3.14, 2.71)});
    
    // Generic data structures
    var int_stack = Stack(i32, 5).init();
    int_stack.push(10);
    int_stack.push(20);
    int_stack.push(30);
    
    print("  Stack contents: ");
    while (!int_stack.isEmpty()) {
        print("{} ", .{int_stack.pop().?});
    }
    print("\n");
    
    // Generic algorithms
    const int_array = [_]i32{ 64, 34, 25, 12, 22, 11, 90 };
    var sorted = int_array;
    bubbleSort(i32, &sorted);
    
    print("  Original: ");
    for (int_array) |item| {
        print("{} ", .{item});
    }
    print("\n  Sorted:   ");
    for (sorted) |item| {
        print("{} ", .{item});
    }
    print("\n");
    
    print("\n");
}

fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

fn Stack(comptime T: type, comptime capacity: usize) type {
    return struct {
        data: [capacity]T,
        top: usize,
        
        const Self = @This();
        
        pub fn init() Self {
            return Self{
                .data = undefined,
                .top = 0,
            };
        }
        
        pub fn push(self: *Self, value: T) void {
            if (self.top < capacity) {
                self.data[self.top] = value;
                self.top += 1;
            }
        }
        
        pub fn pop(self: *Self) ?T {
            if (self.top > 0) {
                self.top -= 1;
                return self.data[self.top];
            }
            return null;
        }
        
        pub fn isEmpty(self: Self) bool {
            return self.top == 0;
        }
    };
}

fn bubbleSort(comptime T: type, array: []T) void {
    var n = array.len;
    while (n > 1) {
        var new_n: usize = 0;
        var i: usize = 1;
        while (i < n) : (i += 1) {
            if (array[i - 1] > array[i]) {
                const temp = array[i];
                array[i] = array[i - 1];
                array[i - 1] = temp;
                new_n = i;
            }
        }
        n = new_n;
    }
}

fn typeReflection() void {
    print("3. Type Reflection:\n");
    
    // Get information about types at compile time
    analyzeType(i32);
    analyzeType(f64);
    analyzeType(bool);
    analyzeType([]const u8);
    
    // Analyze custom struct
    const Person = struct {
        name: []const u8,
        age: u32,
        active: bool,
    };
    analyzeType(Person);
    
    // Conditional compilation based on type properties
    print("  Testing numeric operations:\n");
    testNumericOperations(i32, 42);
    testNumericOperations(f32, 3.14);
    testNumericOperations(bool, true);
    
    print("\n");
}

fn analyzeType(comptime T: type) void {
    const type_info = @typeInfo(T);
    print("  Type: {} ", .{T});
    
    switch (type_info) {
        .Int => |int_info| {
            const sign = if (int_info.signedness == .signed) "signed" else "unsigned";
            print("({s} {}-bit integer)\n", .{ sign, int_info.bits });
        },
        .Float => |float_info| {
            print("({}-bit float)\n", .{float_info.bits});
        },
        .Bool => {
            print("(boolean)\n");
        },
        .Pointer => |ptr_info| {
            if (ptr_info.size == .Slice) {
                print("(slice of {})\n", .{ptr_info.child});
            } else {
                print("(pointer to {})\n", .{ptr_info.child});
            }
        },
        .Struct => |struct_info| {
            print("(struct with {} fields)\n", .{struct_info.fields.len});
            for (struct_info.fields) |field| {
                print("    {s}: {}\n", .{ field.name, field.type });
            }
        },
        else => {
            print("(other type)\n");
        },
    }
}

fn testNumericOperations(comptime T: type, value: T) void {
    const type_info = @typeInfo(T);
    
    switch (type_info) {
        .Int, .Float => {
            const doubled = value + value;
            print("    {} + {} = {}\n", .{ value, value, doubled });
        },
        else => {
            print("    {} is not numeric\n", .{value});
        },
    }
}

fn codeGeneration() void {
    print("4. Code Generation:\n");
    
    // Generate struct with fields at compile time
    const Point3D = generatePointStruct(3);
    const point = Point3D{ .x = 1.0, .y = 2.0, .z = 3.0 };
    print("  3D Point: x={d:.1}, y={d:.1}, z={d:.1}\n", .{ point.x, point.y, point.z });
    
    // Generate enum with values
    const Color = generateColorEnum();
    print("  Generated color: {s}\n", .{@tagName(Color.blue)});
    
    // Generate functions
    const adder_5 = generateAdder(5);
    print("  Generated adder function: 10 + 5 = {}\n", .{adder_5(10)});
    
    // Generate lookup table
    const squares = generateSquareTable(10);
    print("  Square lookup table: ");
    for (squares, 0..) |square, i| {
        if (i < 6) print("{}² = {} ", .{ i, square });
    }
    print("\n");
    
    print("\n");
}

fn generatePointStruct(comptime dimensions: u32) type {
    return switch (dimensions) {
        2 => struct { x: f32, y: f32 },
        3 => struct { x: f32, y: f32, z: f32 },
        4 => struct { x: f32, y: f32, z: f32, w: f32 },
        else => @compileError("Unsupported number of dimensions"),
    };
}

fn generateColorEnum() type {
    return enum {
        red,
        green,
        blue,
        yellow,
        purple,
    };
}

fn generateAdder(comptime addend: i32) fn (i32) i32 {
    return struct {
        fn add(x: i32) i32 {
            return x + addend;
        }
    }.add;
}

fn generateSquareTable(comptime size: usize) [size]u32 {
    var table: [size]u32 = undefined;
    var i: usize = 0;
    while (i < size) : (i += 1) {
        table[i] = @as(u32, @intCast(i * i));
    }
    return table;
}

fn comptimeControl() void {
    print("5. Compile-time Control Flow:\n");
    
    // Conditional compilation
    const build_mode = std.builtin.mode;
    print("  Build mode: {}\n", .{build_mode});
    
    // Compile-time if
    const message = comptime if (build_mode == .Debug) "Debug build" else "Release build";
    print("  Message: {s}\n", .{message});
    
    // Feature flags using comptime
    const features = struct {
        const logging_enabled = true;
        const debug_info = true;
        const profiling = false;
    };
    
    print("  Feature status:\n");
    inline for (@typeInfo(@TypeOf(features)).Struct.fields) |field| {
        const value = @field(features, field.name);
        const status = if (value) "enabled" else "disabled";
        print("    {s}: {s}\n", .{ field.name, status });
    }
    
    // Conditional code generation
    generateConditionalCode();
    
    print("\n");
}

fn generateConditionalCode() void {
    const enable_advanced_features = true;
    
    if (comptime enable_advanced_features) {
        print("  Advanced features are enabled!\n");
        advancedFeature();
    } else {
        print("  Using basic features only\n");
    }
}

fn advancedFeature() void {
    print("    Running advanced feature...\n");
}

fn metaprogramming() void {
    print("6. Metaprogramming Examples:\n");
    
    // Create a generic container with different behaviors
    const ArrayList = createContainer(.array_list);
    const LinkedList = createContainer(.linked_list);
    
    print("  Container types created: ArrayList and LinkedList\n");
    
    // Generate serialization functions
    const Person = struct {
        name: []const u8,
        age: u32,
        active: bool,
    };
    
    const person = Person{ .name = "Alice", .age = 30, .active = true };
    print("  Serialized struct: ");
    serializeStruct(Person, person);
    print("\n");
    
    // Generate validation functions
    const ValidationRules = struct {
        min_age: u32 = 18,
        max_age: u32 = 120,
        required_name: bool = true,
    };
    
    const validation_result = validatePerson(person, ValidationRules{});
    print("  Validation result: {s}\n", .{if (validation_result) "valid" else "invalid"});
    
    print("\n");
}

const ContainerType = enum {
    array_list,
    linked_list,
};

fn createContainer(comptime container_type: ContainerType) type {
    return switch (container_type) {
        .array_list => struct {
            const name = "ArrayList";
        },
        .linked_list => struct {
            const name = "LinkedList";
        },
    };
}

fn serializeStruct(comptime T: type, value: T) void {
    const type_info = @typeInfo(T);
    if (type_info != .Struct) {
        @compileError("serializeStruct only works with structs");
    }
    
    print("{{ ");
    inline for (type_info.Struct.fields, 0..) |field, i| {
        if (i > 0) print(", ");
        const field_value = @field(value, field.name);
        switch (@typeInfo(field.type)) {
            .Pointer => |ptr| {
                if (ptr.size == .Slice and ptr.child == u8) {
                    print("\"{s}\": \"{s}\"", .{ field.name, field_value });
                } else {
                    print("\"{s}\": {}", .{ field.name, field_value });
                }
            },
            else => {
                print("\"{s}\": {}", .{ field.name, field_value });
            },
        }
    }
    print(" }}");
}

fn validatePerson(person: anytype, comptime rules: anytype) bool {
    const PersonType = @TypeOf(person);
    const person_info = @typeInfo(PersonType);
    
    if (person_info != .Struct) return false;
    
    // Check age validation
    if (@hasField(PersonType, "age")) {
        const age = person.age;
        if (age < rules.min_age or age > rules.max_age) {
            return false;
        }
    }
    
    // Check name validation
    if (rules.required_name and @hasField(PersonType, "name")) {
        const name = person.name;
        if (name.len == 0) {
            return false;
        }
    }
    
    return true;
}