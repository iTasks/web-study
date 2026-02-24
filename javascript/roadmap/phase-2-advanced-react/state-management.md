# State Management

[← Back to Phase 2](README.md) | [Roadmap](../README.md)

## Context API

Built into React — best for low-frequency updates (theme, locale, auth user).

```tsx
// 1. Create context with a typed default
interface ThemeContextValue {
  theme: 'light' | 'dark';
  toggle: () => void;
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

// 2. Custom hook — avoids null checks at call sites
export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme must be used inside ThemeProvider');
  return ctx;
}

// 3. Provider component
export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  const toggle = useCallback(() => setTheme((t) => (t === 'light' ? 'dark' : 'light')), []);

  return (
    <ThemeContext.Provider value={{ theme, toggle }}>
      {children}
    </ThemeContext.Provider>
  );
}

// 4. Consumption — any depth in the tree
function ThemeToggle() {
  const { theme, toggle } = useTheme();
  return <button onClick={toggle}>{theme === 'light' ? '🌙' : '☀️'}</button>;
}
```

**Context limitations:** Every consumer re-renders on any context change. For high-frequency updates (form state, animations), prefer Zustand or Redux.

---

## Zustand

Minimal, fast global state — no boilerplate, no providers needed.

```bash
npm install zustand
```

```typescript
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
}

interface CartStore {
  items: CartItem[];
  addItem: (item: Omit<CartItem, 'quantity'>) => void;
  removeItem: (id: string) => void;
  updateQuantity: (id: string, quantity: number) => void;
  clear: () => void;
  total: () => number;
}

export const useCartStore = create<CartStore>()(
  devtools(
    persist(
      (set, get) => ({
        items: [],

        addItem: (item) =>
          set((state) => {
            const existing = state.items.find((i) => i.id === item.id);
            if (existing) {
              return {
                items: state.items.map((i) =>
                  i.id === item.id ? { ...i, quantity: i.quantity + 1 } : i,
                ),
              };
            }
            return { items: [...state.items, { ...item, quantity: 1 }] };
          }),

        removeItem: (id) =>
          set((state) => ({ items: state.items.filter((i) => i.id !== id) })),

        updateQuantity: (id, quantity) =>
          set((state) => ({
            items: quantity <= 0
              ? state.items.filter((i) => i.id !== id)
              : state.items.map((i) => (i.id === id ? { ...i, quantity } : i)),
          })),

        clear: () => set({ items: [] }),

        total: () => get().items.reduce((sum, i) => sum + i.price * i.quantity, 0),
      }),
      { name: 'cart-storage' },   // persisted to localStorage
    ),
  ),
);

// Usage — no Provider needed
function CartButton() {
  const { items, addItem } = useCartStore();
  return (
    <button onClick={() => addItem({ id: '1', name: 'Item', price: 9.99 })}>
      Cart ({items.length})
    </button>
  );
}
```

---

## Redux Toolkit

The official, opinionated Redux — eliminates boilerplate, includes Immer for mutations.

```bash
npm install @reduxjs/toolkit react-redux
```

```typescript
// src/store/userSlice.ts
import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';

// Async thunk — equivalent to a service/command in backend
export const fetchUsers = createAsyncThunk(
  'users/fetchAll',
  async (filters: UserFilters, { rejectWithValue }) => {
    try {
      return await userService.getAll(filters);
    } catch (error) {
      return rejectWithValue((error as ApiError).message);
    }
  },
);

interface UsersState {
  items: User[];
  total: number;
  status: 'idle' | 'loading' | 'succeeded' | 'failed';
  error: string | null;
  selectedId: string | null;
}

const usersSlice = createSlice({
  name: 'users',
  initialState: {
    items: [],
    total: 0,
    status: 'idle',
    error: null,
    selectedId: null,
  } as UsersState,
  reducers: {
    selectUser: (state, action: PayloadAction<string>) => {
      state.selectedId = action.payload;   // Immer allows "mutations"
    },
    clearSelection: (state) => {
      state.selectedId = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchUsers.pending, (state) => {
        state.status = 'loading';
        state.error = null;
      })
      .addCase(fetchUsers.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.items = action.payload.items;
        state.total = action.payload.total;
      })
      .addCase(fetchUsers.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.payload as string;
      });
  },
});

export const { selectUser, clearSelection } = usersSlice.actions;
export default usersSlice.reducer;
```

```typescript
// src/store/index.ts — configure store
import { configureStore } from '@reduxjs/toolkit';
import usersReducer from './userSlice';

export const store = configureStore({
  reducer: {
    users: usersReducer,
  },
});

// Typed hooks
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

export const useAppSelector = <T>(selector: (state: RootState) => T) =>
  useSelector(selector);
export const useAppDispatch = () => useDispatch<AppDispatch>();
```

```tsx
// Usage
function UserList() {
  const dispatch = useAppDispatch();
  const { items, status, error } = useAppSelector((s) => s.users);

  useEffect(() => {
    if (status === 'idle') dispatch(fetchUsers({}));
  }, [dispatch, status]);

  if (status === 'loading') return <Spinner />;
  if (status === 'failed') return <ErrorMessage message={error!} />;

  return <ul>{items.map((u) => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

---

## RTK Query — Server State with Redux

Eliminates manual loading/error state for API calls.

```typescript
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

export const api = createApi({
  reducerPath: 'api',
  baseQuery: fetchBaseQuery({
    baseUrl: import.meta.env.VITE_API_URL,
    prepareHeaders: (headers) => {
      const token = localStorage.getItem('access_token');
      if (token) headers.set('Authorization', `Bearer ${token}`);
      return headers;
    },
  }),
  tagTypes: ['User'],
  endpoints: (builder) => ({
    getUsers: builder.query<PaginatedResponse<User>, UserFilters>({
      query: (filters) => ({ url: '/users', params: filters }),
      providesTags: ['User'],
    }),
    deleteUser: builder.mutation<void, string>({
      query: (id) => ({ url: `/users/${id}`, method: 'DELETE' }),
      invalidatesTags: ['User'],   // auto-refetch user list
    }),
  }),
});

export const { useGetUsersQuery, useDeleteUserMutation } = api;
```

---

## Resources

- [Zustand Documentation](https://zustand-demo.pmnd.rs/)
- [Redux Toolkit Documentation](https://redux-toolkit.js.org/)
- [TanStack Query](https://tanstack.com/query/latest)
- [When to use Context vs Redux](https://redux.js.org/faq/organizing-state#when-should-i-use-redux)

---

→ [Performance Optimization](performance.md) | [Phase 2 Overview](README.md)
