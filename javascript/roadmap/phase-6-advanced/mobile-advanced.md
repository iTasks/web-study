# Mobile Advanced

[← Back to Phase 6](README.md) | [Roadmap](../README.md)

## Performance Profiling

```bash
# Flipper — native performance profiler for React Native
# Available at: https://fbflipper.com/

# Hermes — high-performance JS engine (enabled by default in RN 0.70+)
# in android/app/build.gradle
# hermesEnabled = true
```

```tsx
// React Native Performance — identify JS thread and UI thread bottlenecks
import { PerformanceObserver } from 'react-native-performance';

const observer = new PerformanceObserver((list) => {
  list.getEntries().forEach((entry) => {
    if (entry.duration > 16) {  // > 1 frame
      console.warn(`Slow operation: ${entry.name} — ${entry.duration.toFixed(2)}ms`);
    }
  });
});
observer.observe({ type: 'measure', buffered: true });
```

---

## Native Modules

When a feature isn't available in the Expo SDK or React Native community packages.

```typescript
// ios/MyNativeModule.swift
@objc(MyNativeModule)
class MyNativeModule: NSObject {
  @objc func processData(_ input: String, resolver resolve: RCTPromiseResolveBlock,
                         rejecter reject: RCTPromiseRejectBlock) {
    let result = expensiveNativeOperation(input)
    resolve(result)
  }

  @objc static func requiresMainQueueSetup() -> Bool { false }
}

// JavaScript bridge
import { NativeModules } from 'react-native';
const { MyNativeModule } = NativeModules;

const result = await MyNativeModule.processData(input);
```

---

## Offline-First Architecture

```bash
npm install @tanstack/react-query react-native-mmkv
# Or for more complete solution:
npm install watermelondb
```

```typescript
import { MMKV } from 'react-native-mmkv';
import { createSyncStoragePersister } from '@tanstack/query-sync-storage-persister';
import { persistQueryClient } from '@tanstack/react-query-persist-client';

const storage = new MMKV();

// Persist React Query cache to device storage
const persister = createSyncStoragePersister({
  storage: {
    getItem: (key) => storage.getString(key) ?? null,
    setItem: (key, value) => storage.set(key, value),
    removeItem: (key) => storage.delete(key),
  },
});

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      gcTime: 1000 * 60 * 60 * 24,        // 24h cache
      staleTime: 1000 * 60 * 5,            // 5min stale time
      networkMode: 'offlineFirst',
    },
  },
});

persistQueryClient({ queryClient, persister });
```

---

## Background Sync

```typescript
import * as BackgroundFetch from 'expo-background-fetch';
import * as TaskManager from 'expo-task-manager';

const SYNC_TASK = 'background-sync';

TaskManager.defineTask(SYNC_TASK, async () => {
  try {
    await syncPendingChanges();
    return BackgroundFetch.BackgroundFetchResult.NewData;
  } catch {
    return BackgroundFetch.BackgroundFetchResult.Failed;
  }
});

await BackgroundFetch.registerTaskAsync(SYNC_TASK, {
  minimumInterval: 15 * 60,   // 15 minutes
  stopOnTerminate: false,
  startOnBoot: true,
});
```

---

## Resources

- [React Native Performance](https://reactnative.dev/docs/performance)
- [Hermes Engine](https://hermesengine.dev/)
- [WatermelonDB (offline-first)](https://watermelondb.dev/)

---

→ [Scaling](scaling.md) | [SSR/Next.js](ssr-nextjs.md) | [Phase 6 Overview](README.md)
