# Groovy Samples

[← Back to Groovy](../README.md) | [Main README](../../README.md)

This directory contains comprehensive Groovy programming examples demonstrating the language's key features and capabilities.

## Available Samples

### 1. Gapp.groovy
A simple "Hello World" program to get started with Groovy.

**Topics**: Basic syntax, println

**Run**:
```bash
groovy Gapp.groovy
```

### 2. StringManipulations.groovy
Comprehensive string operations and algorithms.

**Topics**: String reversal, palindrome checking, compression, anagrams, permutations, word frequency, title case

**Run**:
```bash
groovy StringManipulations.groovy
```

### 3. CollectionOperations.groovy
Demonstrates Groovy's powerful collection APIs.

**Topics**: Lists, maps, sets, ranges, filtering, mapping, grouping, zipping, partitioning

**Run**:
```bash
groovy CollectionOperations.groovy
```

### 4. ClosuresAndDSL.groovy
Showcases closures and DSL (Domain-Specific Language) creation.

**Topics**: Closures, higher-order functions, memoization, currying, DSL builders, HTML/config DSLs

**Run**:
```bash
groovy ClosuresAndDSL.groovy
```

### 5. FileOperations.groovy
File I/O operations and directory management.

**Topics**: Reading, writing, appending, copying, deleting files, directory traversal, file metadata

**Run**:
```bash
groovy FileOperations.groovy
```

### 6. JsonXmlProcessing.groovy
JSON and XML data processing.

**Topics**: JSON creation/parsing, XML creation/parsing, data transformation, format conversion

**Run**:
```bash
groovy JsonXmlProcessing.groovy
```

### 7. DatabaseConnection.groovy
Database connectivity and SQL operations using Groovy SQL.

**Topics**: CRUD operations, transactions, joins, aggregations, batch operations, prepared statements

**Run**:
```bash
groovy DatabaseConnection.groovy
```

### 8. RestClient.groovy
HTTP client for consuming REST APIs.

**Topics**: GET/POST/PUT/DELETE requests, JSON handling, custom headers, query parameters, error handling

**Note**: External API calls may be blocked in restricted environments. The sample includes code examples and documentation.

**Run**:
```bash
groovy RestClient.groovy
```

## Running All Samples

You can run all samples at once using:

```bash
for file in *.groovy; do 
    echo "===== Running $file ====="
    groovy "$file"
    echo ""
done
```

Or using Gradle from the parent directory:

```bash
cd ..
gradle runAllSamples
```

## Key Groovy Features Demonstrated

### Dynamic Language Features
- Optional typing with `def`
- Dynamic method/property resolution
- Duck typing

### Collections
- Enhanced list, map, and set operations
- Powerful collection methods (`findAll`, `collect`, `each`, etc.)
- Range support

### Closures
- First-class functions
- Closure delegation and scope
- Higher-order functions

### String Features
- GStrings with interpolation (`"Hello, ${name}"`)
- Multiline strings
- String methods

### Object-Oriented Programming
- Classes and traits
- Properties with automatic getters/setters
- Operator overloading

### Integration
- Seamless Java interop
- SQL database access
- JSON/XML processing
- HTTP client capabilities

## Learning Path

1. Start with **Gapp.groovy** for basic syntax
2. Explore **StringManipulations.groovy** for string operations
3. Learn **CollectionOperations.groovy** for working with data structures
4. Study **ClosuresAndDSL.groovy** for functional programming concepts
5. Practice **FileOperations.groovy** for I/O operations
6. Master **JsonXmlProcessing.groovy** for data processing
7. Understand **DatabaseConnection.groovy** for database interactions
8. Complete with **RestClient.groovy** for API consumption

## Tips

- Groovy code is often more concise than Java
- Use `def` for local variables unless type is important
- Leverage GStrings for string interpolation
- Take advantage of collection methods for cleaner code
- Closures are powerful - use them for callbacks and DSLs

## Additional Resources

- [Groovy Documentation](https://groovy-lang.org/documentation.html)
- [Groovy API Docs](https://docs.groovy-lang.org/latest/html/api/)
- [Groovy Style Guide](https://groovy-lang.org/style-guide.html)
