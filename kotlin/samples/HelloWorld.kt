/**
 * HelloWorld.kt
 * 
 * A simple Kotlin program demonstrating basic syntax and output.
 * This is the starting point for learning Kotlin programming.
 */

fun main() {
    // Print a simple greeting
    println("Hello, Kotlin!")
    println("Welcome to mobile development with Kotlin!")
    
    // Variables demonstration
    val language = "Kotlin"  // Immutable variable (val)
    var version = "1.9"      // Mutable variable (var)
    
    println("\nLanguage: $language")
    println("Version: $version")
    
    // String interpolation
    println("\nYou are learning $language version $version for Android development!")
    
    // Function call
    greet("Mobile Developer")
}

/**
 * Function to greet a person
 * @param name The name of the person to greet
 */
fun greet(name: String) {
    println("\nHello, $name!")
    println("Get ready to build amazing Android apps with Kotlin!")
}
