# Web Study

## Goals

This repository aims to study and develop sample applications for various web-based technologies. It serves as a comprehensive resource to explore different programming languages, frameworks, databases, tools, and features essential for web development.

The repository is organized by programming language first, then by framework, to provide a scalable and intuitive structure for learning and development.

## Repository Structure

This repository follows a language-first organization structure:

```
web-study/
├── java/                    # Java programming language
│   ├── spring/             # Spring framework examples
│   └── samples/            # Pure Java examples
├── python/                 # Python programming language
│   ├── flask/              # Flask framework examples
│   └── samples/            # Pure Python examples
├── javascript/             # JavaScript/TypeScript
│   ├── nodejs/             # Node.js framework examples
│   ├── react/              # React/React Native examples
│   └── samples/            # Pure JavaScript examples
├── go/                     # Go programming language
│   ├── echo/               # Echo framework examples
│   └── samples/            # Pure Go examples
├── csharp/                 # C# programming language
│   └── samples/            # Pure C# examples
├── ruby/                   # Ruby programming language
│   └── samples/            # Pure Ruby examples
├── rust/                   # Rust programming language
│   └── samples/            # Pure Rust examples
├── scala/                  # Scala programming language
│   └── samples/            # Pure Scala examples
├── groovy/                 # Groovy programming language
│   └── samples/            # Pure Groovy examples
├── lisp/                   # Lisp programming language
│   └── samples/            # Pure Lisp examples
├── teavm/                  # TeaVM (Java-to-JavaScript)
│   └── samples/            # TeaVM examples
├── zig/                    # Zig programming language
│   └── samples/            # Pure Zig examples
├── ballerina/              # Ballerina programming language
│   └── samples/            # Pure Ballerina examples
├── r/                      # R programming language
│   └── samples/            # Pure R examples
├── kotlin/                 # Kotlin programming language
│   ├── android-app/        # Android mobile app examples
│   └── samples/            # Pure Kotlin examples
├── swift/                  # Swift programming language
│   ├── ios-app/            # iOS mobile app examples
│   └── samples/            # Pure Swift examples
└── src/                    # Legacy structure (cloud services, tools)
```

## Programming Languages

### [Java](java/)
Enterprise-grade programming language with comprehensive framework support.
- **Frameworks**: Spring (Spring Boot, Spark, Beam)
- **Key Topics**: Enterprise applications, big data processing, microservices

**Basic Syntax:**
```java
// Hello World
import java.util.Optional;
import java.util.List;
import java.util.Arrays;

public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}

// Variables and Constants
final int CONSTANT = 42; // Immutable constant
int mutable = 100; // Mutable variable
var inferred = 3.14; // Type inference (Java 10+)

// Functions (Methods)
public int add(int a, int b) {
    return a + b;
}

// Error Handling
public int divide(int a, int b) throws ArithmeticException {
    if (b == 0) throw new ArithmeticException("Division by zero");
    return a / b;
}

// Classes
public class Point {
    private float x;
    private float y;
    
    public Point(float x, float y) {
        this.x = x;
        this.y = y;
    }
    
    public float getX() { return x; }
    public float getY() { return y; }
}

// Control Flow
int x = 10;
if (x > 0) {
    // if block
} else {
    // else block
}

int[] numbers = {1, 2, 3, 4, 5};
for (int num : numbers) {
    // loop body
}

int i = 0;
while (i < 10) {
    // loop body
    i++;
}

// Optionals (Java 8+)
Optional<Integer> maybeValue = Optional.empty();
int value = maybeValue.orElse(0);

// Streams and Lambda (Java 8+)
List<Integer> list = Arrays.asList(1, 2, 3, 4, 5);
list.stream()
    .filter(n -> n % 2 == 0)
    .map(n -> n * 2)
    .forEach(System.out::println);
```

### [Python](python/)
High-level, interpreted language known for simplicity and extensive libraries.
- **Frameworks**: Flask, Django
- **Key Topics**: Web development, data science, automation, serverless

**Basic Syntax:**
```python
# Hello World
print("Hello, World!")

# Variables and Constants
CONSTANT = 42  # Convention: uppercase for constants
mutable = 100  # Mutable variable
inferred = 3.14  # Dynamic typing with type inference

# Functions
def add(a, b):
    return a + b

# Type hints (Python 3.5+)
def typed_add(a: int, b: int) -> int:
    return a + b

# Error Handling
def divide(a, b):
    if b == 0:
        raise ValueError("Division by zero")
    return a / b

# Classes
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    def distance_from_origin(self):
        return (self.x ** 2 + self.y ** 2) ** 0.5

# Control Flow
x = 10
if x > 0:
    # if block
    pass
else:
    # else block
    pass

numbers = [1, 2, 3, 4, 5]
for num in numbers:
    # loop body
    pass

i = 0
while i < 10:
    # loop body
    i += 1

# Optionals (None)
maybe_value = None
value = maybe_value if maybe_value is not None else 0

# List Comprehensions
squares = [x ** 2 for x in range(10)]
evens = [x for x in range(10) if x % 2 == 0]

# Lambda Functions
doubled = list(map(lambda x: x * 2, [1, 2, 3, 4, 5]))
```

### [JavaScript](javascript/)
Core web technology for client and server-side development.
- **Frameworks**: Node.js, React/React Native
- **Key Topics**: Web applications, mobile apps, server-side development

**Basic Syntax:**
```javascript
// Hello World
console.log("Hello, World!");

// Variables and Constants
const CONSTANT = 42; // Immutable constant
let mutable = 100; // Mutable variable (block-scoped)
var oldStyle = 200; // Mutable variable (function-scoped, legacy)

// Functions
function add(a, b) {
    return a + b;
}

// Arrow Functions (ES6+)
const multiply = (a, b) => a * b;

// Error Handling
function divide(a, b) {
    if (b === 0) throw new Error("Division by zero");
    return a / b;
}

// Try-catch
try {
    divide(10, 0);
} catch (error) {
    console.error(error.message);
}

// Classes (ES6+)
class Point {
    constructor(x, y) {
        this.x = x;
        this.y = y;
    }
    
    distanceFromOrigin() {
        return Math.sqrt(this.x ** 2 + this.y ** 2);
    }
}

// Control Flow
const x = 10;
if (x > 0) {
    // if block
} else {
    // else block
}

const numbers = [1, 2, 3, 4, 5];
for (const num of numbers) {
    // loop body
}

let i = 0;
while (i < 10) {
    // loop body
    i++;
}

// Optionals (null/undefined)
const maybeValue = null;
const value = maybeValue ?? 0; // Nullish coalescing (ES2020)

// Array Methods and Callbacks
const doubled = numbers.map(n => n * 2);
const evens = numbers.filter(n => n % 2 === 0);
const sum = numbers.reduce((acc, n) => acc + n, 0);

// Promises and Async/Await
async function fetchData() {
    const response = await fetch('https://api.example.com/data');
    return await response.json();
}
```

### [Go](go/)
Modern systems programming language with excellent concurrency support.
- **Frameworks**: Echo
- **Key Topics**: Web services, microservices, concurrent programming

**Basic Syntax:**
```go
// Hello World
package main

import (
    "fmt"
    "math"
)

func main() {
    fmt.Println("Hello, World!")
}

// Variables and Constants
const CONSTANT = 42 // Immutable constant
var mutable int = 100 // Mutable variable
inferred := 3.14 // Type inference with short declaration

// Functions
func add(a int, b int) int {
    return a + b
}

// Multiple return values
func divide(a, b int) (int, error) {
    if b == 0 {
        return 0, fmt.Errorf("division by zero")
    }
    return a / b, nil
}

// Error Handling
result, err := divide(10, 2)
if err != nil {
    fmt.Println("Error:", err)
} else {
    fmt.Println("Result:", result)
}

// Structs
type Point struct {
    X float64
    Y float64
}

func (p Point) DistanceFromOrigin() float64 {
    return math.Sqrt(p.X*p.X + p.Y*p.Y)
}

// Control Flow
x := 10
if x > 0 {
    // if block
} else {
    // else block
}

numbers := []int{1, 2, 3, 4, 5}
for _, num := range numbers {
    // loop body
}

i := 0
for i < 10 {
    // loop body
    i++
}

// Pointers
var ptr *int = &mutable
fmt.Println(*ptr) // Dereference

// Goroutines and Channels
ch := make(chan int)
go func() {
    ch <- 42
}()
value := <-ch

// Defer
defer fmt.Println("This runs at the end")
```

### [C#](csharp/)
Object-oriented programming language for the .NET platform.
- **Key Topics**: Enterprise applications, financial systems, FIX protocol

**Basic Syntax:**
```csharp
// Hello World
using System;

class HelloWorld
{
    static void Main(string[] args)
    {
        Console.WriteLine("Hello, World!");
    }
}

// Variables and Constants
const int CONSTANT = 42; // Immutable constant
int mutable = 100; // Mutable variable
var inferred = 3.14; // Type inference

// Functions (Methods)
public int Add(int a, int b)
{
    return a + b;
}

// Error Handling
public int Divide(int a, int b)
{
    if (b == 0) throw new DivideByZeroException();
    return a / b;
}

// Classes and Properties
public class Point
{
    public float X { get; set; }
    public float Y { get; set; }
    
    public Point(float x, float y)
    {
        X = x;
        Y = y;
    }
    
    public double DistanceFromOrigin()
    {
        return Math.Sqrt(X * X + Y * Y);
    }
}

// Control Flow
int x = 10;
if (x > 0)
{
    // if block
}
else
{
    // else block
}

int[] numbers = { 1, 2, 3, 4, 5 };
foreach (int num in numbers)
{
    // loop body
}

int i = 0;
while (i < 10)
{
    // loop body
    i++;
}

// Nullable Types
int? maybeValue = null;
int value = maybeValue ?? 0;

// LINQ and Lambda
var evens = numbers.Where(n => n % 2 == 0);
var doubled = numbers.Select(n => n * 2);
var sum = numbers.Sum();

// Async/Await
async Task<string> FetchDataAsync()
{
    await Task.Delay(1000);
    return "Data";
}
```

### [Ruby](ruby/)
Dynamic programming language focused on simplicity and productivity.
- **Key Topics**: Web development, automation, authentication systems

**Basic Syntax:**
```ruby
# Hello World
puts "Hello, World!"

# Variables and Constants
CONSTANT = 42 # Constant (convention: uppercase)
mutable = 100 # Mutable variable
inferred = 3.14 # Dynamic typing

# Functions (Methods)
def add(a, b)
  a + b # Implicit return
end

# Error Handling
def divide(a, b)
  raise ZeroDivisionError, "Division by zero" if b == 0
  a / b
end

# Exception handling
begin
  divide(10, 0)
rescue ZeroDivisionError => e
  puts "Error: #{e.message}"
end

# Classes
class Point
  attr_accessor :x, :y
  
  def initialize(x, y)
    @x = x
    @y = y
  end
  
  def distance_from_origin
    Math.sqrt(@x**2 + @y**2)
  end
end

# Control Flow
x = 10
if x > 0
  # if block
else
  # else block
end

numbers = [1, 2, 3, 4, 5]
numbers.each do |num|
  # loop body
end

i = 0
while i < 10
  # loop body
  i += 1
end

# Optionals (nil)
maybe_value = nil
value = maybe_value || 0

# Blocks and Iterators
doubled = numbers.map { |n| n * 2 }
evens = numbers.select { |n| n.even? }
sum = numbers.reduce(0) { |acc, n| acc + n }

# Symbols and Hashes
person = { name: "Alice", age: 30 }
puts person[:name]
```

### [Rust](rust/)
Systems programming language focused on safety and performance.
- **Key Topics**: Threading, async programming, webhooks, web servers, memory safety

**Basic Syntax:**
```rust
// Hello World
fn main() {
    println!("Hello, World!");
}

// Variables and Constants
const CONSTANT: i32 = 42; // Immutable constant
let mutable: i32 = 100; // Immutable by default
let mut changeable: i32 = 200; // Mutable variable
let inferred = 3.14; // Type inference

// Functions
fn add(a: i32, b: i32) -> i32 {
    a + b // Expression without semicolon
}

// Error Handling with Result
fn divide(a: i32, b: i32) -> Result<i32, String> {
    if b == 0 {
        return Err(String::from("Division by zero"));
    }
    Ok(a / b)
}

// Using Result
match divide(10, 2) {
    Ok(result) => println!("Result: {}", result),
    Err(e) => println!("Error: {}", e),
}

// Structs
struct Point {
    x: f32,
    y: f32,
}

impl Point {
    fn new(x: f32, y: f32) -> Self {
        Point { x, y }
    }
    
    fn distance_from_origin(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}

// Control Flow
let x = 10;
if x > 0 {
    // if block
} else {
    // else block
}

let numbers = vec![1, 2, 3, 4, 5];
for num in &numbers {
    // loop body
}

let mut i = 0;
while i < 10 {
    // loop body
    i += 1;
}

// Optionals with Option
let maybe_value: Option<i32> = None;
let value = maybe_value.unwrap_or(0);

// Ownership and Borrowing
let s1 = String::from("hello");
let s2 = &s1; // Borrowing
// s1 is still valid here

// Pattern Matching
let number = 7;
match number {
    1 => println!("One"),
    2..=5 => println!("Two to Five"),
    _ => println!("Something else"),
}

// Iterators and Closures
let doubled: Vec<i32> = numbers.iter().map(|x| x * 2).collect();
let evens: Vec<&i32> = numbers.iter().filter(|x| *x % 2 == 0).collect();
```

### [Scala](scala/)
JVM language combining object-oriented and functional programming.
- **Key Topics**: Big data processing, functional programming, JVM integration

**Basic Syntax:**
```scala
// Hello World
import scala.util.{Try, Success, Failure}

object HelloWorld {
  def main(args: Array[String]): Unit = {
    println("Hello, World!")
  }
}

// Variables and Constants
val constant: Int = 42 // Immutable value
var mutable: Int = 100 // Mutable variable
val inferred = 3.14 // Type inference

// Functions
def add(a: Int, b: Int): Int = {
  a + b
}

// Single expression function
def multiply(a: Int, b: Int): Int = a * b

// Error Handling with Try
def divide(a: Int, b: Int): Try[Int] = {
  if (b == 0) Failure(new ArithmeticException("Division by zero"))
  else Success(a / b)
}

divide(10, 2) match {
  case Success(result) => println(s"Result: $result")
  case Failure(e) => println(s"Error: ${e.getMessage}")
}

// Classes and Case Classes
class Point(val x: Float, val y: Float) {
  def distanceFromOrigin: Double = 
    math.sqrt(x * x + y * y)
}

case class ImmutablePoint(x: Float, y: Float)

// Control Flow
val x = 10
if (x > 0) {
  // if block
} else {
  // else block
}

val numbers = List(1, 2, 3, 4, 5)
for (num <- numbers) {
  // loop body
}

var i = 0
while (i < 10) {
  // loop body
  i += 1
}

// Options
val maybeValue: Option[Int] = None
val value = maybeValue.getOrElse(0)

// Collections and Higher-Order Functions
val doubled = numbers.map(_ * 2)
val evens = numbers.filter(_ % 2 == 0)
val sum = numbers.reduce(_ + _)

// Pattern Matching
val number = 7
number match {
  case 1 => println("One")
  case n if n >= 2 && n <= 5 => println("Two to Five")
  case _ => println("Something else")
}

// For Comprehensions
val result = for {
  x <- List(1, 2, 3)
  y <- List(10, 20)
} yield x * y
```

### [Groovy](groovy/)
Dynamic language for the Java platform with enhanced productivity features.
- **Key Topics**: Scripting, DSLs, Java integration

**Basic Syntax:**
```groovy
// Hello World
println "Hello, World!"

// Variables and Constants
final CONSTANT = 42 // Immutable constant
def mutable = 100 // Mutable variable (dynamic typing)
int typed = 200 // Static typing
def inferred = 3.14 // Type inference

// Functions (Methods)
def add(a, b) {
    return a + b
}

// Implicit return
def multiply(a, b) {
    a * b
}

// Error Handling
def divide(a, b) {
    if (b == 0) throw new ArithmeticException("Division by zero")
    return a / b
}

try {
    divide(10, 0)
} catch (ArithmeticException e) {
    println "Error: ${e.message}"
}

// Classes
class Point {
    float x
    float y
    
    Point(float x, float y) {
        this.x = x
        this.y = y
    }
    
    def distanceFromOrigin() {
        Math.sqrt(x**2 + y**2)
    }
}

// Control Flow
def x = 10
if (x > 0) {
    // if block
} else {
    // else block
}

def numbers = [1, 2, 3, 4, 5]
numbers.each { num ->
    // loop body
}

def i = 0
while (i < 10) {
    // loop body
    i++
}

// Null Safety
def maybeValue = null
def value = maybeValue ?: 0 // Elvis operator

// Closures
def doubled = numbers.collect { it * 2 }
def evens = numbers.findAll { it % 2 == 0 }
def sum = numbers.sum()

// Maps and Lists
def person = [name: 'Alice', age: 30]
println person.name

// String Interpolation
def name = "World"
println "Hello, ${name}!"

// Range
def range = 1..10
range.each { println it }
```

### [Lisp](lisp/)
Functional programming language known for symbolic computation.
- **Key Topics**: Symbolic computation, AI, functional programming

**Basic Syntax:**
```lisp
;; Hello World
(print "Hello, World!")

;; Variables and Constants
(defconstant +constant+ 42) ; Constant
(defparameter *mutable* 100) ; Dynamic/special variable
(let ((local-var 200)) ; Local variable
  (print local-var))

;; Functions
(defun add (a b)
  (+ a b))

;; Multiple values
(defun divide (a b)
  (if (zerop b)
      (error "Division by zero")
      (/ a b)))

;; Error Handling
(handler-case
    (divide 10 0)
  (error (e)
    (format t "Error: ~A~%" e)))

;; Structures (similar to classes)
(defstruct point
  (x 0.0 :type float)
  (y 0.0 :type float))

(defun make-point-from-coords (x y)
  (make-point :x x :y y))

(defun distance-from-origin (p)
  (sqrt (+ (* (point-x p) (point-x p))
           (* (point-y p) (point-y p)))))

;; Control Flow
(let ((x 10))
  (if (> x 0)
      (print "positive")
      (print "non-positive")))

;; Looping with dolist
(dolist (num '(1 2 3 4 5))
  ;; loop body
  (print num))

;; Looping with loop
(loop for i from 0 below 10
      do (print i))

;; Conditionals with cond
(let ((x 7))
  (cond
    ((= x 1) (print "One"))
    ((and (>= x 2) (<= x 5)) (print "Two to Five"))
    (t (print "Something else"))))

;; Higher-order functions
(mapcar (lambda (x) (* x 2)) '(1 2 3 4 5)) ; Doubled
(remove-if-not #'evenp '(1 2 3 4 5)) ; Evens
(reduce #'+ '(1 2 3 4 5)) ; Sum

;; Optional parameters
(defun greet (&optional (name "World"))
  (format t "Hello, ~A!~%" name))

;; Macros (compile-time code generation)
(defmacro when-positive (x &body body)
  `(when (> ,x 0)
     ,@body))
```

### [TeaVM](teavm/)
Java-to-JavaScript/WebAssembly transpiler.
- **Key Topics**: Java in browsers, WebAssembly, cross-platform development

**Basic Syntax:**
```java
// TeaVM uses Java syntax but compiles to JavaScript/WebAssembly
import org.teavm.jso.browser.Window;
import org.teavm.jso.dom.html.HTMLDocument;
import org.teavm.jso.dom.html.HTMLElement;
import org.teavm.jso.JSBody;
import java.util.List;
import java.util.Arrays;

// Hello World (runs in browser)
public class HelloWorld {
    public static void main(String[] args) {
        Window.alert("Hello, World!");
    }
}

// DOM Manipulation
public class DOMExample {
    public static void main(String[] args) {
        HTMLDocument document = Window.current().getDocument();
        HTMLElement element = document.getElementById("myElement");
        element.setInnerHTML("Hello from TeaVM!");
    }
}

// Standard Java features work in TeaVM
public class JavaFeatures {
    // Variables and Constants
    static final int CONSTANT = 42;
    int mutable = 100;
    
    // Functions
    public int add(int a, int b) {
        return a + b;
    }
    
    // Classes
    static class Point {
        float x, y;
        
        Point(float x, float y) {
            this.x = x;
            this.y = y;
        }
    }
    
    // Collections
    public void processData() {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);
        numbers.stream()
            .filter(n -> n % 2 == 0)
            .forEach(n -> Window.console().log(n));
    }
}

// Interop with JavaScript
public class JSInterop {
    @JSBody(params = {"message"}, script = "console.log(message);")
    public static native void log(String message);
    
    @JSBody(params = {}, script = "return new Date().getTime();")
    public static native long getCurrentTime();
}
```

### [Zig](zig/)
Modern systems programming language focusing on performance, safety, and maintainability.
- **Key Topics**: Systems programming, comptime, C interoperability, memory safety

**Basic Syntax:**
```zig
// Hello World
const std = @import("std");

pub fn main() void {
    std.debug.print("Hello, World!\n", .{});
}

// Variables and Constants
const constant: i32 = 42; // Immutable constant
var mutable: i32 = 100; // Mutable variable
const inferred = 3.14; // Type inference

// Functions
fn add(a: i32, b: i32) i32 {
    return a + b;
}

// Error Handling
fn divide(a: i32, b: i32) !i32 {
    if (b == 0) return error.DivisionByZero;
    return @divTrunc(a, b);
}

// Structs
const Point = struct {
    x: f32,
    y: f32,
    
    pub fn init(x: f32, y: f32) Point {
        return Point{ .x = x, .y = y };
    }
};

// Control Flow
const x = 10;
if (x > 0) {
    // if block
} else {
    // else block
}

const numbers = [_]i32{1, 2, 3, 4, 5};
for (numbers) |num| {
    // loop body
}

var i: i32 = 0;
while (i < 10) : (i += 1) {
    // loop body
}

// Optionals
const maybe_value: ?i32 = null;
const value: i32 = maybe_value orelse 0;

// Compile-time evaluation (comptime)
fn fibonacci(comptime n: u32) u32 {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}
```

### [Ballerina](ballerina/)
Cloud-native programming language specialized for integration and networked services.
- **Key Topics**: Web services, webhooks, concurrent workers, API integration, data transformation

**Basic Syntax:**
```ballerina
// Hello World
import ballerina/io;

public function main() {
    io:println("Hello, World!");
}

// Variables and Constants
const int CONSTANT = 42; // Immutable constant
int mutable = 100; // Mutable variable
var inferred = 3.14; // Type inference

// Functions
function add(int a, int b) returns int {
    return a + b;
}

// Error Handling
function divide(int a, int b) returns int|error {
    if (b == 0) {
        return error("Division by zero");
    }
    return a / b;
}

// Using error handling
int|error result = divide(10, 2);
if (result is error) {
    io:println("Error: ", result.message());
} else {
    io:println("Result: ", result);
}

// Records (similar to structs/classes)
type Point record {
    float x;
    float y;
};

function distanceFromOrigin(Point p) returns float {
    return float:sqrt(p.x * p.x + p.y * p.y);
}

// Control Flow
int x = 10;
if (x > 0) {
    // if block
} else {
    // else block
}

int[] numbers = [1, 2, 3, 4, 5];
foreach int num in numbers {
    // loop body
}

int i = 0;
while (i < 10) {
    // loop body
    i += 1;
}

// Optionals
int? maybeValue = ();
int value = maybeValue ?: 0;

// HTTP Service
import ballerina/http;

service /api on new http:Listener(8080) {
    resource function get greeting() returns string {
        return "Hello from Ballerina!";
    }
}

// Concurrent Workers
worker A {
    int value = 42;
    value -> B;
}

worker B {
    int received = <- A;
    io:println("Received: ", received);
}

// Query Expressions
type Person record {
    string name;
    int age;
};

Person[] people = [
    {name: "Alice", age: 30},
    {name: "Bob", age: 25}
];

var adults = from var person in people
             where person.age >= 18
             select person.name;
```

### [R](r/)
Programming language and environment for statistical computing and data analysis.
- **Key Topics**: Web applications with Shiny, parallel processing, webhooks with Plumber, data analysis pipelines

**Basic Syntax:**
```r
# Hello World
library(dplyr) # Load dplyr for pipe operator examples

print("Hello, World!")
cat("Hello, World!\n")

# Variables and Constants
CONSTANT <- 42 # Convention: uppercase for constants
mutable <- 100 # Assignment with <-
mutable = 100  # Also valid with =
inferred <- 3.14 # Dynamic typing

# Functions
add <- function(a, b) {
  return(a + b)
}

# Implicit return (last expression)
multiply <- function(a, b) {
  a * b
}

# Error Handling
divide <- function(a, b) {
  if (b == 0) {
    stop("Division by zero")
  }
  return(a / b)
}

# Try-catch
tryCatch(
  divide(10, 0),
  error = function(e) {
    message("Error: ", e$message)
  }
)

# Lists (similar to classes/structs)
Point <- function(x, y) {
  list(
    x = x,
    y = y,
    distanceFromOrigin = function() {
      sqrt(x^2 + y^2)
    }
  )
}

point <- Point(3.0, 4.0)
print(point$distanceFromOrigin())

# Control Flow
x <- 10
if (x > 0) {
  # if block
} else {
  # else block
}

numbers <- c(1, 2, 3, 4, 5)
for (num in numbers) {
  # loop body
  print(num)
}

i <- 0
while (i < 10) {
  # loop body
  i <- i + 1
}

# NA (missing values)
maybe_value <- NA
value <- ifelse(is.na(maybe_value), 0, maybe_value)

# Vectorized operations
doubled <- numbers * 2
evens <- numbers[numbers %% 2 == 0]
total <- sum(numbers)

# Apply family functions
squared <- sapply(numbers, function(x) x^2)
filtered <- Filter(function(x) x > 2, numbers)

# Data Frames
df <- data.frame(
  name = c("Alice", "Bob", "Charlie"),
  age = c(25, 30, 35),
  stringsAsFactors = FALSE
)

# Subsetting
adults <- df[df$age >= 18, ]

# Pipe operator (magrittr/dplyr)
result <- df %>%
  filter(age >= 25) %>%
  select(name)
```
### [Kotlin](kotlin/)
Modern, statically typed programming language for JVM and Android development.
- **Frameworks**: Android SDK, Jetpack Compose
- **Key Topics**: Android mobile development, null safety, coroutines, functional programming, mobile apps

**Basic Syntax:**
```kotlin
// Hello World
fun main() {
    println("Hello, World!")
}

// Variables and Constants
const val CONSTANT = 42 // Compile-time constant
val immutable = 100 // Immutable variable (read-only)
var mutable = 200 // Mutable variable
val inferred = 3.14 // Type inference

// Functions
fun add(a: Int, b: Int): Int {
    return a + b
}

// Single expression function
fun multiply(a: Int, b: Int) = a * b

// Error Handling
fun divide(a: Int, b: Int): Int {
    if (b == 0) throw ArithmeticException("Division by zero")
    return a / b
}

// Try-catch
try {
    divide(10, 0)
} catch (e: ArithmeticException) {
    println("Error: ${e.message}")
}

// Classes and Data Classes
class Point(val x: Float, val y: Float) {
    fun distanceFromOrigin(): Double {
        return Math.sqrt((x * x + y * y).toDouble())
    }
}

// Data class (auto-generates equals, hashCode, toString, copy)
data class Person(val name: String, val age: Int)

// Control Flow
val x = 10
if (x > 0) {
    // if block
} else {
    // else block
}

val numbers = listOf(1, 2, 3, 4, 5)
for (num in numbers) {
    // loop body
}

var i = 0
while (i < 10) {
    // loop body
    i++
}

// Null Safety
val maybeValue: Int? = null // Nullable type
val value = maybeValue ?: 0 // Elvis operator

// Safe call operator
val length = maybeValue?.toString()?.length

// Higher-order Functions and Lambdas
val doubled = numbers.map { it * 2 }
val evens = numbers.filter { it % 2 == 0 }
val sum = numbers.reduce { acc, n -> acc + n }

// When Expression (pattern matching)
val number = 7
when (number) {
    1 -> println("One")
    in 2..5 -> println("Two to Five")
    else -> println("Something else")
}

// Extension Functions
fun String.addExclamation() = this + "!"
val greeting = "Hello".addExclamation() // "Hello!"

// Coroutines (async/await)
import kotlinx.coroutines.*

suspend fun fetchData(): String {
    delay(1000) // Non-blocking delay
    return "Data"
}

// Usage in coroutine scope
runBlocking {
    val result = async { fetchData() }
    println(result.await())
}

// Scope Functions
val person = Person("Alice", 30).apply {
    // this refers to person
    println("Created: $name")
}

// Smart Casts
fun processValue(value: Any) {
    if (value is String) {
        // value is automatically cast to String
        println(value.length)
    }
}
```

### [Swift](swift/)
Powerful, intuitive programming language for iOS, macOS, and Apple ecosystem development.
- **Frameworks**: SwiftUI, UIKit
- **Key Topics**: iOS mobile development, memory safety, modern concurrency, protocol-oriented programming, mobile apps

**Basic Syntax:**
```swift
// Hello World
import Foundation

print("Hello, World!")

// Variables and Constants
let constant = 42 // Immutable constant
var mutable = 100 // Mutable variable
let inferred = 3.14 // Type inference
var typed: String = "Swift"

// Functions
func add(a: Int, b: Int) -> Int {
    return a + b
}

// Implicit return (single expression)
func multiply(a: Int, b: Int) -> Int {
    a * b
}

// Error Handling
enum DivisionError: Error {
    case divisionByZero
}

func divide(a: Int, b: Int) throws -> Int {
    if b == 0 {
        throw DivisionError.divisionByZero
    }
    return a / b
}

// Do-try-catch
do {
    let result = try divide(a: 10, b: 0)
    print("Result: \(result)")
} catch {
    print("Error: \(error)")
}

// Structs and Classes
struct Point {
    var x: Float
    var y: Float
    
    func distanceFromOrigin() -> Double {
        return sqrt(Double(x * x + y * y))
    }
}

class Person {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

// Control Flow
let x = 10
if x > 0 {
    // if block
} else {
    // else block
}

let numbers = [1, 2, 3, 4, 5]
for num in numbers {
    // loop body
}

var i = 0
while i < 10 {
    // loop body
    i += 1
}

// Optionals
var maybeValue: Int? = nil // Optional type
let value = maybeValue ?? 0 // Nil coalescing

// Optional binding
if let unwrapped = maybeValue {
    print("Value: \(unwrapped)")
} else {
    print("No value")
}

// Guard statement
func processValue(_ value: Int?) {
    guard let value = value else {
        return
    }
    print(value)
}

// Higher-order Functions and Closures
let doubled = numbers.map { $0 * 2 }
let evens = numbers.filter { $0 % 2 == 0 }
let sum = numbers.reduce(0) { $0 + $1 }

// Trailing closure syntax
let sorted = numbers.sorted { $0 > $1 }

// Switch Statement (pattern matching)
let number = 7
switch number {
case 1:
    print("One")
case 2...5:
    print("Two to Five")
default:
    print("Something else")
}

// Enums with Associated Values
enum Result<T> {
    case success(T)
    case failure(Error)
}

let result: Result<Int> = .success(42)
switch result {
case .success(let value):
    print("Success: \(value)")
case .failure(let error):
    print("Error: \(error)")
}

// Protocols
protocol Drawable {
    func draw()
}

struct Circle: Drawable {
    var radius: Double
    
    func draw() {
        print("Drawing circle with radius \(radius)")
    }
}

// Extensions
extension Int {
    func squared() -> Int {
        return self * self
    }
}

let squared = 5.squared() // 25

// Generics
func swapValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

// Property Observers
class Counter {
    var count: Int = 0 {
        willSet {
            print("Will set to \(newValue)")
        }
        didSet {
            print("Did set from \(oldValue)")
        }
    }
}

// Async/Await (Swift 5.5+)
func fetchData() async throws -> String {
    try await Task.sleep(nanoseconds: 1_000_000_000)
    return "Data"
}

Task {
    do {
        let data = try await fetchData()
        print(data)
    } catch {
        print("Error: \(error)")
    }
}

// Computed Properties
struct Rectangle {
    var width: Double
    var height: Double
    
    var area: Double {
        return width * height
    }
}
```

### DevOps and Cloud Management

### [DevOps & AWS - Zero to Expert](devops-aws/)
Comprehensive learning path for DevOps practices and AWS cloud management.
- **Level 1 (Fundamentals)**: Linux, Git, Docker, AWS basics
- **Level 2 (Intermediate)**: CI/CD, Kubernetes, Terraform, AWS core services
- **Level 3 (Advanced)**: Advanced K8s, serverless, monitoring, security, high availability
- **Level 4 (Expert)**: Multi-cloud, service mesh, GitOps, platform engineering, chaos engineering
- **Duration**: 24-week structured curriculum with hands-on labs
- **Certifications**: Prepares for AWS and Kubernetes certifications
- **Key Topics**: Infrastructure as Code, container orchestration, cloud architecture, security, observability

### Cloud Services and Tools

The `src/` directory contains cloud services and infrastructure tools:
- **AWS**: Step Functions, Lambda, S3, CDK
- **Google Cloud**: Cloud Functions, App Engine, Kubernetes
- **Infrastructure**: Kubernetes, Docker, CI/CD

## How to Use This Repository

1. **Choose a Language**: Navigate to the language directory you want to study
2. **Explore Frameworks**: Check framework-specific subdirectories for advanced examples  
3. **Start with Samples**: Begin with the `samples/` directory for pure language examples
4. **Read Documentation**: Each directory contains comprehensive README.md files
5. **Run Examples**: Follow setup instructions in each directory's README

## Contribution Guidelines

1. **Language-First Organization**: Place content in appropriate language directories
2. **Framework Separation**: Keep framework examples in dedicated subdirectories
3. **Comprehensive Documentation**: Include README.md files with setup and usage instructions
4. **Working Examples**: Ensure all code examples compile and run successfully
5. **Consistent Structure**: Follow the established directory structure

### Adding New Content

1. **New Language**: Create new top-level directory with `samples/` subdirectory
2. **New Framework**: Add framework subdirectory under appropriate language
3. **New Examples**: Place in relevant `samples/` or framework directory
4. **Documentation**: Update README.md files to reflect new content

## Resources and References

- [Web Development Best Practices](https://developer.mozilla.org/en-US/docs/Learn)
- [Cloud Native Computing Foundation](https://www.cncf.io/)
- [Modern Web Development Frameworks](https://jamstack.org/)
- [Microservices Architecture](https://microservices.io/)
- [C Study Repository](https://github.com/smaruf/c-study)

Feel free to explore each language and framework, and contribute to the repository by adding more sample applications and documentation.
