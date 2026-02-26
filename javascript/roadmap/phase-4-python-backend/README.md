# Phase 4 – Python Backend (Production Grade)

[← Back to Roadmap](../README.md) | [JavaScript](../../README.md) | [Main README](../../../README.md)

## Overview

Since you already work in backend engineering, this phase focuses on **frontend integration quality** — designing APIs that React/React Native clients consume cleanly.

**Duration:** ~4 weeks (2–3 hrs/day)

---

## Recommended Stacks

| Option | Technology | Best For |
|--------|-----------|----------|
| Option 1 | [FastAPI](fastapi.md) | Modern, async, type-safe, high performance |
| Option 2 | [Django + DRF](django-drf.md) | Full-featured, admin panel, ORM, batteries included |

---

## Topics

| Topic | Document | Description |
|-------|----------|-------------|
| FastAPI | [fastapi.md](fastapi.md) | Async, Pydantic, JWT, WebSockets, DI |
| Django + DRF | [django-drf.md](django-drf.md) | Serializers, ViewSets, auth, permissions, ORM |

---

## Frontend Integration Focus

Regardless of framework, ensure your backend:

- ✅ Returns consistent JSON error shapes
- ✅ Implements proper CORS for dev and production origins
- ✅ Paginates list endpoints (`page`, `page_size`, `total`)
- ✅ Supports filtering and sorting via query params
- ✅ Returns appropriate HTTP status codes
- ✅ Documents endpoints with OpenAPI (both frameworks do this automatically)
- ✅ Uses JWT with refresh tokens for auth

---

## Previous Phase

← [Phase 3 – React Native](../phase-3-react-native/README.md)

## Next Phase

→ [Phase 5 – Full-Stack Architecture](../phase-5-fullstack-architecture/README.md)
