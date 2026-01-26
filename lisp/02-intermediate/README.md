# Level 2: Intermediate

Welcome to intermediate Common Lisp! This level builds on the basics with functions, recursion, higher-order programming, file I/O, and data structures.

## Learning Objectives

By completing this level, you will:
- Define and use functions effectively
- Master recursive programming
- Work with higher-order functions
- Perform file input/output operations
- Use various data structures

## Files and Topics

### 01-functions.lisp
Master function definition and usage:
- Simple functions with `defun`
- Optional and keyword parameters
- Rest parameters for variadic functions
- Local functions with `labels`
- Anonymous functions (lambda)

**Run it:**
```bash
sbcl --script 01-functions.lisp
```

### 02-recursion.lisp
Learn recursive programming:
- Basic recursion (factorial, Fibonacci)
- List recursion
- Tail recursion for efficiency
- Tree recursion
- Mutual recursion

**Run it:**
```bash
sbcl --script 02-recursion.lisp
```

### 03-higher-order-functions.lisp
Functions that work with functions:
- `mapcar`, `reduce` for list transformation
- `remove-if`, `remove-if-not` for filtering
- `every`, `some` for testing predicates
- Function composition
- Returning functions, partial application

**Run it:**
```bash
sbcl --script 03-higher-order-functions.lisp
```

### 04-file-io.lisp
File operations in Lisp:
- Reading and writing files
- Line-by-line processing
- Reading/writing Lisp expressions
- Appending to files
- File existence checks
- Copying files

**Run it:**
```bash
sbcl --script 04-file-io.lisp
```

### 05-data-structures.lisp
Beyond simple lists:
- Association lists (alists)
- Property lists (plists)
- Hash tables
- Arrays (single and multi-dimensional)
- Structures
- Queues and stacks

**Run it:**
```bash
sbcl --script 05-data-structures.lisp
```

## Practice Exercises

After studying the examples, try these exercises:

1. **Recursive Tree Walker**: Write a function that traverses a nested tree structure and counts all atoms
2. **File Statistics**: Read a text file and compute word count, line count, and character count
3. **Data Processor**: Read a CSV-like file and process it into a list of alists or hash tables
4. **Function Pipeline**: Create a pipeline of functions that transforms data step-by-step
5. **Contact Manager**: Build a simple contact manager using structures or hash tables with file persistence

## Next Steps

Once you're comfortable with these concepts, move on to:
- **03-advanced/**: Macros, CLOS, packages, and optimization
- Build small projects combining multiple concepts
- Explore Quicklisp libraries

## Tips for Success

- **Profile your code**: Use tail recursion when appropriate
- **Choose the right data structure**: Hash tables for lookups, lists for sequential access
- **Use higher-order functions**: They make code more concise and expressive
- **REPL-driven development**: Test functions interactively before saving
- **Handle edge cases**: Empty lists, nil values, file errors

## Resources

- [Practical Common Lisp - Functions](https://gigamonkeys.com/book/functions.html)
- [Practical Common Lisp - Collections](https://gigamonkeys.com/book/collections.html)
- [Practical Common Lisp - Files and File I/O](https://gigamonkeys.com/book/files-and-file-io.html)
- [Common Lisp Cookbook - Data Structures](https://lispcookbook.github.io/cl-cookbook/data-structures.html)
