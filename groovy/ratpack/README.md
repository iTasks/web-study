# Ratpack Web Framework Examples

This directory contains Groovy web application examples using the Ratpack framework.

## What is Ratpack?

Ratpack is a modern, lightweight web framework for the JVM (Java Virtual Machine) that is designed for building high-performance, reactive web applications. It's particularly well-suited for building REST APIs and microservices.

## Features

- **Reactive and Non-blocking**: Built on Netty for high performance
- **Lightweight**: Minimal overhead and fast startup times
- **Groovy DSL**: Clean and expressive syntax
- **HTTP/2 Support**: Modern protocol support
- **Built-in JSON Support**: Easy JSON parsing and rendering
- **Promise-based**: Asynchronous programming with promises

## Prerequisites

- Java 8 or higher (JDK)
- Groovy 2.4 or higher

## Running the Application

### Using Groovy directly (with Grape):

```bash
groovy RatpackApp.groovy
```

The Grape annotations will automatically download required dependencies on first run.

### Using Gradle:

```bash
gradle run
```

## API Endpoints

Once the server is running (default port 5050), you can access:

- **GET /** - Welcome page with API documentation
- **GET /api/health** - Health check endpoint
- **GET /api/users** - Get all users
- **GET /api/users/:id** - Get user by ID
- **POST /api/users** - Create a new user
- **PUT /api/users/:id** - Update user
- **DELETE /api/users/:id** - Delete user

## Example Requests

### Get all users
```bash
curl http://localhost:5050/api/users
```

### Get user by ID
```bash
curl http://localhost:5050/api/users/1
```

### Create a new user
```bash
curl -X POST http://localhost:5050/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com","age":30}'
```

### Update a user
```bash
curl -X PUT http://localhost:5050/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice Updated","age":29}'
```

### Delete a user
```bash
curl -X DELETE http://localhost:5050/api/users/3
```

### Health check
```bash
curl http://localhost:5050/api/health
```

## Project Structure

```
ratpack/
├── README.md           # This file
└── RatpackApp.groovy   # Main application file
```

## Key Concepts

### Handlers
Ratpack uses handlers to process requests. Handlers are chained together to form a request processing pipeline.

### Context
The context object provides access to request and response objects, as well as utilities for parsing and rendering.

### JSON Support
Ratpack has built-in support for JSON through Jackson. Use `json()` to render JSON responses and `parse(Map)` to parse JSON requests.

### Asynchronous Processing
Ratpack uses promises for asynchronous processing. The `then` method is used to handle the result of asynchronous operations.

## Advantages of Ratpack

1. **Performance**: Built on Netty, one of the fastest network frameworks
2. **Simplicity**: Clean DSL makes code easy to read and write
3. **Scalability**: Non-blocking architecture handles many concurrent connections
4. **Modern**: Supports latest web standards and practices
5. **Testing**: Easy to test with built-in testing support

## Resources

- [Ratpack Official Documentation](https://ratpack.io/)
- [Ratpack GitHub](https://github.com/ratpack/ratpack)
- [Groovy Documentation](https://groovy-lang.org/documentation.html)

## Next Steps

- Add database integration (e.g., PostgreSQL, MongoDB)
- Implement authentication and authorization
- Add request validation
- Implement caching
- Add metrics and monitoring
- Create integration tests
