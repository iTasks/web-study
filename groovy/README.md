# Groovy

## Purpose

This directory contains Groovy programming language study materials and sample applications. Groovy is a Java-syntax-compatible object-oriented programming language for the Java platform that combines features from Python, Ruby, and Smalltalk.

## Contents

### Pure Language Samples
- `samples/`: Core Groovy language examples and applications
  - Dynamic scripting examples
  - Java interoperability demonstrations
  - DSL (Domain Specific Language) implementations

## Setup Instructions

### Prerequisites
- Java 8 or higher (JDK)
- Groovy 4.0 or higher

### Installation
1. **Install Java JDK**
   ```bash
   # On Ubuntu/Debian
   sudo apt install openjdk-11-jdk
   
   # On macOS with Homebrew
   brew install openjdk@11
   ```

2. **Install Groovy**
   ```bash
   # On Ubuntu/Debian
   sudo apt install groovy
   
   # On macOS with Homebrew
   brew install groovy
   
   # Using SDKMAN (recommended)
   curl -s "https://get.sdkman.io" | bash
   sdk install groovy
   
   # Verify installation
   groovy --version
   ```

### Building and Running

#### For samples directory:
```bash
cd groovy/samples
groovy Gapp.groovy
```

## Usage

### Running Sample Applications
```bash
# Run Groovy script directly
groovy samples/Gapp.groovy

# Compile to Java bytecode
groovyc samples/Gapp.groovy
java -cp .:$GROOVY_HOME/lib/groovy-4.0.jar Gapp
```

## Project Structure

```
groovy/
├── README.md                    # This file
└── samples/                     # Pure Groovy language examples
    └── Gapp.groovy             # Sample Groovy application
```

## Key Learning Topics

- **Dynamic Features**: Meta-programming, runtime method injection
- **Java Integration**: Seamless Java interoperability
- **Scripting**: Command-line scripting, build automation
- **DSLs**: Creating domain-specific languages
- **Collections**: Enhanced collection operations

## Contribution Guidelines

1. **Code Style**: Follow Groovy style conventions
2. **Documentation**: Include GroovyDoc comments
3. **Testing**: Use Spock or JUnit for testing
4. **Build**: Use Gradle or Maven for project management

## Resources and References

- [Official Groovy Documentation](https://groovy-lang.org/documentation.html)
- [Groovy in Action](https://www.manning.com/books/groovy-in-action-second-edition)
- [Spock Testing Framework](https://spockframework.org/)