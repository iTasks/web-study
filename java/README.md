# Java

[← Back to Main](../README.md) | [Web Study Repository](https://github.com/iTasks/web-study)

## Purpose

This directory contains Java programming language study materials, sample applications, and framework implementations. Java is a high-level, class-based, object-oriented programming language that is designed to have as few implementation dependencies as possible.

## Contents

### Frameworks
- **[Spring](spring/)**: Enterprise-grade framework for building Java applications
  - [Spark with Hadoop](spring/spark-hadoop/): Apache Spark with Hadoop integration examples
  - [Spark with Beam](spring/spark-beam/): Apache Beam data processing pipelines

### Pure Language Samples
- **[Samples](samples/)**: Core Java language examples and utilities
  - Data structures and algorithms implementations
  - Concurrency and threading examples
  - File I/O and data processing utilities
  - REST client implementations
  - Game implementations (PingPong, RubiksCube)

## Setup Instructions

### Prerequisites
- Java Development Kit (JDK) 11 or higher
- Maven 3.6+ for dependency management
- IDE of choice (IntelliJ IDEA, Eclipse, VS Code)

### Installation
1. **Install Java JDK**
   ```bash
   # On Ubuntu/Debian
   sudo apt update
   sudo apt install openjdk-11-jdk
   
   # On macOS with Homebrew
   brew install openjdk@11
   
   # Verify installation
   java -version
   javac -version
   ```

2. **Install Maven**
   ```bash
   # On Ubuntu/Debian
   sudo apt install maven
   
   # On macOS with Homebrew
   brew install maven
   
   # Verify installation
   mvn -version
   ```

### Building and Running

#### For samples directory:
```bash
cd java/samples
mvn compile
mvn exec:java -Dexec.mainClass="Application"
```

#### For Spring framework examples:
```bash
cd java/spring/spark-hadoop
mvn clean install
mvn exec:java -Dexec.mainClass="HadoopSparkApplication"
```

## Usage

### Running Sample Applications
Each sample in the `samples/` directory can be compiled and run independently:

```bash
# Compile a specific Java file
javac samples/Application.java

# Run the compiled class
java -cp samples Application
```

### Working with Spring Framework Examples
Navigate to the specific Spring project directory and use Maven commands:

```bash
cd java/spring/spark-beam
mvn spring-boot:run
```

## Project Structure

```
java/
├── README.md                 # This file
├── samples/                  # Pure Java language examples
│   ├── Application.java      # Main application example
│   ├── Combination.java      # Combinatorial algorithms
│   ├── SortingAlgorithms.java # Sorting implementations
│   ├── StringManipulations.java # String processing utilities
│   ├── pom.xml              # Maven configuration
│   └── ...                  # Additional Java samples
└── spring/                  # Spring framework examples
    ├── spark-hadoop/        # Spark + Hadoop integration
    └── spark-beam/          # Apache Beam pipelines
```

## Key Learning Topics

- **Core Java Concepts**: OOP principles, collections, generics, lambdas
- **Concurrency**: Thread management, executors, concurrent collections
- **I/O Operations**: File handling, streams, serialization
- **Network Programming**: REST clients, socket programming
- **Data Processing**: Algorithms, data structures, stream processing
- **Framework Integration**: Spring ecosystem, Apache Spark, Apache Beam

## Contribution Guidelines

1. **Code Style**: Follow Java naming conventions and coding standards
2. **Documentation**: Include javadoc comments for public methods and classes
3. **Testing**: Write unit tests using JUnit for new functionality
4. **Dependencies**: Use Maven for dependency management
5. **Examples**: Provide clear, runnable examples with sample data

### Adding New Samples
1. Place pure Java examples in the `samples/` directory
2. Add framework-specific examples in appropriate subdirectories under their framework folder
3. Update this README with new content descriptions
4. Ensure all code compiles and runs successfully

### Code Quality Standards
- Use meaningful variable and method names
- Include error handling where appropriate
- Follow the single responsibility principle
- Write clean, readable code with appropriate comments

## Resources and References

- [Official Java Documentation](https://docs.oracle.com/en/java/)
- [Spring Framework Documentation](https://spring.io/projects/spring-framework)
- [Apache Spark Documentation](https://spark.apache.org/documentation.html)
- [Apache Beam Documentation](https://beam.apache.org/documentation/)
- [Maven Documentation](https://maven.apache.org/guides/)
- [Java Tutorials by Oracle](https://docs.oracle.com/javase/tutorial/)