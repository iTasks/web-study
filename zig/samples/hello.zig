//! Hello World and Basic Zig Syntax
//! This file demonstrates the basics of Zig syntax, including:
//! - Program entry point
//! - Standard library imports
//! - Basic output
//! - Comments and documentation

// Import the standard library
const std = @import("std");

// Import the print function from the standard library
const print = std.debug.print;

/// The main function is the entry point of a Zig program
/// It has the signature: fn main() void or fn main() !void
pub fn main() void {
    // Single-line comment
    print("Hello, World!\n");
    
    /* Multi-line comment
       can span multiple lines
       and is useful for longer explanations */
    
    // Demonstrate basic string operations
    const greeting = "Welcome to Zig!";
    print("{s}\n", .{greeting});
    
    // Print formatted output
    const name = "Zig Developer";
    const version = "0.11.0";
    print("Hello, {s}! You're using Zig version {s}\n", .{ name, version });
    
    // Demonstrate basic arithmetic
    const a = 42;
    const b = 13;
    print("Basic arithmetic: {} + {} = {}\n", .{ a, b, a + b });
    
    // Show different number formats
    const hex_value = 0xFF;
    const binary_value = 0b11111111;
    const octal_value = 0o377;
    
    print("Different number formats:\n");
    print("  Decimal: {}\n", .{hex_value});
    print("  Hex: 0x{X}\n", .{hex_value});
    print("  Binary: 0b{b}\n", .{hex_value});
    print("  All represent the same value: {} = {} = {}\n", .{ hex_value, binary_value, octal_value });
    
    // Character and string literals
    const char = 'Z';
    const string = "Zig is awesome!";
    const multiline_string =
        \\This is a multiline string
        \\using Zig's multiline string syntax.
        \\No need to escape newlines!
    ;
    
    print("\nCharacter: {c}\n", .{char});
    print("String: {s}\n", .{string});
    print("Multiline string:\n{s}\n", .{multiline_string});
    
    // Boolean values
    const is_awesome = true;
    const is_difficult = false;
    print("\nZig is awesome: {}\n", .{is_awesome});
    print("Zig is difficult: {}\n", .{is_difficult});
}

/// This is a documentation comment for a function
/// It can be extracted for automatic documentation generation
fn demonstrateDocComments() void {
    // This function shows how to write documentation comments
    // Documentation comments use /// or //!
    print("This function demonstrates documentation comments\n");
}