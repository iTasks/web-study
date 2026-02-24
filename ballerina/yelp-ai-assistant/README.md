# Yelp-Style AI Assistant — Ballerina

[← Back to Ballerina](../README.md) | [Main README](../../README.md)

A Ballerina replica of the [Python yelp-ai-assistant](https://github.com/smaruf/python-ai-course/tree/main/yelp-ai-assistant).

## Quick Start

```bash
cd ballerina/yelp-ai-assistant
bal run
```

Server starts on port **9090**.

## API

### POST /assistant/query

```bash
curl -X POST http://localhost:9090/assistant/query \
  -H "Content-Type: application/json" \
  -d '{"query":"Does it have a heated patio?","business_id":"12345"}'
```

Response:
```json
{
  "answer": "The Rustic Table — heated patio: Yes (canonical).",
  "confidence": 0.4,
  "intent": "amenity",
  "evidence": {"structured": true, "reviews_used": 3, "photos_used": 2},
  "latency_ms": 1.0
}
```

### GET /health

```bash
curl http://localhost:9090/health
```

### GET /health/detailed

```bash
curl http://localhost:9090/health/detailed
```

## Architecture

```
POST /assistant/query
  → classifyIntent()    (string keyword matching)
  → route by intent     (useStructured / useReview / usePhoto flags)
  → searchStructured()  – map<BusinessData>, field keyword scoring
  → searchReviews()     – word-overlap similarity
  → searchPhotos()      – caption substring match
  → generateAnswer()    – per-intent mock RAG answer
  → cacheSet()          – map<CacheEntry>, 5-min TTL
  ← QueryResponse JSON
```

## Query Intents

| Intent      | Example                        | Services used               |
|-------------|--------------------------------|-----------------------------|
| operational | "Is it open right now?"        | Structured only             |
| amenity     | "Do they have heated patio?"   | Structured + Review + Photo |
| quality     | "Is it good for a date night?" | Review only                 |
| photo       | "Show me photos of patio"      | Photo + Structured          |
| unknown     | (anything else)                | Structured + Review         |

## Ballerina features used

- `type` keyword for union enum: `type QueryIntent "operational"|"amenity"|...`
- Closed records `record {| ... |}` for all domain types
- `service /` with `resource function` for HTTP endpoints
- `@http:Payload` automatic JSON deserialization
- `map<T>` for in-memory stores
- Query expressions: `from X in Y where ... select ...`
- Module-level `init()` for startup data seeding
