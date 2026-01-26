/**
 * ClosuresAndDSL.groovy
 * Demonstrates Groovy's powerful closures and DSL capabilities
 */

class ClosuresAndDSL {

    /**
     * Basic closure examples
     */
    static void demonstrateBasicClosures() {
        println "=== Basic Closures ==="
        
        // Simple closure
        def greet = { name -> println "Hello, $name!" }
        greet('Groovy')
        
        // Closure with implicit parameter 'it'
        def square = { it * it }
        println "Square of 5: ${square(5)}"
        
        // Multi-parameter closure
        def add = { a, b -> a + b }
        println "5 + 3 = ${add(5, 3)}"
        
        // Closure with no parameters
        def sayHello = { -> println "Hello!" }
        sayHello()
        println()
    }

    /**
     * Closure scope and delegation
     */
    static void demonstrateClosureScope() {
        println "=== Closure Scope ==="
        
        def outerVar = 'outer'
        def closure = {
            def innerVar = 'inner'
            println "Outer variable: $outerVar"
            println "Inner variable: $innerVar"
        }
        closure()
        
        // Closure can modify outer variables
        def counter = 0
        def increment = { counter++ }
        increment()
        increment()
        println "Counter after two increments: $counter"
        println()
    }

    /**
     * Higher-order functions with closures
     */
    static void demonstrateHigherOrderFunctions() {
        println "=== Higher-Order Functions ==="
        
        // Function that takes a closure
        def applyTwice = { func, value ->
            func(func(value))
        }
        
        def double = { it * 2 }
        println "Apply double twice to 3: ${applyTwice(double, 3)}"
        
        // Function that returns a closure
        def multiplier = { factor ->
            return { num -> num * factor }
        }
        
        def times3 = multiplier(3)
        println "3 * 7 = ${times3(7)}"
        println()
    }

    /**
     * Collection operations with closures
     */
    static void demonstrateCollectionClosures() {
        println "=== Collection Operations with Closures ==="
        
        def numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        
        // each - iterate
        print "Numbers: "
        numbers.each { print "$it " }
        println()
        
        // collect - map
        def squared = numbers.collect { it * it }
        println "Squared: $squared"
        
        // findAll - filter
        def evens = numbers.findAll { it % 2 == 0 }
        println "Evens: $evens"
        
        // any - check if any element matches
        println "Any number > 5: ${numbers.any { it > 5 }}"
        
        // every - check if all elements match
        println "All numbers positive: ${numbers.every { it > 0 }}"
        
        // inject - reduce/fold
        def sum = numbers.inject(0) { acc, val -> acc + val }
        println "Sum: $sum"
        println()
    }

    /**
     * Memoization with closures
     */
    static void demonstrateMemoization() {
        println "=== Memoization ==="
        
        // Fibonacci with memoization
        def fib
        fib = { n ->
            n <= 1 ? n : fib(n - 1) + fib(n - 2)
        }.memoize()
        
        println "Fibonacci(10): ${fib(10)}"
        println "Fibonacci(20): ${fib(20)}"
        println()
    }

    /**
     * Simple DSL for building HTML
     */
    static void demonstrateHTMLDSL() {
        println "=== HTML DSL ==="
        
        def html = new groovy.xml.MarkupBuilder(new StringWriter())
        
        def result = html.html {
            head {
                title('Groovy DSL Example')
            }
            body {
                h1('Welcome to Groovy DSL')
                p('This is a paragraph created using Groovy DSL')
                div(class: 'content') {
                    ul {
                        li('Item 1')
                        li('Item 2')
                        li('Item 3')
                    }
                }
            }
        }
        
        println "Generated HTML structure"
        println()
    }

    /**
     * Simple DSL for building configurations
     */
    static void demonstrateConfigDSL() {
        println "=== Configuration DSL ==="
        
        class ConfigBuilder {
            Map config = [:]
            
            def database(Closure closure) {
                def dbConfig = [:]
                closure.delegate = new DatabaseConfig(dbConfig)
                closure.resolveStrategy = Closure.DELEGATE_FIRST
                closure()
                config.database = dbConfig
            }
            
            def server(Closure closure) {
                def serverConfig = [:]
                closure.delegate = new ServerConfig(serverConfig)
                closure.resolveStrategy = Closure.DELEGATE_FIRST
                closure()
                config.server = serverConfig
            }
        }
        
        class DatabaseConfig {
            Map config
            DatabaseConfig(Map config) { this.config = config }
            def url(String value) { config.url = value }
            def username(String value) { config.username = value }
            def password(String value) { config.password = value }
        }
        
        class ServerConfig {
            Map config
            ServerConfig(Map config) { this.config = config }
            def port(Integer value) { config.port = value }
            def host(String value) { config.host = value }
        }
        
        def configure = { Closure closure ->
            def builder = new ConfigBuilder()
            closure.delegate = builder
            closure.resolveStrategy = Closure.DELEGATE_FIRST
            closure()
            return builder.config
        }
        
        // Using the DSL
        def config = configure {
            database {
                url 'jdbc:mysql://localhost:3306/mydb'
                username 'admin'
                password 'secret'
            }
            server {
                host 'localhost'
                port 8080
            }
        }
        
        println "Configuration: $config"
        println()
    }

    /**
     * Curry and partial application
     */
    static void demonstrateCurrying() {
        println "=== Currying and Partial Application ==="
        
        // Basic curry
        def add = { a, b -> a + b }
        def addFive = add.curry(5)
        println "5 + 3 = ${addFive(3)}"
        
        // Right curry
        def divide = { a, b -> a / b }
        def divideByTwo = divide.rcurry(2)
        println "10 / 2 = ${divideByTwo(10)}"
        
        // Multi-parameter curry
        def greet = { greeting, name, punctuation ->
            "$greeting, $name$punctuation"
        }
        def sayHello = greet.curry('Hello')
        def sayHelloJohn = sayHello.curry('John')
        println sayHelloJohn('!')
        println()
    }

    static void main(String[] args) {
        println "=== Closures and DSL in Groovy ==="
        println()
        
        demonstrateBasicClosures()
        demonstrateClosureScope()
        demonstrateHigherOrderFunctions()
        demonstrateCollectionClosures()
        demonstrateMemoization()
        demonstrateHTMLDSL()
        demonstrateConfigDSL()
        demonstrateCurrying()
    }
}
