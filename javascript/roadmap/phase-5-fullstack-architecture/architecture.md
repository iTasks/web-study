# Real-World Architecture

[← Back to Phase 5](README.md) | [Roadmap](../README.md)

## Docker Compose Stack

```yaml
# docker-compose.yml
version: "3.9"

services:
  # ── Frontend (React) ──────────────────────────────
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      args:
        VITE_API_URL: /api          # relative — proxied by nginx
    ports: []                       # only exposed via nginx
    depends_on:
      - backend

  # ── Backend (FastAPI) ─────────────────────────────
  backend:
    build: ./backend
    environment:
      DATABASE_URL: postgresql+asyncpg://user:password@db:5432/mydb
      REDIS_URL: redis://redis:6379/0
      JWT_SECRET: ${JWT_SECRET}
      JWT_REFRESH_SECRET: ${JWT_REFRESH_SECRET}
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      retries: 3

  # ── Nginx (Reverse Proxy) ─────────────────────────
  nginx:
    image: nginx:1.25-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - frontend
      - backend

  # ── PostgreSQL ────────────────────────────────────
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydb
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d mydb"]
      interval: 10s
      retries: 5

  # ── Redis (Cache + Sessions) ──────────────────────
  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

---

## Frontend Dockerfile (Multi-Stage)

```dockerfile
# frontend/Dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --frozen-lockfile
COPY . .
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL
RUN npm run build

# Production stage — minimal nginx image
FROM nginx:1.25-alpine AS production
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## Backend Dockerfile

```dockerfile
# backend/Dockerfile
FROM python:3.12-slim AS base
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app

FROM base AS dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM dependencies AS production
COPY . .
RUN addgroup --system app && adduser --system --group app
USER app
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

---

## Nginx Configuration

```nginx
# nginx/nginx.conf
events { worker_connections 1024; }

http {
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=30r/s;
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/m;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;

    server {
        listen 80;
        server_name _;
        return 301 https://$host$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name app.example.com;

        ssl_certificate     /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;

        # Security headers
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options DENY;
        add_header Content-Security-Policy "default-src 'self'";

        # Frontend — serve static files
        location / {
            proxy_pass http://frontend:80;
            proxy_set_header Host $host;
        }

        # Backend API
        location /api/ {
            limit_req zone=api burst=50 nodelay;
            rewrite ^/api/(.*)$ /$1 break;
            proxy_pass http://backend:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # Auth endpoints — stricter rate limiting
        location /api/auth/ {
            limit_req zone=auth burst=5 nodelay;
            proxy_pass http://backend:8000/auth/;
        }

        # WebSocket
        location /ws/ {
            proxy_pass http://backend:8000/ws/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
}
```

---

## Redis Caching (FastAPI)

```python
# app/cache.py
import json
from functools import wraps
from typing import Any, Callable
import redis.asyncio as aioredis
from app.config import settings

redis_client = aioredis.from_url(settings.REDIS_URL)

async def cache_get(key: str) -> Any | None:
    data = await redis_client.get(key)
    return json.loads(data) if data else None

async def cache_set(key: str, value: Any, ttl: int = 300):
    await redis_client.setex(key, ttl, json.dumps(value, default=str))

async def cache_delete(key: str):
    await redis_client.delete(key)

def cached(prefix: str, ttl: int = 300):
    """Decorator for caching endpoint responses."""
    def decorator(func: Callable):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            key = f"{prefix}:{':'.join(str(v) for v in kwargs.values())}"
            if cached_val := await cache_get(key):
                return cached_val
            result = await func(*args, **kwargs)
            await cache_set(key, result, ttl)
            return result
        return wrapper
    return decorator

# Usage
@router.get("/{user_id}")
@cached(prefix="user", ttl=600)
async def get_user(user_id: str, service: UserService = Depends()):
    return await service.get_by_id(user_id)
```

---

## Object Storage (S3-Compatible)

```python
# app/storage.py — works with AWS S3, MinIO, Backblaze B2, Cloudflare R2
import boto3
from botocore.client import Config

s3 = boto3.client(
    "s3",
    endpoint_url=settings.S3_ENDPOINT,
    aws_access_key_id=settings.S3_KEY,
    aws_secret_access_key=settings.S3_SECRET,
    config=Config(signature_version="s3v4"),
)

async def upload_file(file: UploadFile, path: str) -> str:
    """Upload file and return CDN URL."""
    s3.upload_fileobj(
        file.file,
        settings.S3_BUCKET,
        path,
        ExtraArgs={"ContentType": file.content_type, "ACL": "public-read"},
    )
    return f"{settings.CDN_URL}/{path}"
```

---

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Nginx Configuration](https://nginx.org/en/docs/)
- [Redis Documentation](https://redis.io/docs/)

---

→ [CI/CD](cicd.md) | [Authentication](authentication.md) | [Phase 5 Overview](README.md)
