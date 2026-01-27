# Scala

[← Back to Main](../README.md) | [Web Study Repository](https://github.com/iTasks/web-study)

## Purpose

This directory contains Scala programming language study materials and sample applications. Scala is a general-purpose programming language that combines object-oriented and functional programming paradigms, running on the Java Virtual Machine (JVM).

## Contents

### Pure Language Samples
- `samples/`: Core Scala language examples and applications
  - Functional programming demonstrations
  - Object-oriented programming examples
  - JVM interoperability samples

## Setup Instructions

### Prerequisites
- Java 8 or higher (JDK)
- SBT (Scala Build Tool) or Maven
- Scala 2.13 or 3.x

### Installation
1. **Install Java JDK**
   ```bash
   # On Ubuntu/Debian
   sudo apt install openjdk-11-jdk
   
   # On macOS with Homebrew
   brew install openjdk@11
   ```

2. **Install Scala and SBT**
   ```bash
   # On Ubuntu/Debian
   sudo apt install scala
   
   # Install SBT
   echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
   curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
   sudo apt update
   sudo apt install sbt
   
   # On macOS with Homebrew
   brew install scala sbt
   
   # Verify installation
   scala -version
   sbt version
   ```

### Building and Running

#### For samples directory:
```bash
cd scala/samples
scala scapp.scala
# Or compile first
scalac scapp.scala
scala ScApp
```

## Usage

### Running Sample Applications
```bash
# Run Scala script directly
scala samples/scapp.scala

# Compile and run
cd samples
scalac scapp.scala
scala ScApp
```

## Project Structure

```
scala/
├── README.md                    # This file
└── samples/                     # Pure Scala language examples
    └── scapp.scala             # Sample Scala application
```

## Key Learning Topics

- **Functional Programming**: Immutability, higher-order functions, pattern matching
- **Object-Oriented Programming**: Classes, traits, case classes
- **Type System**: Static typing, type inference, generics
- **Collections**: Immutable collections, transformations, parallel processing
- **Concurrency**: Actors, futures, parallel collections

## Contribution Guidelines

1. **Code Style**: Follow Scala style guide conventions
2. **Documentation**: Include Scaladoc comments for APIs
3. **Testing**: Use ScalaTest or similar frameworks
4. **Build**: Use SBT for project management

## Resources and References

- [Official Scala Documentation](https://docs.scala-lang.org/)
- [Scala School](https://twitter.github.io/scala_school/)
- [Scala Exercises](https://www.scala-exercises.org/)
- [SBT Documentation](https://www.scala-sbt.org/)