# Planning:

The project will use **Java 21 + Spring Boot** for the application and **Python** for automation, deployment helpers, testing, and load testing.

# MicroK8s Learning Project

## Project: `microk8s-spring-platform`

Build a small production-like distributed platform:

```text
                         ┌─────────────────────┐
                         │       Client        │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │      Ingress        │
                         │      MicroK8s       │
                         └──────────┬──────────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              │                     │                     │
              ▼                     ▼                     ▼
       ┌─────────────┐       ┌─────────────┐       ┌─────────────┐
       │ user-service│       │order-service│       │notification │
       │ Java 21     │       │ Java 21     │       │ Java 21     │
       │ Spring Boot │       │ Spring Boot │       │ Spring Boot │
       └──────┬──────┘       └──────┬──────┘       └──────┬──────┘
              │                     │                     │
              └─────────────────────┼─────────────────────┘
                                    │
                           ┌────────▼────────┐
                           │      Kafka      │
                           └────────┬────────┘
                                    │
                      ┌─────────────┴─────────────┐
                      ▼                           ▼
               ┌─────────────┐             ┌─────────────┐
               │ PostgreSQL  │             │    Redis    │
               └─────────────┘             └─────────────┘
```

Python will sit **outside and around the platform**:

```text
Python
 ├── cluster setup
 ├── deployment
 ├── health checks
 ├── test data generation
 ├── API tests
 ├── load testing
 ├── metrics collection
 └── deployment verification
```

---

# Phase 1 — Kubernetes fundamentals

**Goal:** Understand what MicroK8s is actually running.

### Learn

* Containers
* Kubernetes architecture
* Nodes
* Pods
* Deployments
* ReplicaSets
* Services
* Namespaces
* ConfigMaps
* Secrets
* Labels/selectors

Start with a single MicroK8s node.

### Exercises

Install:

```bash
microk8s
```

Then:

```bash
microk8s status
microk8s kubectl get nodes
microk8s kubectl get pods -A
```

Create:

```text
namespace: platform
```

Then deploy nginx.

Learn:

```bash
kubectl get
kubectl describe
kubectl logs
kubectl exec
kubectl delete
kubectl apply
```

### Deliverable

Create:

```text
k8s/
  namespace.yaml
  nginx-deployment.yaml
  nginx-service.yaml
```

and deploy everything using:

```bash
microk8s kubectl apply -f k8s/
```

---

# Phase 2 — Containerize Java 21

Now introduce your real application.

Create:

```text
user-service
```

Technology:

```text
Java 21
Spring Boot
Spring Web
Spring Actuator
Spring Data JPA
PostgreSQL
```

Example API:

```text
GET    /users
GET    /users/{id}
POST   /users
PUT    /users/{id}
DELETE /users/{id}
```

### Important learning

Don't just build the API.

Learn how the application behaves inside Kubernetes.

Add:

```text
/actuator/health
/actuator/metrics
```

Then create a Docker image:

```text
user-service:0.1.0
```

Deploy it to MicroK8s.

---

# Phase 3 — Local container registry

This is where MicroK8s becomes interesting.

Enable its registry:

```bash
microk8s enable registry
```

Build:

```bash
docker build -t localhost:32000/user-service:0.1 .
```

Push:

```bash
docker push localhost:32000/user-service:0.1
```

Deploy:

```yaml
image: localhost:32000/user-service:0.1
```

Now you understand the complete pipeline:

```text
Java source
    ↓
Maven
    ↓
JAR
    ↓
Docker image
    ↓
MicroK8s registry
    ↓
Kubernetes Deployment
    ↓
Pod
```

---

# Phase 4 — Python automation

This should become a major part of the project.

Create:

```text
automation/
    cluster.py
    build.py
    deploy.py
    health.py
    test_data.py
    rollback.py
```

Use Python libraries such as:

```text
subprocess
requests
PyYAML
kubernetes
```

For example:

```python
subprocess.run(
    ["microk8s", "kubectl", "get", "pods"],
    check=True
)
```

Eventually:

```bash
python automation/deploy.py
```

should perform:

```text
1. Build Java
2. Build Docker image
3. Push image
4. Apply Kubernetes manifests
5. Wait for rollout
6. Check health
7. Run smoke tests
```

---

# Phase 5 — Configuration and Secrets

Don't hardcode configuration.

Learn:

```text
ConfigMap
Secret
Environment variables
Secret mounting
```

Example:

```text
SPRING_DATASOURCE_URL
SPRING_DATASOURCE_USERNAME
SPRING_DATASOURCE_PASSWORD
```

Architecture:

```text
Kubernetes
   │
   ├── ConfigMap
   │      └── application configuration
   │
   └── Secret
          └── credentials
```

Then make Spring Boot consume them.

---

# Phase 6 — PostgreSQL

Deploy PostgreSQL to MicroK8s.

Learn:

```text
PersistentVolume
PersistentVolumeClaim
StorageClass
StatefulSet
```

This is an important milestone because you'll learn the difference between:

```text
stateless application
```

and

```text
stateful infrastructure
```

Your architecture becomes:

```text
user-service
     │
     ▼
PostgreSQL
     │
     ▼
Persistent Volume
```

---

# Phase 7 — Multiple Spring services

Add:

```text
user-service
order-service
notification-service
```

For example:

```text
POST /orders
```

creates:

```text
OrderCreated
```

which eventually becomes:

```text
Kafka
   │
   ├── notification-service
   └── analytics-service
```

Now you're learning **microservices + Kubernetes**, rather than Kubernetes in isolation.

---

# Phase 8 — Kafka

Add Kafka.

Learn:

```text
Broker
Topic
Partition
Producer
Consumer
Consumer Group
Offset
```

Spring:

```text
spring-kafka
```

Architecture:

```text
order-service
      │
      │ OrderCreated
      ▼
    Kafka
      │
      ├───────────────┐
      ▼               ▼
notification      analytics
```

Then deliberately kill a consumer:

```bash
microk8s kubectl delete pod ...
```

and observe what happens.

This is an important Kubernetes learning exercise.

---

# Phase 9 — Redis

Introduce Redis for:

```text
caching
idempotency
rate limiting
```

For example:

```text
GET /users/{id}

        │
        ▼
      Redis
      /   \
   hit     miss
    │        │
    │        ▼
    │    PostgreSQL
    │        │
    └────────┘
```

Measure the difference with and without caching.

---

# Phase 10 — Ingress

Enable MicroK8s ingress.

Instead of:

```text
localhost:30001
localhost:30002
localhost:30003
```

you'll have:

```text
http://platform.local/users
http://platform.local/orders
```

Learn:

```text
Ingress
Ingress Controller
Host routing
Path routing
TLS
```

Example:

```text
platform.local
      │
      ▼
   Ingress
      │
 ┌────┼─────┐
 ▼    ▼     ▼
user order notification
```

---

# Phase 11 — Scaling

Now start experimenting with Kubernetes' real strengths.

Change:

```yaml
replicas: 1
```

to:

```yaml
replicas: 3
```

Then:

```bash
microk8s kubectl get pods
```

You'll see:

```text
user-service-xxx
user-service-yyy
user-service-zzz
```

Test:

```bash
microk8s kubectl scale deployment user-service --replicas=5
```

Then learn:

```text
RollingUpdate
ReadinessProbe
LivenessProbe
StartupProbe
Resource requests
Resource limits
HorizontalPodAutoscaler
```

---

# Phase 12 — Python load testing

This is where your Python skills become particularly useful.

I recommend **Locust**.

Create:

```text
loadtest/
    locustfile.py
    scenarios/
        users.py
        orders.py
```

Example scenario:

```text
100 users
     │
     ├── GET /users
     ├── GET /users/{id}
     ├── POST /orders
     └── GET /orders/{id}
```

Measure:

```text
requests/sec
average latency
p50
p95
p99
error rate
```

Then compare:

```text
1 replica
vs
3 replicas
vs
5 replicas
```

This becomes a real experiment rather than simply "learning Kubernetes."

---

# Phase 13 — Observability

Add:

```text
Prometheus
Grafana
```

MicroK8s has addons that make this relatively easy.

Monitor:

```text
CPU
Memory
Pod restarts
HTTP requests
HTTP latency
JVM memory
GC
Kafka lag
PostgreSQL
Redis
```

Your architecture becomes:

```text
                    ┌──────────────┐
                    │   Grafana    │
                    └──────▲───────┘
                           │
                    ┌──────┴───────┐
                    │  Prometheus   │
                    └──────▲───────┘
                           │
       ┌───────────────────┼───────────────────┐
       │                   │                   │
    Spring              Kafka              Redis
       │
    PostgreSQL
```

---

# Phase 14 — Python deployment CLI

By now your Python automation should become a proper CLI.

Something like:

```bash
python -m platform_cli build
python -m platform_cli image
python -m platform_cli deploy
python -m platform_cli status
python -m platform_cli health
python -m platform_cli smoke
python -m platform_cli loadtest
python -m platform_cli rollback
```

Or:

```bash
platform deploy
platform status
platform test
platform loadtest
```

Use:

```text
argparse
```

or preferably:

```text
Typer
```

---

# Phase 15 — Helm

Once you understand raw Kubernetes YAML, **then** learn Helm.

Don't start with Helm.

Convert:

```text
k8s/
    deployment.yaml
    service.yaml
    configmap.yaml
    ingress.yaml
```

into:

```text
helm/
  platform/
    Chart.yaml
    values.yaml
    templates/
        deployment.yaml
        service.yaml
        ingress.yaml
        configmap.yaml
```

Now you can have:

```text
values-dev.yaml
values-test.yaml
values-prod.yaml
```

and:

```bash
helm install platform ./helm/platform
```

---

# Phase 16 — CI/CD

Finally introduce GitHub Actions.

Pipeline:

```text
Git push
   │
   ▼
GitHub Actions
   │
   ├── Java tests
   ├── Python tests
   ├── Build JAR
   ├── Docker build
   ├── Security scan
   └── Deploy
          │
          ▼
       MicroK8s
          │
          ▼
       Smoke test
```

Python can perform deployment verification.

For example:

```text
deployment successful
       ↓
wait for rollout
       ↓
GET /actuator/health
       ↓
HTTP 200
       ↓
smoke tests
       ↓
deployment accepted
```

---

# Final Project Structure

I'd aim for something like:

```text
microk8s-spring-platform/
│
├── services/
│   ├── user-service/
│   │   ├── src/
│   │   ├── pom.xml
│   │   └── Dockerfile
│   │
│   ├── order-service/
│   │   ├── src/
│   │   ├── pom.xml
│   │   └── Dockerfile
│   │
│   └── notification-service/
│       ├── src/
│       ├── pom.xml
│       └── Dockerfile
│
├── infrastructure/
│   ├── k8s/
│   │   ├── namespace.yaml
│   │   ├── postgres.yaml
│   │   ├── redis.yaml
│   │   ├── kafka.yaml
│   │   ├── services.yaml
│   │   └── ingress.yaml
│   │
│   └── helm/
│       └── platform/
│
├── automation/
│   ├── build.py
│   ├── deploy.py
│   ├── health.py
│   ├── smoke.py
│   ├── rollback.py
│   └── cli.py
│
├── loadtest/
│   ├── locustfile.py
│   └── scenarios/
│
├── scripts/
│   ├── setup-cluster.sh
│   └── cleanup-cluster.sh
│
├── docs/
│   ├── architecture.md
│   ├── kubernetes.md
│   ├── troubleshooting.md
│   └── performance.md
│
└── README.md
```

## Recommended learning sequence

I'd follow this exact order:

```text
1. Docker
       ↓
2. Kubernetes fundamentals
       ↓
3. MicroK8s
       ↓
4. Java 21 + Spring Boot
       ↓
5. Containerization
       ↓
6. Kubernetes Deployment/Service
       ↓
7. ConfigMap + Secret
       ↓
8. PostgreSQL + persistent storage
       ↓
9. Multiple Spring services
       ↓
10. Kafka
       ↓
11. Redis
       ↓
12. Ingress
       ↓
13. Scaling + probes + resources
       ↓
14. Python automation
       ↓
15. Python/Locust load testing
       ↓
16. Prometheus + Grafana
       ↓
17. Helm
       ↓
18. CI/CD
```

### What makes this especially useful for your profile

Given your **Java/Spring + distributed systems + AWS/Kubernetes background**, I wouldn't spend weeks learning basic Kubernetes syntax. The valuable part would be using this project to deepen the areas that are often tested in senior backend interviews:

**Kubernetes → JVM → Spring → distributed systems → Kafka → observability → performance → automation.**

The best final exercise would be a **failure/performance lab**:

> Run 5,000 requests/minute → observe p95/p99 latency → scale Spring pods → introduce Kafka lag → kill pods → exhaust PostgreSQL connections → inspect JVM GC → diagnose everything through Prometheus/Grafana → automate the recovery/verification with Python.

That turns MicroK8s from a tutorial into a **senior-level distributed-systems portfolio project**.
