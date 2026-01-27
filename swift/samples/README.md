# Swift Samples

[← Back to Swift](../README.md) | [Main README](../../README.md)

## Purpose

This directory contains pure Swift language examples demonstrating core language features, idioms, and best practices. These samples are designed to help learn Swift programming fundamentals before diving into iOS mobile development.

## Contents

### Language Fundamentals
- **HelloWorld.swift**: Basic Swift program structure
- **Variables.swift**: Constants (let) vs variables (var), type inference
- **Functions.swift**: Function declarations, parameters, return values

### Object-Oriented Programming
- **Structs.swift**: Structure definitions and value semantics
- **Classes.swift**: Class definitions and reference semantics
- **Enums.swift**: Enumerations with associated values
- **Protocols.swift**: Protocol definitions and conformance

### Functional Programming
- **Closures.swift**: Closure expressions and capturing values
- **HigherOrderFunctions.swift**: Map, filter, reduce operations
- **Collections.swift**: Array, Set, Dictionary operations
- **Generics.swift**: Generic types and functions

### Advanced Features
- **AsyncAwait.swift**: Modern concurrency with async/await
- **ErrorHandling.swift**: Error handling with do-try-catch
- **Optionals.swift**: Optional types and unwrapping strategies
- **PropertyWrappers.swift**: Custom property wrappers

## Setup

### Prerequisites
- Swift compiler installed (comes with Xcode on macOS)
- macOS or Linux with Swift installed

### Running Samples

```bash
# Run a single Swift file
swift HelloWorld.swift

# Compile and run
swiftc HelloWorld.swift -o HelloWorld
./HelloWorld

# With Swift Package Manager
swift run
```

## Learning Path

1. Start with **HelloWorld.swift** for basic syntax
2. Progress through **Variables.swift** and **Functions.swift**
3. Understand value vs reference types with **Structs.swift** and **Classes.swift**
4. Explore protocols with **Protocols.swift**
5. Master functional programming with **Closures.swift** and **HigherOrderFunctions.swift**
6. Advanced topics: **AsyncAwait.swift** and **PropertyWrappers.swift**

## Key Concepts

- **Type Safety**: Swift's strong type system prevents many common errors
- **Optionals**: Explicit handling of absence of values
- **Value Types**: Structs are preferred over classes in many cases
- **Protocol-Oriented**: Programming with protocols rather than inheritance
- **Memory Safety**: Automatic Reference Counting (ARC) manages memory
- **Modern Concurrency**: async/await for clean asynchronous code

## Resources

- [Swift Playgrounds](https://www.apple.com/swift/playgrounds/)
- [Swift Programming Language Book](https://docs.swift.org/swift-book/)
- [100 Days of Swift](https://www.hackingwithswift.com/100)
