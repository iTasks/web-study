# Testing React Applications

[← Back to Phase 2](README.md) | [Roadmap](../README.md)

## Testing Stack

| Tool | Purpose |
|------|---------|
| **Jest** | Test runner, assertion library, mocking |
| **React Testing Library** | Component rendering and user interaction |
| **MSW** (Mock Service Worker) | API mocking at the network level |
| **Vitest** | Jest-compatible runner, faster with Vite |

```bash
# With Vite (recommended)
npm install -D vitest @testing-library/react @testing-library/user-event @testing-library/jest-dom jsdom

# With Create React App (legacy)
npm install -D @testing-library/react @testing-library/user-event @testing-library/jest-dom msw
```

---

## Testing Philosophy

> Test behavior, not implementation.

```tsx
// ❌ Tests implementation — fragile, breaks on refactor
expect(component.state.isLoading).toBe(true);
expect(wrapper.find('Spinner').exists()).toBe(true);

// ✅ Tests behavior — resilient to refactors
expect(screen.getByRole('progressbar')).toBeInTheDocument();
expect(screen.queryByText('Submit')).not.toBeInTheDocument();
```

This mirrors test-driven thinking in backend systems: test contracts (inputs/outputs), not internals.

---

## Component Tests

```tsx
// UserCard.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserCard } from './UserCard';

const mockUser: User = {
  id: '1',
  name: 'Alice Smith',
  email: 'alice@example.com',
  role: 'admin',
};

describe('UserCard', () => {
  it('renders user information', () => {
    render(<UserCard user={mockUser} onDeactivate={() => {}} />);

    expect(screen.getByText('Alice Smith')).toBeInTheDocument();
    expect(screen.getByText('alice@example.com')).toBeInTheDocument();
    expect(screen.getByText('admin')).toBeInTheDocument();
  });

  it('calls onDeactivate with user id when button clicked', async () => {
    const user = userEvent.setup();
    const onDeactivate = vi.fn();

    render(<UserCard user={mockUser} onDeactivate={onDeactivate} />);
    await user.click(screen.getByRole('button', { name: /deactivate/i }));

    expect(onDeactivate).toHaveBeenCalledTimes(1);
  });

  it('disables button when loading prop is true', () => {
    render(<UserCard user={mockUser} onDeactivate={() => {}} loading />);
    expect(screen.getByRole('button', { name: /deactivate/i })).toBeDisabled();
  });
});
```

---

## Testing Async Components

```tsx
// UserList.test.tsx — component that fetches data
import { render, screen, waitFor } from '@testing-library/react';
import { rest } from 'msw';
import { setupServer } from 'msw/node';
import { UserList } from './UserList';

const server = setupServer(
  rest.get('/api/users', (req, res, ctx) => {
    return res(ctx.json({
      items: [{ id: '1', name: 'Alice', email: 'alice@example.com' }],
      total: 1,
    }));
  }),
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('UserList', () => {
  it('shows loading spinner while fetching', () => {
    render(<UserList />);
    expect(screen.getByRole('progressbar')).toBeInTheDocument();
  });

  it('renders users after successful fetch', async () => {
    render(<UserList />);
    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
    });
  });

  it('shows error message on fetch failure', async () => {
    server.use(
      rest.get('/api/users', (req, res, ctx) =>
        res(ctx.status(500), ctx.json({ message: 'Server error' })),
      ),
    );
    render(<UserList />);
    await waitFor(() => {
      expect(screen.getByRole('alert')).toBeInTheDocument();
    });
  });
});
```

---

## Testing Custom Hooks

```tsx
// useCounter.test.ts
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('initializes with provided value', () => {
    const { result } = renderHook(() => useCounter(10));
    expect(result.current.count).toBe(10);
  });

  it('increments count', () => {
    const { result } = renderHook(() => useCounter(0));
    act(() => result.current.increment());
    expect(result.current.count).toBe(1);
  });

  it('does not exceed max', () => {
    const { result } = renderHook(() => useCounter(9, { max: 10 }));
    act(() => {
      result.current.increment();
      result.current.increment();  // should not go past 10
    });
    expect(result.current.count).toBe(10);
  });
});
```

---

## Testing with React Query / Redux

```tsx
// Test wrapper with providers
function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });

  return function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>
        <Provider store={store}>
          {children}
        </Provider>
      </QueryClientProvider>
    );
  };
}

// Use in tests
render(<ComponentUnderTest />, { wrapper: createWrapper() });
```

---

## Vitest Configuration (Vite Projects)

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './src/test/setup.ts',
  },
});

// src/test/setup.ts
import '@testing-library/jest-dom';
```

```json
// package.json scripts
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage"
  }
}
```

---

## Resources

- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
- [Vitest](https://vitest.dev/)
- [MSW (Mock Service Worker)](https://mswjs.io/)
- [Testing Library Queries](https://testing-library.com/docs/queries/about)

---

→ [Build Tools](build-tools.md) | [Advanced Patterns](advanced-patterns.md) | [Phase 2 Overview](README.md)
