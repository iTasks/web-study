# HIVE - Thermostat Monitoring Demo

**Reactive vs Virtual Threads Comparison**

> 🎯 **Looking for recommendations?** Check [OPTIMAL_SOLUTION.md](OPTIMAL_SOLUTION.md) for a quick decision guide!

This is a Java implementation demonstrating the comparison between two concurrent programming approaches:
- **Reactive Stack:** Spring WebFlux with Project Reactor
- **Virtual Threads Stack:** Spring Boot 3.5 with Java 25 Virtual Threads and Structured Concurrency

---

## 1. Purpose

This demo application compares two approaches to building the same concurrent system, demonstrating that virtual threads achieve the same scalability as reactive programming but with significantly simpler, more readable code.

---

## 2. Demo Scenario

A building with multiple thermostats reporting temperature readings. The system must:

1. Collect temperature readings from multiple sensors concurrently
2. Persist readings to a PostgreSQL database
3. Push real-time updates to connected browser dashboards via Server-Sent Events (SSE)
4. Handle many concurrent connections without blocking threads

---

## 3. Architecture Overview

Both implementations share the same logical architecture — only the concurrency model differs.

### High-Level Components

- **Sensor Simulator** - Generates temperature readings for N thermostats
- **Ingestion Service** - Receives readings, validates, and coordinates storage + notification
- **Weather Service** - Fetches outdoor temperature with retry logic and circuit breaker
- **Alert Service** - Checks thresholds (min/max temp, outdoor delta) and triggers alerts
- **Rate Limiter** - Limits readings per sensor per minute (sliding window)
- **Aggregation Service** - Computes rolling averages and hourly statistics
- **SSE Broadcaster** - Pushes real-time updates to connected browser dashboards
- **Store** - Persists readings, alerts, and aggregations to PostgreSQL

### Request Processing Flow

```
POST /api/readings
    ↓
Rate Limit Check → (if exceeded) → 429 Error
    ↓
Parallel Operations (Fan-out):
    ├─ Save to DB (Repository)
    ├─ SSE Broadcast (Subscribers)
    └─ Fetch Weather (Retry 3x)
    ↓
Compute Delta (indoor - outdoor temperature)
    ↓
Alert Check → (if threshold exceeded) → Trigger Alert + SSE Broadcast
    ↓
Response: ProcessingResult { reading, weather, delta, alert? }
```

---

## 4. Technology Stack

### Reactive Version (hive-reactive)
- Java 25
- Spring Boot 3.5.0 with WebFlux
- Project Reactor
- R2DBC + PostgreSQL
- Reactor Netty

### Virtual Threads Version (hive-vthreads)
- Java 25
- Spring Boot 3.5.0 with Web MVC
- Virtual Threads (`spring.threads.virtual.enabled=true`)
- Structured Concurrency (JEP 480 - Finalized)
- JDBC + PostgreSQL
- Tomcat with virtual thread executor

### Shared Components
- PostgreSQL 16
- Docker Compose for local setup
- Rich HTML/JS dashboard with:
  - Dark mode toggle
  - Toast notifications
  - Real-time sparkline charts
  - SSE connection status indicator
  - Keyboard shortcuts

---

## 5. API Endpoints

Both implementations expose identical APIs:

### Temperature Readings
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/readings` | Submit a temperature reading (returns ProcessingResult with weather) |
| GET | `/api/readings/{sensorId}` | Get latest reading for a sensor |
| GET | `/api/readings/history` | Query historical readings |
| GET | `/api/stream` | SSE stream of temperature updates |
| GET | `/api/status` | Aggregated building status |

### Alerts
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/alerts` | Get recent alerts (default limit: 50) |
| GET | `/api/alerts/unacknowledged` | Get unacknowledged alerts |
| GET | `/api/alerts/stream` | SSE stream of real-time alerts |
| POST | `/api/alerts/{id}/acknowledge` | Acknowledge an alert |

### Aggregations
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/aggregates` | Get rolling aggregates for all sensors |
| GET | `/api/aggregates/{sensorId}` | Get rolling aggregate for a specific sensor |

---

## 6. Getting Started

### Prerequisites
- **Java 25** (required for Structured Concurrency preview features)
  - Download from: https://jdk.java.net/25/
  - Note: The virtual threads implementation uses JEP 480 (Structured Concurrency) which is a preview feature in Java 25
  - For Java 21/22/23, you can use virtual threads without structured concurrency (see migration notes in ANALYSIS.md)
- Docker (for PostgreSQL)
- Maven 3.9+

### Start PostgreSQL

```bash
docker compose up -d postgres
```

### Run Reactive Version (port 8081)

```bash
mvn spring-boot:run -pl hive-reactive
```

Open browser: http://localhost:8081

### Run Virtual Threads Version (port 8082)

```bash
mvn spring-boot:run -pl hive-vthreads
```

Open browser: http://localhost:8082

### Run Both with Docker Compose

```bash
docker compose up --build
```

- Reactive: http://localhost:8081
- Virtual Threads: http://localhost:8082

---

## 7. Database Schema

The system uses PostgreSQL with the following tables:

- **readings** - Temperature readings from sensors
- **sensor_thresholds** - Temperature thresholds for each sensor
- **alerts** - Triggered alerts when thresholds are exceeded
- **hourly_stats** - Aggregated hourly statistics

---

## 8. Project Structure

```
hive/
├── pom.xml                        # Parent POM
├── docker-compose.yml             # Docker orchestration
├── README.md                      # This file
├── ANALYSIS.md                    # Detailed comparison and analysis
├── hive-reactive/                 # Reactive implementation
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/
│       ├── main/
│       │   ├── java/              # Java source files
│       │   └── resources/         # Application config, SQL, static files
│       └── test/                  # Unit tests
└── hive-vthreads/                 # Virtual Threads implementation
    ├── pom.xml
    ├── Dockerfile
    └── src/
        ├── main/
        │   ├── java/              # Java source files
        │   └── resources/         # Application config, SQL, static files
        └── test/                  # Unit tests
```

---

## 9. Key Features

### Reactive Implementation (hive-reactive)
- Non-blocking I/O with Project Reactor
- Mono and Flux for reactive streams
- R2DBC for non-blocking database access
- Declarative operator chains
- Built-in backpressure

### Virtual Threads Implementation (hive-vthreads)
- Lightweight virtual threads (Project Loom)
- Structured Concurrency for task coordination
- Standard JDBC for database access
- Imperative, sequential code style
- Normal try-catch error handling

---

## 10. Testing the System

### Submit a Reading

```bash
curl -X POST http://localhost:8081/api/readings \
  -H "Content-Type: application/json" \
  -d '{
    "sensorId": "T-1",
    "temperature": 22.5,
    "location": "Office",
    "timestamp": "2026-02-15T10:00:00Z"
  }'
```

### Get Building Status

```bash
curl http://localhost:8081/api/status
```

### Stream Real-time Updates

```bash
curl -N http://localhost:8081/api/stream
```

---

## 11. Performance Comparison

See the following documents for detailed analysis:
- **[OPTIMAL_SOLUTION.md](OPTIMAL_SOLUTION.md)** - 🎯 **START HERE!** Quick decision guide with optimal recommendations
- **[ANALYSIS.md](ANALYSIS.md)** - Comprehensive performance metrics, complexity comparison, and detailed analysis
- **[SUMMARY.md](SUMMARY.md)** - Project statistics and overview

---

## 12. License

This project is for educational purposes, demonstrating modern Java concurrency patterns.

---

## 13. Important Notes

### Java Version Requirement
This project demonstrates the latest Java concurrency features and requires **Java 25** with preview features enabled:
- **Virtual Threads** (JEP 444) - Finalized in Java 21
- **Structured Concurrency** (JEP 480) - Preview feature in Java 25

If you only have Java 21-24, you can still use virtual threads but will need to modify the code to not use `StructuredTaskScope` (which is a preview API). See [ANALYSIS.md](ANALYSIS.md) for migration guidance.

### Project Statistics
- **Total Files**: 69+ (Java, XML, SQL, HTML, JS, CSS)
- **Java Classes**: 56
- **Lines of Code**: ~1,800 (both implementations combined)
- **Database Tables**: 4 (readings, alerts, sensor_thresholds, hourly_stats)
- **API Endpoints**: 11 endpoints across both implementations

---

## 14. References

- [Project Loom - Virtual Threads](https://openjdk.org/jeps/444)
- [Structured Concurrency (JEP 480)](https://openjdk.org/jeps/480)
- [Spring WebFlux](https://docs.spring.io/spring-framework/reference/web/webflux.html)
- [Project Reactor](https://projectreactor.io/)
- [R2DBC](https://r2dbc.io/)
- [Original HIVE Repository](https://github.com/rokon12/hive)
