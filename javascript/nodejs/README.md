# Node.js Framework

[← Back to JavaScript](../README.md) | [Main README](../../README.md)

## Purpose

This directory contains Node.js framework examples and implementations. Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine that allows you to run JavaScript on the server side.

## Contents

- `lambda/`: AWS Lambda function implementations
- `ng/`: Node.js applications and utilities
- Various server-side JavaScript examples
- **[Queue Processing](queue_processing/)**: Parallel queue processing with MongoDB and PostgreSQL

## Setup Instructions

### Prerequisites
- Node.js 16 or higher
- npm or yarn package manager

### Installation
```bash
# Install dependencies
cd javascript/nodejs
npm install

# For Lambda examples
cd lambda
npm install
```

### Running Applications

#### Basic Node.js Server
```bash
cd javascript/nodejs
node server.js
```

#### Lambda Functions
```bash
cd javascript/nodejs/lambda
npm run start
```

## Key Features

- **Asynchronous I/O**: Non-blocking I/O operations
- **Event-Driven**: Event loop architecture
- **NPM Ecosystem**: Vast package ecosystem
- **Server-Side JavaScript**: Full-stack JavaScript development
- **Cloud Integration**: AWS Lambda support

## Learning Topics

- Node.js event loop and asynchronous programming
- Express.js web framework
- AWS Lambda serverless functions
- File system operations
- HTTP server implementation
- Package management with npm

## Resources

- [Node.js Documentation](https://nodejs.org/en/docs/)
- [Express.js Documentation](https://expressjs.com/)
- [AWS Lambda Node.js](https://docs.aws.amazon.com/lambda/latest/dg/lambda-nodejs.html)
- [NPM Documentation](https://docs.npmjs.com/)