# Android App with Kotlin

[← Back to Kotlin](../README.md) | [Main README](../../README.md)

## Overview

This is a sample Android mobile application built with Kotlin, demonstrating modern Android development practices including Jetpack Compose, MVVM architecture, and Material Design 3.

## Features

- **Modern UI**: Built with Jetpack Compose for declarative UI
- **Material Design 3**: Latest Material Design components and theming
- **MVVM Architecture**: Separation of concerns with ViewModels
- **Coroutines**: Asynchronous programming with Kotlin Coroutines
- **Navigation**: Type-safe navigation with Jetpack Navigation Compose
- **Dependency Injection**: Using Hilt for dependency management

## Project Structure

```
android-app/
├── app/
│   ├── src/
│   │   ├── main/
│   │   │   ├── kotlin/
│   │   │   │   ├── ui/
│   │   │   │   │   ├── MainActivity.kt
│   │   │   │   │   ├── theme/
│   │   │   │   │   └── screens/
│   │   │   │   ├── viewmodel/
│   │   │   │   ├── model/
│   │   │   │   └── MyApplication.kt
│   │   │   ├── res/
│   │   │   │   ├── values/
│   │   │   │   ├── drawable/
│   │   │   │   └── layout/
│   │   │   └── AndroidManifest.xml
│   │   ├── test/              # Unit tests
│   │   └── androidTest/        # Instrumentation tests
│   └── build.gradle.kts
├── gradle/
├── gradlew
├── gradlew.bat
└── settings.gradle.kts
```

## Prerequisites

- Android Studio Hedgehog or newer
- JDK 11 or higher
- Android SDK with minimum API level 24 (Android 7.0)
- Kotlin 1.9 or higher

## Setup Instructions

1. **Open Project in Android Studio**
   ```bash
   cd kotlin/android-app
   # Open the project in Android Studio
   ```

2. **Sync Gradle**
   - Android Studio will automatically sync Gradle dependencies
   - Wait for the sync to complete

3. **Configure Emulator or Device**
   - Set up an Android Virtual Device (AVD) in Android Studio
   - Or connect a physical Android device with USB debugging enabled

## Building and Running

### Using Android Studio
1. Open the project in Android Studio
2. Click the "Run" button (green play icon) or press Shift+F10
3. Select a target device or emulator
4. The app will build and launch automatically

### Using Command Line
```bash
# Build debug APK
./gradlew assembleDebug

# Install on connected device
./gradlew installDebug

# Build and run
./gradlew installDebug && adb shell am start -n com.example.myapp/.MainActivity

# Run tests
./gradlew test
./gradlew connectedAndroidTest
```

## Key Components

### MainActivity.kt
The main entry point of the application using Jetpack Compose.

### Jetpack Compose UI
Modern declarative UI framework for building native Android interfaces.

### ViewModel
Manages UI-related data in a lifecycle-conscious way.

### Repository Pattern
Abstracts data sources and provides a clean API to the rest of the app.

## Dependencies

- **Jetpack Compose**: Modern UI toolkit
- **Material3**: Material Design components
- **Navigation Compose**: Type-safe navigation
- **ViewModel**: Lifecycle-aware data management
- **Coroutines**: Asynchronous programming
- **Hilt**: Dependency injection
- **Room**: Local database
- **Retrofit**: Network requests

## Learning Resources

- [Android Developer Guides](https://developer.android.com/guide)
- [Jetpack Compose Tutorial](https://developer.android.com/jetpack/compose/tutorial)
- [Kotlin for Android](https://developer.android.com/kotlin)
- [Material Design 3](https://m3.material.io/)
- [Android Codelabs](https://developer.android.com/courses)

## Next Steps

1. Explore the UI components in Jetpack Compose
2. Implement additional screens and navigation
3. Add network requests with Retrofit
4. Implement local data persistence with Room
5. Add unit tests and UI tests
6. Integrate with backend APIs

## Common Tasks

### Add a new screen
1. Create a new Composable function in `ui/screens/`
2. Add navigation route in navigation graph
3. Create ViewModel if needed

### Add a dependency
Update `app/build.gradle.kts`:
```kotlin
dependencies {
    implementation("androidx.compose.ui:ui:1.5.0")
}
```

### Change app icon
Replace files in `app/src/main/res/mipmap-*/`

## Troubleshooting

- **Gradle sync fails**: Check internet connection and Gradle version
- **Build errors**: Clean and rebuild project (Build → Clean Project)
- **App crashes**: Check Logcat for error messages
- **Emulator issues**: Wipe data and restart AVD
