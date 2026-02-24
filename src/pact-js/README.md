# Pact-JS

[← Back to src](../readme.md) | [Main README](../../README.md)

## Overview

Pact-JS is a library that allows you to implement Consumer Driven Contracts using the Pact framework in JavaScript. It is particularly useful for testing interactions between front-end and back-end services.

## Source

You can find the source code and more details about Pact-JS at the following link:
- [Pact-JS GitHub Repository](https://github.com/pact-foundation/pact-js)

## Documentation

For detailed usage and documentation, refer to the [Pact-JS Documentation](https://docs.pact.io/getting_started/).

## Installation

To install Pact-JS, use npm:

```sh
npm install @pact-foundation/pact
```


#### Getting Started

Here is a basic example of how to use Pact-JS:

```javascript
const { Pact } = require('@pact-foundation/pact');
const path = require('path');

const provider = new Pact({
  consumer: 'ConsumerName',
  provider: 'ProviderName',
  port: 1234,
  log: path.resolve(process.cwd(), 'logs', 'pact.log'),
  dir: path.resolve(process.cwd(), 'pacts'),
  logLevel: 'INFO',
});

provider.setup()
  .then(() => {
    // Your test code here
  })
  .finally(() => provider.finalize());
```
