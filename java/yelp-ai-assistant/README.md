# Yelp-Style AI Assistant — Java (Spring Boot)

A Spring Boot 3.x replica of the [Python yelp-ai-assistant](https://github.com/smaruf/python-ai-course/tree/main/yelp-ai-assistant).

## Quick Start

```bash
cd java/yelp-ai-assistant
./mvnw spring-boot:run
# or
mvn spring-boot:run
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
  "latency_ms": 5.2
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
  → IntentClassifier     (regex signal groups, 17+15+14+6 patterns)
  → QueryRouter          (intent → {useStructured, useReviewVector, usePhotoHybrid})
  → CompletableFuture parallel fan-out (guarded by CircuitBreakers)
       StructuredSearchService    – ConcurrentHashMap, field keyword scoring
       ReviewVectorSearchService  – CopyOnWriteArrayList, bag-of-words cosine sim
       PhotoHybridRetrievalService– CopyOnWriteArrayList, caption overlap
  → EvidenceBundle.build() (0.4/0.3/0.3 weighted score, conflict notes)
  → RagService (mock LLM, per-intent template answers)
  → QueryCache.set()     (LinkedHashMap LRU, 10k entries, 5-min TTL)
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
