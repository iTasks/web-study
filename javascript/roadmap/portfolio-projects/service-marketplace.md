# Service Marketplace App

[← Back to Portfolio](README.md) | [Roadmap](../README.md)

## Overview

A mobile-first service marketplace (think TaskRabbit / Fiverr) — demonstrates React Native + FastAPI integration with real-world features.

## Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | React Native + Expo |
| Navigation | React Navigation |
| State | Zustand + React Query |
| Backend | FastAPI + PostgreSQL |
| Payments | Stripe API |
| Maps | Google Maps / Mapbox |
| Storage | S3-compatible (profile photos) |
| Push | Expo Push Notifications |
| Deploy | EAS Build + Railway/Render |

---

## Features to Build

### Phase 3 Milestone (Mobile UI)
- [ ] Onboarding screens
- [ ] Service listing with categories
- [ ] Service detail page
- [ ] Provider profile page
- [ ] Bottom tab navigation
- [ ] Search with filters

### Phase 4 Milestone (Backend)
- [ ] FastAPI backend with full CRUD
- [ ] User auth (customer + provider roles)
- [ ] Service search with geolocation filtering
- [ ] Booking creation and management

### Phase 5 Milestone (Production)
- [ ] Stripe payment integration
- [ ] Push notification for booking updates
- [ ] Photo upload to S3
- [ ] Production EAS build

---

## Key Learning Points

- Complex navigation patterns (tabs + stacks + modals)
- Native API integration (location, camera, notifications)
- Payment flow implementation
- Role-based UX (different flows for customers vs providers)

---

## Data Model

```python
# Simplified schema
class User(BaseModel):
    id: str
    name: str
    email: str
    role: Literal["customer", "provider"]
    avatar_url: Optional[str]

class Service(BaseModel):
    id: str
    provider_id: str
    title: str
    description: str
    category: str
    price_per_hour: Decimal
    location: Point       # lat/lng
    rating: float
    review_count: int

class Booking(BaseModel):
    id: str
    service_id: str
    customer_id: str
    scheduled_at: datetime
    duration_hours: float
    status: Literal["pending", "confirmed", "completed", "cancelled"]
    total_amount: Decimal
    stripe_payment_intent_id: Optional[str]
```

---

→ [SaaS Admin Panel](saas-admin-panel.md) | [Portfolio Overview](README.md)
