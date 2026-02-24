# Groovy

[← Back to Main](../README.md) | [Web Study Repository](https://github.com/iTasks/web-study)

## Purpose

This directory contains Groovy programming language study materials and sample applications. Groovy is a powerful, optionally typed and dynamic language for the Java platform that combines features from Python, Ruby, and Smalltalk with a Java-like syntax. It seamlessly integrates with existing Java code and libraries.

## Contents

### Pure Language Samples
- **[Samples](samples/)**: Core Groovy language examples and applications
  - **Gapp.groovy** - Simple "Hello World" application
  - **StringManipulations.groovy** - String operations including reverse, palindrome check, compression, anagrams, permutations, and word frequency
  - **CollectionOperations.groovy** - List, map, set, and range operations with Groovy's powerful collection APIs
  - **ClosuresAndDSL.groovy** - Closures, higher-order functions, DSL creation, and functional programming patterns
  - **FileOperations.groovy** - File I/O operations including read, write, copy, delete, and directory traversal
  - **JsonXmlProcessing.groovy** - JSON and XML parsing, creation, and transformation

### Web Framework Examples
- **[Ratpack](ratpack/)**: Ratpack web framework examples
  - Lightweight, high-performance REST API server
  - Reactive and non-blocking architecture
  - RESTful endpoints with CRUD operations
  - JSON request/response handling

### AI Assistant Examples
- **[Yelp AI Assistant](yelp-ai-assistant/)**: Yelp-style AI assistant implementation in Groovy (Ratpack)

## Setup Instructions

### Prerequisites
- Java 8 or higher (JDK)
- Groovy 2.4 or higher (Groovy 3.x recommended)
- Gradle 6.0+ (optional, for build management)

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
   
   # Using SDKMAN (recommended for latest version)
   curl -s "https://get.sdkman.io" | bash
   sdk install groovy
   
   # Verify installation
   groovy --version
   ```

3. **Install Gradle (optional)**
   ```bash
   # Using SDKMAN
   sdk install gradle
   
   # On macOS with Homebrew
   brew install gradle
   
   # Verify installation
   gradle --version
   ```

### Building and Running

#### For samples directory:

```bash
cd groovy/samples

# Run individual samples
groovy Gapp.groovy
groovy StringManipulations.groovy
groovy CollectionOperations.groovy
groovy ClosuresAndDSL.groovy
groovy FileOperations.groovy
groovy JsonXmlProcessing.groovy

# Compile to Java bytecode (optional)
groovyc StringManipulations.groovy
java -cp .:$GROOVY_HOME/lib/groovy-3.0.19.jar StringManipulations
```

#### For Ratpack web application:

```bash
cd groovy/ratpack

# Run with Groovy (Grape will auto-download dependencies)
groovy RatpackApp.groovy

# Access the API at http://localhost:5050
```

#### Using Gradle:

```bash
cd groovy

# Build the project
gradle build

# Run all samples
gradle runAllSamples

# Clean build artifacts
gradle clean
```

## Usage

### Running Sample Applications

```bash
# Run Groovy script directly
groovy samples/StringManipulations.groovy

# Compile to Java bytecode
groovyc samples/CollectionOperations.groovy
java -cp .:$GROOVY_HOME/lib/* CollectionOperations

# Using Groovy Console (GUI)
groovyConsole samples/ClosuresAndDSL.groovy
```

### Interactive Groovy Shell

```bash
# Start Groovy shell
groovysh

# Try some Groovy code
groovy:000> println "Hello, Groovy!"
groovy:000> def list = [1, 2, 3, 4, 5]
groovy:000> list.findAll { it % 2 == 0 }
```

## Project Structure

```
groovy/
├── README.md                           # This file
├── build.gradle                        # Gradle build configuration
├── .gitignore                          # Git ignore file
├── samples/                            # Pure Groovy language examples
│   ├── Gapp.groovy                    # Hello World application
│   ├── StringManipulations.groovy     # String operations
│   ├── CollectionOperations.groovy    # Collection operations
│   ├── ClosuresAndDSL.groovy         # Closures and DSL examples
│   ├── FileOperations.groovy         # File I/O operations
│   └── JsonXmlProcessing.groovy      # JSON/XML processing
└── ratpack/                            # Ratpack web framework
    ├── README.md                       # Ratpack-specific documentation
    └── RatpackApp.groovy              # REST API application
```

## Key Learning Topics

### Language Features
- **Dynamic Typing**: Optional static typing with `def` keyword
- **Closures**: First-class functions and functional programming
- **Operator Overloading**: Custom operators for domain-specific code
- **String Interpolation**: GStrings with `${}` syntax
- **Collections**: Enhanced list, map, and set operations
- **Meta-programming**: Runtime method injection and AST transformations
- **Traits**: Composable units of behavior (similar to mixins)

### Advanced Concepts
- **DSL Creation**: Building domain-specific languages
- **AST Transformations**: Compile-time code generation
- **Category Classes**: Adding methods to existing classes
- **Method Missing**: Dynamic method resolution
- **ExpandoMetaClass**: Runtime class enhancement
- **Grape**: Dependency management with `@Grab` annotations

### Java Integration
- **Seamless Interoperability**: Call Java from Groovy and vice versa
- **Java Libraries**: Use any Java library directly
- **Groovy as Scripting Layer**: Add scripting to Java applications
- **Build Tools**: Gradle uses Groovy for build scripts

### Web Development
- **Ratpack**: Modern, reactive web framework
- **Grails**: Full-stack web framework (similar to Rails)
- **REST APIs**: Easy JSON/XML handling
- **Testing**: Spock framework for BDD-style testing

## Production Readiness Features

### Build Management
- Gradle build configuration with dependency management
- Support for external libraries (HTTP client, database drivers, JSON/XML processors)
- Custom tasks for running samples and tests
- Proper `.gitignore` for build artifacts

### Code Quality
- Comprehensive examples demonstrating best practices
- Error handling patterns
- Resource management (file operations with proper cleanup)
- Type safety where appropriate

### Documentation
- Detailed README files for each component
- Inline documentation in code samples
- API endpoint documentation for web examples
- Usage examples and tutorials

### Testing
- Spock framework support in build configuration
- Unit testing capabilities
- Integration testing for web applications

## Contribution Guidelines

1. **Code Style**: Follow Groovy style conventions
   - Use camelCase for variables and methods
   - Use PascalCase for classes
   - Prefer `def` for local variables unless type is important
   - Use GStrings for string interpolation

2. **Documentation**: Include GroovyDoc comments
   ```groovy
   /**
    * Calculates the sum of two numbers
    * @param a First number
    * @param b Second number
    * @return Sum of a and b
    */
   def add(a, b) {
       a + b
   }
   ```

3. **Testing**: Use Spock or JUnit for testing
   ```groovy
   class MySpec extends Specification {
       def "should add two numbers"() {
           expect:
           add(2, 3) == 5
       }
   }
   ```

4. **Build**: Use Gradle for project management
   - Add dependencies to `build.gradle`
   - Create tasks for common operations
   - Keep build scripts maintainable

## Resources and References

- [Official Groovy Documentation](https://groovy-lang.org/documentation.html)
- [Groovy API Documentation](https://docs.groovy-lang.org/latest/html/api/)
- [Groovy in Action (Book)](https://www.manning.com/books/groovy-in-action-second-edition)
- [Spock Testing Framework](https://spockframework.org/)
- [Ratpack Web Framework](https://ratpack.io/)
- [Grails Framework](https://grails.org/)
- [Gradle Build Tool](https://gradle.org/)

## Common Use Cases

### Scripting
Groovy excels at scripting tasks, build automation, and data processing:
```groovy
// Process log files
new File('app.log').eachLine { line ->
    if (line.contains('ERROR')) {
        println line
    }
}
```

### REST API Development
Build lightweight, high-performance REST APIs with Ratpack or Micronaut.

### Build Automation
Gradle uses Groovy for build scripts, making it powerful for CI/CD pipelines.

### Testing
Spock framework provides expressive, readable tests with Groovy syntax.

### Data Processing
Groovy's collection operations make it ideal for ETL and data transformation.

## Next Steps

1. **Explore Samples**: Start with basic samples and progress to advanced topics
2. **Try Ratpack**: Build a REST API with the Ratpack framework
3. **Learn Spock**: Write tests using the Spock framework
4. **Study Grails**: Explore full-stack web development
5. **Meta-programming**: Dive into AST transformations and runtime enhancements
6. **Integration**: Integrate Groovy with existing Java projects