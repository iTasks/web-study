# Yelp-Style AI Assistant — Zig

A single-file Zig implementation of a Yelp-style AI assistant HTTP server. It classifies natural-language queries about a business (intent detection), routes them to in-memory search services, and returns a mock-RAG style answer.

## Features

- **Intent Classification** — keyword-based scoring across 4 intents: `operational`, `amenity`, `quality`, `photo`
- **3 Search Services** — StructuredSearch (hours/amenities), ReviewSearch (word-overlap scoring), PhotoSearch (caption lookup)
- **Orchestration** — weighted multi-service evidence gathering per intent
- **Mock RAG Answers** — template-driven answer generation from evidence
- **In-Memory Cache** — 16-slot hash ring buffer with mutex protection (thread-safe)
- **Circuit Breakers** — per-service atomic failure counters; opens at 5 failures
- **HTTP/1.1 Server** — raw TCP with manual request parsing, multi-threaded (one thread per connection)
- **Demo Data** — "The Rustic Table" seeded at startup

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/assistant/query` | Submit a natural-language query |
| `GET` | `/health` | Basic health check |
| `GET` | `/health/detailed` | Circuit breaker + cache stats |

### Query Request

```json
{
  "query": "Does it have wifi?",
  "business_id": "12345"
}
```

### Query Response

```json
{
  "answer": "The Rustic Table has WiFi. (Yes)",
  "confidence": 0.90,
  "intent": "amenity",
  "evidence": {"structured": true, "reviews_used": 0, "photos_used": 0},
  "latency_ms": 0.0
}
```

## Seeded Demo Data

- **Business:** The Rustic Table, `business_id=12345`, 123 Main St New York
- **Hours:** Mon–Thu 09:00–22:00, Fri 09:00–23:00, Sat 10:00–23:00, Sun 10:00–21:00
- **Amenities:** `heated_patio=true`, `parking=false`, `wifi=true`, `wheelchair_accessible=true`
- **Reviews:** 3 reviews (ratings 5.0, 4.0, 4.0)
- **Photos:** 2 photos (patio + interior)

## Requirements

- **Zig 0.15.0+** (tested with 0.15.2)

```bash
zig version   # should be 0.15.x
```

## Build & Run

```bash
# From the project root
cd zig/yelp-ai-assistant

# Build
zig build

# Run (listens on :8080)
zig build run

# Or run the binary directly
./zig-out/bin/yelp-ai-assistant
```

## Usage Examples

```bash
# Basic health check
curl http://localhost:8080/health

# Detailed health (circuit breakers + cache)
curl http://localhost:8080/health/detailed

# Amenity query
curl -X POST http://localhost:8080/assistant/query \
  -H "Content-Type: application/json" \
  -d '{"query":"Does it have wifi?","business_id":"12345"}'

# Operational query (hours)
curl -X POST http://localhost:8080/assistant/query \
  -H "Content-Type: application/json" \
  -d '{"query":"What time does it close today?","business_id":"12345"}'

# Quality query (reviews)
curl -X POST http://localhost:8080/assistant/query \
  -H "Content-Type: application/json" \
  -d '{"query":"Is the food good for a date night?","business_id":"12345"}'

# Photo query
curl -X POST http://localhost:8080/assistant/query \
  -H "Content-Type: application/json" \
  -d '{"query":"Show me pictures of the patio","business_id":"12345"}'
```

## Architecture

```
src/main.zig (single file)
├── Types               — QueryIntent, BusinessData, Review, Photo, etc.
├── SimpleCache         — 16-slot hash ring with Thread.Mutex
├── AppState            — global singleton (seeded at startup)
├── classifyIntent()    — keyword scoring → highest-hit intent
├── structuredSearch()  — hours/amenities from in-memory data
├── reviewSearch()      — word-overlap against 3 seeded reviews
├── photoSearch()       — returns photo captions
├── orchestrate()       — routes intent → service(s) → answer
├── handleHealth()      — GET /health
├── handleHealthDetailed() — GET /health/detailed
├── handleQuery()       — POST /assistant/query (cache + classify + search + respond)
├── parseRequest()      — minimal HTTP/1.1 parser
├── handleConnection()  — per-thread connection handler
└── main()              — bind :8080, accept loop with Thread.spawn + detach
```

## File Structure

```
zig/yelp-ai-assistant/
├── build.zig        — Zig 0.15 build script
├── build.zig.zon    — package manifest
├── src/
│   └── main.zig    — complete implementation (~850 lines)
└── README.md
```
