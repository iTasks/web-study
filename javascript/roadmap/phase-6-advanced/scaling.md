# Scaling

[← Back to Phase 6](README.md) | [Roadmap](../README.md)

## Caching Strategy

```
Browser Cache
    ↓ miss
CDN (CloudFront/Cloudflare)
    ↓ miss
Nginx Cache
    ↓ miss
Application Cache (Redis)
    ↓ miss
Database
```

### React Query Cache Headers

```typescript
// Backend — set cache headers aligned with React Query staleTime
@router.get("/products")
async def list_products():
    headers = {
        "Cache-Control": "public, s-maxage=60, stale-while-revalidate=300",
        "CDN-Cache-Control": "public, max-age=60",
    }
    return Response(content=json.dumps(data), headers=headers)
```

### CDN Configuration (CloudFront)

```json
{
  "CacheBehaviors": [
    {
      "PathPattern": "/assets/*",
      "ViewerProtocolPolicy": "redirect-to-https",
      "CachePolicyId": "long-cache",
      "MinTTL": 31536000,
      "DefaultTTL": 31536000
    },
    {
      "PathPattern": "/api/*",
      "ViewerProtocolPolicy": "redirect-to-https",
      "CachePolicyId": "no-cache",
      "MinTTL": 0,
      "DefaultTTL": 0
    }
  ]
}
```

---

## Load Balancing

```nginx
# nginx upstream configuration
upstream backend {
    least_conn;                              # least connections algorithm
    server backend1:8000 weight=3;
    server backend2:8000 weight=3;
    server backend3:8000 weight=1 backup;   # backup server
    keepalive 32;                            # connection pool
}

server {
    location /api/ {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";      # enable keepalive
    }
}
```

---

## Rate Limiting

```python
# FastAPI rate limiting with Redis + slowapi
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address, storage_uri=settings.REDIS_URL)

@router.post("/auth/login")
@limiter.limit("5/minute")
async def login(request: Request, credentials: LoginRequest):
    ...

@router.get("/users")
@limiter.limit("100/minute")
async def list_users(request: Request):
    ...
```

---

## Horizontal Scaling Checklist

- ✅ **Stateless** backend — no in-memory session state (use Redis)
- ✅ **Shared storage** — S3/compatible for file uploads (not local disk)
- ✅ **Distributed cache** — Redis instead of in-process cache
- ✅ **Database connection pooling** — PgBouncer or SQLAlchemy pool
- ✅ **Background tasks** — Celery/RQ with Redis, not in-process threads
- ✅ **Health endpoints** — `/health` and `/ready` for load balancer checks
- ✅ **Graceful shutdown** — handle SIGTERM, drain requests before exit
- ✅ **12-Factor App** — config via env vars, no hardcoded values

---

## Database Connection Pooling

```python
# SQLAlchemy async engine with pool
from sqlalchemy.ext.asyncio import create_async_engine

engine = create_async_engine(
    settings.DATABASE_URL,
    pool_size=20,          # connections per worker
    max_overflow=10,       # extra connections under load
    pool_pre_ping=True,    # check connection health
    pool_recycle=3600,     # recycle connections after 1h
)
```

---

## Resources

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [NGINX Load Balancing](https://nginx.org/en/docs/http/load_balancing.html)
- [Redis Caching Strategies](https://redis.io/docs/manual/patterns/)
- [12-Factor App](https://12factor.net/)

---

→ [Phase 6 Overview](README.md) | [Portfolio Projects](../portfolio-projects/README.md)
