# Spring Framework

[← Back to Java](../README.md) | [Main README](../../README.md)

## Purpose

This directory contains Spring Framework examples and implementations. Spring is a comprehensive programming and configuration model for modern Java-based enterprise applications, providing support for dependency injection, aspect-oriented programming, and various enterprise integration patterns.

## Contents

- `spark-hadoop/`: Apache Spark integration with Hadoop for big data processing
- `spark-beam/`: Apache Beam data processing pipelines with Spring Boot

## Setup Instructions

### Prerequisites
- Java 11 or higher
- Maven 3.6+
- Apache Spark (for spark examples)
- Hadoop (for Hadoop integration examples)

### Installation
```bash
# Install dependencies
cd java/spring
mvn clean install

# For Spark examples
cd spark-hadoop
mvn clean install

cd ../spark-beam
mvn clean install
```

### Running Applications

#### Spark-Hadoop Example
```bash
cd java/spring/spark-hadoop
mvn exec:java -Dexec.mainClass="HadoopSparkApplication"
```

#### Spark-Beam Example
```bash
cd java/spring/spark-beam
mvn spring-boot:run
```

## Key Features

- **Dependency Injection**: IoC container for managing object dependencies
- **Data Processing**: Integration with Apache Spark and Apache Beam
- **Big Data**: Hadoop ecosystem integration
- **Enterprise Integration**: Comprehensive enterprise application support

## Learning Topics

- Spring Boot application structure
- Apache Spark integration with Spring
- Apache Beam pipeline development
- Hadoop filesystem operations
- Enterprise data processing patterns

## Resources

- [Spring Framework Documentation](https://spring.io/projects/spring-framework)
- [Apache Spark Documentation](https://spark.apache.org/documentation.html)
- [Apache Beam Documentation](https://beam.apache.org/documentation/)
- [Hadoop Documentation](https://hadoop.apache.org/docs/)