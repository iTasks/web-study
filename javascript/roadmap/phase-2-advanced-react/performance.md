# Performance Optimization

[← Back to Phase 2](README.md) | [Roadmap](../README.md)

## Memoization

### React.memo

Prevents a component from re-rendering when its props haven't changed.

```tsx
// Without memo — re-renders whenever parent re-renders
function ExpensiveRow({ item }: { item: Item }) {
  return <tr><td>{item.name}</td><td>{item.value}</td></tr>;
}

// With memo — only re-renders when item prop changes
const ExpensiveRow = React.memo(function ExpensiveRow({ item }: { item: Item }) {
  return <tr><td>{item.name}</td><td>{item.value}</td></tr>;
});

// Custom comparison (like C# IEqualityComparer)
const ExpensiveRow = React.memo(
  function ExpensiveRow({ item }: { item: Item }) { ... },
  (prev, next) => prev.item.id === next.item.id && prev.item.value === next.item.value,
);
```

### useMemo + useCallback (review)

```tsx
// useMemo — cache computed value
const sortedItems = useMemo(
  () => [...items].sort((a, b) => a.name.localeCompare(b.name)),
  [items],
);

// useCallback — stable function reference for memoized children
const handleSelect = useCallback(
  (id: string) => setSelected(id),
  [],  // deps: empty → function is created once
);

// ⚠️ Common mistake: adding useMemo/useCallback everywhere
// Only add them when:
// 1. Computation is measurably slow (use React Profiler first)
// 2. Preventing child re-renders (when child is React.memo'd)
// 3. Stabilizing useEffect dependencies
```

---

## Code Splitting

Split your bundle so users only download code they need.

### Route-Level Splitting (Highest Impact)

```tsx
import { lazy, Suspense } from 'react';

// Each route chunk is loaded on demand
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Reports   = lazy(() => import('./pages/Reports'));
const Settings  = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/reports"   element={<Reports />} />
        <Route path="/settings"  element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

### Component-Level Splitting

```tsx
// Heavy components loaded only when rendered
const HeavyChart = lazy(() => import('./HeavyChart'));
const RichEditor = lazy(() => import('./RichEditor'));

function PostEditor({ showChart }: { showChart: boolean }) {
  return (
    <div>
      <Suspense fallback={<EditorSkeleton />}>
        <RichEditor />
      </Suspense>
      {showChart && (
        <Suspense fallback={<ChartSkeleton />}>
          <HeavyChart />
        </Suspense>
      )}
    </div>
  );
}
```

---

## Avoiding Unnecessary Re-renders

```tsx
// ❌ New object created on every render → child always re-renders
function Parent() {
  return <Child config={{ timeout: 5000 }} />;
}

// ✅ Stable reference with useMemo
function Parent() {
  const config = useMemo(() => ({ timeout: 5000 }), []);
  return <Child config={config} />;
}

// ✅ Even better — hoist constant outside component
const CHILD_CONFIG = { timeout: 5000 };
function Parent() {
  return <Child config={CHILD_CONFIG} />;
}

// ❌ Inline callback → new function every render
function Parent() {
  return <Button onClick={() => doSomething()} />;
}

// ✅ useCallback for memoized children
function Parent() {
  const handleClick = useCallback(() => doSomething(), []);
  return <Button onClick={handleClick} />;
}
```

### Key Prop Patterns

```tsx
// ✅ Stable keys — use entity IDs, not array indices
{items.map((item) => <Row key={item.id} item={item} />)}

// ❌ Index keys cause React to reuse DOM nodes incorrectly on reorder/delete
{items.map((item, i) => <Row key={i} item={item} />)}

// Use index ONLY for static, never-reordered lists
```

---

## Virtualization (Large Lists)

Render only visible items — essential for lists > 100 items.

```bash
npm install @tanstack/react-virtual
```

```tsx
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,   // estimated row height in px
    overscan: 10,             // extra rows above/below viewport
  });

  return (
    <div ref={parentRef} style={{ height: '600px', overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map((virtualRow) => (
          <div
            key={virtualRow.index}
            style={{
              position: 'absolute',
              transform: `translateY(${virtualRow.start}px)`,
            }}
          >
            <Row item={items[virtualRow.index]!} />
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

## React Profiler

Built into React DevTools — identify which components render and why.

```tsx
// Wrap with Profiler to measure render time in code
import { Profiler } from 'react';

function onRenderCallback(
  id: string,              // component tree identifier
  phase: 'mount' | 'update' | 'nested-update',
  actualDuration: number,  // ms spent rendering
  baseDuration: number,    // estimated ms without memoization
) {
  if (actualDuration > 16) {  // > 1 frame at 60fps
    console.warn(`Slow render in ${id}: ${actualDuration.toFixed(2)}ms`);
  }
}

<Profiler id="DataTable" onRender={onRenderCallback}>
  <DataTable data={data} />
</Profiler>
```

---

## Resources

- [React DevTools Profiler](https://react.dev/learn/react-developer-tools)
- [Optimizing Performance](https://react.dev/reference/react/memo)
- [TanStack Virtual](https://tanstack.com/virtual/latest)

---

→ [Advanced Patterns](advanced-patterns.md) | [State Management](state-management.md) | [Phase 2 Overview](README.md)
