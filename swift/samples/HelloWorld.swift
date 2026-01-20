/**
 * HelloWorld.swift
 * 
 * A simple Swift program demonstrating basic syntax and output.
 * This is the starting point for learning Swift programming.
 */

import Foundation

// Main program execution
func main() {
    // Print a simple greeting
    print("Hello, Swift!")
    print("Welcome to mobile development with Swift!")
    
    // Variables demonstration
    let language = "Swift"    // Immutable constant (let)
    var version = "5.9"       // Mutable variable (var)
    
    print("\nLanguage: \(language)")
    print("Version: \(version)")
    
    // String interpolation
    print("\nYou are learning \(language) version \(version) for iOS development!")
    
    // Function call
    greet(name: "iOS Developer")
}

/**
 * Function to greet a person
 * - Parameter name: The name of the person to greet
 */
func greet(name: String) {
    print("\nHello, \(name)!")
    print("Get ready to build amazing iOS apps with Swift!")
}

// Execute main function
main()
