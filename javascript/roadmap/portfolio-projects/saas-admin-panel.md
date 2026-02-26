# SaaS Admin Panel

[← Back to Portfolio](README.md) | [Roadmap](../README.md)

## Overview

A multi-tenant SaaS admin panel — demonstrates advanced React patterns, RBAC, and Next.js SSR.

## Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Next.js 14 (App Router) + TypeScript |
| UI | Tailwind CSS + shadcn/ui |
| State | Zustand + TanStack Query |
| Backend | Django + DRF |
| Auth | NextAuth.js + JWT |
| Database | PostgreSQL (multi-tenant schema) |
| Analytics | Recharts / Tremor |
| Cache | Redis |
| Deploy | Vercel (frontend) + Railway (backend) |

---

## Features to Build

### Phase 1–2 Milestone (React)
- [ ] Dashboard layout with sidebar navigation
- [ ] Analytics charts (line, bar, pie)
- [ ] User management table (search, filter, sort, paginate)
- [ ] Role badge display
- [ ] Responsive design

### Phase 4 Milestone (Django Backend)
- [ ] Multi-tenant data isolation (tenant per schema or row-level)
- [ ] Django Admin setup
- [ ] Full CRUD API for users, roles, settings
- [ ] Activity log

### Phase 5 Milestone (Production)
- [ ] NextAuth.js integration with Django backend
- [ ] Role-based page access
- [ ] Deployed to Vercel + Railway
- [ ] CDN for static assets

---

## Multi-Tenancy Approach

```python
# Row-level multi-tenancy with Django
class TenantManager(models.Manager):
    def get_queryset(self):
        tenant = get_current_tenant()   # from thread-local / middleware
        return super().get_queryset().filter(tenant=tenant)

class Resource(models.Model):
    tenant = models.ForeignKey(Tenant, on_delete=models.CASCADE, db_index=True)
    # ... other fields

    objects = TenantManager()

# Middleware sets current tenant from subdomain or JWT claim
class TenantMiddleware:
    def __call__(self, request):
        tenant_id = extract_tenant_from_request(request)
        set_current_tenant(tenant_id)
        return self.get_response(request)
```

---

## Role-Based Access in Next.js

```tsx
// middleware.ts — Next.js Edge Middleware
import { withAuth } from 'next-auth/middleware';
import { NextResponse } from 'next/server';

export default withAuth(
  function middleware(req) {
    const { token } = req.nextauth;
    const { pathname } = req.nextUrl;

    if (pathname.startsWith('/admin') && token?.role !== 'admin') {
      return NextResponse.redirect(new URL('/unauthorized', req.url));
    }
    return NextResponse.next();
  },
  { callbacks: { authorized: ({ token }) => !!token } },
);

export const config = {
  matcher: ['/dashboard/:path*', '/admin/:path*'],
};
```

---

## Key Learning Points

- Next.js App Router with server + client components
- Django multi-tenancy patterns
- Complex RBAC implementation end-to-end
- Production deployment with Vercel + Railway
- Dashboard analytics design patterns

---

→ [Portfolio Overview](README.md) | [Roadmap Overview](../README.md)
