# React / React Native

## Purpose

This directory contains React and React Native framework examples and implementations. React is a JavaScript library for building user interfaces, and React Native extends React to mobile app development.

## Contents

- React Native mobile application components
- Interactive UI component examples
- State management demonstrations
- Navigation and routing examples
- AWS integration examples (CDK, Step Functions)

## Setup Instructions

### Prerequisites
- Node.js 16 or higher
- React Native CLI
- Android Studio (for Android development)
- Xcode (for iOS development on macOS)

### Installation
```bash
# Install React Native CLI
npm install -g @react-native-community/cli

# Install project dependencies
cd javascript/react
npm install

# For iOS (macOS only)
cd ios && pod install
```

### Running Applications

#### Android
```bash
cd javascript/react
npx react-native run-android
```

#### iOS (macOS only)
```bash
cd javascript/react
npx react-native run-ios
```

## Key Features

- **Component-Based**: Reusable UI components
- **Cross-Platform**: Single codebase for iOS and Android
- **Hot Reloading**: Fast development iteration
- **Native Performance**: Native module integration
- **Rich Ecosystem**: Extensive third-party library support

## Learning Topics

- React Native component lifecycle
- State management with hooks
- Navigation between screens
- Platform-specific code
- Native module integration
- Performance optimization
- UI/UX design patterns
- AWS integration patterns

## Resources and References

- [React Native Documentation](https://reactnative.dev/docs/getting-started)
- [React Documentation](https://reactjs.org/docs/getting-started.html)
- [React Native Community](https://github.com/react-native-community)
- [React Cheatsheet](https://devhints.io/react)
- [W3Schools React Tutorial](https://www.w3schools.com/react/default.asp)
