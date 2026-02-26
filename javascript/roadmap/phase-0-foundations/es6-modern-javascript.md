# Modern JavaScript (ES6+)

[← Back to Phase 0](README.md) | [Roadmap](../README.md)

## Why This Matters

You don't need "what is a variable" JavaScript. You need the idioms that React and TypeScript rely on heavily. All of the syntax below appears constantly in real React codebases.

---

## Core Syntax

### `let` / `const`

```javascript
const PI = 3.14159;         // immutable binding (prefer this)
let counter = 0;            // mutable binding
// var is function-scoped — avoid it
```

### Arrow Functions

```javascript
// Concise expression body (implicit return)
const double = (x) => x * 2;

// Block body with explicit return
const greet = (name) => {
  const msg = `Hello, ${name}`;
  return msg;
};

// Key difference: arrow functions inherit `this` from enclosing scope
// (critical in React class components and callbacks)
```

### Destructuring

```javascript
// Object destructuring
const { id, name, role = 'user' } = userObject;  // with default

// Array destructuring (used by every React hook)
const [state, setState] = useState(0);

// Nested destructuring
const { address: { city, country } } = user;

// Function parameter destructuring
const render = ({ title, children }) => { /* ... */ };
```

### Spread & Rest Operator

```javascript
// Spread — expand iterable into positions
const merged = { ...defaults, ...overrides };          // object merge
const combined = [...listA, ...listB];                 // array concat
const copy = { ...original, status: 'updated' };      // immutable update (key in React)

// Rest — collect remaining items
const { id, ...rest } = user;                          // omit one key
const sum = (...nums) => nums.reduce((a, b) => a + b, 0);
```

### Template Literals

```javascript
const url = `${BASE_URL}/api/v1/users/${userId}`;
const multiline = `
  SELECT *
  FROM users
  WHERE id = ${userId}
`;
```

### Modules (ESM)

```javascript
// Named exports — preferred for libraries
export const add = (a, b) => a + b;
export interface Config { ... }

// Default export — preferred for components
export default function App() { ... }

// Importing
import { add } from './math';
import App from './App';
import * as utils from './utils';   // namespace import

// Re-exporting (barrel files)
export { Button } from './Button';
export { Input } from './Input';
```

---

## Asynchronous Programming

### Promises

```javascript
fetch('/api/users')
  .then((res) => res.json())
  .then((data) => console.log(data))
  .catch((err) => console.error(err))
  .finally(() => setLoading(false));

// Promise combinators
const [users, posts] = await Promise.all([fetchUsers(), fetchPosts()]);
const first = await Promise.race([slow(), fast()]);
const results = await Promise.allSettled([may(), fail()]);
```

### Async / Await

```javascript
// Direct translation of Python asyncio pattern
async function loadDashboard(userId: string) {
  try {
    const user = await fetchUser(userId);
    const [orders, prefs] = await Promise.all([
      fetchOrders(userId),
      fetchPreferences(userId),
    ]);
    return { user, orders, prefs };
  } catch (error) {
    if (error instanceof NetworkError) {
      throw new AppError('Service unavailable', 503);
    }
    throw error;
  }
}
```

### Error Handling

```javascript
// Custom error classes (mirrors Python Exception hierarchy)
class ApiError extends Error {
  constructor(
    message: string,
    public readonly statusCode: number,
    public readonly code: string,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

// Type narrowing in catch
try {
  await riskyOperation();
} catch (error) {
  if (error instanceof ApiError && error.statusCode === 401) {
    redirectToLogin();
  } else {
    throw error;  // re-throw unknown errors
  }
}
```

---

## Closures

```javascript
// Closure = function + its lexical environment
function makeCounter(initial = 0) {
  let count = initial;           // captured in closure
  return {
    increment: () => ++count,
    decrement: () => --count,
    value: () => count,
  };
}

// React hooks are built on closures
function useToggle(initial = false) {
  const [on, setOn] = useState(initial);
  const toggle = useCallback(() => setOn((v) => !v), []);  // stable closure
  return [on, toggle];
}
```

---

## Array Methods

```javascript
const users = [
  { id: 1, name: 'Alice', active: true,  score: 90 },
  { id: 2, name: 'Bob',   active: false, score: 75 },
  { id: 3, name: 'Carol', active: true,  score: 85 },
];

// map — transform (like Python list comprehension)
const names = users.map((u) => u.name);
// ['Alice', 'Bob', 'Carol']

// filter — select (like Python filter())
const active = users.filter((u) => u.active);

// reduce — accumulate (like Python functools.reduce)
const total = users.reduce((sum, u) => sum + u.score, 0);

// find / findIndex
const alice = users.find((u) => u.name === 'Alice');

// some / every (like Python any() / all())
const hasInactive = users.some((u) => !u.active);
const allScored = users.every((u) => u.score > 0);

// Chaining (common React pattern)
const topActiveNames = users
  .filter((u) => u.active)
  .sort((a, b) => b.score - a.score)
  .map((u) => u.name);
```

---

## Optional Chaining & Nullish Coalescing

```javascript
// Optional chaining — safe property access (mirrors Python getattr)
const city = user?.address?.city;
const len = data?.items?.length ?? 0;

// Nullish coalescing — only falls back on null/undefined (not 0 or "")
const port = config.port ?? 3000;
const label = item.name ?? 'Unnamed';
```

---

## Short-circuit Evaluation (Common in JSX)

```javascript
// Render conditionally (used everywhere in React)
{isLoading && <Spinner />}
{error && <ErrorBanner message={error.message} />}
{user ? <Dashboard user={user} /> : <Login />}
```

---

## Practice Exercises

1. Re-implement Python list comprehensions for filtering and transforming arrays
2. Build a small utility library (`lodash`-lite) using only ES6+ methods
3. Write an async data fetcher with retry logic and exponential backoff
4. Implement a simple event emitter using closures
5. Create a type-safe configuration loader using destructuring with defaults

---

## Resources

- [MDN JavaScript Reference](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference)
- [javascript.info](https://javascript.info/) — Deep explanations with examples
- [ES6 Features Overview](http://es6-features.org/)
- [You Don't Know JS (book series)](https://github.com/getify/You-Dont-Know-JS)

---

→ [TypeScript](typescript.md) | [Phase 0 Overview](README.md)
