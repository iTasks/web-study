# FastAPI (Modern Python Backend)

[← Back to Phase 4](README.md) | [Roadmap](../README.md)

## Setup

```bash
pip install fastapi uvicorn[standard] pydantic[email] python-jose[cryptography] passlib[bcrypt] sqlalchemy alembic psycopg2-binary python-multipart

# Project structure
backend/
├── main.py
├── requirements.txt
├── alembic/
├── app/
│   ├── __init__.py
│   ├── config.py
│   ├── database.py
│   ├── models/
│   ├── schemas/          # Pydantic models (DTOs)
│   ├── routers/
│   ├── services/
│   └── dependencies.py
```

---

## Application Bootstrap

```python
# app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import users, auth

app = FastAPI(
    title="My API",
    version="1.0.0",
    docs_url="/docs",        # Swagger UI (dev only — disable in prod)
    redoc_url="/redoc",
)

# CORS — explicitly list allowed origins
ALLOWED_ORIGINS = [
    "http://localhost:5173",   # Vite dev
    "https://app.example.com", # Production
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)

app.include_router(auth.router,  prefix="/auth",  tags=["auth"])
app.include_router(users.router, prefix="/users", tags=["users"])

@app.get("/health")
def health_check():
    return {"status": "ok"}
```

---

## Pydantic Schemas (DTOs)

```python
# app/schemas/user.py
from pydantic import BaseModel, EmailStr, Field, ConfigDict
from datetime import datetime
from typing import Optional
from enum import Enum

class UserRole(str, Enum):
    admin  = "admin"
    editor = "editor"
    viewer = "viewer"

class UserBase(BaseModel):
    name:  str = Field(..., min_length=1, max_length=100)
    email: EmailStr

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)
    role: UserRole = UserRole.viewer

class UserUpdate(BaseModel):
    name:  Optional[str]     = Field(None, min_length=1, max_length=100)
    email: Optional[EmailStr] = None
    role:  Optional[UserRole] = None

class UserResponse(UserBase):
    model_config = ConfigDict(from_attributes=True)  # ORM mode

    id:         str
    role:       UserRole
    created_at: datetime
    deleted_at: Optional[datetime] = None

class PaginatedResponse(BaseModel):
    items:     list[UserResponse]
    total:     int
    page:      int
    page_size: int
```

---

## Dependency Injection

```python
# app/dependencies.py
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.services.auth import verify_access_token
from app.services.user import UserService
from app.database import get_db

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db = Depends(get_db),
) -> User:
    token = credentials.credentials
    payload = verify_access_token(token)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )
    user = await UserService(db).get_by_id(payload["sub"])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

def require_role(*roles: str):
    def checker(user: User = Depends(get_current_user)) -> User:
        if user.role not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions",
            )
        return user
    return checker
```

---

## Router with Full CRUD

```python
# app/routers/users.py
from fastapi import APIRouter, Depends, Query, status
from app.schemas.user import UserCreate, UserUpdate, UserResponse, PaginatedResponse
from app.services.user import UserService
from app.dependencies import get_current_user, require_role

router = APIRouter()

@router.get("", response_model=PaginatedResponse)
async def list_users(
    page:      int   = Query(1, ge=1),
    page_size: int   = Query(20, ge=1, le=100),
    search:    str   = Query(""),
    role:      str   = Query(None),
    _user                = Depends(require_role("admin", "editor")),
    service: UserService = Depends(),
):
    return await service.list(page=page, page_size=page_size, search=search, role=role)

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: str,
    current_user = Depends(get_current_user),
    service: UserService = Depends(),
):
    user = await service.get_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.post("", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    body:    UserCreate,
    _user          = Depends(require_role("admin")),
    service: UserService = Depends(),
):
    return await service.create(body)

@router.patch("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: str,
    body:    UserUpdate,
    _user          = Depends(require_role("admin", "editor")),
    service: UserService = Depends(),
):
    return await service.update(user_id, body)

@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: str,
    _user          = Depends(require_role("admin")),
    service: UserService = Depends(),
):
    await service.delete(user_id)
```

---

## JWT Authentication

```python
# app/services/auth.py
from datetime import datetime, timedelta
from jose import jwt, JWTError
from passlib.context import CryptContext
from app.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def create_access_token(user_id: str, expires_minutes: int = 60) -> str:
    return jwt.encode(
        {"sub": user_id, "exp": datetime.utcnow() + timedelta(minutes=expires_minutes)},
        settings.JWT_SECRET,
        algorithm="HS256",
    )

def create_refresh_token(user_id: str) -> str:
    return jwt.encode(
        {"sub": user_id, "type": "refresh",
         "exp": datetime.utcnow() + timedelta(days=30)},
        settings.JWT_REFRESH_SECRET,
        algorithm="HS256",
    )

def verify_access_token(token: str) -> dict | None:
    try:
        return jwt.decode(token, settings.JWT_SECRET, algorithms=["HS256"])
    except JWTError:
        return None
```

---

## WebSockets (Real-Time)

```python
# app/routers/ws.py
from fastapi import WebSocket, WebSocketDisconnect

class ConnectionManager:
    def __init__(self):
        self.active: dict[str, WebSocket] = {}

    async def connect(self, user_id: str, ws: WebSocket):
        await ws.accept()
        self.active[user_id] = ws

    def disconnect(self, user_id: str):
        self.active.pop(user_id, None)

    async def send_to(self, user_id: str, data: dict):
        if ws := self.active.get(user_id):
            await ws.send_json(data)

    async def broadcast(self, data: dict):
        for ws in self.active.values():
            await ws.send_json(data)

manager = ConnectionManager()

@router.websocket("/ws/{user_id}")
async def websocket_endpoint(ws: WebSocket, user_id: str):
    await manager.connect(user_id, ws)
    try:
        while True:
            data = await ws.receive_json()
            await manager.broadcast({"from": user_id, **data})
    except WebSocketDisconnect:
        manager.disconnect(user_id)
```

---

## Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Pydantic v2](https://docs.pydantic.dev/latest/)
- [SQLAlchemy](https://docs.sqlalchemy.org/)
- [Alembic Migrations](https://alembic.sqlalchemy.org/)

---

→ [Django + DRF](django-drf.md) | [Phase 4 Overview](README.md)
