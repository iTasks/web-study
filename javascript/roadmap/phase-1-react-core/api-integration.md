# API Integration

[← Back to Phase 1](README.md) | [Roadmap](../README.md)

## HTTP Clients

### Axios (Recommended)

```bash
npm install axios
```

```typescript
// src/lib/apiClient.ts — shared Axios instance
import axios, { AxiosError } from 'axios';

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL ?? 'http://localhost:8000',
  timeout: 10_000,
  headers: { 'Content-Type': 'application/json' },
});

// Request interceptor — attach auth token
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor — handle token expiry globally
apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    if (error.response?.status === 401) {
      // Try to refresh token
      try {
        const refreshed = await refreshAccessToken();
        localStorage.setItem('access_token', refreshed.access_token);
        // Retry original request
        return apiClient.request(error.config!);
      } catch {
        localStorage.removeItem('access_token');
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  },
);
```

### Fetch API

Built into modern browsers — no dependencies required.

```typescript
async function fetchJson<T>(url: string, options?: RequestInit): Promise<T> {
  const response = await fetch(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${getToken()}`,
      ...options?.headers,
    },
  });

  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    throw new ApiError(body.message ?? response.statusText, response.status);
  }

  return response.json() as Promise<T>;
}
```

---

## Typed API Service Layer

Separate data-fetching logic from UI — mirrors the repository/service pattern.

```typescript
// src/services/userService.ts
import { apiClient } from '@/lib/apiClient';

export interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'editor' | 'viewer';
  createdAt: string;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
}

export interface UserFilters {
  search?: string;
  role?: User['role'];
  page?: number;
  pageSize?: number;
}

export const userService = {
  async getAll(filters: UserFilters = {}): Promise<PaginatedResponse<User>> {
    const { data } = await apiClient.get<PaginatedResponse<User>>('/users', {
      params: filters,
    });
    return data;
  },

  async getById(id: string): Promise<User> {
    const { data } = await apiClient.get<User>(`/users/${id}`);
    return data;
  },

  async create(payload: Omit<User, 'id' | 'createdAt'>): Promise<User> {
    const { data } = await apiClient.post<User>('/users', payload);
    return data;
  },

  async update(id: string, payload: Partial<User>): Promise<User> {
    const { data } = await apiClient.patch<User>(`/users/${id}`, payload);
    return data;
  },

  async delete(id: string): Promise<void> {
    await apiClient.delete(`/users/${id}`);
  },
};
```

---

## Data Fetching in Components

### With React Query (TanStack Query) — Recommended

```bash
npm install @tanstack/react-query
```

```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { userService } from '@/services/userService';

// Setup in main.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
const queryClient = new QueryClient();

// Query hook usage
function UserList() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: () => userService.getAll(),
    staleTime: 5 * 60 * 1000,   // cache for 5 minutes
  });

  const queryClient = useQueryClient();

  const deleteMutation = useMutation({
    mutationFn: userService.delete,
    onSuccess: () => {
      // Invalidate and refetch
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });

  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;

  return (
    <ul>
      {data?.items.map((user) => (
        <li key={user.id}>
          {user.name}
          <button
            onClick={() => deleteMutation.mutate(user.id)}
            disabled={deleteMutation.isPending}
          >
            Delete
          </button>
        </li>
      ))}
    </ul>
  );
}
```

### Manual `useEffect` Pattern

```tsx
function useUsers(filters: UserFilters) {
  const [state, setState] = useState<RequestState<PaginatedResponse<User>>>({
    status: 'idle',
  });

  useEffect(() => {
    setState({ status: 'loading' });
    userService
      .getAll(filters)
      .then((data) => setState({ status: 'success', data }))
      .catch((error) => setState({ status: 'error', error }));
  }, [filters]);   // re-fetch when filters change

  return state;
}
```

---

## Token-Based Auth (JWT)

### Frontend Auth Flow

```typescript
// src/lib/auth.ts
export interface AuthTokens {
  access_token: string;
  refresh_token: string;
  expires_in: number;
}

export async function login(email: string, password: string): Promise<AuthTokens> {
  const { data } = await apiClient.post<AuthTokens>('/auth/login', {
    email,
    password,
  });
  localStorage.setItem('access_token', data.access_token);
  localStorage.setItem('refresh_token', data.refresh_token);
  return data;
}

export async function refreshAccessToken(): Promise<AuthTokens> {
  const refresh_token = localStorage.getItem('refresh_token');
  const { data } = await axios.post<AuthTokens>('/auth/refresh', {
    refresh_token,
  });
  return data;
}

export function logout() {
  localStorage.removeItem('access_token');
  localStorage.removeItem('refresh_token');
  window.location.href = '/login';
}
```

---

## Python Backend Setup (FastAPI)

```python
# main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="My API", version="1.0.0")

# CORS — allow your React dev server
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],  # Vite default port
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pagination helper
from pydantic import BaseModel
from typing import Generic, TypeVar, List

T = TypeVar("T")

class PaginatedResponse(BaseModel, Generic[T]):
    items: List[T]
    total: int
    page: int
    page_size: int

# Auth endpoints
@app.post("/auth/login")
async def login(credentials: LoginRequest) -> TokenResponse:
    user = await authenticate_user(credentials.email, credentials.password)
    access_token = create_access_token(user.id)
    refresh_token = create_refresh_token(user.id)
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=3600,
    )
```

---

## Error Handling Patterns

```typescript
// src/lib/errors.ts
export class ApiError extends Error {
  constructor(
    message: string,
    public readonly status: number,
    public readonly code?: string,
  ) {
    super(message);
    this.name = 'ApiError';
  }

  get isUnauthorized() { return this.status === 401; }
  get isForbidden()    { return this.status === 403; }
  get isNotFound()     { return this.status === 404; }
  get isServerError()  { return this.status >= 500; }
}

// Global error boundary in React component
function ErrorFallback({ error, resetError }: { error: Error; resetError: () => void }) {
  if (error instanceof ApiError && error.isServerError) {
    return (
      <div role="alert">
        <h2>Something went wrong on our end</h2>
        <button onClick={resetError}>Try again</button>
      </div>
    );
  }
  return <div role="alert">{error.message}</div>;
}
```

---

## Resources

- [Axios Documentation](https://axios-http.com/docs/intro)
- [TanStack Query](https://tanstack.com/query/latest)
- [FastAPI CORS](https://fastapi.tiangolo.com/tutorial/cors/)
- [JWT.io](https://jwt.io/)

---

→ [Phase 1 Overview](README.md) | [Phase 2 – Advanced React](../phase-2-advanced-react/README.md)
