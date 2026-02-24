# Yelp-Style AI Assistant — Groovy (Ratpack)

[← Back to Groovy](../README.md) | [Main README](../../README.md)

A Ratpack-powered Groovy replica of the [Python yelp-ai-assistant](https://github.com/smaruf/python-ai-course/tree/main/yelp-ai-assistant).

Single-file script using `@Grab` — no build step needed.

## Quick Start

```bash
cd groovy/yelp-ai-assistant
groovy YelpAssistant.groovy
```

Server starts on port **5050**.

## API

### POST /assistant/query

```bash
curl -X POST http://localhost:5050/assistant/query \
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
  "latency_ms": 2.5
}
```

### GET /health

```bash
curl http://localhost:5050/health
```

### GET /health/detailed

```bash
curl http://localhost:5050/health/detailed
```

## Architecture

```
POST /assistant/query
  → IntentClassifier   (~/pattern/ regex with =~ operator)
  → QueryRouter        (intent → {useStructured, useReview, usePhoto})
  → Parallel threads (Thread.start)
       StructuredSearchService    – ConcurrentHashMap, field keyword scoring
       ReviewVectorSearchService  – bag-of-words cosine similarity
       PhotoHybridRetrievalService– caption keyword overlap
  → AnswerOrchestrator (0.4/0.3/0.3 weighted score, conflict notes)
  → RagService         (mock LLM, per-intent template answers)
  → QueryCache.set()   (LinkedHashMap LRU, 10k entries, 5-min TTL)
  ← QueryResponse JSON
```

## Query Intents

| Intent      | Example                        | Services used               |
|-------------|--------------------------------|-----------------------------|
| operational | "Is it open right now?"        | Structured only             |
| amenity     | "Do they have heated patio?"   | Structured + Review + Photo |
| quality     | "Is it good for a date night?" | Review vector               |
| photo       | "Show me photos of patio"      | Photo hybrid                |
| unknown     | (anything else)                | Structured + Review         |
