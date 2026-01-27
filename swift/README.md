# Swift

[← Back to Main](../README.md) | [Web Study Repository](https://github.com/iTasks/web-study)

## Purpose

This directory contains Swift programming language study materials, sample applications, and mobile development implementations. Swift is a powerful, intuitive programming language developed by Apple for iOS, macOS, watchOS, and tvOS app development.

## Contents

### Mobile Development
- **iOS**: Native iOS mobile application development
  - SwiftUI for modern declarative UI
  - UIKit for traditional UI development
  - Combine framework for reactive programming
  - Core Data for persistence
  - URLSession for networking

### Pure Language Samples
- `samples/`: Core Swift language examples
  - Protocols and protocol extensions
  - Generics and associated types
  - Closures and higher-order functions
  - Error handling with Result type
  - Value types vs reference types
  - Property wrappers and result builders

## Setup Instructions

### Prerequisites
- macOS (required for iOS development)
- Xcode 14 or higher
- Swift 5.7 or higher
- iOS Simulator or physical iOS device

### Installation
1. **Install Xcode**
   - Download from Mac App Store or [Apple Developer](https://developer.apple.com/xcode/)
   - Open Xcode and accept license agreement
   - Install additional components when prompted

2. **Install Xcode Command Line Tools**
   ```bash
   xcode-select --install
   
   # Verify installation
   swift --version
   xcodebuild -version
   ```

3. **Setup iOS Simulator** (optional)
   - Open Xcode → Preferences → Components
   - Download desired iOS simulator versions

### Building and Running

#### For samples directory:
```bash
cd swift/samples
swift HelloWorld.swift
```

#### For iOS applications:
```bash
cd swift/ios-app
xcodebuild -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 14' build

# Or open in Xcode
open ios-app/MyApp.xcodeproj
# Then press Cmd+R to build and run
```

#### Using Swift Package Manager:
```bash
cd swift/samples
swift build
swift run
```

## Usage

### Running Sample Applications
Each sample in the `samples/` directory can be compiled and run independently:

```bash
# Run a Swift file directly
swift samples/Application.swift

# Or compile and run
swiftc samples/Application.swift -o Application
./Application
```

### Working with iOS Applications
Navigate to the iOS project directory:

```bash
# Open project in Xcode
cd swift/ios-app
open MyApp.xcodeproj

# Build from command line
xcodebuild -scheme MyApp -configuration Debug build

# Run tests
xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 14'
```

### Using Swift Playgrounds
For interactive learning, open `.playground` files in Xcode:
```bash
open swift/samples/Learning.playground
```

## Project Structure

```
swift/
├── README.md                 # This file
├── samples/                  # Pure Swift language examples
│   ├── HelloWorld.swift     # Basic Swift application
│   ├── Protocols.swift      # Protocol examples
│   ├── Generics.swift       # Generic programming
│   ├── Closures.swift       # Closure examples
│   ├── ErrorHandling.swift  # Error handling patterns
│   ├── Collections.swift    # Collection operations
│   └── Package.swift        # Swift Package Manager config
└── ios-app/                 # iOS mobile application
    ├── MyApp.xcodeproj/     # Xcode project
    ├── MyApp/
    │   ├── ContentView.swift    # SwiftUI views
    │   ├── Models/              # Data models
    │   ├── ViewModels/          # View models
    │   ├── Services/            # Business logic
    │   └── Resources/           # Assets and resources
    ├── MyAppTests/          # Unit tests
    └── MyAppUITests/        # UI tests
```

## Key Learning Topics

- **Core Swift Concepts**: Structs, classes, enums, protocols, generics
- **Memory Management**: ARC (Automatic Reference Counting), weak/strong references
- **Functional Programming**: Map, filter, reduce, higher-order functions
- **Concurrency**: async/await, actors, TaskGroup, structured concurrency
- **iOS Development**: SwiftUI, UIKit, App lifecycle, navigation
- **Modern iOS**: Widgets, App Clips, SharePlay, Live Activities
- **Architecture**: MVVM, Clean Architecture, Coordinator pattern
- **Testing**: XCTest, UI testing, snapshot testing

## Contribution Guidelines

1. **Code Style**: Follow Swift API Design Guidelines
2. **Documentation**: Include documentation comments for public APIs
3. **Testing**: Write unit tests using XCTest
4. **Dependencies**: Use Swift Package Manager or CocoaPods
5. **Examples**: Provide clear, runnable examples with sample data

### Adding New Samples
1. Place pure Swift examples in the `samples/` directory
2. Add mobile-specific examples in the iOS app directory
3. Update this README with new content descriptions
4. Ensure all code compiles and runs successfully

### Code Quality Standards
- Use meaningful variable and function names
- Leverage Swift's type system and safety features
- Prefer value types (structs) over reference types when appropriate
- Use guard statements for early returns
- Handle optionals safely with optional binding or nil coalescing
- Write clean, idiomatic Swift code

## Resources and References

- [Official Swift Documentation](https://swift.org/documentation/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Swift Programming Language Book](https://docs.swift.org/swift-book/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Swift Evolution](https://apple.github.io/swift-evolution/)
- [WWDC Videos](https://developer.apple.com/videos/)
- [Ray Wenderlich Tutorials](https://www.raywenderlich.com/ios)
- [Hacking with Swift](https://www.hackingwithswift.com/)
