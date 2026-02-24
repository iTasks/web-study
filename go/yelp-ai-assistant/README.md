# Yelp-Style AI Assistant — Go

A Go replica of the [Python yelp-ai-assistant](https://github.com/smaruf/python-ai-course/tree/main/yelp-ai-assistant).

Uses only the Go standard library (`net/http`, `sync`, `regexp`, `crypto/sha256`).

## Architecture

```
POST /assistant/query
  → IntentClassifier   (regex signal groups)
  → QueryRouter        (intent → service flags)
  → Parallel search (goroutines + WaitGroup)
       StructuredSearchService    – scored field matching
       ReviewVectorSearchService  – bag-of-words cosine similarity
       PhotoHybridRetrievalService– caption keyword overlap
  → AnswerOrchestrator (0.4/0.3/0.3 weighted score)
  → MockRAG            (per-intent template answers)
  → QueryCache.Set()   (LRU, 10k entries, 5-min TTL)
  ← QueryResponse JSON
```

## Quick Start

```bash
cd go/yelp-ai-assistant
go run main.go
```

## API

### POST /assistant/query

```bash
curl -X POST http://localhost:8080/assistant/query \
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
  "latency_ms": 0.5
}
```

### GET /health

```bash
curl http://localhost:8080/health
```

### GET /health/detailed

```bash
curl http://localhost:8080/health/detailed
```

## Query Intents

| Intent      | Example                         | Services used                  |
|-------------|---------------------------------|-------------------------------|
| operational | "Is it open right now?"         | Structured only                |
| amenity     | "Do they have a heated patio?"  | Structured + Review + Photo    |
| quality     | "Is it good for a date night?"  | Review vector search           |
| photo       | "Show me photos of the patio"   | Photo hybrid retrieval         |
| unknown     | (anything else)                 | Structured + Review            |
