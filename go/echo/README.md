# Echo Framework - Production-Ready Examples

## Purpose

This directory contains production-ready Echo framework examples with comprehensive observability and monitoring middlewares. Echo is a high performance, minimalist Go web framework that provides an optimized HTTP router which smartly prioritizes routes and supports extensive middleware.

## 🚀 Quick Start

```bash
# Install dependencies
cd go/echo
go mod download

# Run the production server
go run production_server.go monitoring.go tracing.go

# Or use the Makefile
make run-prod
```

The server will start on `http://localhost:8080`

## 📁 Contents

### Production-Ready Features

This implementation includes:

- **Production Server** (`production_server.go`) - Complete server with all production middlewares
- **Prometheus Monitoring** (`monitoring.go`) - Comprehensive metrics collection
- **Distributed Tracing** (`tracing.go`) - Request tracing with trace/span IDs
- **Comprehensive Tests** (`main_test.go`) - Unit and integration tests
- **Production Guide** (`PRODUCTION_GUIDE.md`) - Detailed deployment documentation
- **Docker Support** (`Dockerfile`, `docker-compose.yml`) - Container deployment
- **Development Tools** (`Makefile`) - Common development tasks

### Middleware Stack

All servers include a complete production-ready middleware stack:

1. **Request ID** - Unique identifier for each request
2. **Distributed Tracing** - Trace ID and Span ID tracking
3. **Prometheus Metrics** - Request/response metrics collection
4. **Structured Logging** - JSON-formatted logs with context
5. **Panic Recovery** - Graceful recovery from panics
6. **Security Headers** - HSTS, XSS protection, CSP
7. **CORS** - Cross-origin resource sharing
8. **Gzip Compression** - Response compression
9. **Rate Limiting** - Request rate limiting (100 req/s)
10. **Request Timeout** - Configurable timeouts (30s)

### Observability Endpoints

- `GET /health` - Health check (Kubernetes liveness probe)
- `GET /ready` - Readiness check (Kubernetes readiness probe)
- `GET /metrics` - Prometheus metrics endpoint
- `GET /info` - System information

### API Endpoints

REST API examples:
- `GET /api/v1/users` - List all users
- `POST /api/v1/users` - Create a user
- `GET /api/v1/users/:id` - Get specific user
- `PUT /api/v1/users/:id` - Update user
- `DELETE /api/v1/users/:id` - Delete user

Testing endpoints:
- `GET /api/v1/slow` - Test timeout handling (2s delay)
- `GET /api/v1/error` - Test error handling
- `GET /api/v1/panic` - Test panic recovery
- `GET /api/v1/trace` - Test distributed tracing

## 🛠️ Setup Instructions

### Prerequisites
- Go 1.19 or higher
- Docker (optional, for containerized deployment)
- Docker Compose (optional, for monitoring stack)

### Installation

```bash
# Navigate to the echo directory
cd go/echo

# Install dependencies
go mod download

# Run tests
go test -v

# Build the server
go build -o server production_server.go monitoring.go tracing.go

# Run the server
./server
```

### Using Make

```bash
make install    # Install dependencies
make test       # Run tests
make run-prod   # Run production server
make build      # Build binary
make docker-build  # Build Docker image
```

## 📊 Monitoring & Observability

### Prometheus Metrics

The server exposes Prometheus metrics at `/metrics`:

```bash
curl http://localhost:8080/metrics
```

Available metrics:
- `http_requests_total` - Total HTTP requests by method, endpoint, status
- `http_request_duration_seconds` - Request duration histogram
- `http_request_size_bytes` - Request size summary
- `http_response_size_bytes` - Response size summary
- `http_requests_active` - Currently active requests

### Distributed Tracing

Trace requests across services using trace headers:

```bash
curl -H "X-Trace-ID: my-trace-123" \
     -H "X-Parent-Span-ID: parent-456" \
     http://localhost:8080/api/v1/trace
```

Response includes:
- `trace_id` - Unique trace identifier
- `span_id` - Current span identifier
- `parent_id` - Parent span identifier
- `duration` - Request duration

### Health Checks

```bash
# Health check
curl http://localhost:8080/health

# Readiness check (for Kubernetes)
curl http://localhost:8080/ready

# System info
curl http://localhost:8080/info
```

## 🐳 Docker Deployment

### Build and Run

```bash
# Build Docker image
docker build -t echo-server .

# Run container
docker run -p 8080:8080 echo-server
```

### Docker Compose (with Monitoring)

Run the complete stack with Prometheus and Grafana:

```bash
docker-compose up -d
```

Access:
- Echo Server: http://localhost:8080
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)

## 📖 Documentation

- **[PRODUCTION_GUIDE.md](PRODUCTION_GUIDE.md)** - Comprehensive production deployment guide
  - Detailed middleware configuration
  - Kubernetes deployment examples
  - Performance tuning
  - Best practices
  - Troubleshooting

## 🧪 Testing

```bash
# Run all tests
go test -v

# Run with coverage
go test -v -cover

# Run benchmarks
go test -bench=. -benchmem
```

## 🔑 Key Features

### High Performance
- Optimized HTTP router with smart route prioritization
- Gzip compression for reduced bandwidth
- Connection pooling and keep-alive support

### Production-Ready Middleware
- Comprehensive error handling and recovery
- Rate limiting to prevent abuse
- Security headers (HSTS, CSP, XSS protection)
- Request timeouts to prevent hanging requests

### Observability
- Structured JSON logging with full context
- Prometheus metrics for monitoring
- Distributed tracing support
- Health and readiness probes

### Cloud-Native
- Graceful shutdown for zero-downtime deployments
- Kubernetes-compatible health checks
- Docker and container-ready
- Horizontal scaling support

## 📚 Learning Topics

This implementation demonstrates:

1. **Echo Server Setup** - Complete production configuration
2. **Middleware Stack** - Layered middleware architecture
3. **Error Handling** - Structured error responses
4. **Logging** - JSON-formatted structured logging
5. **Metrics** - Prometheus integration
6. **Tracing** - Distributed tracing patterns
7. **Testing** - Unit and integration testing
8. **Docker** - Containerization and deployment
9. **Kubernetes** - Cloud-native patterns
10. **Graceful Shutdown** - Clean application termination

## 🔗 Resources

- [Echo Framework Documentation](https://echo.labstack.com/)
- [Echo GitHub Repository](https://github.com/labstack/echo)
- [Echo Cookbook](https://echo.labstack.com/cookbook/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Go Web Development](https://golang.org/doc/articles/wiki/)
- [Twelve-Factor App](https://12factor.net/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

## 📝 Examples

### Basic Request

```bash
curl http://localhost:8080/api/v1/users
```

### Create User

```bash
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'
```

### With Tracing

```bash
curl -H "X-Trace-ID: my-trace-123" \
     http://localhost:8080/api/v1/users
```

### Check Metrics

```bash
curl http://localhost:8080/metrics | grep http_requests_total
```

## 🤝 Contributing

Contributions are welcome! Please ensure:
- All tests pass: `make test`
- Code is formatted: `make fmt`
- No lint errors: `make vet`
- Documentation is updated

## 📄 License

This is part of the web-study repository for educational purposes.