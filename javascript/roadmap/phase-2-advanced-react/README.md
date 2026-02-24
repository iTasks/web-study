# Phase 2 – Advanced React (Production Level)

[← Back to Roadmap](../README.md) | [JavaScript](../../README.md) | [Main README](../../../README.md)

## Overview

This phase takes you from "can build features" to "can build production systems". Focus shifts to architecture decisions, performance, and maintainability at scale.

**Duration:** ~5 weeks (2–3 hrs/day)

---

## Topics

| Topic | Document | Description |
|-------|----------|-------------|
| State Management | [state-management.md](state-management.md) | Context, Redux Toolkit, Zustand — when to use which |
| Performance Optimization | [performance.md](performance.md) | Memoization, code splitting, Suspense, profiling |
| Advanced Patterns | [advanced-patterns.md](advanced-patterns.md) | Custom hooks, compound components, HOC, error boundaries |
| Testing | [testing.md](testing.md) | Jest, React Testing Library, mocking APIs |
| Build Tools | [build-tools.md](build-tools.md) | Vite, ESLint, Prettier, Webpack basics |

---

## Learning Goals

By the end of Phase 2 you should be able to:

- Choose the right state management tool for the problem at hand
- Identify and fix performance bottlenecks using React DevTools Profiler
- Write testable components following testing-library best practices
- Set up a production-ready Vite build with code splitting
- Apply advanced patterns to solve real architectural problems

---

## State Management Decision Matrix

| Use Case | Tool |
|----------|------|
| Small app / isolated UI state | `useState` + `useContext` |
| Medium app, simple async | Zustand |
| Large app, complex async, team | Redux Toolkit |
| Server state (cache, sync) | TanStack Query |

---

## Previous Phase

← [Phase 1 – React Core](../phase-1-react-core/README.md)

## Next Phase

→ [Phase 3 – React Native](../phase-3-react-native/README.md)
