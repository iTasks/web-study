# Yelp-Style AI Assistant — C# (ASP.NET Core 8)

[← Back to C#](../README.md) | [Main README](../../README.md)

A minimal-API ASP.NET Core 8 replica of the [Python yelp-ai-assistant](https://github.com/smaruf/python-ai-course/tree/main/yelp-ai-assistant).

Uses **zero external NuGet packages** — only built-in ASP.NET Core.

## Quick Start

```bash
cd csharp/yelp-ai-assistant
dotnet run
```

Server starts on port **8080**.

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
  "latency_ms": 2.1
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

## Architecture

```
POST /assistant/query
  → IntentClassifier   (compiled Regex signal groups)
  → QueryRouter        (intent → RoutingDecision)
  → Task.WhenAll parallel fan-out (CircuitBreaker-guarded)
       StructuredSearchService    – ConcurrentDictionary, field keyword scoring
       ReviewVectorSearchService  – bag-of-words cosine similarity
       PhotoHybridRetrievalService– caption keyword overlap
  → AnswerOrchestrator (0.4/0.3/0.3 weighted, conflict notes)
  → RagService         (mock LLM, per-intent template answers)
  → QueryCache.Set()   (LinkedList LRU, 10k entries, 5-min TTL)
  ← QueryResponse JSON (snake_case)
```

## Query Intents

| Intent      | Example                        | Services used               |
|-------------|--------------------------------|-----------------------------|
| operational | "Is it open right now?"        | Structured only             |
| amenity     | "Do they have heated patio?"   | Structured + Review + Photo |
| quality     | "Is it good for a date night?" | Review vector               |
| photo       | "Show me photos of patio"      | Photo hybrid                |
| unknown     | (anything else)                | Structured + Review         |
