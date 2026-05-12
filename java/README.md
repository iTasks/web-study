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

### Reactive vs Virtual Threads
- **[HIVE](hive/)**: Thermostat monitoring demo comparing Reactive Stack vs Virtual Threads
  - [Project Overview](hive/PROJECT_OVERVIEW.md): High-level architecture and goals
  - [Analysis](hive/ANALYSIS.md): Technical analysis of reactive and virtual thread approaches
  - [Optimal Solution](hive/OPTIMAL_SOLUTION.md): Recommended implementation path
  - [Security](hive/SECURITY.md): Security considerations and controls
  - [Summary](hive/SUMMARY.md): Consolidated findings and outcomes

### AI Assistant Examples
- **[Yelp AI Assistant](yelp-ai-assistant/)**: Yelp-style AI assistant implementation in Java (Spring Boot)

### Migration and Modern Java Notes
- **[Migrate to Quarkus](migrate_to_quarkus.md)**: Notes on moving from Java EE approaches to Quarkus and AI-era development practices

### Fossil + Git + Architecture Documentation
- **[Fossil vs Git](fossil_git/comparing_fossil_vs_git.md)**: Comparison of Fossil SCM and Git philosophies and workflows
- **[Fossil with Git Combined](fossil_git/fossil_with_git_combined.md)**: Practical dual-VCS migration and coexistence strategy
- **[Project Planning](fossil_git/project_planning.md)**: Production architecture planning for Java + SQLite hybrid Git/Fossil platforms
- **[IaC for Hybrid Cloud](fossil_git/iac_for_project_hybrid_cloud.md)**: Infrastructure-as-code planning for hybrid local/cloud deployments
- **[IaC with Mobile Integration](fossil_git/iac_for_project_with_mobile_integration.md)**: Enterprise infrastructure blueprint including mobile integration

### Software Quality and Testing Docs
- **[Apache JMeter with AI CLI](sqa/apache_jmeter_with_ai_cli.md)**: Performance testing workflows using JMeter CLI and AI-assisted plan generation
- **[Cucumber + Selenium + JMeter for .NET](sqa/cucumber_selenium_jmeter_for_dotnet.md)**: Cross-tool testing architecture and responsibilities
- **[Cucumber + Selenium + JS + PyScript](sqa/cucumber_selenium_js_pyscript.md)**: Hybrid UI automation and scripting test strategy

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
├── migrate_to_quarkus.md     # Quarkus migration and AI-era Java notes
├── fossil_git/               # Fossil + Git + architecture planning docs
│   ├── comparing_fossil_vs_git.md
│   ├── fossil_with_git_combined.md
│   ├── project_planning.md
│   ├── iac_for_project_hybrid_cloud.md
│   └── iac_for_project_with_mobile_integration.md
├── sqa/                      # Software quality and test strategy docs
│   ├── apache_jmeter_with_ai_cli.md
│   ├── cucumber_selenium_jmeter_for_dotnet.md
│   └── cucumber_selenium_js_pyscript.md
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
