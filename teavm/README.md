# TeaVM

[← Back to Main](../README.md) | [Web Study Repository](https://github.com/iTasks/web-study)

## Purpose

This directory contains TeaVM study materials and sample applications. TeaVM is an ahead-of-time transpiler that takes Java bytecode and produces JavaScript, WebAssembly, or C code, allowing Java applications to run in web browsers and other JavaScript environments.

## Contents

### Pure Language Samples
- **[Samples](samples/)**: TeaVM examples and applications
  - Java-to-JavaScript transpilation examples
  - WebAssembly compilation demonstrations
  - Coroutine implementations

## Setup Instructions

### Prerequisites
- Java 8 or higher (JDK)
- Maven or Gradle for build management
- Node.js (for running generated JavaScript)

### Installation
1. **Install Java JDK**
   ```bash
   # On Ubuntu/Debian
   sudo apt install openjdk-11-jdk
   
   # On macOS with Homebrew
   brew install openjdk@11
   ```

2. **Install Maven**
   ```bash
   # On Ubuntu/Debian
   sudo apt install maven
   
   # On macOS with Homebrew
   brew install maven
   ```

3. **Set up TeaVM Project**
   ```bash
   # Create new TeaVM project
   mvn archetype:generate -DgroupId=org.teavm -DartifactId=teavm-example
   ```

### Building and Running

#### For samples directory:
```bash
cd teavm/samples
mvn clean compile
mvn teavm:build
# Generated JavaScript will be in target/javascript/
```

## Usage

### Building TeaVM Applications
```bash
# Compile Java to JavaScript
cd teavm/samples
mvn teavm:build

# Run in browser
# Open target/javascript/index.html in browser
```

## Project Structure

```
teavm/
├── README.md                    # This file
└── samples/                     # TeaVM examples
    └── coroutine/              # Coroutine implementation examples
```

## Key Learning Topics

- **Java-to-JavaScript Transpilation**: Converting Java code to run in browsers
- **WebAssembly**: Compiling Java to WebAssembly for better performance
- **Coroutines**: Implementing cooperative multitasking
- **Browser Integration**: Accessing DOM and browser APIs from Java
- **Performance Optimization**: Optimizing generated JavaScript/WebAssembly

## Contribution Guidelines

1. **Code Style**: Follow Java conventions for source code
2. **Documentation**: Include Javadoc comments
3. **Testing**: Test both Java and generated JavaScript/WebAssembly
4. **Build**: Use Maven or Gradle with TeaVM plugins

## Resources and References

- [TeaVM Official Website](http://teavm.org/)
- [TeaVM GitHub Repository](https://github.com/konsoletyper/teavm)
- [TeaVM Documentation](http://teavm.org/docs/)
- [WebAssembly Specification](https://webassembly.org/)