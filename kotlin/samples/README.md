# Kotlin Samples

## Purpose

This directory contains pure Kotlin language examples demonstrating core language features, idioms, and best practices. These samples are designed to help learn Kotlin programming fundamentals before diving into Android mobile development.

## Contents

### Language Fundamentals
- **HelloWorld.kt**: Basic Kotlin program structure
- **Variables.kt**: Variable declarations, val vs var, type inference
- **Functions.kt**: Function declarations, default parameters, named arguments

### Object-Oriented Programming
- **Classes.kt**: Class definitions, constructors, properties
- **DataClasses.kt**: Data classes and their benefits
- **SealedClasses.kt**: Sealed classes for restricted hierarchies
- **Inheritance.kt**: Class inheritance and interfaces

### Functional Programming
- **HigherOrderFunctions.kt**: Functions as first-class citizens
- **Extensions.kt**: Extension functions and properties
- **Collections.kt**: List, Set, Map operations
- **Lambdas.kt**: Lambda expressions and closures

### Advanced Features
- **Coroutines.kt**: Asynchronous programming with coroutines
- **Flow.kt**: Reactive streams with Kotlin Flow
- **NullSafety.kt**: Null safety features
- **Generics.kt**: Generic types and functions

## Setup

### Prerequisites
- Kotlin compiler installed
- Java JDK 11 or higher

### Running Samples

```bash
# Run a single Kotlin file
kotlinc HelloWorld.kt -include-runtime -d HelloWorld.jar
java -jar HelloWorld.jar

# Or use kotlin script
kotlin HelloWorld.kt

# With Gradle
gradle run
```

## Learning Path

1. Start with **HelloWorld.kt** for basic syntax
2. Progress through **Variables.kt** and **Functions.kt**
3. Explore OOP concepts in **Classes.kt** and **DataClasses.kt**
4. Master functional programming with **Collections.kt** and **Lambdas.kt**
5. Advanced topics: **Coroutines.kt** and **Flow.kt**

## Key Concepts

- **Null Safety**: Kotlin's type system eliminates null pointer exceptions
- **Immutability**: Prefer `val` over `var` for safer code
- **Extension Functions**: Add functionality to existing classes
- **Data Classes**: Automatic equals(), hashCode(), toString()
- **Coroutines**: Lightweight concurrency without callback hell

## Resources

- [Kotlin Koans](https://play.kotlinlang.org/koans/overview)
- [Kotlin by Example](https://play.kotlinlang.org/byExample/overview)
- [Official Kotlin Tutorials](https://kotlinlang.org/docs/tutorials.html)
