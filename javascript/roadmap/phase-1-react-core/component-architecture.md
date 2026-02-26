# Component Architecture

[← Back to Phase 1](README.md) | [Roadmap](../README.md)

## Smart vs Dumb Components

Separation of concerns — mirrors controller/service/view split in backend architectures.

| Type | Also Called | Responsibility |
|------|-------------|----------------|
| Smart | Container, connected | Fetches data, manages state, contains business logic |
| Dumb | Presentational, pure | Receives props, renders UI, no side effects |

```tsx
// ✅ Dumb / Presentational — purely a renderer
interface UserCardProps {
  name: string;
  email: string;
  role: string;
  onDeactivate: () => void;
}

function UserCard({ name, email, role, onDeactivate }: UserCardProps) {
  return (
    <article className="user-card">
      <h2>{name}</h2>
      <p>{email}</p>
      <span className={`badge badge--${role}`}>{role}</span>
      <button onClick={onDeactivate}>Deactivate</button>
    </article>
  );
}

// ✅ Smart / Container — owns data and logic
function UserCardContainer({ userId }: { userId: string }) {
  const { data: user, loading } = useFetch<User>(`/api/users/${userId}`);
  const deactivate = useDeactivateUser(userId);

  if (loading) return <Skeleton />;
  if (!user) return null;

  return <UserCard {...user} onDeactivate={deactivate} />;
}
```

**Benefits of this split:**
- Dumb components are trivially testable (no mocks needed)
- Dumb components are reusable across different data sources
- Smart components encapsulate data concerns

---

## Lifting State Up

When two sibling components need to share state, lift it to their closest common ancestor.

```tsx
// ❌ Anti-pattern: duplicate or prop-drilled state
function Parent() {
  return (
    <>
      <FilterBar />      {/* has its own filter state */}
      <DataTable />      {/* can't see FilterBar's state */}
    </>
  );
}

// ✅ Lift state to parent
function Parent() {
  const [filter, setFilter] = useState('');

  return (
    <>
      <FilterBar value={filter} onChange={setFilter} />
      <DataTable filter={filter} />
    </>
  );
}
```

---

## Composition vs Inheritance

React strongly favors **composition** (wrapping, combining). Inheritance is rarely used.

```tsx
// Composition via children prop
interface CardProps {
  title: string;
  children: React.ReactNode;
  actions?: React.ReactNode;
}

function Card({ title, children, actions }: CardProps) {
  return (
    <section className="card">
      <header className="card__header">
        <h2>{title}</h2>
        {actions && <div className="card__actions">{actions}</div>}
      </header>
      <div className="card__body">{children}</div>
    </section>
  );
}

// Usage — compose, don't inherit
function UserProfile({ user }: { user: User }) {
  return (
    <Card
      title={user.name}
      actions={<EditButton userId={user.id} />}
    >
      <UserDetails user={user} />
      <UserStats userId={user.id} />
    </Card>
  );
}
```

---

## Controlled vs Uncontrolled Components

| Type | State lives in | Use case |
|------|---------------|----------|
| Controlled | React state | Validation, dependent fields, real-time feedback |
| Uncontrolled | DOM (ref) | File inputs, simple forms, integrating with non-React code |

```tsx
// Controlled — React owns the value
function ControlledInput() {
  const [value, setValue] = useState('');
  return (
    <input
      value={value}
      onChange={(e) => setValue(e.target.value)}
    />
  );
}

// Uncontrolled — DOM owns the value, read via ref
function UncontrolledInput() {
  const ref = useRef<HTMLInputElement>(null);

  const handleSubmit = () => {
    console.log(ref.current?.value);
  };

  return <input ref={ref} defaultValue="initial" />;
}
```

---

## Component Granularity Guidelines

Decompose when:
- A component has more than one reason to change
- A section of JSX is repeated 2+ times
- A sub-tree has its own isolated state
- A section becomes hard to read (>100 lines is a signal)

```tsx
// Before decomposition — hard to maintain
function Dashboard() {
  // 200+ lines of mixed concerns
}

// After decomposition
function Dashboard() {
  return (
    <div className="dashboard">
      <DashboardHeader />
      <DashboardStats />
      <RecentActivityFeed />
      <QuickActions />
    </div>
  );
}
```

---

## Prop Types Best Practices

```tsx
// Use interfaces for component props
interface ButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  loading?: boolean;
  onClick?: () => void;
  // Extend native button attributes
  type?: 'button' | 'submit' | 'reset';
}

// Spread HTML attributes for flexibility
type InputProps = React.InputHTMLAttributes<HTMLInputElement> & {
  label: string;
  error?: string;
};

function Input({ label, error, ...inputProps }: InputProps) {
  return (
    <label>
      {label}
      <input {...inputProps} aria-invalid={!!error} />
      {error && <span className="error">{error}</span>}
    </label>
  );
}
```

---

## Resources

- [Thinking in React](https://react.dev/learn/thinking-in-react)
- [Sharing State Between Components](https://react.dev/learn/sharing-state-between-components)
- [Composition vs Inheritance](https://react.dev/learn/passing-data-deeply-with-context)

---

→ [Routing](routing.md) | [Core Concepts](core-concepts.md) | [Phase 1 Overview](README.md)
