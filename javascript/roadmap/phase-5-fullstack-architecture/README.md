# Phase 5 – Full-Stack Architecture

[← Back to Roadmap](../README.md) | [JavaScript](../../README.md) | [Main README](../../../README.md)

## Overview

This phase connects all the pieces into a production-grade system. Your distributed systems background applies directly here — apply the same principles you use in .NET/Python services to the frontend/mobile layer.

**Duration:** ~4 weeks (2–3 hrs/day)

---

## Topics

| Topic | Document | Description |
|-------|----------|-------------|
| Authentication Flow | [authentication.md](authentication.md) | JWT, refresh tokens, RBAC, secure mobile storage |
| Real-World Architecture | [architecture.md](architecture.md) | API gateway, Redis, PostgreSQL, Docker, Nginx |
| CI/CD & Deployment | [cicd.md](cicd.md) | GitHub Actions, Docker, cloud deployment |

---

## Architecture Overview

```
┌─────────────────┐   ┌─────────────────┐
│   React Web     │   │  React Native   │
│   (Vite/CDN)    │   │   (Expo/EAS)    │
└────────┬────────┘   └────────┬────────┘
         │ HTTPS                │ HTTPS
         ▼                      ▼
┌─────────────────────────────────────────┐
│            Nginx (Reverse Proxy)         │
│         + SSL termination + Rate limit   │
└────────────────────┬────────────────────┘
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
┌──────────────────┐  ┌──────────────────┐
│  FastAPI/Django  │  │   Static Assets  │
│   (Backend API)  │  │   (S3 / CDN)     │
└────────┬─────────┘  └──────────────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌───────┐ ┌───────┐
│ Postgres│ │ Redis │
│  (DB)  │ │(Cache)│
└───────┘ └───────┘
```

---

## Learning Goals

By the end of Phase 5 you should be able to:

- Implement secure JWT auth with refresh token rotation
- Design a production-ready Dockerized stack
- Set up a CI/CD pipeline with automated testing and deployment
- Apply caching strategies between React and FastAPI
- Implement role-based access control end-to-end

---

## Previous Phase

← [Phase 4 – Python Backend](../phase-4-python-backend/README.md)

## Next Phase

→ [Phase 6 – Advanced](../phase-6-advanced/README.md)
