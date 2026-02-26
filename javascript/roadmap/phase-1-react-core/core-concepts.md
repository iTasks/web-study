# React Core Concepts & Hooks

[← Back to Phase 1](README.md) | [Roadmap](../README.md)

## What is React?

React is a JavaScript library for building user interfaces using a **component tree**. Each component is a function that takes data (props) and returns UI (JSX).

```
App
├── Header (props: title)
├── Sidebar (props: items)
└── Main
    ├── UserCard (props: user)
    └── PostList (props: posts)
```

---

## JSX

JSX is syntactic sugar — it compiles to `React.createElement()` calls.

```tsx
// JSX
const element = <h1 className="title">Hello, {name}</h1>;

// Compiled output
const element = React.createElement('h1', { className: 'title' }, `Hello, ${name}`);

// Rules
// 1. className instead of class (JS keyword conflict)
// 2. Self-closing tags: <img />, <Input />
// 3. One root element (or use <> fragment </>)
// 4. Expressions in {}, not statements
// 5. camelCase event names: onClick, onChange, onSubmit
```

---

## Functional Components

```tsx
// Minimal component
function Greeting() {
  return <p>Hello!</p>;
}

// With typed props
interface UserCardProps {
  user: User;
  onSelect: (id: string) => void;
  compact?: boolean;           // optional prop
}

function UserCard({ user, onSelect, compact = false }: UserCardProps) {
  return (
    <div className={compact ? 'card card--compact' : 'card'}>
      <h2>{user.name}</h2>
      <p>{user.email}</p>
      <button onClick={() => onSelect(user.id)}>Select</button>
    </div>
  );
}
```

---

## Virtual DOM

React maintains a lightweight in-memory representation of the DOM. On state change:

1. React re-renders the component tree (fast, in memory)
2. Diffs old vs new virtual DOM (reconciliation)
3. Applies minimal patches to the real DOM

**Implication for you:** Never mutate state directly. Always return new objects/arrays.

```tsx
// ❌ Wrong — mutates state, React won't detect change
state.items.push(newItem);

// ✅ Correct — new array reference
setState([...state.items, newItem]);
```

---

## useState

```tsx
import { useState } from 'react';

// Simple counter
function Counter() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>+</button>
      <button onClick={() => setCount((prev) => prev - 1)}>-</button>
    </div>
  );
}

// Object state — always spread to preserve other fields
interface FormState {
  name: string;
  email: string;
  loading: boolean;
}

function Form() {
  const [form, setForm] = useState<FormState>({ name: '', email: '', loading: false });

  const handleChange = (field: keyof FormState) =>
    (e: React.ChangeEvent<HTMLInputElement>) =>
      setForm((prev) => ({ ...prev, [field]: e.target.value }));

  return (
    <form>
      <input value={form.name} onChange={handleChange('name')} />
      <input value={form.email} onChange={handleChange('email')} />
    </form>
  );
}
```

---

## useEffect

Runs side effects after render. Maps to lifecycle methods in class components.

```tsx
import { useEffect, useState } from 'react';

function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;   // avoid state update on unmounted component

    setLoading(true);
    fetchUser(userId)
      .then((data) => { if (!cancelled) setUser(data); })
      .catch((err) => { if (!cancelled) setError(err); })
      .finally(() => { if (!cancelled) setLoading(false); });

    return () => { cancelled = true; };  // cleanup = cancel pending work
  }, [userId]);   // dependency array: re-run when userId changes

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!user) return null;
  return <div>{user.name}</div>;
}

// Common useEffect patterns:
// - [] (empty deps): run once on mount (like componentDidMount)
// - [dep1, dep2]: run when deps change
// - cleanup return: unsubscribe, cancel timers, abort fetches
```

---

## useRef

Mutable ref that persists across renders without causing re-renders.

```tsx
import { useRef, useEffect } from 'react';

function FocusInput() {
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    inputRef.current?.focus();   // focus on mount
  }, []);

  return <input ref={inputRef} />;
}

// Storing previous values
function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T>();
  useEffect(() => { ref.current = value; });
  return ref.current;
}
```

---

## useMemo

Memoize expensive computations. Re-computes only when dependencies change.

```tsx
import { useMemo } from 'react';

function DataTable({ data, filter, sortKey }: TableProps) {
  // Only re-computes when data, filter, or sortKey change
  const processed = useMemo(
    () =>
      data
        .filter((row) => row.name.includes(filter))
        .sort((a, b) => (a[sortKey] > b[sortKey] ? 1 : -1)),
    [data, filter, sortKey],
  );

  return <table>...</table>;
}
```

---

## useCallback

Memoize a function reference. Prevents child re-renders when passing callbacks.

```tsx
import { useCallback, useState } from 'react';

function Parent() {
  const [items, setItems] = useState<Item[]>([]);

  // Stable function reference — won't cause List to re-render
  const handleDelete = useCallback((id: string) => {
    setItems((prev) => prev.filter((item) => item.id !== id));
  }, []);   // no deps — setItems from useState is always stable

  return <List items={items} onDelete={handleDelete} />;
}
```

---

## Custom Hooks

Extract reusable stateful logic — equivalent to service classes in backend code.

```tsx
// Data fetching hook (replaces useEffect boilerplate everywhere)
function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    fetch(url)
      .then((r) => r.json())
      .then((d) => { if (!cancelled) setData(d as T); })
      .catch((e) => { if (!cancelled) setError(e as Error); })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [url]);

  return { data, loading, error };
}

// Usage
function UserPage({ id }: { id: string }) {
  const { data: user, loading, error } = useFetch<User>(`/api/users/${id}`);
  // ...
}
```

---

## Resources

- [React Documentation – Learn](https://react.dev/learn)
- [React Hooks Reference](https://react.dev/reference/react)
- [Thinking in React](https://react.dev/learn/thinking-in-react)

---

→ [Component Architecture](component-architecture.md) | [Phase 1 Overview](README.md)
