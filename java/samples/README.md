# Java Samples

[← Back to Java](../README.md) | [Main README](../../README.md)

## Overview

This module focuses on the Java programming language and its related technologies. The goal is to provide sample applications and study materials for various Java frameworks and tools.

## Goals

- To explore and understand the Java programming language.
- To develop sample applications using different Java frameworks and tools.
- To provide educational resources for learning Java.

## Contents

### Frameworks and Libraries

1. **Spring Framework**
   - Comprehensive framework for enterprise Java development.
   - [Spring Documentation](https://spring.io/projects/spring-framework)

2. **JUnit**
   - Framework for unit testing in Java.
   - [JUnit Documentation](https://junit.org/junit5/)

3. **JaCoCo**
   - Code coverage library for Java.
   - [JaCoCo Documentation](https://www.jacoco.org/jacoco/)

4. **Cucumber**
   - Framework for behavior-driven development (BDD).
   - [Cucumber Documentation](https://cucumber.io/docs/guides/10-minute-tutorial/)

5. **Selenium**
   - Framework for automating web browser testing.
   - [Selenium Documentation](https://www.selenium.dev/documentation/en/)

6. **Gradle**
   - Build automation tool for Java projects.
   - [Gradle Documentation](https://docs.gradle.org/current/userguide/userguide.html)

### Algorithms and Data Structures

- **[Algorithms Package](algorithms/)**
  - **Tree Algorithms**: Balanced Binary Trees, AVL Trees, tree balancing
  - **Graph Algorithms**: BFS, DFS, shortest path, cycle detection
  - **Network Algorithms**: Dijkstra's algorithm, Minimum Spanning Tree, Floyd-Warshall
  - See [algorithms/README.md](algorithms/README.md) for detailed documentation

### Sample Applications

- **Spring Boot Application**
  - A sample application demonstrating the use of Spring Boot for building RESTful web services.
  - [Spring Boot Documentation](https://spring.io/projects/spring-boot)

- **JUnit Testing Example**
  - A sample project with unit tests written using JUnit.
  - [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)

- **Cucumber with Selenium**
  - A sample project demonstrating BDD testing with Cucumber and Selenium.
  - [Cucumber and Selenium Integration](https://cucumber.io/docs/guides/browser-automation/)

### Version-Specific Features

- **Java11Features.java**
  - Demonstrates Java 11 features including var in lambda parameters, HTTP Client, new String methods, and enhanced file operations.
  - Key features: `var` in lambdas, `HttpClient`, `String.isBlank()`, `String.lines()`, `String.strip()`, `String.repeat()`, `Files.readString()`, `Files.writeString()`

- **Java18Features.java**
  - Demonstrates Java 18 features including UTF-8 by default, Simple Web Server, and code snippets in JavaDoc.
  - Key features: UTF-8 default charset, `jwebserver` command-line tool, `@snippet` JavaDoc tag, pattern matching for switch (preview)

- **Java21Features.java**
  - Demonstrates Java 21 LTS features including Virtual Threads, pattern matching for switch, record patterns, and sequenced collections.
  - Key features: Virtual threads (`Thread.ofVirtual()`), pattern matching with guards, record patterns, `SequencedCollection` interface

- **Java25Features.java**
  - Demonstrates expected Java 25 features including primitive patterns, stream gatherers, and enhanced pattern matching.
  - Note: Java 25 features may be in preview or subject to change. Release expected in March 2025.


## Getting Started

To get started with the Java module, follow these steps:

1. **Clone the Repository**
   ```bash
   git clone https://github.com/iTasks/web-study.git
   cd web-study/java
   ```

2. **Set Up the Environment**
   - Ensure you have Java installed. You can download it from [here](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html).
   - Install Gradle for build automation. Instructions can be found [here](https://gradle.org/install/).

3. **Build and Run Sample Applications**
   - Navigate to the sample application directory.
   - Use Gradle to build and run the application.
     ```bash
     gradle build
     gradle run
     ```

## Resources

- [Java Documentation](https://docs.oracle.com/en/java/)
- [Spring Framework Documentation](https://spring.io/projects/spring-framework)
- [JUnit Documentation](https://junit.org/junit5/)
- [JaCoCo Documentation](https://www.jacoco.org/jacoco/)
- [Cucumber Documentation](https://cucumber.io/docs/guides/10-minute-tutorial/)
- [Selenium Documentation](https://www.selenium.dev/documentation/en/)
- [Gradle Documentation](https://docs.gradle.org/current/userguide/userguide.html)

## Structure

```
src/java
├── Application.java
├── Combination.java
├── FixSetCombinations.java
├── FutureExample.java
├── ImageFilter.java
├── Java11Features.java
├── Java18Features.java
├── Java21Features.java
├── Java25Features.java
├── LineSplit.java
├── MatrixManipulations.java
├── MyCallable.java
├── PayPalIpnController.java
├── PingPongGame.java
├── Pipe.java
├── README.md
├── Ranking.java
├── RestClient.java
├── RubiksCube.jave
├── SearchingAlgorithms.java
├── SetManipulations.java
├── SharedResources.java
├── SortingAlgorithms.java
├── Spliter.java
├── StringManipulations.java
├── WordCount.java
├── algorithms                        # NEW: Advanced algorithms
│   ├── README.md                    # Algorithms documentation
│   ├── tree/                        # Tree algorithms
│   │   ├── BALANCED_BINARY_TREE.md  # Comprehensive balanced tree guide
│   │   ├── TreeNode.java            # Basic tree node structure
│   │   ├── BalancedBinaryTree.java  # Check if tree is balanced
│   │   └── AVLTree.java             # Self-balancing AVL tree
│   ├── graph/                       # Graph algorithms
│   │   └── GraphAlgorithms.java     # BFS, DFS, cycle detection
│   └── network/                     # Network algorithms
│       └── NetworkAlgorithms.java   # Dijkstra, MST, Floyd-Warshall
├── grid_check.java
├── pom.xml
├── simple_grid_sum.java
├── spark-hadoop
│   ├── HadoopSparkApplication.java
│   ├── README.md
│   ├── generator.py
│   ├── pom.xml
└── test
```
