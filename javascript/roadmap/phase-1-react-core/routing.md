# Routing with React Router

[← Back to Phase 1](README.md) | [Roadmap](../README.md)

## Overview

React Router v6 is the standard routing library for React web apps. It provides declarative, component-based routing.

```bash
npm install react-router-dom
```

---

## Basic Setup

```tsx
// main.tsx — wrap your app with BrowserRouter
import { BrowserRouter } from 'react-router-dom';
import App from './App';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <BrowserRouter>
    <App />
  </BrowserRouter>,
);

// App.tsx — define routes
import { Routes, Route } from 'react-router-dom';

function App() {
  return (
    <Routes>
      <Route path="/" element={<HomePage />} />
      <Route path="/users" element={<UsersPage />} />
      <Route path="/users/:id" element={<UserDetailPage />} />
      <Route path="*" element={<NotFoundPage />} />
    </Routes>
  );
}
```

---

## Dynamic Routes & Params

```tsx
import { useParams } from 'react-router-dom';

// Route definition
<Route path="/users/:userId/orders/:orderId" element={<OrderDetail />} />

// Component usage
function OrderDetail() {
  const { userId, orderId } = useParams<{
    userId: string;
    orderId: string;
  }>();

  const { data: order } = useFetch<Order>(`/api/users/${userId}/orders/${orderId}`);

  return <div>{order?.total}</div>;
}
```

---

## Nested Routes

Nested routes render child routes inside a parent layout without reloading the parent.

```tsx
// Layout component — renders shared UI + <Outlet />
import { Outlet, NavLink } from 'react-router-dom';

function DashboardLayout() {
  return (
    <div className="dashboard">
      <nav>
        <NavLink to="/dashboard/overview">Overview</NavLink>
        <NavLink to="/dashboard/analytics">Analytics</NavLink>
        <NavLink to="/dashboard/settings">Settings</NavLink>
      </nav>
      <main>
        <Outlet />   {/* child route renders here */}
      </main>
    </div>
  );
}

// Route configuration
function App() {
  return (
    <Routes>
      <Route path="/" element={<PublicLayout />}>
        <Route index element={<LandingPage />} />
        <Route path="login" element={<LoginPage />} />
      </Route>
      <Route path="/dashboard" element={<DashboardLayout />}>
        <Route index element={<Navigate to="overview" replace />} />
        <Route path="overview" element={<OverviewPage />} />
        <Route path="analytics" element={<AnalyticsPage />} />
        <Route path="settings" element={<SettingsPage />} />
      </Route>
    </Routes>
  );
}
```

---

## Protected Routes

Implement auth guards — mirrors middleware in backend routing.

```tsx
interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredRole?: UserRole;
}

function ProtectedRoute({ children, requiredRole }: ProtectedRouteProps) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) return <FullPageSpinner />;

  if (!user) {
    // Redirect to login, preserving intended destination
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  if (requiredRole && !user.roles.includes(requiredRole)) {
    return <Navigate to="/unauthorized" replace />;
  }

  return <>{children}</>;
}

// Usage
<Route
  path="/admin"
  element={
    <ProtectedRoute requiredRole="admin">
      <AdminLayout />
    </ProtectedRoute>
  }
>
  <Route path="users" element={<ManageUsersPage />} />
</Route>
```

---

## Navigation Hooks

```tsx
import { useNavigate, useSearchParams, useLocation } from 'react-router-dom';

function SearchPage() {
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const location = useLocation();

  const query = searchParams.get('q') ?? '';

  // Programmatic navigation
  const goToUser = (id: string) => navigate(`/users/${id}`);
  const goBack = () => navigate(-1);
  const goForward = () => navigate(1);

  // Update URL params without navigation
  const updateFilter = (key: string, value: string) => {
    setSearchParams((prev) => {
      prev.set(key, value);
      return prev;
    });
  };

  // Read state passed during navigation
  const { from } = location.state as { from?: Location } ?? {};

  return <div>...</div>;
}
```

---

## Lazy Loading Routes

Code-split routes to reduce initial bundle size.

```tsx
import { lazy, Suspense } from 'react';

// Route components loaded only when navigated to
const DashboardPage = lazy(() => import('./pages/DashboardPage'));
const AdminPage = lazy(() => import('./pages/AdminPage'));
const ReportsPage = lazy(() => import('./pages/ReportsPage'));

function App() {
  return (
    <Suspense fallback={<FullPageSpinner />}>
      <Routes>
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/admin" element={<AdminPage />} />
        <Route path="/reports" element={<ReportsPage />} />
      </Routes>
    </Suspense>
  );
}
```

---

## Resources

- [React Router Documentation](https://reactrouter.com/en/main)
- [React Router Tutorial](https://reactrouter.com/en/main/start/tutorial)

---

→ [Forms](forms.md) | [Component Architecture](component-architecture.md) | [Phase 1 Overview](README.md)
