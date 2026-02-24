# Authentication Flow

[← Back to Phase 5](README.md) | [Roadmap](../README.md)

## JWT Flow Overview

```
Client                     Backend
  │                           │
  ├── POST /auth/login ───────►│
  │   { email, password }      │  verify credentials
  │                            │  generate access_token (1h)
  │                            │  generate refresh_token (30d)
  │◄─── 200 OK ───────────────┤
  │   { access_token,          │
  │     refresh_token }        │
  │                            │
  ├── GET /users ─────────────►│  Authorization: Bearer <access_token>
  │                            │  verify token signature + expiry
  │◄─── 200 OK ───────────────┤
  │                            │
  │   (token expires)          │
  ├── POST /auth/refresh ──────►│  { refresh_token }
  │                            │  verify refresh token
  │                            │  issue new access_token
  │◄─── 200 OK ───────────────┤
  │   { access_token }         │
```

---

## Refresh Token Rotation

```python
# app/routers/auth.py (FastAPI)
from fastapi import APIRouter, HTTPException, status
from app.services.auth import (
    authenticate_user, create_access_token,
    create_refresh_token, verify_refresh_token,
    revoke_refresh_token,
)

router = APIRouter()

@router.post("/login")
async def login(credentials: LoginRequest) -> TokenResponse:
    user = await authenticate_user(credentials.email, credentials.password)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Invalid credentials")
    return TokenResponse(
        access_token=create_access_token(user.id),
        refresh_token=create_refresh_token(user.id),
        expires_in=3600,
    )

@router.post("/refresh")
async def refresh(body: RefreshRequest, db=Depends(get_db)) -> TokenResponse:
    payload = verify_refresh_token(body.refresh_token)
    if not payload:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Invalid or expired refresh token")

    # Rotation: revoke old token, issue new pair
    await revoke_refresh_token(body.refresh_token, db)
    user_id = payload["sub"]
    return TokenResponse(
        access_token=create_access_token(user_id),
        refresh_token=create_refresh_token(user_id),
        expires_in=3600,
    )

@router.post("/logout")
async def logout(body: RefreshRequest, db=Depends(get_db)):
    await revoke_refresh_token(body.refresh_token, db)
    return {"message": "Logged out"}
```

---

## Frontend Auth Context (React)

```tsx
// src/context/AuthContext.tsx
interface AuthContextValue {
  user: AuthUser | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  isAuthenticated: boolean;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Restore session on app load
  useEffect(() => {
    const token = localStorage.getItem('access_token');
    if (token) {
      authService.getMe()
        .then(setUser)
        .catch(() => localStorage.removeItem('access_token'))
        .finally(() => setIsLoading(false));
    } else {
      setIsLoading(false);
    }
  }, []);

  const login = async (email: string, password: string) => {
    const tokens = await authService.login(email, password);
    localStorage.setItem('access_token', tokens.access_token);
    localStorage.setItem('refresh_token', tokens.refresh_token);
    setUser(await authService.getMe());
  };

  const logout = async () => {
    const refresh = localStorage.getItem('refresh_token');
    if (refresh) await authService.logout(refresh).catch(() => {});
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, isAuthenticated: !!user, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be inside AuthProvider');
  return ctx;
};
```

---

## Role-Based Access Control (RBAC)

```tsx
// React — role-gated components
interface RoleGateProps {
  children: React.ReactNode;
  allowedRoles: UserRole[];
  fallback?: React.ReactNode;
}

function RoleGate({ children, allowedRoles, fallback = null }: RoleGateProps) {
  const { user } = useAuth();
  if (!user || !allowedRoles.includes(user.role)) return <>{fallback}</>;
  return <>{children}</>;
}

// Usage
<RoleGate allowedRoles={['admin']}>
  <DeleteButton />
</RoleGate>

<RoleGate allowedRoles={['admin', 'editor']} fallback={<ReadOnlyView />}>
  <EditableView />
</RoleGate>
```

---

## Secure Storage — React Native

On mobile, **never use AsyncStorage for tokens** — it's unencrypted.

```typescript
// Use expo-secure-store (Keychain / Keystore)
import * as SecureStore from 'expo-secure-store';

export const authStorage = {
  async saveTokens(access: string, refresh: string) {
    await Promise.all([
      SecureStore.setItemAsync('access_token', access),
      SecureStore.setItemAsync('refresh_token', refresh),
    ]);
  },
  async getAccessToken(): Promise<string | null> {
    return SecureStore.getItemAsync('access_token');
  },
  async clearTokens() {
    await Promise.all([
      SecureStore.deleteItemAsync('access_token'),
      SecureStore.deleteItemAsync('refresh_token'),
    ]);
  },
};
```

---

## Resources

- [JWT.io](https://jwt.io/)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [Refresh Token Rotation](https://auth0.com/docs/secure/tokens/refresh-tokens/refresh-token-rotation)

---

→ [Architecture](architecture.md) | [Phase 5 Overview](README.md)
