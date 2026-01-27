# Go

[← Back to Main](../README.md) | [Web Study Repository](https://github.com/iTasks/web-study)

## Purpose

This directory contains Go programming language study materials, sample applications, and framework implementations. Go is an open-source programming language developed by Google that makes it easy to build simple, reliable, and efficient software.

## Contents

### Frameworks
- **Echo**: High performance, minimalist Go web framework
  - `echo/`: Echo web framework examples and utilities

### Pure Language Samples
- `samples/`: Core Go language examples and applications
  - REST API implementations
  - Wallet applications and blockchain-related code
  - Concurrent programming examples
  - Network programming utilities

## Setup Instructions

### Prerequisites
- Go 1.19 or higher
- Git for dependency management

### Installation
1. **Install Go**
   ```bash
   # On Ubuntu/Debian
   sudo rm -rf /usr/local/go
   wget https://golang.org/dl/go1.21.0.linux-amd64.tar.gz
   sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
   export PATH=$PATH:/usr/local/go/bin
   
   # On macOS with Homebrew
   brew install go
   
   # On Windows, download from golang.org
   
   # Verify installation
   go version
   ```

2. **Set up Go Environment**
   ```bash
   # Add to your shell profile (.bashrc, .zshrc, etc.)
   export GOPATH=$HOME/go
   export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
   
   # Create workspace directories
   mkdir -p $GOPATH/{bin,src,pkg}
   ```

3. **Install Dependencies**
   ```bash
   # For Echo framework
   go mod init your-project-name
   go get github.com/labstack/echo/v4
   
   # For common utilities
   go get github.com/gorilla/mux
   go get github.com/gin-gonic/gin
   ```

### Building and Running

#### For samples directory:
```bash
cd go/samples
go run main.go

# Or build executable
go build -o app main.go
./app
```

#### For Echo framework examples:
```bash
cd go/echo
go mod tidy
go run server.go
```

## Usage

### Running Sample Applications
Each sample in the `samples/` directory can be run independently:

```bash
# Run a specific Go file
go run samples/main.go

# Build and run executable
cd samples
go build -o wallet-app wallet/
./wallet-app
```

### Working with Echo Framework Examples
Navigate to the Echo project directory:

```bash
cd go/echo
go run main.go
# Server will start on http://localhost:8080
```

## Project Structure

```
go/
├── README.md                    # This file
├── samples/                     # Pure Go language examples
│   ├── main.go                 # Main application entry point
│   ├── simple-rest/            # Simple REST API implementation
│   │   ├── go.mod              # Go module definition
│   │   └── main.go             # REST server implementation
│   └── wallet/                 # Wallet application examples
│       ├── wallet-stream/      # Streaming wallet implementation
│       ├── wallet-bridge/      # Wallet bridge service
│       └── comm-wallet/        # Communication wallet
└── echo/                       # Echo framework examples
    └── [Echo applications]     # Echo-specific implementations
```

## Key Learning Topics

- **Core Go Concepts**: Goroutines, channels, interfaces, structs
- **Concurrency**: Goroutines, channels, select statements, sync package
- **Web Development**: HTTP servers, REST APIs, middleware, routing
- **Network Programming**: TCP/UDP sockets, HTTP clients, WebSocket
- **Testing**: Unit testing with testing package, benchmarking
- **Package Management**: Go modules, dependency management
- **Performance**: Profiling, optimization, memory management

## Contribution Guidelines

1. **Code Style**: Follow Go formatting standards (use `go fmt`)
2. **Documentation**: Include Go doc comments for exported functions and types
3. **Testing**: Write unit tests using Go's testing package
4. **Dependencies**: Use Go modules for dependency management
5. **Error Handling**: Follow Go error handling conventions

### Adding New Samples
1. Place pure Go examples in the `samples/` directory
2. Add framework-specific examples in appropriate subdirectories
3. Update this README with new content descriptions
4. Include go.mod file for module dependencies

### Code Quality Standards
- Use meaningful package, variable, and function names
- Follow Go naming conventions (exported vs unexported)
- Handle errors explicitly and appropriately
- Write clean, readable code with appropriate comments
- Use Go's built-in formatting tools (`go fmt`, `go vet`)

## Resources and References

- [Previous Go Lang Study Repository](https://github.com/smaruf/go-lang-study)
- [Official Go Documentation](https://golang.org/doc/)
- [Go Tour](https://tour.golang.org/)
- [Echo Framework Documentation](https://echo.labstack.com/)
- [Gin Web Framework](https://gin-gonic.com/)
- [Go by Example](https://gobyexample.com/)
- [Effective Go](https://golang.org/doc/effective_go.html)
- [Go Module Reference](https://golang.org/ref/mod)
- [Go Testing Package](https://golang.org/pkg/testing/)