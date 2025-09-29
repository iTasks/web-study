# Ballerina

## Purpose

This directory contains Ballerina programming language study materials and sample applications. Ballerina is a cloud-native programming language that specializes in integration and is designed to make it easier to write programs that integrate with networked services and APIs.

## Contents

### Pure Language Samples
- `samples/`: Core Ballerina language examples and applications
  - Web service implementations
  - Webhook handling examples
  - Concurrent programming with workers
  - API integration utilities
  - Data processing and transformation

## Setup Instructions

### Prerequisites
- Ballerina 2201.8.0 or higher
- Java 11 or higher (required by Ballerina)

### Installation
1. **Install Ballerina**
   ```bash
   # Download from official website
   curl -L https://dist.ballerina.io/downloads/2201.8.0/ballerina-2201.8.0-swan-lake-linux-x64.deb -o ballerina.deb
   sudo dpkg -i ballerina.deb
   
   # Or using package managers
   # Ubuntu/Debian
   curl -fsSL https://dist.ballerina.io/downloads/2201.8.0/ballerina-2201.8.0-swan-lake-linux-x64.deb -o ballerina.deb
   sudo dpkg -i ballerina.deb
   
   # Verify installation
   bal version
   ```

2. **Alternative: Using Docker**
   ```bash
   docker run -it ballerina/ballerina:latest
   ```

### Building and Running

#### For samples directory:
```bash
cd ballerina/samples

# Compile and run a specific service
bal run web_service.bal

# Build to JAR (for deployment)
bal build web_service.bal
```

## Usage

### Running Sample Applications
```bash
# Run web service example
cd ballerina/samples
bal run web_service.bal

# Run webhook handler
bal run webhook_handler.bal

# Run concurrent worker example
bal run concurrent_workers.bal

# Run API client example
bal run api_client.bal
```

## Project Structure

```
ballerina/
├── README.md                    # This file
└── samples/                     # Pure Ballerina language examples
    ├── web_service.bal         # HTTP web service implementation
    ├── webhook_handler.bal     # Webhook handling example
    ├── concurrent_workers.bal  # Worker-based concurrency
    ├── api_client.bal          # REST API client
    └── data_transformer.bal    # Data processing and transformation
```

## Key Learning Topics

- **Integration**: Native support for HTTP, GraphQL, gRPC, WebSockets
- **Concurrency**: Worker-based concurrent programming model
- **Data Handling**: Built-in support for JSON, XML, and structured data
- **Network Programming**: First-class support for networked services
- **Observability**: Built-in observability features (metrics, tracing, logging)
- **Cloud Native**: Designed for microservices and cloud deployments

## Contribution Guidelines

1. **Code Style**: Use `bal format` for code formatting
2. **Documentation**: Include comprehensive doc comments
3. **Testing**: Write tests using Ballerina's testing framework
4. **Error Handling**: Use Ballerina's error handling mechanisms
5. **Examples**: Provide clear, runnable examples with sample data

### Adding New Samples
1. Place pure Ballerina examples in the `samples/` directory
2. Follow Ballerina naming conventions (snake_case for files)
3. Update this README with new content descriptions
4. Ensure all code compiles and runs successfully

### Code Quality Standards
- Use meaningful service and function names
- Include proper error handling
- Write self-documenting code with clear comments
- Follow Ballerina best practices for concurrent programming

## Resources and References

- [Ballerina Language Documentation](https://ballerina.io/learn/)
- [Ballerina by Example](https://ballerina.io/learn/by-example/)
- [Ballerina API Documentation](https://lib.ballerina.io/)
- [Ballerina Central](https://central.ballerina.io/)
- [Ballerina GitHub Repository](https://github.com/ballerina-platform/ballerina-lang)