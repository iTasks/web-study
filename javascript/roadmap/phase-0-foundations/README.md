# Phase 0 – Foundations

[← Back to Roadmap](../README.md) | [JavaScript](../../README.md) | [Main README](../../../README.md)

## Overview

Before writing React or React Native, build solid JavaScript and TypeScript foundations. As a backend engineer you already understand async, types, and module systems — this phase focuses on the **JS-specific idioms** you'll use constantly in React.

**Duration:** ~3 weeks (2–3 hrs/day)

---

## Topics

| Topic | Document | Description |
|-------|----------|-------------|
| Modern JavaScript (ES6+) | [es6-modern-javascript.md](es6-modern-javascript.md) | Syntax, async/await, closures, array methods |
| TypeScript | [typescript.md](typescript.md) | Interfaces, generics, utility types, strict mode |

---

## Learning Goals

By the end of Phase 0 you should be able to:

- Write idiomatic ES6+ JavaScript without hesitation
- Use `async/await` and Promises confidently
- Model data with TypeScript interfaces and generics
- Understand JavaScript's module system (ESM vs CommonJS)
- Re-implement familiar backend patterns (DI, decorators, DTOs) in TypeScript

---

## Quick Practice

```typescript
// Re-implement Python list comprehension
const squares = Array.from({ length: 10 }, (_, i) => i ** 2);

// Async pipeline (mirrors Python asyncio)
const fetchUser = async (id: number): Promise<User> => {
  const res = await fetch(`/api/users/${id}`);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json() as Promise<User>;
};

// Destructuring + spread (mirrors Python unpacking)
const { name, ...rest } = user;
const merged = { ...defaults, ...overrides };
```

---

## Next Phase

→ [Phase 1 – React Core](../phase-1-react-core/README.md)
