# Lisp Tests

[← Back to Lisp](../README.md) | [Main README](../../README.md)

This directory contains example test files for the Common Lisp learning materials.

## Running Tests

### Simple Inline Tests

Run the example tests without any dependencies:

```bash
sbcl --script example-tests.lisp
```

This will run simple inline tests that don't require any external libraries.

### Using FiveAM (Recommended)

For a full-featured testing experience:

1. **Install Quicklisp** (if not already installed):
   ```bash
   curl -O https://beta.quicklisp.org/quicklisp.lisp
   sbcl --load quicklisp.lisp
   ```
   
   In the REPL:
   ```lisp
   (quicklisp-quickstart:install)
   (ql:add-to-init-file)
   ```

2. **Install FiveAM**:
   ```bash
   sbcl --eval "(ql:quickload :fiveam)" --quit
   ```

3. **Run tests with FiveAM**:
   ```lisp
   ;; In REPL
   (ql:quickload :fiveam)
   (load "example-tests.lisp")
   (fiveam:run! 'basic-tests)
   ```

## Writing Your Own Tests

### Basic Test Template

```lisp
(ql:quickload :fiveam)

;; Define a test suite
(fiveam:def-suite my-suite
  :description "My test suite")

;; Set current suite
(fiveam:in-suite my-suite)

;; Write a test
(fiveam:test my-first-test
  "Test description"
  (fiveam:is (= 4 (+ 2 2))))

;; Run tests
(fiveam:run! 'my-suite)
```

### Test Assertions

FiveAM provides several assertion forms:

```lisp
;; Basic equality
(fiveam:is (= 4 (+ 2 2)))

;; Predicates
(fiveam:is (evenp 4))
(fiveam:is (null nil))

;; Equality with custom comparison
(fiveam:is (equal '(1 2 3) (list 1 2 3)))
(fiveam:is (string= "hello" "hello"))

;; Expected failures
(fiveam:signals error (error "This should signal an error"))

;; Custom failure messages
(fiveam:is (= 5 (+ 2 2))
           "2 + 2 should equal 4, not 5")
```

## Testing Best Practices

1. **Test one thing per test**: Keep tests focused and simple
2. **Use descriptive names**: Test names should explain what is being tested
3. **Test edge cases**: Empty lists, nil, zero, negative numbers, etc.
4. **Test normal cases**: Typical use cases
5. **Test boundary conditions**: Maximum/minimum values, limits
6. **Make tests repeatable**: Tests should produce the same results every time
7. **Run tests frequently**: Run tests after every change
8. **Keep tests independent**: Tests shouldn't depend on each other

## Testing Frameworks

### FiveAM (Recommended)
- **Installation**: `(ql:quickload :fiveam)`
- **Features**: Suites, fixtures, assertions, test dependencies
- **Best for**: General testing

### Prove
- **Installation**: `(ql:quickload :prove)`
- **Features**: TAP output, modern syntax
- **Best for**: CI/CD integration

### Lisp-Unit
- **Installation**: `(ql:quickload :lisp-unit)`
- **Features**: Simple, straightforward
- **Best for**: Beginners

### RT (Regression Test)
- **Installation**: Built into some implementations
- **Features**: Classic, minimal
- **Best for**: Simple regression testing

## Example: Testing a Function

```lisp
;; Function to test
(defun fibonacci (n)
  "Calculate nth Fibonacci number"
  (cond
    ((<= n 0) 0)
    ((= n 1) 1)
    (t (+ (fibonacci (- n 1))
          (fibonacci (- n 2))))))

;; Tests
(fiveam:test fibonacci-tests
  "Test fibonacci function"
  (fiveam:is (= 0 (fibonacci 0)))
  (fiveam:is (= 1 (fibonacci 1)))
  (fiveam:is (= 1 (fibonacci 2)))
  (fiveam:is (= 2 (fibonacci 3)))
  (fiveam:is (= 3 (fibonacci 4)))
  (fiveam:is (= 5 (fibonacci 5)))
  (fiveam:is (= 8 (fibonacci 6))))
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Lisp Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install SBCL
        run: sudo apt-get install -y sbcl
      - name: Install Quicklisp
        run: |
          curl -O https://beta.quicklisp.org/quicklisp.lisp
          sbcl --load quicklisp.lisp --eval "(quicklisp-quickstart:install)" --quit
      - name: Run Tests
        run: |
          sbcl --eval "(ql:quickload :fiveam)" \
               --load tests/example-tests.lisp \
               --eval "(fiveam:run! 'basic-tests)" \
               --quit
```

## Resources

- [FiveAM Documentation](https://common-lisp.net/project/fiveam/)
- [Prove Documentation](https://github.com/fukamachi/prove)
- [Testing in Common Lisp](https://lispcookbook.github.io/cl-cookbook/testing.html)
- [Common Lisp Testing Best Practices](https://google.github.io/styleguide/lispguide.xml#Testing)
