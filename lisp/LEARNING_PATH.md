# Common Lisp Learning Path: Zero to Expert

This comprehensive learning path will take you from a complete beginner to an expert Common Lisp programmer. Follow the structured curriculum below to master one of the most powerful programming languages ever created.

## Overview

**Time to Complete**: 8-12 weeks (at 10-15 hours per week)

**Prerequisites**: 
- Basic programming knowledge (any language)
- Ability to use command-line tools
- Patience and curiosity

## Learning Philosophy

Common Lisp learning is different from other languages:
- **Interactive Development**: Use the REPL constantly
- **Bottom-Up Programming**: Build layers of abstractions
- **Code as Data**: Embrace homoiconicity
- **Incremental Testing**: Test as you code

## The Four Levels

### Level 1: Basics (Week 1-2)
**Goal**: Understand fundamental Lisp concepts and syntax

**Location**: `01-basics/`

**Topics**:
1. Hello World and basic I/O
2. Data types (numbers, strings, symbols, lists)
3. Variables and constants
4. Control flow (if, cond, case, loops)
5. List operations (car, cdr, cons, etc.)

**Practice**:
- Write a simple calculator
- Implement temperature converter
- Create a grade calculator
- Build a palindrome checker

**Time**: 15-20 hours

**Checkpoint**: Can you write simple programs using lists and conditionals?

---

### Level 2: Intermediate (Week 3-5)
**Goal**: Master functions, recursion, and data structures

**Location**: `02-intermediate/`

**Topics**:
1. Functions (definition, parameters, lambda)
2. Recursion (basic and tail recursion)
3. Higher-order functions (map, reduce, filter)
4. File I/O operations
5. Data structures (alists, plists, hash tables, structures)

**Practice**:
- Implement recursive algorithms (factorial, fibonacci, tree traversal)
- Build a file processor
- Create a contact manager with file persistence
- Write a data pipeline using higher-order functions

**Time**: 30-40 hours

**Checkpoint**: Can you write recursive functions and choose appropriate data structures?

---

### Level 3: Advanced (Week 6-9)
**Goal**: Leverage Lisp's unique features: macros, CLOS, packages

**Location**: `03-advanced/`

**Topics**:
1. Macros and meta-programming
2. CLOS (Common Lisp Object System)
3. Package system for code organization
4. Performance optimization
5. Symbolic computation

**Practice**:
- Create your own control structure macros
- Build an OOP system with inheritance
- Design a library with proper package structure
- Optimize performance-critical code
- Write a symbolic differentiator

**Time**: 40-50 hours

**Checkpoint**: Can you write macros and use CLOS effectively?

---

### Level 4: Expert (Week 10-12)
**Goal**: Build real-world applications and advanced systems

**Location**: `04-expert/`

**Topics**:
1. Web server implementation
2. Domain-Specific Languages (DSLs)
3. Complete calculator with parser
4. Advanced pattern matching
5. Interpreter/compiler construction

**Practice**:
- Build a web application
- Create a query language DSL
- Implement a compiler for a simple language
- Design a game engine
- Contribute to open-source Lisp projects

**Time**: 40-60 hours

**Checkpoint**: Can you build production-ready applications?

---

## Detailed Week-by-Week Plan

### Week 1: Getting Started
- **Day 1-2**: Setup SBCL, learn REPL basics
- **Day 3-4**: Study 01-hello-world.lisp and 02-data-types.lisp
- **Day 5**: Work through 03-variables.lisp
- **Day 6**: Master 04-control-flow.lisp
- **Day 7**: Practice with 05-list-operations.lisp

**Deliverable**: Simple calculator program

### Week 2: Solidify Basics
- **Day 1-3**: Complete all Level 1 practice exercises
- **Day 4-5**: Build grade calculator and palindrome checker
- **Day 6-7**: Review and reinforce concepts

**Deliverable**: Temperature converter with menu system

### Week 3: Functions and Recursion
- **Day 1-2**: Study 01-functions.lisp
- **Day 3-4**: Deep dive into 02-recursion.lisp
- **Day 5-6**: Master 03-higher-order-functions.lisp
- **Day 7**: Practice writing recursive functions

**Deliverable**: Recursive tree walker

### Week 4: Data and I/O
- **Day 1-3**: Work through 04-file-io.lisp
- **Day 4-6**: Study 05-data-structures.lisp
- **Day 7**: Choose appropriate data structures for problems

**Deliverable**: File-based contact manager

### Week 5: Intermediate Practice
- **Day 1-4**: Complete all Level 2 practice exercises
- **Day 5-7**: Build a larger project combining concepts

**Deliverable**: Data processing pipeline

### Week 6: Macros
- **Day 1-4**: Deep study of 01-macros.lisp
- **Day 5-6**: Write your own macros
- **Day 7**: Understand macro expansion

**Deliverable**: Custom control structure macros

### Week 7: Object-Oriented Programming
- **Day 1-4**: Master 02-clos.lisp
- **Day 5-6**: Design class hierarchies
- **Day 7**: Implement multi-methods

**Deliverable**: OOP system with inheritance

### Week 8: Packages and Optimization
- **Day 1-3**: Study 03-packages.lisp and 04-optimization.lisp
- **Day 4-5**: Organize code into packages
- **Day 6-7**: Optimize performance-critical code

**Deliverable**: Optimized library with clean API

### Week 9: Symbolic Computing
- **Day 1-4**: Work through 05-symbolic-computation.lisp
- **Day 5-7**: Build symbolic manipulation tools

**Deliverable**: Computer algebra system

### Week 10: Real-World Applications
- **Day 1-3**: Study 01-web-server.lisp and 02-dsl-builder.lisp
- **Day 4-7**: Build a simple web application

**Deliverable**: Web app with DSL-generated HTML

### Week 11: Interpreters and Parsers
- **Day 1-4**: Master 03-calculator-app.lisp and 05-interpreter.lisp
- **Day 5-7**: Build your own language interpreter

**Deliverable**: Simple language interpreter

### Week 12: Advanced Patterns and Projects
- **Day 1-3**: Study 04-pattern-matcher.lisp
- **Day 4-7**: Complete final project

**Deliverable**: Production-quality application

---

## Learning Resources by Level

### Beginner Resources
- [Common Lisp HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Front/index.htm)
- [Learn X in Y Minutes: Common Lisp](https://learnxinyminutes.com/docs/common-lisp/)
- [Practical Common Lisp - Early Chapters](https://gigamonkeys.com/book/)

### Intermediate Resources
- [Common Lisp Cookbook](https://lispcookbook.github.io/cl-cookbook/)
- [Practical Common Lisp - Full Book](https://gigamonkeys.com/book/)
- [SBCL User Manual](http://www.sbcl.org/manual/)

### Advanced Resources
- [On Lisp by Paul Graham](http://www.paulgraham.com/onlisp.html)
- [Let Over Lambda](https://letoverlambda.com/)
- [Art of the Metaobject Protocol](https://mitpress.mit.edu/books/art-metaobject-protocol)

### Expert Resources
- [PAIP (Paradigms of AI Programming)](https://github.com/norvig/paip-lisp)
- [Common Lisp Recipes](http://weitz.de/cl-recipes/)
- Research papers and conference proceedings

---

## Study Tips

### Daily Practice
1. **Start with REPL**: Always experiment in the REPL first
2. **Type, Don't Copy**: Type examples yourself
3. **Modify Examples**: Change values, add features
4. **Explain to Others**: Teaching solidifies learning

### Weekly Goals
- Complete all examples in the week's modules
- Finish at least one practice exercise
- Write one small program from scratch
- Review previous week's material

### Common Pitfalls
1. **Skipping REPL practice**: The REPL is essential
2. **Not reading error messages**: They're usually helpful
3. **Fighting parentheses**: Use a good editor with paredit
4. **Rushing through macros**: Take time to understand them
5. **Ignoring the standard**: Read the HyperSpec

---

## Editor Setup

### Recommended: Emacs + SLIME
```elisp
;; In your .emacs or init.el
(setq inferior-lisp-program "sbcl")
(require 'slime)
(slime-setup '(slime-fancy slime-company))
```

### Alternative: VS Code + Alive
- Install "Alive" extension
- Configure SBCL path
- Use integrated REPL

### Other Options
- Vim + Slimv
- Atom + SLIMA
- Sublime Text + SublimeREPL

---

## Assessment Checkpoints

### After Level 1
Can you:
- [ ] Write basic Lisp expressions?
- [ ] Use lists and their operations?
- [ ] Implement simple conditionals?
- [ ] Create basic programs?

### After Level 2
Can you:
- [ ] Define and use functions effectively?
- [ ] Write recursive algorithms?
- [ ] Use higher-order functions?
- [ ] Choose appropriate data structures?
- [ ] Read and write files?

### After Level 3
Can you:
- [ ] Write useful macros?
- [ ] Design with CLOS?
- [ ] Organize code in packages?
- [ ] Optimize performance?
- [ ] Manipulate code as data?

### After Level 4
Can you:
- [ ] Build complete applications?
- [ ] Create DSLs?
- [ ] Implement interpreters?
- [ ] Use advanced patterns?
- [ ] Deploy production code?

---

## Beyond Expert

### Specializations
- **AI and Machine Learning**: Study PAIP
- **Compilers**: Build a complete compiler
- **Web Development**: Master Hunchentoot, Caveman2
- **Game Development**: Explore game engines
- **Systems Programming**: FFI, low-level optimization

### Contribution
- Join the Lisp community
- Contribute to open-source projects
- Write libraries and share them
- Answer questions, help beginners
- Write blog posts about Lisp

---

## Final Project Ideas

Choose one to demonstrate mastery:

1. **Web Framework**: Build a minimal web framework
2. **Database System**: Implement a simple in-memory database
3. **Game**: Create a text adventure or simple game
4. **Compiler**: Build a compiler for a toy language
5. **Tool**: Create a useful development tool

---

## Success Metrics

You've mastered Common Lisp when you can:
- Read and understand Lisp codebases
- Write idiomatic, efficient Lisp code
- Choose between macros and functions appropriately
- Build production applications
- Contribute meaningfully to Lisp projects

**Congratulations on starting your Common Lisp journey!**

The path is challenging but immensely rewarding. Lisp will change how you think about programming.

*"Lisp is worth learning for the profound enlightenment experience you will have when you finally get it; that experience will make you a better programmer for the rest of your days, even if you never actually use Lisp itself a lot."* - Eric S. Raymond
