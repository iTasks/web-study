# Phase 1 – React Core (Web)

[← Back to Roadmap](../README.md) | [JavaScript](../../README.md) | [Main README](../../../README.md)

## Overview

React is a **component-based UI library**, not a framework. You compose small, reusable pieces. Understanding this mental model unlocks everything else.

**Duration:** ~5 weeks (2–3 hrs/day)

---

## Topics

| Topic | Document | Description |
|-------|----------|-------------|
| Core Concepts & Hooks | [core-concepts.md](core-concepts.md) | JSX, components, state, all built-in hooks |
| Component Architecture | [component-architecture.md](component-architecture.md) | Smart/dumb, lifting state, composition |
| Routing | [routing.md](routing.md) | React Router v6, nested routes, layouts |
| Forms | [forms.md](forms.md) | Controlled forms, validation, libraries |
| API Integration | [api-integration.md](api-integration.md) | Axios, error handling, JWT, backend setup |

---

## Learning Goals

By the end of Phase 1 you should be able to:

- Build a multi-page React app with routing
- Manage local and lifted state correctly
- Fetch data from a Python API with error handling and loading states
- Build controlled forms with validation
- Write components in TypeScript with proper prop types

---

## Mental Model for Backend Engineers

React is **declarative**: you describe *what* the UI should look like for a given state, not *how* to update the DOM. The framework handles rendering.

```
State changes → React re-renders affected components → DOM updates
```

This maps well to backend thinking:
- **State** = your application's data model (like a request context)
- **Props** = function arguments (immutable, passed top-down)
- **Side effects** (`useEffect`) = triggers outside rendering (like middleware hooks)
- **Custom hooks** = reusable service logic extracted from components

---

## Quick Start

```bash
# Create a new React + TypeScript project with Vite (recommended)
npm create vite@latest my-app -- --template react-ts
cd my-app
npm install
npm run dev
```

---

## Previous Phase

← [Phase 0 – Foundations](../phase-0-foundations/README.md)

## Next Phase

→ [Phase 2 – Advanced React](../phase-2-advanced-react/README.md)
