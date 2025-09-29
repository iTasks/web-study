# Rust

## Purpose

This directory contains Rust programming language study materials and sample applications. Rust is a systems programming language that runs blazingly fast, prevents segfaults, and guarantees thread safety.

## Contents

### Pure Language Samples
- `samples/`: Core Rust language examples and applications
  - **Web Development**: HTTP server implementations with Hyper
  - **Threading**: Multi-threaded programming with shared state and message passing
  - **Webhooks**: Comprehensive webhook server handling GitHub, Slack, and generic webhooks
  - **Async/Coroutines**: Advanced async programming with tokio, custom futures, and concurrent execution
  - **System Programming**: Low-level system interactions and performance optimization

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

# Run threading examples
cargo run --bin threading_example

# Run webhook server
cargo run --bin webhook_server

# Run async/coroutines examples
cargo run --bin async_coroutines

# Build optimized version for production
cargo build --release

# Run specific optimized binary
cargo run --release --bin webhook_server
```

## Project Structure

```
rust/
├── README.md                      # This file
└── samples/                       # Pure Rust language examples
    ├── Cargo.toml                # Project configuration and dependencies
    ├── rust_http_server.rs       # Basic HTTP server with Hyper
    ├── threading_example.rs      # Multi-threading patterns and shared state
    ├── webhook_server.rs         # Comprehensive webhook handling server
    └── async_coroutines.rs       # Async programming and coroutines
```

## Key Learning Topics

- **Core Rust Concepts**: Ownership, borrowing, lifetimes, pattern matching, error handling
- **Memory Safety**: Zero-cost abstractions, no garbage collector, safe concurrency
- **Threading & Concurrency**: Multi-threading, shared state with Mutex/Arc, message passing
- **Async Programming**: async/await, tokio runtime, custom futures, concurrent execution
- **Web Development**: HTTP servers, webhook handling, REST APIs with Hyper
- **Systems Programming**: Low-level control with high-level ergonomics, performance optimization
- **Network Programming**: TCP/HTTP servers, client implementations, protocol handling

## Contribution Guidelines

1. **Code Style**: Use `cargo fmt` for formatting
2. **Documentation**: Include doc comments for public APIs
3. **Testing**: Write tests using Rust's built-in testing framework
4. **Dependencies**: Use Cargo.toml for dependency management

## Resources and References

### Official Documentation
- [The Rust Programming Language Book](https://doc.rust-lang.org/book/) - Comprehensive Rust guide
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/) - Learn by example
- [Cargo Documentation](https://doc.rust-lang.org/cargo/) - Package manager and build tool
- [Standard Library Documentation](https://doc.rust-lang.org/std/) - Core library reference

### Async Programming
- [Tokio Tutorial](https://tokio.rs/tokio/tutorial) - Async runtime for Rust
- [Async Book](https://rust-lang.github.io/async-book/) - Official async programming guide
- [Futures Crate](https://docs.rs/futures/) - Future and stream utilities

### Web Development
- [Hyper Documentation](https://hyper.rs/) - Fast HTTP implementation
- [Serde Guide](https://serde.rs/) - Serialization framework
- [Axum Framework](https://github.com/tokio-rs/axum) - Modern web framework

### Community Resources
- [Crates.io](https://crates.io/) - Package registry
- [This Week in Rust](https://this-week-in-rust.org/) - Weekly newsletter
- [Rust Users Forum](https://users.rust-lang.org/) - Community discussions
- [Awesome Rust](https://github.com/rust-unofficial/awesome-rust) - Curated resources