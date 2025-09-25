# JavaScript

## Purpose

This directory contains JavaScript/TypeScript programming language study materials, sample applications, and framework implementations. JavaScript is a high-level, interpreted programming language that is one of the core technologies of the World Wide Web, alongside HTML and CSS.

## Contents

### Frameworks
- **Node.js**: JavaScript runtime built on Chrome's V8 JavaScript engine
  - `nodejs/`: Server-side JavaScript applications and utilities
  - `nodejs/lambda/`: AWS Lambda function implementations
- **React**: Library for building user interfaces, particularly React Native
  - `react/`: React Native mobile application examples

### Pure Language Samples
- `samples/`: Core JavaScript/TypeScript language examples
  - Testing frameworks (Pact.js)
  - Browser-based applications
  - TypeScript implementations
  - Interactive HTML/JavaScript demonstrations

## Setup Instructions

### Prerequisites
- Node.js 16 or higher
- npm (Node Package Manager) or yarn
- A modern web browser for client-side examples

### Installation
1. **Install Node.js**
   ```bash
   # On Ubuntu/Debian
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   
   # On macOS with Homebrew
   brew install node
   
   # On Windows, download from nodejs.org
   
   # Verify installation
   node --version
   npm --version
   ```

2. **Install Dependencies**
   ```bash
   # For Node.js samples
   cd javascript/nodejs
   npm install
   
   # For React Native samples
   cd javascript/react
   npm install
   
   # For testing samples
   cd javascript/samples
   npm install
   ```

### Building and Running

#### For Node.js applications:
```bash
cd javascript/nodejs
npm start
# Or run specific files
node app.js
```

#### For React Native applications:
```bash
cd javascript/react
npm install
npx react-native run-android  # For Android
npx react-native run-ios      # For iOS
```

#### For browser-based samples:
```bash
# Simply open HTML files in a web browser
open javascript/samples/startrek-adventure.html
```

## Usage

### Running Node.js Applications
Each Node.js application can be run using npm scripts or directly with node:

```bash
# Using npm scripts
cd javascript/nodejs
npm run dev

# Direct execution
node javascript/nodejs/server.js
```

### Working with React Native Examples
Navigate to the React Native directory:

```bash
cd javascript/react
npx react-native start
# In a new terminal
npx react-native run-android
```

### Testing with Pact.js
```bash
cd javascript/samples
npm test
# Or run specific test files
npm run test:pact
```

## Project Structure

```
javascript/
├── README.md                    # This file
├── nodejs/                      # Node.js framework examples
│   ├── lambda/                  # AWS Lambda functions
│   ├── ng/                      # Node.js applications
│   └── readme.md               # Node.js specific documentation
├── react/                       # React/React Native examples
│   ├── AppTryOne.js            # Basic React Native app
│   ├── ComponentCat.js         # Component examples
│   ├── HelloWorldApp.js        # Hello World implementation
│   ├── PropsMenu.jsx           # Props demonstration
│   ├── TextInputCat.jsx        # Input handling examples
│   ├── startreck.jsx           # Star Trek themed application
│   └── ...                     # Additional React components
└── samples/                     # Pure JavaScript/TypeScript examples
    ├── arrange_act_assert_test.ts # Testing patterns
    ├── startrek-adventure.html   # Interactive HTML/JS application
    ├── verify_provider.ts        # Pact.js provider verification
    └── README.md                 # Samples documentation
```

## Key Learning Topics

- **Core JavaScript**: ES6+, async/await, promises, closures, prototypes
- **Node.js**: Server-side development, Express.js, middleware, npm ecosystem
- **React/React Native**: Component-based architecture, JSX, state management, hooks
- **TypeScript**: Static typing, interfaces, generics, advanced types
- **Testing**: Unit testing, integration testing, contract testing with Pact.js
- **Asynchronous Programming**: Callbacks, promises, async/await patterns
- **Modern Development**: Babel, webpack, module systems (CommonJS, ES modules)

## Contribution Guidelines

1. **Code Style**: Follow JavaScript Standard Style or Airbnb style guide
2. **Documentation**: Include JSDoc comments for functions and classes
3. **Testing**: Write unit tests using Jest, Mocha, or similar frameworks
4. **Dependencies**: Use package.json for dependency management
5. **TypeScript**: Use TypeScript for larger applications, include type definitions

### Adding New Samples
1. Place pure JavaScript/TypeScript examples in the `samples/` directory
2. Add framework-specific examples in appropriate subdirectories
3. Update this README with new content descriptions
4. Include package.json with dependencies and scripts

### Code Quality Standards
- Use meaningful variable and function names
- Follow consistent indentation and formatting
- Use modern JavaScript features (ES6+)
- Handle errors and edge cases appropriately
- Write clean, readable code with appropriate comments

## Resources and References

- [MDN JavaScript Documentation](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
- [Node.js Documentation](https://nodejs.org/en/docs/)
- [React Documentation](https://reactjs.org/docs/getting-started.html)
- [React Native Documentation](https://reactnative.dev/docs/getting-started)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [JavaScript Standard Style](https://standardjs.com/)
- [Jest Testing Framework](https://jestjs.io/)
- [Pact.js Documentation](https://docs.pact.io/implementation_guides/javascript/)