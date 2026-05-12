# Cucumber + Selenium + JS + Pyscript:

One can combine Cucumber + Selenium with both JavaScript and Python-based scripting very effectively for advanced UI testing.

The key is understanding the roles:

| Technology | Role                            |
| ---------- | ------------------------------- |
| Cucumber   | BDD scenarios                   |
| Selenium   | Browser automation              |
| JavaScript | Frontend/UI interaction         |
| Python     | Utilities, AI, validation, data |
| PyScript   | In-browser Python execution     |

---

# Most Practical Architecture

```text id="9ot1d8"
Feature Files (Cucumber)
        │
        ▼
Step Definitions
(JS or Python)
        │
        ▼
Selenium WebDriver
        │
        ├── Execute JavaScript
        └── Trigger Python Utilities
```

---

# Recommended Technology Choices

# OPTION 1 (Most Common)

## Cucumber + Selenium + JavaScript

Stack:

* Node.js
* Cucumber.js
* Selenium

Best for:

* frontend-heavy apps
* React/Vue/Angular
* modern web testing

---

# OPTION 2

## Behave + Selenium + Python

Stack:

* Behave
* Selenium

Best for:

* AI testing
* data-heavy validation
* backend-oriented teams

---

# OPTION 3 (Hybrid)

## Cucumber.js + Selenium + Python Utilities

Very powerful enterprise setup.

Use:

* JS for browser actions
* Python for:

  * OCR
  * AI validation
  * image comparison
  * API validation
  * ML logic

This is often the best architecture.

---

# Basic Cucumber + Selenium + JS Setup

# Install

```bash id="h4g58x"
npm init -y
```

Install:

```bash id="0zv3gc"
npm install selenium-webdriver @cucumber/cucumber chromedriver
```

---

# Folder Structure

```text id="yv40z6"
project/
│
├── features/
│    ├── login.feature
│
├── steps/
│    ├── login.steps.js
│
├── support/
│
└── package.json
```

---

# Feature File

```gherkin id="26zkgn"
Feature: Login

Scenario: Valid login
   Given user opens login page
   When user enters credentials
   Then dashboard appears
```

---

# Selenium Step Definitions

```javascript id="l9l5e7"
const { Given, When, Then } = require('@cucumber/cucumber');
const { Builder, By } = require('selenium-webdriver');

let driver;

Given('user opens login page', async function () {
    driver = await new Builder().forBrowser('chrome').build();

    await driver.get('https://example.com/login');
});

When('user enters credentials', async function () {
    await driver.findElement(By.id('user'))
        .sendKeys('admin');

    await driver.findElement(By.id('pass'))
        .sendKeys('123');

    await driver.findElement(By.id('login'))
        .click();
});

Then('dashboard appears', async function () {
    const title = await driver.getTitle();

    console.log(title);

    await driver.quit();
});
```

Run:

```bash id="dlpv1m"
npx cucumber-js
```

---

# Using JavaScript Inside Selenium

One huge advantage:

```javascript id="qjk4fj"
await driver.executeScript(`
   document.body.style.zoom='50%'
`);
```

You can:

* manipulate DOM
* trigger hidden events
* inspect React state
* bypass UI limitations

Very powerful.

---

# Integrating Python

# Option A — Call Python from JS

Example:

```javascript id="h6zjlwm"
const { execSync } = require('child_process');

const result = execSync('python validate.py');

console.log(result.toString());
```

Useful for:

* AI validation
* OCR
* image processing
* PDF checks

---

# Example Python Validation

```python id="vsvx6z"
from PIL import Image

print("validation passed")
```

---

# Advanced Enterprise Hybrid

```text id="r3v6md"
Cucumber.js
    │
    ├── Selenium Browser Actions
    │
    ├── Execute JS in Browser
    │
    └── Call Python Services
            │
            ├── AI Validation
            ├── OCR
            ├── Image Compare
            └── API Checks
```

This is extremely powerful.

---

# Where PyScript Fits

PyScript runs Python INSIDE browser.

But:

> PyScript is usually NOT ideal for Selenium automation itself.

Instead use it for:

* validating PyScript apps
* testing Python-in-browser behavior

---

# Example Selenium Testing PyScript App

Example page:

```html id="2phm6x"
<py-script>
print("hello")
</py-script>
```

Selenium:

```javascript id="d9u4d0"
const content =
 await driver.findElement(By.tagName("py-terminal"))
             .getText();
```

Useful if your app actually uses PyScript.

---

# Recommended Modern Stack

For new projects:

```text id="txj38r"
Cucumber.js
+ Playwright
+ Python AI utilities
```

Why many teams move from Selenium:

* faster
* more stable
* auto waiting
* better modern browser support

---

# Best Real-World Usage Pattern

## Use JS For

* browser control
* DOM manipulation
* frontend validation

## Use Python For

* AI
* OCR
* ML
* data analysis
* screenshots
* reporting

---

# Powerful AI Testing Possibilities

Because anyone who knows backend/distributed systems, can build:

```text id="s5wvpo"
Cucumber
   │
Selenium
   │
Screenshot
   │
Python AI Vision
   │
UI Validation
```

Examples:

* detect broken layouts
* compare screenshots
* validate charts
* detect UI anomalies
* OCR PDFs
* validate multilingual UI

---

# Example Full Enterprise Flow

```text id="5v97tz"
Feature File
   │
Cucumber.js
   │
Selenium
   │
Execute JS
   │
Capture Screenshot
   │
Python AI Validation
   │
Generate HTML Report
```

This is close to modern intelligent QA automation architecture.
