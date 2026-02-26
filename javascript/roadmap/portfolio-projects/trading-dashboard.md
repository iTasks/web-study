# Trading Dashboard

[← Back to Portfolio](README.md) | [Roadmap](../README.md)

## Overview

A real-time trading dashboard for stocks/crypto — directly relevant to CSE/DSE background.

## Stack

| Layer | Technology |
|-------|-----------|
| Web Frontend | React + Vite + TypeScript |
| Charts | Recharts or TradingView Lightweight Charts |
| Real-time | WebSocket (FastAPI backend) |
| State | Zustand + React Query |
| Backend | FastAPI + Python |
| Simulation | Python async price engine |
| Database | PostgreSQL (time-series via TimescaleDB) |
| Cache | Redis (order book, latest prices) |
| Deploy | Docker Compose → DigitalOcean/AWS |

---

## Features to Build

### Phase 1 Milestone (Mock data)
- [ ] Price ticker cards (symbol, price, change %)
- [ ] Candlestick chart (mock OHLCV data)
- [ ] Watchlist sidebar
- [ ] Responsive layout

### Phase 2 Milestone (State management)
- [ ] Zustand store for watchlist
- [ ] Filter/sort instruments
- [ ] Persisted watchlist (localStorage)

### Phase 4 Milestone (Backend)
- [ ] FastAPI price simulator (random walk)
- [ ] WebSocket endpoint broadcasting price ticks
- [ ] REST endpoints for historical OHLCV data
- [ ] Portfolio holdings endpoint

### Phase 5 Milestone (Production)
- [ ] JWT auth (user accounts)
- [ ] Dockerized stack
- [ ] Redis for order book caching
- [ ] Nginx reverse proxy
- [ ] Deployed and publicly accessible

---

## Key Learning Points

- WebSocket management in React (connect, reconnect, cleanup)
- High-frequency data rendering without performance issues
- Time-series data visualization
- Python async streaming with `asyncio`

---

## Architecture Diagram

```
Browser
  │ WebSocket
  ▼
FastAPI WS endpoint
  │ subscribe
  ▼
Price Simulation Engine (asyncio)
  │ publish
  ├──► Redis Pub/Sub ──► Connected clients
  └──► PostgreSQL/TimescaleDB (store ticks)
```

---

## Starter Code

```python
# backend/app/price_engine.py
import asyncio
import random
from datetime import datetime

class PriceEngine:
    def __init__(self):
        self.prices: dict[str, float] = {
            "BTCUSD": 45_000.0,
            "ETHUSD": 2_500.0,
            "AAPL": 185.0,
        }
        self._subscribers: list[asyncio.Queue] = []

    def subscribe(self) -> asyncio.Queue:
        q: asyncio.Queue = asyncio.Queue(maxsize=100)
        self._subscribers.append(q)
        return q

    def unsubscribe(self, q: asyncio.Queue):
        self._subscribers.remove(q)

    async def run(self):
        while True:
            for symbol in self.prices:
                change = random.uniform(-0.002, 0.002)
                self.prices[symbol] *= 1 + change
                tick = {
                    "symbol": symbol,
                    "price": round(self.prices[symbol], 2),
                    "ts": datetime.utcnow().isoformat(),
                    "change": round(change * 100, 4),
                }
                for q in self._subscribers:
                    try:
                        q.put_nowait(tick)
                    except asyncio.QueueFull:
                        pass
            await asyncio.sleep(0.5)
```

---

→ [Service Marketplace](service-marketplace.md) | [Portfolio Overview](README.md)
