# Phase 3 – React Native (Mobile)

[← Back to Roadmap](../README.md) | [JavaScript](../../README.md) | [Main README](../../../README.md)

## Overview

React Native lets you build native iOS and Android apps using React. You reuse your React knowledge — components, hooks, state management — but swap HTML elements for native UI primitives.

**Duration:** ~5 weeks (2–3 hrs/day)

---

## Topics

| Topic | Document | Description |
|-------|----------|-------------|
| Core Concepts | [core-concepts.md](core-concepts.md) | Native components, Flexbox, platform differences |
| Navigation | [navigation.md](navigation.md) | React Navigation, stack, tabs, deep linking |
| Native Features | [native-features.md](native-features.md) | Camera, location, push notifications, storage |
| Expo vs Bare | [expo-vs-bare.md](expo-vs-bare.md) | Tradeoffs, when to use each |

---

## State Management

Reuse everything from Phase 2:
- **Zustand** — preferred for mobile (smaller bundle)
- **Redux Toolkit** — large apps
- **TanStack Query** — server state, offline-first

---

## Key Differences from React Web

| React Web | React Native |
|-----------|-------------|
| `<div>` | `<View>` |
| `<p>`, `<span>` | `<Text>` |
| `<img>` | `<Image>` |
| `<input>` | `<TextInput>` |
| `<button>` | `<TouchableOpacity>` / `<Pressable>` |
| CSS files | `StyleSheet.create()` |
| Flexbox (column default) | Flexbox (column default — same!) |
| `onClick` | `onPress` |

---

## Learning Goals

By the end of Phase 3 you should be able to:

- Build a cross-platform mobile app from scratch
- Implement multi-screen navigation with tabs and stacks
- Access native device features (camera, location, notifications)
- Choose between Expo and bare React Native correctly
- Deploy a production build to App Store / Google Play

---

## Quick Start with Expo (Recommended for Learning)

```bash
npx create-expo-app my-app --template blank-typescript
cd my-app
npx expo start
```

---

## Previous Phase

← [Phase 2 – Advanced React](../phase-2-advanced-react/README.md)

## Next Phase

→ [Phase 4 – Python Backend](../phase-4-python-backend/README.md)
