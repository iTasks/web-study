# Advanced Patterns

[← Back to Phase 2](README.md) | [Roadmap](../README.md)

## Custom Hooks

The primary abstraction mechanism — reusable stateful logic, equivalent to service classes.

```tsx
// useDebounce — delay value changes (search inputs, autocomplete)
function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debounced;
}

// useLocalStorage — persist state with localStorage
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? (JSON.parse(item) as T) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setStoredValue = useCallback(
    (val: T | ((prev: T) => T)) => {
      const next = val instanceof Function ? val(value) : val;
      setValue(next);
      localStorage.setItem(key, JSON.stringify(next));
    },
    [key, value],
  );

  return [value, setStoredValue] as const;
}

// useMediaQuery — responsive breakpoints in JS
function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(() => window.matchMedia(query).matches);

  useEffect(() => {
    const mq = window.matchMedia(query);
    const handler = (e: MediaQueryListEvent) => setMatches(e.matches);
    mq.addEventListener('change', handler);
    return () => mq.removeEventListener('change', handler);
  }, [query]);

  return matches;
}
```

---

## Compound Components

Components that work together to form a higher-level abstraction — like a `<select>` + `<option>` relationship.

```tsx
// Context to share state between compound parts
interface TabsContextValue {
  activeTab: string;
  setActiveTab: (id: string) => void;
}

const TabsContext = createContext<TabsContextValue | null>(null);

function useTabs() {
  const ctx = useContext(TabsContext);
  if (!ctx) throw new Error('Must be used inside <Tabs>');
  return ctx;
}

// Container component
interface TabsProps {
  defaultTab: string;
  children: React.ReactNode;
}

function Tabs({ defaultTab, children }: TabsProps) {
  const [activeTab, setActiveTab] = useState(defaultTab);
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

// Sub-components
function TabList({ children }: { children: React.ReactNode }) {
  return <div role="tablist" className="tab-list">{children}</div>;
}

function Tab({ id, children }: { id: string; children: React.ReactNode }) {
  const { activeTab, setActiveTab } = useTabs();
  return (
    <button
      role="tab"
      aria-selected={activeTab === id}
      onClick={() => setActiveTab(id)}
      className={`tab ${activeTab === id ? 'tab--active' : ''}`}
    >
      {children}
    </button>
  );
}

function TabPanel({ id, children }: { id: string; children: React.ReactNode }) {
  const { activeTab } = useTabs();
  if (activeTab !== id) return null;
  return <div role="tabpanel">{children}</div>;
}

// Attach sub-components (namespace pattern)
Tabs.List  = TabList;
Tabs.Tab   = Tab;
Tabs.Panel = TabPanel;

// Usage — expressive, flexible
<Tabs defaultTab="overview">
  <Tabs.List>
    <Tabs.Tab id="overview">Overview</Tabs.Tab>
    <Tabs.Tab id="details">Details</Tabs.Tab>
    <Tabs.Tab id="history">History</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel id="overview"><Overview /></Tabs.Panel>
  <Tabs.Panel id="details"><Details /></Tabs.Panel>
  <Tabs.Panel id="history"><History /></Tabs.Panel>
</Tabs>
```

---

## Error Boundaries

React's mechanism to catch rendering errors and show a fallback UI — equivalent to try/catch at component level.

```tsx
import { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: (error: Error, reset: () => void) => ReactNode;
}

interface State {
  error: Error | null;
}

class ErrorBoundary extends Component<Props, State> {
  state: State = { error: null };

  static getDerivedStateFromError(error: Error): State {
    return { error };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    // Log to monitoring (Sentry, Datadog, etc.)
    console.error('Uncaught error:', error, info.componentStack);
  }

  reset = () => this.setState({ error: null });

  render() {
    const { error } = this.state;
    if (error) {
      return this.props.fallback
        ? this.props.fallback(error, this.reset)
        : (
          <div role="alert">
            <h2>Something went wrong</h2>
            <button onClick={this.reset}>Try again</button>
          </div>
        );
    }
    return this.props.children;
  }
}

// Usage with custom fallback
<ErrorBoundary
  fallback={(error, reset) => (
    <ErrorCard message={error.message} onRetry={reset} />
  )}
>
  <DataDashboard />
</ErrorBoundary>
```

---

## Higher-Order Components (HOC)

Wraps a component to add cross-cutting behavior. Legacy pattern — prefer custom hooks in new code, but important for understanding existing codebases.

```tsx
// withAuth HOC — guards component behind authentication
function withAuth<P extends object>(
  WrappedComponent: React.ComponentType<P>,
  requiredRole?: UserRole,
) {
  return function AuthenticatedComponent(props: P) {
    const { user, loading } = useAuth();

    if (loading) return <Spinner />;
    if (!user) return <Navigate to="/login" />;
    if (requiredRole && !user.roles.includes(requiredRole)) {
      return <Forbidden />;
    }

    return <WrappedComponent {...props} />;
  };
}

// withErrorBoundary HOC
function withErrorBoundary<P extends object>(
  WrappedComponent: React.ComponentType<P>,
  fallback: ReactNode,
) {
  return function WithErrorBoundary(props: P) {
    return (
      <ErrorBoundary fallback={() => fallback}>
        <WrappedComponent {...props} />
      </ErrorBoundary>
    );
  };
}

// Usage
const ProtectedAdmin = withAuth(AdminPage, 'admin');
```

---

## Resources

- [React Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
- [Error Boundaries](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary)
- [Compound Components Pattern](https://kentcdodds.com/blog/compound-components-with-react-hooks)

---

→ [Testing](testing.md) | [Performance](performance.md) | [Phase 2 Overview](README.md)
