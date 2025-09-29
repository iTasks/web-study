# Web Study

## Goals

This repository aims to study and develop sample applications for various web-based technologies. It serves as a comprehensive resource to explore different programming languages, frameworks, databases, tools, and features essential for web development.

The repository is organized by programming language first, then by framework, to provide a scalable and intuitive structure for learning and development.

## Repository Structure

This repository follows a language-first organization structure:

```
web-study/
├── java/                    # Java programming language
│   ├── spring/             # Spring framework examples
│   └── samples/            # Pure Java examples
├── python/                 # Python programming language
│   ├── flask/              # Flask framework examples
│   └── samples/            # Pure Python examples
├── javascript/             # JavaScript/TypeScript
│   ├── nodejs/             # Node.js framework examples
│   ├── react/              # React/React Native examples
│   └── samples/            # Pure JavaScript examples
├── go/                     # Go programming language
│   ├── echo/               # Echo framework examples
│   └── samples/            # Pure Go examples
├── csharp/                 # C# programming language
│   └── samples/            # Pure C# examples
├── ruby/                   # Ruby programming language
│   └── samples/            # Pure Ruby examples
├── rust/                   # Rust programming language
│   └── samples/            # Pure Rust examples
├── scala/                  # Scala programming language
│   └── samples/            # Pure Scala examples
├── groovy/                 # Groovy programming language
│   └── samples/            # Pure Groovy examples
├── lisp/                   # Lisp programming language
│   └── samples/            # Pure Lisp examples
├── teavm/                  # TeaVM (Java-to-JavaScript)
│   └── samples/            # TeaVM examples
├── zig/                    # Zig programming language
│   └── samples/            # Pure Zig examples
├── ballerina/              # Ballerina programming language
│   └── samples/            # Pure Ballerina examples
├── r/                      # R programming language
│   └── samples/            # Pure R examples
└── src/                    # Legacy structure (cloud services, tools)
```

## Programming Languages

### [Java](java/)
Enterprise-grade programming language with comprehensive framework support.
- **Frameworks**: Spring (Spring Boot, Spark, Beam)
- **Key Topics**: Enterprise applications, big data processing, microservices

### [Python](python/)
High-level, interpreted language known for simplicity and extensive libraries.
- **Frameworks**: Flask, Django
- **Key Topics**: Web development, data science, automation, serverless

### [JavaScript](javascript/)
Core web technology for client and server-side development.
- **Frameworks**: Node.js, React/React Native
- **Key Topics**: Web applications, mobile apps, server-side development

### [Go](go/)
Modern systems programming language with excellent concurrency support.
- **Frameworks**: Echo
- **Key Topics**: Web services, microservices, concurrent programming

### [C#](csharp/)
Object-oriented programming language for the .NET platform.
- **Key Topics**: Enterprise applications, financial systems, FIX protocol

### [Ruby](ruby/)
Dynamic programming language focused on simplicity and productivity.
- **Key Topics**: Web development, automation, authentication systems

### [Rust](rust/)
Systems programming language focused on safety and performance.
- **Key Topics**: Threading, async programming, webhooks, web servers, memory safety

### [Scala](scala/)
JVM language combining object-oriented and functional programming.
- **Key Topics**: Big data processing, functional programming, JVM integration

### [Groovy](groovy/)
Dynamic language for the Java platform with enhanced productivity features.
- **Key Topics**: Scripting, DSLs, Java integration

### [Lisp](lisp/)
Functional programming language known for symbolic computation.
- **Key Topics**: Symbolic computation, AI, functional programming

### [TeaVM](teavm/)
Java-to-JavaScript/WebAssembly transpiler.
- **Key Topics**: Java in browsers, WebAssembly, cross-platform development

### [Zig](zig/)
Modern systems programming language focusing on performance, safety, and maintainability.
- **Key Topics**: Systems programming, comptime, C interoperability, memory safety

### [Ballerina](ballerina/)
Cloud-native programming language specialized for integration and networked services.
- **Key Topics**: Web services, webhooks, concurrent workers, API integration, data transformation

### [R](r/)
Programming language and environment for statistical computing and data analysis.
- **Key Topics**: Web applications with Shiny, parallel processing, webhooks with Plumber, data analysis pipelines

### [Ballerina](ballerina/)
Cloud-native programming language specialized for integration and networked services.
- **Key Topics**: Web services, webhooks, concurrent workers, API integration, data transformation

### [R](r/)
Programming language and environment for statistical computing and data analysis.
- **Key Topics**: Web applications with Shiny, parallel processing, webhooks with Plumber, data analysis pipelines

## Cloud Services and Tools

The `src/` directory contains cloud services and infrastructure tools:
- **AWS**: Step Functions, Lambda, S3, CDK
- **Google Cloud**: Cloud Functions, App Engine, Kubernetes
- **Infrastructure**: Kubernetes, Docker, CI/CD

## How to Use This Repository

1. **Choose a Language**: Navigate to the language directory you want to study
2. **Explore Frameworks**: Check framework-specific subdirectories for advanced examples  
3. **Start with Samples**: Begin with the `samples/` directory for pure language examples
4. **Read Documentation**: Each directory contains comprehensive README.md files
5. **Run Examples**: Follow setup instructions in each directory's README

## Contribution Guidelines

1. **Language-First Organization**: Place content in appropriate language directories
2. **Framework Separation**: Keep framework examples in dedicated subdirectories
3. **Comprehensive Documentation**: Include README.md files with setup and usage instructions
4. **Working Examples**: Ensure all code examples compile and run successfully
5. **Consistent Structure**: Follow the established directory structure

### Adding New Content

1. **New Language**: Create new top-level directory with `samples/` subdirectory
2. **New Framework**: Add framework subdirectory under appropriate language
3. **New Examples**: Place in relevant `samples/` or framework directory
4. **Documentation**: Update README.md files to reflect new content

## Resources and References

- [Web Development Best Practices](https://developer.mozilla.org/en-US/docs/Learn)
- [Cloud Native Computing Foundation](https://www.cncf.io/)
- [Modern Web Development Frameworks](https://jamstack.org/)
- [Microservices Architecture](https://microservices.io/)

Feel free to explore each language and framework, and contribute to the repository by adding more sample applications and documentation.
