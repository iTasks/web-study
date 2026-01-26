# Level 3: Advanced

Welcome to advanced Common Lisp! This level covers powerful features that make Lisp unique: macros, CLOS, packages, optimization, and symbolic computation.

## Learning Objectives

By completing this level, you will:
- Write powerful macros for code generation
- Master object-oriented programming with CLOS
- Organize code with the package system
- Optimize performance-critical code
- Perform symbolic computation and manipulation

## Files and Topics

### 01-macros.lisp
Meta-programming with macros:
- Basic macro definition
- Control structure macros
- Code generation macros
- Anaphoric macros
- With- macros
- Macro hygiene with gensym

**Run it:**
```bash
sbcl --script 01-macros.lisp
```

### 02-clos.lisp
Common Lisp Object System:
- Defining classes and creating instances
- Generic functions and methods
- Inheritance (single and multiple)
- Multi-methods (dispatch on multiple args)
- Before/after/around methods
- Class-allocated slots

**Run it:**
```bash
sbcl --script 02-clos.lisp
```

### 03-packages.lisp
Code organization with packages:
- Defining packages
- Importing and exporting symbols
- Package nicknames
- Avoiding name conflicts
- Symbol visibility
- Best practices

**Run it:**
```bash
sbcl --script 03-packages.lisp
```

### 04-optimization.lisp
Performance optimization techniques:
- Type declarations
- Tail recursion optimization
- Inline functions
- Loop optimization
- Avoiding consing
- Destructive operations
- Specialized arrays

**Run it:**
```bash
sbcl --script 04-optimization.lisp
```

### 05-symbolic-computation.lisp
Symbolic processing and manipulation:
- Symbolic expressions
- Symbolic differentiation
- Expression simplification
- Pattern matching
- Symbolic algebra
- Code as data

**Run it:**
```bash
sbcl --script 05-symbolic-computation.lisp
```

## Practice Exercises

After studying the examples, try these exercises:

1. **DSL Builder**: Create a domain-specific language using macros for a specific problem domain
2. **OOP System**: Build a complete system using CLOS with inheritance and polymorphism
3. **Library Design**: Design a library with proper package organization and exported API
4. **Performance Challenge**: Optimize a slow function using declarations and profiling
5. **Computer Algebra System**: Extend the symbolic computation examples to handle more operations

## Next Steps

Once you're comfortable with these concepts, move on to:
- **04-expert/**: Real-world applications and advanced patterns
- Build complete applications combining all concepts
- Explore advanced libraries via Quicklisp

## Tips for Success

- **Macros**: Understand when to use macros vs functions
- **CLOS**: Use multi-methods for complex dispatch logic
- **Packages**: Keep exports minimal and well-documented
- **Optimization**: Profile first, optimize later
- **Symbolic**: Think of code as data, data as code
- **Testing**: Test macro expansions, class hierarchies, and edge cases

## Advanced Concepts

### When to Use Macros
- Creating new control structures
- Code generation and repetitive patterns
- DSL implementation
- Performance optimizations

### CLOS Design Patterns
- Strategy pattern with methods
- Decorator with before/after methods
- Visitor with multi-methods
- Factory with make-instance

### Performance Tuning
- Use `(time ...)` to measure
- Profile with implementation tools
- Declare types for numeric code
- Consider space vs. speed tradeoffs

## Resources

- [Practical Common Lisp - Macros](https://gigamonkeys.com/book/macros-defining-your-own.html)
- [Practical Common Lisp - Object Orientation](https://gigamonkeys.com/book/object-reorientation-generic-functions.html)
- [Common Lisp Cookbook - Performance](https://lispcookbook.github.io/cl-cookbook/performance.html)
- [On Lisp by Paul Graham](http://www.paulgraham.com/onlisp.html)
- [The Art of the Metaobject Protocol](https://mitpress.mit.edu/books/art-metaobject-protocol)
