This is the unified, production-ready master project plan for your **Intelligent Multi-Currency Payment & Exchange Engine**. It synthesizes the local-first architecture (Mini-PC/Mobile), the highly scalable, event-driven server infrastructure, ironclad security boundaries, and the automated verification pipeline into a structured **14-Week Release Schedule**.

---

## 1. Complete High-Level Blueprint

This master plan orchestrates two distinct target systems working in perfect synchronization:

1. **The Client Edge Unit (Mini-PC / Mobile):** A GraalVM native binary using an encrypted SQLite/H2 storage instance, enforcing an $N$-day rolling ledger cleanup, and exposing local capabilities via an MCP server.
2. **The Server Infrastructure:** A highly scalable, non-blocking cluster running virtual threads, managed via an Event-Driven Saga Pattern, protected by Redis rate limiters and Resilience4j circuit breakers.

---

## 2. End-to-End Production Release Schedule

```
[Phase 1: Architecture] ──> [Phase 2: Client Edge] ──> [Phase 3: Server Core]
                                                               │
[Phase 6: Deployment]  <──  [Phase 5: Load Testing] <── [Phase 4: Security & AI]

```

### Phase 1: Environment Baseline & Architecture Lock (Weeks 1–2)

* **Objective:** Establish common cross-platform schemas, networking protocols, and development environments.
* **Tasks:**
* Initialize Git mono-repo structures separating the client component from server modules.
* Establish unified **Protobuf / JSON serialization contracts** for all multi-currency ledger transactions.
* Configure base CI/CD pipelines to build targets on **Eliya OpenJDK 25 LTS** base images.


* **Milestone:** Cryptographic key generation pipelines validated; local and remote skeletons successfully communicate over dummy mTLS links.

### Phase 2: Client Edge & Local Ledger Engine (Weeks 3–5)

* **Objective:** Deliver a zero-weight client node capable of processing local transactions with absolute data limits.
* **Tasks:**
* Embed **SQLCipher/H2** with a runtime key derivation engine linked to user passkeys.
* Implement the `LocalLedgerPurgeManager` running the rolling $N$-day consolidation algorithm.
* Build the **MCP Server Tools** wrapper to link local wallet functions directly to raw text instruction parsing.
* Configure **GraalVM Native Image** compilation scripts to output standalone native binaries targeting ARM64 and x86_64.


* **Milestone:** Client application compiles natively in $< 50\text{MB}$ of RAM and executes local balance rollups under 5ms.

### Phase 3: Distributed Server Infrastructure (Weeks 6–8)

* **Objective:** Implement a scalable, event-driven server runtime to orchestrate multiple clients.
* **Tasks:**
* Configure **Spring Boot Virtual Threads** to optimize blocking database connections.
* Deploy a **Redis-backed Token Bucket Rate Limiter** to shape inbound client synchronization bursts.
* Build the asynchronous, choreography-based **Saga Pattern** across a highly available Kafka or RabbitMQ cluster.
* Implement **Resilience4j Circuit Breakers** to handle third-party market data aggregator downtime by immediately defaulting to a low-latency Redis cache lookup.


* **Milestone:** Saga engine demonstrates data consistency across independent ledger balances during simulated network splits.

### Phase 4: Zero-Trust Security & AI Verification (Weeks 9–10)

* **Objective:** Seal the transport layers and build defenses against adversarial prompt injection.
* **Tasks:**
* Enforce strict **mTLS boundaries** on the API Gateway; implement **JSON Web Encryption (JWE)** for transit data blocks.
* Integrate custom Spring AI **AroundAdvisors** to intercept prompt structures and mitigate prompt injection attempts before they reach the LLM context.
* Write the **LLM-as-a-Judge Evaluation Suite** to continuously verify that variations in natural language prompts correctly map to explicit MCP tools.


* **Milestone:** The system blocks malicious injection attempts and achieves a $>99\%$ accurate intent-to-MCP-tool mapping rate.

### Phase 5: Load-Bearing & Failure Simulation Testing (Weeks 11–12)

* **Objective:** Validate that the application handles severe transactional and network strain.
* **Tasks:**
* Spin up **Testcontainers** running local instances of Kafka and Redis to run end-to-end integration test suites.
* Execute **Gatling / JMeter stress tests** modeling a high-concurrency event load of client nodes syncing concurrently.
* Trigger deliberate network disconnects to the main clearing banks during stress validation to confirm circuit breakers intercept failures instantly.


* **Milestone:** The engine maintains stable sub-millisecond route decision latency under sustained peak throughput.

### Phase 6: Production Deployment & Hardening (Weeks 13–14)

* **Objective:** Securely launch the architecture into a production-hardened environment.
* **Tasks:**
* Deploy the scalable server cluster using containerized microservices managed via Kubernetes.
* Enforce the execution flag `-XX:EliyaProfile=Production` across all running instances.
* Configure Prometheus, Grafana, and Spring Boot Actuator to expose metrics covering virtual thread density, MCP tool latency, and token consumption rates.


* **Milestone:** System handles transaction lifecycles end-to-end from a client Mini-PC node up to the cloud ledger with automated cleanup and forensic audit patterns active.

---

## 3. High-Priority Risk Mitigation Blueprint

| Risk | Operational Impact | Technical Counter-Measure |
| --- | --- | --- |
| **Adversarial Tool Abuse** | User manipulates prompt logic to call tools out of order or bypass checks. | Enforce isolation between the LLM and validation logic. The LLM handles intent extraction; the native Spring platform handles signed authorization. |
| **Local Client Hardware Failure** | Mini-PC or Mobile device loses power midway through a ledger clean up. | Run your application inside the **Eliya OpenJDK distribution**. The `Production` profile handles JVM memory allocations deterministically and forces atomic, safe transactional write cycles before system components recycle. |
| **Downstream Aggregator Outages** | Live market-rate aggregators slow down, stalling transaction processing. | The **Resilience4j Circuit Breaker** intercepts slow API routes within milliseconds and switches traffic to a high-speed Redis cache instance, preserving low latencies. |
| **Data Growth on Client Storage** | Finite client storage (Mini-PC/Mobile disk) fills up from ledger history. | The sliding $N$-day retention schedule runs an automated daily cleanup, rolling historical item data into a consolidated checkpoint to keep local data footprints small. |
