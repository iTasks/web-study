# Yelp-Style AI Assistant (Rust)

[← Back to Rust](../README.md) | [Main README](../../README.md)

A Rust implementation of a Yelp-style AI assistant that classifies query intent, routes to search services, orchestrates results, and generates mock LLM answers.

## Architecture

```
src/
├── main.rs           – tokio main, hyper HTTP server, routing, seed data
├── models.rs         – Data types (QueryIntent, BusinessData, Review, etc.)
├── intent.rs         – IntentClassifier (regex keyword matching)
├── routing.rs        – QueryRouter (maps intent → search services)
├── search.rs         – StructuredSearch, ReviewVectorSearch, PhotoHybridRetrieval
├── orchestration.rs  – AnswerOrchestrator (weighted score fusion)
├── rag.rs            – RagService (mock LLM answer generation)
├── cache.rs          – QueryCache (LRU + TTL, backed by SHA-256 key hash)
└── circuit_breaker.rs – CircuitBreaker + ConcurrencyLimiter
```

## Build & Run

```bash
# Build
cd rust/yelp-ai-assistant
cargo build --release

# Run (listens on port 8080)
cargo run --release
```

## API Endpoints

### `POST /assistant/query`

```bash
curl -s -X POST http://localhost:8080/assistant/query \
  -H "Content-Type: application/json" \
  -H "X-Correlation-ID: req-001" \
  -d '{"query": "What are the hours?", "business_id": "12345"}' | jq
```

```bash
# Amenity query
curl -s -X POST http://localhost:8080/assistant/query \
  -H "Content-Type: application/json" \
  -d '{"query": "Does it have wifi?", "business_id": "12345"}' | jq

# Quality / review query
curl -s -X POST http://localhost:8080/assistant/query \
  -H "Content-Type: application/json" \
  -d '{"query": "Is the food good? Show me reviews.", "business_id": "12345"}' | jq

# Photo query
curl -s -X POST http://localhost:8080/assistant/query \
  -H "Content-Type: application/json" \
  -d '{"query": "Show me photos of the patio", "business_id": "12345"}' | jq
```

**Response shape:**
```json
{
  "answer": "The Rustic Table hours:\nMonday: 11:00 – 22:00\n...",
  "confidence": 0.9,
  "intent": "operational",
  "evidence": {
    "structured": true,
    "reviews_used": 0,
    "photos_used": 0
  },
  "latency_ms": 1.23
}
```

### `GET /health`

```bash
curl http://localhost:8080/health
```

### `GET /health/detailed`

```bash
curl http://localhost:8080/health/detailed
```

Returns circuit-breaker state for each service plus cache and concurrency limiter info.

## Key Features

| Feature | Implementation |
|---|---|
| Intent classification | Regex keyword groups; tie-break: Operational > Amenity > Photo > Quality |
| Search routing | OPERATIONAL→structured; AMENITY→all three; QUALITY→review; PHOTO→photo |
| Cosine similarity | Bag-of-words on review text |
| Photo retrieval | Caption token overlap + proxy image similarity |
| Evidence fusion | `0.4 × structured + 0.3 × avg_review_sim + 0.3 × avg_photo_sim` |
| Cache | SHA-256-keyed LRU (max 10 000 entries, 5-minute TTL) |
| Circuit breaker | Closed/Open/Half-Open with 5-failure threshold, 30 s recovery |
| Concurrency limiter | Tokio semaphore (50 concurrent requests) |
| Middleware | `X-Correlation-ID` echoed on every response |
| Parallelism | Three search tasks spawned concurrently via `tokio::join!` |

## Demo Data

Seeded at startup:

- **Business**: "The Rustic Table" (`business_id=12345`)
  - Amenities: patio ✓, parking ✓, wifi ✗, heated_seating ✓
  - Hours: Mon–Thu 11–22, Fri 11–23, Sat 10–23, Sun 10–21
- **3 Reviews** (ratings 5.0, 4.0, 4.5)
- **2 Photos** (interior + patio)
