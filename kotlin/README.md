# Kotlin

[← Back to Main](../README.md) | [Web Study Repository](https://github.com/iTasks/web-study)

## Purpose

This directory contains Kotlin programming language study materials, sample applications, and mobile development implementations. Kotlin is a modern, statically typed programming language that runs on the Java Virtual Machine (JVM) and is Google's preferred language for Android app development.

## Contents

### Mobile Development
- **[Android App](android-app/)**: Native Android mobile application development
  - Jetpack Compose for modern UI development
  - Material Design components
  - MVVM architecture patterns
  - Room database integration
  - Retrofit for networking

### Pure Language Samples
- **[Samples](samples/)**: Core Kotlin language examples
  - Data classes and sealed classes
  - Coroutines and Flow
  - Extension functions
  - Null safety demonstrations
  - Collection operations
  - Higher-order functions

## Setup Instructions

### Prerequisites
- Java Development Kit (JDK) 11 or higher
- Kotlin compiler 1.8 or higher
- Android Studio (for mobile development)
- Gradle 7.0+ for build automation

### Installation
1. **Install Java JDK**
   ```bash
   # On Ubuntu/Debian
   sudo apt update
   sudo apt install openjdk-11-jdk
   
   # On macOS with Homebrew
   brew install openjdk@11
   
   # Verify installation
   java -version
   ```

2. **Install Kotlin Compiler**
   ```bash
   # On Ubuntu/Debian
   sudo snap install --classic kotlin
   
   # On macOS with Homebrew
   brew install kotlin
   
   # Verify installation
   kotlin -version
   ```

3. **Install Android Studio** (for mobile development)
   - Download from [Android Studio website](https://developer.android.com/studio)
   - Follow installation wizard
   - Install Android SDK and required tools

### Building and Running

#### For samples directory:
```bash
cd kotlin/samples
kotlinc HelloWorld.kt -include-runtime -d HelloWorld.jar
java -jar HelloWorld.jar
```

#### For Android applications:
```bash
cd kotlin/android-app
./gradlew build
./gradlew installDebug  # Install on connected device/emulator
```

#### Using Gradle:
```bash
cd kotlin/samples
gradle build
gradle run
```

## Usage

### Running Sample Applications
Each sample in the `samples/` directory can be compiled and run independently:

```bash
# Compile a specific Kotlin file
kotlinc samples/Application.kt -include-runtime -d Application.jar

# Run the compiled jar
java -jar Application.jar
```

### Working with Android Applications
Navigate to the Android project directory and use Gradle commands:

```bash
cd kotlin/android-app
./gradlew assembleDebug  # Build debug APK
./gradlew installDebug   # Install on device
./gradlew test           # Run unit tests
```

## Project Structure

```
kotlin/
├── README.md                 # This file
├── samples/                  # Pure Kotlin language examples
│   ├── HelloWorld.kt        # Basic Kotlin application
│   ├── Coroutines.kt        # Coroutine examples
│   ├── DataClasses.kt       # Data class demonstrations
│   ├── Extensions.kt        # Extension function examples
│   ├── Collections.kt       # Collection operations
│   └── build.gradle.kts     # Gradle build configuration
└── android-app/             # Android mobile application
    ├── app/
    │   ├── src/
    │   │   └── main/
    │   │       ├── kotlin/  # Kotlin source files
    │   │       └── res/     # Android resources
    │   └── build.gradle.kts
    ├── gradle/
    ├── gradlew              # Gradle wrapper script
    └── settings.gradle.kts
```

## Key Learning Topics

- **Core Kotlin Concepts**: Classes, objects, functions, lambdas, properties
- **Null Safety**: Nullable types, safe calls, elvis operator
- **Coroutines**: Asynchronous programming, suspend functions, Flow
- **Collections**: List, Set, Map operations with functional programming
- **Android Development**: Activities, fragments, Jetpack Compose, ViewModels
- **Modern Android**: Material Design 3, Navigation component, dependency injection
- **Architecture**: MVVM, Clean Architecture, repository pattern
- **Testing**: JUnit, MockK, Espresso for UI testing

## Contribution Guidelines

1. **Code Style**: Follow Kotlin coding conventions and Android style guide
2. **Documentation**: Include KDoc comments for public APIs
3. **Testing**: Write unit tests using JUnit and integration tests
4. **Dependencies**: Use Gradle for dependency management
5. **Examples**: Provide clear, runnable examples with sample data

### Adding New Samples
1. Place pure Kotlin examples in the `samples/` directory
2. Add mobile-specific examples in the Android app directory
3. Update this README with new content descriptions
4. Ensure all code compiles and runs successfully

### Code Quality Standards
- Use meaningful variable and function names
- Leverage Kotlin idioms (data classes, sealed classes, etc.)
- Prefer immutability where possible
- Handle errors appropriately with Result or exceptions
- Write clean, idiomatic Kotlin code

## Resources and References

- [Official Kotlin Documentation](https://kotlinlang.org/docs/home.html)
- [Android Developer Documentation](https://developer.android.com/kotlin)
- [Kotlin Coroutines Guide](https://kotlinlang.org/docs/coroutines-guide.html)
- [Jetpack Compose Documentation](https://developer.android.com/jetpack/compose)
- [Kotlin Style Guide](https://kotlinlang.org/docs/coding-conventions.html)
- [Android Architecture Guide](https://developer.android.com/topic/architecture)
- [Kotlin Playground](https://play.kotlinlang.org/)
- [Android Codelabs](https://developer.android.com/courses)
