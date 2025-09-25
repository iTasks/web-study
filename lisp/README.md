# Lisp

## Purpose

This directory contains Lisp programming language study materials and sample applications. Lisp is one of the oldest high-level programming languages, known for its distinctive fully parenthesized prefix notation and powerful macro system.

## Contents

### Pure Language Samples
- `samples/`: Core Lisp language examples and applications
  - File I/O operations
  - Functional programming demonstrations
  - Symbolic computation examples

## Setup Instructions

### Prerequisites
- A Lisp implementation (SBCL, CLISP, or CCL recommended)
- Quicklisp for library management (optional)

### Installation
1. **Install SBCL (Steel Bank Common Lisp)**
   ```bash
   # On Ubuntu/Debian
   sudo apt install sbcl
   
   # On macOS with Homebrew
   brew install sbcl
   
   # Verify installation
   sbcl --version
   ```

2. **Install Quicklisp (Optional)**
   ```bash
   curl -O https://beta.quicklisp.org/quicklisp.lisp
   sbcl --load quicklisp.lisp
   # In SBCL REPL:
   # (quicklisp-quickstart:install)
   # (ql:add-to-init-file)
   ```

### Building and Running

#### For samples directory:
```bash
cd lisp/samples
sbcl --script read_file.lisp
# Or load in REPL
sbcl
# In REPL: (load "read_file.lisp")
```

## Usage

### Running Sample Applications
```bash
# Run Lisp script
sbcl --script samples/read_file.lisp

# Interactive REPL
sbcl
# Load file: (load "samples/read_file.lisp")
```

## Project Structure

```
lisp/
├── README.md                    # This file
└── samples/                     # Pure Lisp language examples
    └── read_file.lisp          # File reading example
```

## Key Learning Topics

- **Functional Programming**: Pure functions, recursion, higher-order functions
- **Symbolic Computation**: List processing, symbolic mathematics
- **Macros**: Code generation, meta-programming
- **REPL-Driven Development**: Interactive programming style
- **S-Expressions**: Homoiconicity, code as data

## Contribution Guidelines

1. **Code Style**: Follow Common Lisp conventions
2. **Documentation**: Include docstrings for functions
3. **Testing**: Use FiveAM or similar testing frameworks
4. **Packages**: Use proper package definitions

## Resources and References

- [Common Lisp HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Front/index.htm)
- [Practical Common Lisp](https://gigamonkeys.com/book/)
- [SBCL Manual](http://www.sbcl.org/manual/)
- [Quicklisp](https://www.quicklisp.org/)