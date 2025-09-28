//! Structs and Enums in Zig
//! This file demonstrates:
//! - Struct definitions and usage
//! - Methods and associated functions
//! - Enums and tagged unions
//! - Generic structs
//! - Packed structs for memory layout control

const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    print("=== Zig Structs and Enums Demo ===\n\n");
    
    basicStructs();
    structMethods();
    enumExamples();
    taggedUnions();
    genericStructs();
    packedStructs();
}

fn basicStructs() void {
    print("1. Basic Structs:\n");
    
    // Define a simple struct inline
    const Point = struct {
        x: f32,
        y: f32,
        
        // Struct can have default values
        const Self = @This();
        
        // Constructor-like function
        pub fn init(x: f32, y: f32) Self {
            return Self{ .x = x, .y = y };
        }
    };
    
    // Create struct instances
    const origin = Point{ .x = 0.0, .y = 0.0 };
    const p1 = Point.init(3.0, 4.0);
    const p2 = Point{ .x = 1.0, .y = 2.0 };
    
    print("  Origin: ({d:.1}, {d:.1})\n", .{ origin.x, origin.y });
    print("  Point 1: ({d:.1}, {d:.1})\n", .{ p1.x, p1.y });
    print("  Point 2: ({d:.1}, {d:.1})\n", .{ p2.x, p2.y });
    
    // More complex struct
    const Person = struct {
        name: []const u8,
        age: u32,
        email: ?[]const u8, // Optional field
        is_active: bool = true, // Default value
    };
    
    const alice = Person{
        .name = "Alice",
        .age = 30,
        .email = "alice@example.com",
    };
    
    const bob = Person{
        .name = "Bob",
        .age = 25,
        .email = null, // No email provided
        .is_active = false,
    };
    
    print("  Person: {s}, Age: {}, Email: {?s}, Active: {}\n", 
          .{ alice.name, alice.age, alice.email, alice.is_active });
    print("  Person: {s}, Age: {}, Email: {?s}, Active: {}\n", 
          .{ bob.name, bob.age, bob.email, bob.is_active });
    
    print("\n");
}

fn structMethods() void {
    print("2. Struct Methods:\n");
    
    // Rectangle struct with methods
    const Rectangle = struct {
        width: f32,
        height: f32,
        
        const Self = @This();
        
        // Constructor
        pub fn init(width: f32, height: f32) Self {
            return Self{ .width = width, .height = height };
        }
        
        // Method to calculate area
        pub fn area(self: Self) f32 {
            return self.width * self.height;
        }
        
        // Method to calculate perimeter
        pub fn perimeter(self: Self) f32 {
            return 2 * (self.width + self.height);
        }
        
        // Method that modifies the struct
        pub fn scale(self: *Self, factor: f32) void {
            self.width *= factor;
            self.height *= factor;
        }
        
        // Static method (doesn't need self)
        pub fn square(side: f32) Self {
            return Self.init(side, side);
        }
        
        // Method for formatted output
        pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = fmt;
            _ = options;
            try writer.print("Rectangle({}x{})", .{ self.width, self.height });
        }
    };
    
    var rect = Rectangle.init(5.0, 3.0);
    print("  Rectangle: {}\n", .{rect});
    print("  Area: {d:.2}\n", .{rect.area()});
    print("  Perimeter: {d:.2}\n", .{rect.perimeter()});
    
    // Modify the rectangle
    rect.scale(1.5);
    print("  After scaling by 1.5: {}\n", .{rect});
    print("  New area: {d:.2}\n", .{rect.area()});
    
    // Create a square using static method
    const square = Rectangle.square(4.0);
    print("  Square: {}\n", .{square});
    print("  Square area: {d:.2}\n", .{square.area()});
    
    print("\n");
}

fn enumExamples() void {
    print("3. Enums:\n");
    
    // Basic enum
    const Color = enum {
        red,
        green,
        blue,
        yellow,
        
        // Enum can have methods
        pub fn isWarm(self: Color) bool {
            return switch (self) {
                .red, .yellow => true,
                .green, .blue => false,
            };
        }
        
        // Convert to string
        pub fn toString(self: Color) []const u8 {
            return switch (self) {
                .red => "Red",
                .green => "Green",
                .blue => "Blue",
                .yellow => "Yellow",
            };
        }
    };
    
    const colors = [_]Color{ .red, .green, .blue, .yellow };
    
    for (colors) |color| {
        const warm_str = if (color.isWarm()) "warm" else "cool";
        print("  {s} is a {} color\n", .{ color.toString(), warm_str });
    }
    
    // Enum with explicit values
    const StatusCode = enum(u16) {
        ok = 200,
        not_found = 404,
        server_error = 500,
        
        pub fn isError(self: StatusCode) bool {
            return @intFromEnum(self) >= 400;
        }
    };
    
    const codes = [_]StatusCode{ .ok, .not_found, .server_error };
    
    for (codes) |code| {
        const code_value = @intFromEnum(code);
        const status = if (code.isError()) "error" else "success";
        print("  Status {} ({}): {s}\n", .{ code_value, @tagName(code), status });
    }
    
    print("\n");
}

fn taggedUnions() void {
    print("4. Tagged Unions:\n");
    
    // Tagged union (enum with payload)
    const Value = union(enum) {
        integer: i32,
        float: f64,
        string: []const u8,
        boolean: bool,
        
        // Method to get type name
        pub fn typeName(self: Value) []const u8 {
            return switch (self) {
                .integer => "integer",
                .float => "float",
                .string => "string",
                .boolean => "boolean",
            };
        }
        
        // Method to format value as string
        pub fn format(self: Value, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = fmt;
            _ = options;
            switch (self) {
                .integer => |i| try writer.print("{}", .{i}),
                .float => |f| try writer.print("{d:.2}", .{f}),
                .string => |s| try writer.print("\"{s}\"", .{s}),
                .boolean => |b| try writer.print("{}", .{b}),
            }
        }
    };
    
    const values = [_]Value{
        Value{ .integer = 42 },
        Value{ .float = 3.14159 },
        Value{ .string = "Hello, Zig!" },
        Value{ .boolean = true },
    };
    
    for (values, 0..) |value, i| {
        print("  Value {}: {} (type: {s})\n", .{ i, value, value.typeName() });
    }
    
    // More complex example: Result type
    const Result = union(enum) {
        success: []const u8,
        error: []const u8,
        
        pub fn isOk(self: Result) bool {
            return switch (self) {
                .success => true,
                .error => false,
            };
        }
    };
    
    const operations = [_]Result{
        Result{ .success = "Operation completed successfully" },
        Result{ .error = "File not found" },
        Result{ .success = "Data saved" },
    };
    
    for (operations, 0..) |result, i| {
        print("  Operation {}: ", .{i});
        switch (result) {
            .success => |msg| print("✓ {s}\n", .{msg}),
            .error => |err| print("✗ {s}\n", .{err}),
        }
    }
    
    print("\n");
}

fn genericStructs() void {
    print("5. Generic Structs:\n");
    
    // Generic list node
    fn Node(comptime T: type) type {
        return struct {
            data: T,
            next: ?*Self,
            
            const Self = @This();
            
            pub fn init(data: T) Self {
                return Self{
                    .data = data,
                    .next = null,
                };
            }
        };
    }
    
    // Generic pair
    fn Pair(comptime T: type, comptime U: type) type {
        return struct {
            first: T,
            second: U,
            
            const Self = @This();
            
            pub fn init(first: T, second: U) Self {
                return Self{ .first = first, .second = second };
            }
            
            pub fn swap(self: Self) Pair(U, T) {
                return Pair(U, T).init(self.second, self.first);
            }
        };
    }
    
    // Use generic structs
    var int_node = Node(i32).init(42);
    var string_node = Node([]const u8).init("Hello");
    
    print("  Integer node: {}\n", .{int_node.data});
    print("  String node: {s}\n", .{string_node.data});
    
    const int_str_pair = Pair(i32, []const u8).init(123, "world");
    const str_int_pair = int_str_pair.swap();
    
    print("  Original pair: ({}, {s})\n", .{ int_str_pair.first, int_str_pair.second });
    print("  Swapped pair: ({s}, {})\n", .{ str_int_pair.first, str_int_pair.second });
    
    // Generic array with methods
    fn Array(comptime T: type, comptime size: usize) type {
        return struct {
            data: [size]T,
            
            const Self = @This();
            
            pub fn init(initial_value: T) Self {
                return Self{ .data = [_]T{initial_value} ** size };
            }
            
            pub fn get(self: Self, index: usize) ?T {
                if (index >= size) return null;
                return self.data[index];
            }
            
            pub fn sum(self: Self) T {
                var total: T = 0;
                for (self.data) |item| {
                    total += item;
                }
                return total;
            }
        };
    }
    
    const int_array = Array(i32, 5).init(7);
    print("  Generic array sum: {}\n", .{int_array.sum()});
    
    print("\n");
}

fn packedStructs() void {
    print("6. Packed Structs (Memory Layout Control):\n");
    
    // Packed struct for bit-level control
    const Flags = packed struct {
        read: bool,
        write: bool,
        execute: bool,
        _reserved: u5 = 0,  // Padding to make it exactly 8 bits
        
        pub fn fromU8(value: u8) Flags {
            return @bitCast(value);
        }
        
        pub fn toU8(self: Flags) u8 {
            return @bitCast(self);
        }
    };
    
    var permissions = Flags{
        .read = true,
        .write = false,
        .execute = true,
    };
    
    print("  Permissions: read={}, write={}, execute={}\n", 
          .{ permissions.read, permissions.write, permissions.execute });
    print("  As byte: 0b{b:0>8}\n", .{permissions.toU8()});
    
    // Modify permissions
    permissions.write = true;
    print("  After enabling write: 0b{b:0>8}\n", .{permissions.toU8()});
    
    // Create from byte value
    const new_permissions = Flags.fromU8(0b00000110); // read=false, write=true, execute=true
    print("  From byte 0b00000110: read={}, write={}, execute={}\n",
          .{ new_permissions.read, new_permissions.write, new_permissions.execute });
    
    // Network packet header example
    const PacketHeader = packed struct {
        version: u4,
        header_length: u4,
        type_of_service: u8,
        total_length: u16,
        
        pub fn format(self: PacketHeader, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = fmt;
            _ = options;
            try writer.print("PacketHeader(v{}, len={}, tos={}, total={})", 
                           .{ self.version, self.header_length, self.type_of_service, self.total_length });
        }
    };
    
    const packet = PacketHeader{
        .version = 4,
        .header_length = 5,
        .type_of_service = 0,
        .total_length = 1500,
    };
    
    print("  Network packet: {}\n", .{packet});
    print("  Struct size: {} bytes\n", .{@sizeOf(PacketHeader)});
    
    print("\n");
}