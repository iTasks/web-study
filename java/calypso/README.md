# Calypso (Java Capital Markets Platform)

[← Back to Java](../README.md) | [Main README](../../README.md)

## Purpose

This directory provides a practical learning path for Nasdaq Calypso and starter tooling for automation and load testing workflows.
The included Spring starter uses **Java 21+** and **Spring Boot 3.5.x**.

## Learning Plan

### Phase 1: Foundations
- Understand capital markets basics: products, counterparties, lifecycle, settlement
- Learn Calypso platform concepts: front/middle/back office responsibilities
- Review core Java and Spring Boot concepts used in Calypso integrations

### Phase 2: Core Calypso Concepts
- Trade lifecycle modeling (capture → validation → booking → settlement)
- Static data setup (books, counterparties, calendars, currencies)
- Workflows, status transitions, and exception handling
- Scheduling and batch processing concepts

### Phase 3: Integration and Automation
- Inbound/outbound interfaces (file, API, message-driven patterns)
- Reconciliation and reporting automation patterns
- Operational runbooks for health checks and daily controls
- Test data generation for repeatable QA/UAT flows

### Phase 4: Performance and Reliability
- Define baseline SLAs for booking, pricing, and batch windows
- Create repeatable load profiles and stress scenarios
- Analyze latency bottlenecks and throughput limits
- Add regression checks to prevent performance degradation

### Phase 5: Production Readiness
- Monitoring strategy (service health, queue depth, failures)
- Release checklist and rollback approach
- Incident response playbooks and post-incident review process
- Compliance and auditability checks for operational controls

## Automation & Load-Testing Tools

### Java + Spring Boot (Java 21+)
- **[`spring-java21/`](spring-java21/)**
  - Starter Java 21 + Spring Boot project structure for Calypso-oriented APIs and services.

### Kotlin
- **[`tools/kotlin/trade_workload_generator.main.kts`](tools/kotlin/trade_workload_generator.main.kts)**
  - Generates synthetic trade workload JSON files for testing and replay.

### Groovy
- **[`tools/groovy/batch_health_check.groovy`](tools/groovy/batch_health_check.groovy)**
  - Parses batch execution CSV logs and flags SLA breaches.

### Python
- **[`tools/python/reconciliation_summary.py`](tools/python/reconciliation_summary.py)**
  - Builds reconciliation summaries from transaction CSV files.
- **[`load-testing/python-locust/locustfile.py`](load-testing/python-locust/locustfile.py)**
  - Locust-based load profile for trade capture and pricing APIs.

## Quick Start

```bash
# Java 21 + Spring Boot starter project
cd java/calypso/spring-java21
mvn spring-boot:run

# Kotlin workload generator
kotlin java/calypso/tools/kotlin/trade_workload_generator.main.kts --count 200 --out /tmp/trades.json

# Groovy batch SLA check
groovy java/calypso/tools/groovy/batch_health_check.groovy --input /tmp/batch-runs.csv --sla-ms 800

# Python reconciliation summary
python3 java/calypso/tools/python/reconciliation_summary.py --input /tmp/transactions.csv --out /tmp/recon-summary.json

# Python Locust load test
locust -f java/calypso/load-testing/python-locust/locustfile.py --host=http://localhost:8080 --headless -u 50 -r 5 --run-time 2m
```

## Project Structure

```
java/calypso/
├── README.md
├── spring-java21/
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/com/itasks/calypso/
│       │   │   ├── CalypsoApplication.java
│       │   │   └── HealthController.java
│       │   └── resources/application.yml
│       └── test/java/com/itasks/calypso/
│           └── CalypsoApplicationTests.java
├── tools/
│   ├── kotlin/
│   │   └── trade_workload_generator.main.kts
│   ├── groovy/
│   │   └── batch_health_check.groovy
│   └── python/
│       └── reconciliation_summary.py
└── load-testing/
    └── python-locust/
        └── locustfile.py
```
