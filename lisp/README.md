# Lisp

## Purpose

This directory contains a **production-ready, comprehensive learning resource** for Common Lisp, from zero to expert level. Lisp is one of the oldest and most powerful high-level programming languages, known for its distinctive fully parenthesized prefix notation, powerful macro system, and unparalleled flexibility.

## 🎯 Learning Path Overview

This repository provides a **structured curriculum** that takes you from complete beginner to expert Lisp programmer through four progressive levels:

| Level | Focus | Time | Skills |
|-------|-------|------|--------|
| **[01-basics/](01-basics/)** | Fundamentals | 2 weeks | Syntax, data types, control flow, lists |
| **[02-intermediate/](02-intermediate/)** | Core Skills | 3 weeks | Functions, recursion, I/O, data structures |
| **[03-advanced/](03-advanced/)** | Advanced Features | 4 weeks | Macros, CLOS, packages, optimization |
| **[04-expert/](04-expert/)** | Real-World Apps | 3 weeks | Web servers, DSLs, interpreters, patterns |

📖 **[See Complete Learning Path Guide →](LEARNING_PATH.md)**

## Contents

### Structured Learning Levels

#### 📘 Level 1: Basics (`01-basics/`)
Foundation concepts for Common Lisp:
- Hello World and basic I/O
- Data types (numbers, strings, symbols, lists)
- Variables and constants
- Control flow structures
- List operations

[View Level 1 Details →](01-basics/README.md)

#### 📗 Level 2: Intermediate (`02-intermediate/`)
Building practical programming skills:
- Function definition and usage
- Recursion (basic and tail-recursive)
- Higher-order functions (map, reduce, filter)
- File I/O operations
- Data structures (alists, plists, hash tables, structures)

[View Level 2 Details →](02-intermediate/README.md)

#### 📙 Level 3: Advanced (`03-advanced/`)
Mastering Lisp's unique features:
- Macros and meta-programming
- CLOS (Common Lisp Object System)
- Package system and code organization
- Performance optimization techniques
- Symbolic computation

[View Level 3 Details →](03-advanced/README.md)

#### 📕 Level 4: Expert (`04-expert/`)
Real-world applications and advanced systems:
- Web server implementation
- Domain-Specific Languages (DSLs)
- Calculator with expression parser
- Advanced pattern matching
- Interpreter/compiler construction

[View Level 4 Details →](04-expert/README.md)

### Legacy Samples
- `samples/`: Original core Lisp language examples
  - File I/O operations (legacy format)
  - Additional reference implementations

## 🚀 Quick Start

### Prerequisites
- **Lisp Implementation**: SBCL recommended (fastest, best tooling)
- **Editor**: Emacs + SLIME, VS Code + Alive, or Vim + Slimv
- **Optional**: Quicklisp for library management

### Installation

#### 1. Install SBCL (Steel Bank Common Lisp)
```bash
# Ubuntu/Debian
sudo apt install sbcl

# macOS (Homebrew)
brew install sbcl

# Fedora/RHEL
sudo dnf install sbcl

# Verify installation
sbcl --version
```

#### 2. Install Quicklisp (Package Manager)
```bash
# Download Quicklisp installer
curl -O https://beta.quicklisp.org/quicklisp.lisp

# Verify download (optional but recommended)
# Check SHA256: curl https://beta.quicklisp.org/quicklisp.lisp.sha256

# Install Quicklisp
sbcl --load quicklisp.lisp --eval "(quicklisp-quickstart:install)" --quit
```

**Note**: For production systems, consider using your system's package manager if available:
```bash
# Ubuntu/Debian (if available)
sudo apt install cl-quicklisp
```

In your SBCL REPL:
```lisp
(ql:add-to-init-file)  ; Add Quicklisp to startup
```

#### 3. Set Up Your Editor

**Option A: Emacs + SLIME** (Recommended)
```bash
# Install Emacs
sudo apt install emacs  # Ubuntu/Debian
brew install emacs      # macOS

# Add to ~/.emacs or ~/.emacs.d/init.el:
(setq inferior-lisp-program "sbcl")
(load (expand-file-name "~/quicklisp/slime-helper.el"))
(slime-setup '(slime-fancy slime-company))
```

**Option B: VS Code + Alive**
1. Install VS Code
2. Install "Alive" extension
3. Configure SBCL path in settings

### Running Examples

#### Start with Level 1 Basics:
```bash
cd lisp/01-basics

# Run any example:
sbcl --script 01-hello-world.lisp
sbcl --script 02-data-types.lisp

# Or use interactive REPL:
sbcl
* (load "01-hello-world.lisp")
```

#### Interactive Development (REPL):
```bash
sbcl
* (format t "Hello, Lisp!~%")
* (+ 2 3)
* (defun greet (name) (format t "Hello, ~a!~%" name))
* (greet "World")
```

### Learning Path

1. **Start Here**: Read [LEARNING_PATH.md](LEARNING_PATH.md) for complete curriculum
2. **Level 1**: Complete all files in `01-basics/` (2 weeks)
3. **Level 2**: Progress to `02-intermediate/` (3 weeks)
4. **Level 3**: Master `03-advanced/` (4 weeks)
5. **Level 4**: Build real apps in `04-expert/` (3 weeks)

**Estimated Total Time**: 8-12 weeks at 10-15 hours per week

## 📁 Project Structure

```
lisp/
├── README.md                    # This file - Start here!
├── LEARNING_PATH.md            # Complete curriculum and study guide
│
├── 01-basics/                  # Level 1: Fundamentals (2 weeks)
│   ├── README.md              # Level overview and exercises
│   ├── 01-hello-world.lisp   # Your first program
│   ├── 02-data-types.lisp    # Numbers, strings, symbols, lists
│   ├── 03-variables.lisp     # Variables and constants
│   ├── 04-control-flow.lisp  # if, cond, case, loops
│   └── 05-list-operations.lisp # car, cdr, cons, etc.
│
├── 02-intermediate/            # Level 2: Core Skills (3 weeks)
│   ├── README.md              # Level overview and exercises
│   ├── 01-functions.lisp     # Function definition and usage
│   ├── 02-recursion.lisp     # Recursive programming
│   ├── 03-higher-order-functions.lisp # map, reduce, filter
│   ├── 04-file-io.lisp       # File operations
│   └── 05-data-structures.lisp # Hash tables, structs, etc.
│
├── 03-advanced/                # Level 3: Advanced Features (4 weeks)
│   ├── README.md              # Level overview and exercises
│   ├── 01-macros.lisp        # Meta-programming with macros
│   ├── 02-clos.lisp          # Object-oriented programming
│   ├── 03-packages.lisp      # Code organization
│   ├── 04-optimization.lisp  # Performance tuning
│   └── 05-symbolic-computation.lisp # Symbolic processing
│
├── 04-expert/                  # Level 4: Real-World Apps (3 weeks)
│   ├── README.md              # Level overview and projects
│   ├── 01-web-server.lisp    # HTTP server implementation
│   ├── 02-dsl-builder.lisp   # Domain-specific languages
│   ├── 03-calculator-app.lisp # Complete calculator with parser
│   ├── 04-pattern-matcher.lisp # Advanced pattern matching
│   └── 05-interpreter.lisp   # Meta-circular evaluator
│
├── samples/                    # Legacy examples
│   └── read_file.lisp         # Original file I/O example
│
└── tests/                      # Test examples (to be added)
```

## 🎓 Key Learning Topics

### Core Concepts
- **S-Expressions**: Code as data, homoiconicity
- **Functional Programming**: Pure functions, recursion, higher-order functions
- **REPL-Driven Development**: Interactive, incremental programming
- **List Processing**: The foundation of Lisp

### Advanced Features
- **Macros**: Code generation, DSL creation, meta-programming
- **CLOS**: Multiple inheritance, multi-methods, MOP
- **Symbolic Computation**: Manipulating and transforming code
- **Condition System**: Advanced error handling

### Real-World Skills
- **Web Development**: Building HTTP servers and web applications
- **Language Implementation**: Parsers, interpreters, compilers
- **Pattern Matching**: Advanced code analysis and transformation
- **Performance Optimization**: Type declarations, compilation, profiling

## ✨ Why Learn Common Lisp?

1. **Most Powerful Language Features**: Macros, CLOS, conditions, packages
2. **Interactive Development**: Instant feedback with REPL
3. **Production-Ready**: Used in CAD, AI, financial systems
4. **Thought-Provoking**: Changes how you think about programming
5. **Timeless**: Concepts from 1958 still relevant today

## 🎯 Learning Objectives by Level

### After Level 1: Basics
✓ Write simple Lisp programs  
✓ Understand lists and their operations  
✓ Use basic control structures  
✓ Work with the REPL effectively

### After Level 2: Intermediate
✓ Define and use functions  
✓ Write recursive algorithms  
✓ Apply higher-order functions  
✓ Choose appropriate data structures  
✓ Perform file I/O operations

### After Level 3: Advanced
✓ Create powerful macros  
✓ Design with CLOS  
✓ Organize large codebases with packages  
✓ Optimize performance-critical code  
✓ Manipulate code symbolically

### After Level 4: Expert
✓ Build production applications  
✓ Create domain-specific languages  
✓ Implement interpreters/compilers  
✓ Apply advanced patterns  
✓ Contribute to Lisp projects

## 💡 Tips for Success

### Daily Practice
- **Start with the REPL**: Always experiment interactively first
- **Type, Don't Copy**: Type examples yourself to build muscle memory
- **Modify Examples**: Change values, add features, break things
- **Read Error Messages**: Lisp's error messages are usually helpful

### Weekly Goals
- Complete all examples in your current level
- Finish at least one practice exercise
- Write one program from scratch
- Review previous material

### Common Pitfalls to Avoid
1. ❌ Skipping REPL practice → ✅ Use REPL constantly
2. ❌ Fighting parentheses → ✅ Use paredit/parinfer
3. ❌ Rushing through macros → ✅ Take time to understand
4. ❌ Ignoring the standard → ✅ Read the HyperSpec
5. ❌ Learning alone → ✅ Join the community

## 🧪 Testing

### Running Tests
```bash
# Install FiveAM testing framework
sbcl --eval "(ql:quickload :fiveam)"

# Run tests (when available)
sbcl --load tests/run-tests.lisp
```

### Writing Tests
```lisp
(ql:quickload :fiveam)

(fiveam:def-suite my-tests)
(fiveam:in-suite my-tests)

(fiveam:test addition
  (fiveam:is (= 4 (+ 2 2)))
  (fiveam:is (= 0 (- 5 5))))

(fiveam:run! 'my-tests)
```

## 🤝 Contribution Guidelines

We welcome contributions! Here's how to help:

### Code Style
- Follow [Google Common Lisp Style Guide](https://google.github.io/styleguide/lispguide.xml)
- Use descriptive names
- Include docstrings for all functions
- Add comments for complex logic

### Adding Examples
1. Place examples in appropriate level directory
2. Follow naming convention: `NN-topic-name.lisp`
3. Include comprehensive comments
4. Update level README.md
5. Test thoroughly

### Quality Standards
- ✓ Code runs without errors
- ✓ Well-commented and explained
- ✓ Demonstrates one concept clearly
- ✓ Follows Lisp idioms
- ✓ Includes example usage

## 📚 Resources and References

### Essential References
- 📖 [Common Lisp HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Front/index.htm) - The official standard
- 📕 [Practical Common Lisp](https://gigamonkeys.com/book/) - Best learning book (free online)
- 📗 [Common Lisp Cookbook](https://lispcookbook.github.io/cl-cookbook/) - Practical recipes
- 📘 [SBCL Manual](http://www.sbcl.org/manual/) - Implementation reference

### Books
- **Beginner**: Practical Common Lisp by Peter Seibel
- **Intermediate**: Land of Lisp by Conrad Barski
- **Advanced**: On Lisp by Paul Graham (free online)
- **Expert**: PAIP by Peter Norvig, Let Over Lambda by Doug Hoyte

### Online Resources
- [Learn X in Y Minutes: Common Lisp](https://learnxinyminutes.com/docs/common-lisp/)
- [Lisp-Lang.org](https://lisp-lang.org/) - Modern Lisp portal
- [Awesome Common Lisp](https://github.com/CodyReichert/awesome-cl) - Curated libraries
- [Planet Lisp](http://planet.lisp.org/) - Blog aggregator

### Community
- [r/lisp](https://reddit.com/r/lisp) - Reddit community
- [Lisp Discord](https://discord.gg/hhk46CE) - Real-time chat
- [Common-Lisp.net](https://common-lisp.net/) - Project hosting
- [Lisp Forum](https://lisp-lang.org/community/) - Discussion forums

### Tools and Libraries
- [Quicklisp](https://www.quicklisp.org/) - Package manager
- [Roswell](https://github.com/roswell/roswell) - Lisp installer/manager
- [SLIME](https://common-lisp.net/project/slime/) - Emacs development environment
- [Alive](https://github.com/nobody-famous/alive) - VS Code extension

### Video Resources
- [Little Bits of Lisp](https://www.youtube.com/playlist?list=PL2VAYZE_4wRJi_vgpjsH75kMhN4KsuzR_)
- [Common Lisp Study Group](https://www.youtube.com/c/CBaggers)
- [Lisp Tutorials](https://www.youtube.com/results?search_query=common+lisp+tutorial)

## 🎯 Next Steps

1. **Install SBCL**: Follow the Quick Start section above
2. **Read**: [LEARNING_PATH.md](LEARNING_PATH.md) for complete curriculum
3. **Start**: Begin with `01-basics/01-hello-world.lisp`
4. **Practice**: Complete exercises in each level
5. **Build**: Create your own projects
6. **Share**: Contribute back to the community

## 📝 License

This learning resource is part of the web-study repository. All code examples are provided for educational purposes.

## 🙏 Acknowledgments

This comprehensive Common Lisp learning path draws inspiration from:
- Practical Common Lisp by Peter Seibel
- On Lisp by Paul Graham
- The Common Lisp community
- Decades of Lisp wisdom and best practices

---

**Ready to start your Lisp journey?** 🚀

Begin with [LEARNING_PATH.md](LEARNING_PATH.md) or dive right into [01-basics/](01-basics/)!

*"Lisp is worth learning for the profound enlightenment experience you will have when you finally get it."* - Eric S. Raymond