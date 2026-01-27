# iOS App with Swift

[← Back to Swift](../README.md) | [Main README](../../README.md)

## Overview

This is a sample iOS mobile application built with Swift and SwiftUI, demonstrating modern iOS development practices including declarative UI, MVVM architecture, and the latest iOS frameworks.

## Features

- **SwiftUI**: Modern declarative UI framework
- **MVVM Architecture**: Clean separation of concerns
- **Combine**: Reactive programming for data flow
- **Async/Await**: Modern Swift concurrency
- **Navigation**: SwiftUI NavigationStack
- **Data Persistence**: Core Data or SwiftData integration

## Project Structure

```
ios-app/
├── MyApp.xcodeproj/           # Xcode project file
├── MyApp/
│   ├── MyAppApp.swift         # App entry point
│   ├── Views/
│   │   ├── ContentView.swift  # Main view
│   │   └── DetailView.swift   # Detail views
│   ├── ViewModels/
│   │   └── ContentViewModel.swift
│   ├── Models/
│   │   └── DataModels.swift
│   ├── Services/
│   │   └── NetworkService.swift
│   ├── Resources/
│   │   ├── Assets.xcassets/   # Images and colors
│   │   └── Info.plist
│   └── Preview Content/       # Preview assets
├── MyAppTests/                # Unit tests
└── MyAppUITests/              # UI tests
```

## Prerequisites

- macOS 13 (Ventura) or newer
- Xcode 14 or newer
- Swift 5.7 or higher
- iOS 16.0+ (deployment target)

## Setup Instructions

1. **Open Project in Xcode**
   ```bash
   cd swift/ios-app
   open MyApp.xcodeproj
   ```

2. **Configure Signing**
   - Select the project in Xcode
   - Go to "Signing & Capabilities" tab
   - Select your development team

3. **Select Simulator or Device**
   - Choose a simulator from the device menu
   - Or connect a physical iOS device

## Building and Running

### Using Xcode
1. Open `MyApp.xcodeproj` in Xcode
2. Select a simulator or connected device
3. Click the "Run" button (play icon) or press Cmd+R
4. The app will build and launch automatically

### Using Command Line
```bash
# Build the project
xcodebuild -scheme MyApp -configuration Debug build

# Run on simulator
xcodebuild -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 14' build

# Run tests
xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 14'

# Archive for release
xcodebuild archive -scheme MyApp -archivePath MyApp.xcarchive
```

## Key Components

### MyAppApp.swift
The main entry point using the `@main` attribute and SwiftUI App protocol.

### ContentView.swift
The primary view of the application built with SwiftUI.

### ViewModels
ObservableObject classes that manage state and business logic.

### Models
Data structures representing the app's domain objects.

### Services
Network requests, data persistence, and other service layers.

## Dependencies

SwiftUI apps use Swift Package Manager for dependencies. Common packages include:

- **Alamofire**: Elegant HTTP networking
- **SDWebImage**: Async image loading
- **SwiftLint**: Code style and conventions
- **Realm**: Mobile database
- **Firebase**: Backend services

### Adding Dependencies
1. File → Add Packages...
2. Enter package URL
3. Select version/branch
4. Add to target

## SwiftUI Previews

SwiftUI provides live previews in Xcode:

```swift
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

Enable Canvas: Editor → Canvas (Cmd+Option+Return)

## Learning Resources

- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Swift Documentation](https://swift.org/documentation/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [WWDC Videos](https://developer.apple.com/videos/)
- [100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui)

## Next Steps

1. Explore SwiftUI view modifiers and layouts
2. Implement navigation with NavigationStack
3. Add networking with URLSession or Alamofire
4. Implement data persistence with Core Data or SwiftData
5. Add unit tests and UI tests
6. Integrate with iOS frameworks (Maps, Camera, etc.)

## Common Tasks

### Add a new view
1. Create new Swift file: File → New → File
2. Select SwiftUI View template
3. Add view to navigation hierarchy

### Change app icon
1. Select Assets.xcassets
2. Click AppIcon
3. Drag images to appropriate slots

### Add a Swift package
1. File → Add Packages...
2. Search or paste package URL
3. Select version and add to target

### Configure app settings
Edit Info.plist or use Xcode's Info tab in project settings.

## Troubleshooting

- **Build fails**: Clean build folder (Cmd+Shift+K) and rebuild
- **Simulator issues**: Reset simulator (Device → Erase All Content and Settings)
- **Signing errors**: Check team selection in Signing & Capabilities
- **Preview crashes**: Ensure preview provider is correctly configured
- **SwiftUI state issues**: Check @State, @Binding, @ObservedObject usage

## Testing

### Unit Tests
```swift
import XCTest
@testable import MyApp

class MyAppTests: XCTestCase {
    func testExample() {
        // Test code here
    }
}
```

### UI Tests
```swift
import XCTest

class MyAppUITests: XCTestCase {
    func testExample() {
        let app = XCUIApplication()
        app.launch()
        // UI test code here
    }
}
```

Run tests: Product → Test (Cmd+U)
