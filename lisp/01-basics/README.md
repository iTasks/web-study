# Level 1: Basics

Welcome to the first level of learning Common Lisp! This section covers the fundamental concepts you need to get started with Lisp programming.

## Learning Objectives

By completing this level, you will:
- Understand Lisp syntax and structure
- Work with basic data types
- Use variables and constants
- Control program flow
- Perform basic list operations

## Files and Topics

### 01-hello-world.lisp
Your first Lisp program! Learn how to:
- Print output to the console
- Use the `format` function
- Write basic Lisp expressions

**Run it:**
```bash
sbcl --script 01-hello-world.lisp
```

### 02-data-types.lisp
Explore Lisp's rich data type system:
- Numbers (integers, floats, ratios, complex)
- Strings and characters
- Symbols
- Booleans
- Lists and arrays

**Run it:**
```bash
sbcl --script 02-data-types.lisp
```

### 03-variables.lisp
Learn variable management:
- Global variables (`defvar`, `defparameter`)
- Constants (`defconstant`)
- Local variables (`let`, `let*`)
- Setting values (`setf`, `incf`, `decf`)

**Run it:**
```bash
sbcl --script 03-variables.lisp
```

### 04-control-flow.lisp
Master control structures:
- Conditional execution (`if`, `when`, `unless`)
- Multiple conditions (`cond`, `case`)
- Boolean logic (`and`, `or`, `not`)

**Run it:**
```bash
sbcl --script 04-control-flow.lisp
```

### 05-list-operations.lisp
Lists are fundamental to Lisp:
- Creating lists
- Accessing elements (`car`, `cdr`, `nth`)
- Adding and removing elements
- Finding and transforming lists

**Run it:**
```bash
sbcl --script 05-list-operations.lisp
```

## Practice Exercises

After studying the examples, try these exercises:

1. **Calculator**: Write a program that performs basic arithmetic (add, subtract, multiply, divide)
2. **Grade Calculator**: Take a numeric score and convert it to a letter grade
3. **List Manipulator**: Create a program that reverses a list and finds the maximum value
4. **Temperature Converter**: Convert between Celsius and Fahrenheit
5. **Palindrome Checker**: Check if a list of numbers is the same forwards and backwards

## Next Steps

Once you're comfortable with these basics, move on to:
- **02-intermediate/**: Functions, recursion, and file I/O
- Practice interactive REPL development
- Explore the Common Lisp HyperSpec for deeper understanding

## Tips for Success

- **Use the REPL**: Lisp is designed for interactive development
- **Experiment**: Modify the examples and see what happens
- **Read error messages**: They're usually helpful in Lisp
- **Think in expressions**: Everything in Lisp returns a value
- **Embrace parentheses**: They define structure, not just grouping

## Resources

- [Common Lisp HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Front/index.htm)
- [Practical Common Lisp - Chapter 3](https://gigamonkeys.com/book/practical-a-simple-database.html)
- [Learn X in Y Minutes: Common Lisp](https://learnxinyminutes.com/docs/common-lisp/)
