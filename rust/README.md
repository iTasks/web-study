# Rust

## Purpose

This directory contains Rust programming language study materials and sample applications. Rust is a systems programming language that runs blazingly fast, prevents segfaults, and guarantees thread safety.

## Contents

### Pure Language Samples
- `samples/`: Core Rust language examples and applications
  - HTTP server implementations
  - System programming examples
  - Concurrent programming demonstrations
  - Network programming utilities

## Setup Instructions

### Prerequisites
- Rust 1.70 or higher (managed via rustup)
- Cargo (Rust's package manager, included with Rust)

### Installation
1. **Install Rust**
   ```bash
   # Install rustup (recommended way)
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source ~/.cargo/env
   
   # Verify installation
   rustc --version
   cargo --version
   ```

2. **Update Rust (if already installed)**
   ```bash
   rustup update
   ```

### Building and Running

#### For samples directory:
```bash
cd rust/samples
cargo build
cargo run
```

## Usage

### Running Sample Applications
```bash
# Run HTTP server example
cd rust/samples
cargo run --bin rust_http_server

# Build optimized version
cargo build --release
```

## Project Structure

```
rust/
├── README.md                    # This file
└── samples/                     # Pure Rust language examples
    ├── Cargo.toml              # Project configuration and dependencies
    └── rust_http_server.rs     # HTTP server implementation
```

## Key Learning Topics

- **Core Rust Concepts**: Ownership, borrowing, lifetimes, pattern matching
- **Memory Safety**: Zero-cost abstractions, no garbage collector
- **Concurrency**: Fearless concurrency, async/await, channels
- **Systems Programming**: Low-level control with high-level ergonomics
- **Web Development**: HTTP servers, async web frameworks

## Contribution Guidelines

1. **Code Style**: Use `cargo fmt` for formatting
2. **Documentation**: Include doc comments for public APIs
3. **Testing**: Write tests using Rust's built-in testing framework
4. **Dependencies**: Use Cargo.toml for dependency management

## Resources and References

- [The Rust Programming Language Book](https://doc.rust-lang.org/book/)
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [Cargo Documentation](https://doc.rust-lang.org/cargo/)
- [Crates.io](https://crates.io/)