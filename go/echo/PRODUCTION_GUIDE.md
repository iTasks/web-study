# Production-Ready Echo Server Examples

This directory contains production-ready examples of Echo framework applications with comprehensive observability and monitoring middlewares.

## Features

### 1. Production-Ready Middlewares

All examples include a complete middleware stack for production use:

- **Request ID**: Unique identifier for each request for distributed tracing
- **Structured Logging**: JSON-formatted logs with request context
- **Panic Recovery**: Graceful recovery from panics with stack traces
- **Security Headers**: HSTS, XSS protection, content security policy
- **CORS**: Configurable cross-origin resource sharing
- **Gzip Compression**: Automatic response compression
- **Rate Limiting**: Request rate limiting to prevent abuse
- **Request Timeout**: Configurable request timeouts

### 2. Observability & Monitoring

#### Distributed Tracing
- Automatic trace ID generation
- Span ID tracking
- Parent-child relationship support
- Trace context propagation via headers
- Integration ready for APM tools (OpenTelemetry, Jaeger, etc.)

#### Prometheus Metrics
- HTTP request total counter
- Request duration histograms
- Request/response size tracking
- Active requests gauge
- Per-endpoint granularity
- Standard Prometheus format

#### Health Checks
- `/health` - Basic health check
- `/ready` - Readiness probe (Kubernetes compatible)
- `/live` - Liveness probe
- `/metrics` - Prometheus metrics endpoint
- `/info` - System information

### 3. Graceful Shutdown

All servers implement graceful shutdown:
- Signal handling (SIGINT, SIGTERM)
- Configurable shutdown timeout
- In-flight request completion
- Clean resource cleanup

## Files

- `main.go` - Basic Echo server with production middlewares
- `production_server.go` - Complete production-ready server with all features
- `monitoring.go` - Prometheus metrics middleware
- `tracing.go` - Distributed tracing middleware
- `main_test.go` - Comprehensive test suite

## Quick Start

### 1. Install Dependencies

```bash
cd go/echo
go mod download
```

### 2. Run the Basic Server

```bash
go run main.go
```

### 3. Run the Production Server

```bash
go run production_server.go monitoring.go tracing.go
```

The server will start on `http://localhost:8080`

### 4. Run Tests

```bash
go test -v
```

### 5. Run Benchmarks

```bash
go test -bench=. -benchmem
```

## API Endpoints

### Health & Monitoring

```bash
# Health check
curl http://localhost:8080/health

# Readiness check
curl http://localhost:8080/ready

# Prometheus metrics
curl http://localhost:8080/metrics

# System info
curl http://localhost:8080/info
```

### User Management API

```bash
# Get all users
curl http://localhost:8080/api/v1/users

# Create a user
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'

# Get specific user
curl http://localhost:8080/api/v1/users/1

# Update user
curl -X PUT http://localhost:8080/api/v1/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane Doe"}'

# Delete user
curl -X DELETE http://localhost:8080/api/v1/users/1
```

### Testing Features

```bash
# Test slow endpoint (2 second delay)
curl http://localhost:8080/api/v1/slow

# Test error handling
curl http://localhost:8080/api/v1/error

# Test panic recovery
curl http://localhost:8080/api/v1/panic

# Test distributed tracing
curl -H "X-Trace-ID: my-trace-123" \
     -H "X-Parent-Span-ID: parent-span-456" \
     http://localhost:8080/api/v1/trace
```

## Middleware Configuration

### Request ID Middleware

Automatically adds unique IDs to each request:

```go
e.Use(middleware.RequestID())
```

Access the request ID:
```go
requestID := c.Response().Header().Get(echo.HeaderXRequestID)
```

### Distributed Tracing Middleware

Add trace context to requests:

```go
e.Use(TracingMiddleware())
```

Access trace context:
```go
trace := GetTraceContext(c)
fmt.Printf("Trace ID: %s, Span ID: %s\n", trace.TraceID, trace.SpanID)
```

Headers:
- `X-Trace-ID`: Unique trace identifier
- `X-Span-ID`: Current span identifier
- `X-Parent-Span-ID`: Parent span identifier (optional)

### Prometheus Metrics Middleware

Collect request metrics:

```go
e.Use(PrometheusMiddleware())
```

Exposed metrics:
- `http_requests_total` - Total requests by method, endpoint, and status
- `http_request_duration_seconds` - Request duration histogram
- `http_request_size_bytes` - Request size summary
- `http_response_size_bytes` - Response size summary
- `http_requests_active` - Current active requests

### Structured Logging

JSON-formatted logs with full context:

```go
e.Use(middleware.LoggerWithConfig(middleware.LoggerConfig{
    Format: `{"time":"${time_rfc3339}","id":"${id}","remote_ip":"${remote_ip}",` +
        `"method":"${method}","uri":"${uri}","status":${status},"latency_ms":${latency_ms}}` + "\n",
}))
```

### Rate Limiting

Prevent API abuse:

```go
// Simple configuration: 100 requests per second
e.Use(middleware.RateLimiter(middleware.NewRateLimiterMemoryStore(100)))

// Advanced configuration with custom settings
config := middleware.RateLimiterConfig{
    Store: middleware.NewRateLimiterMemoryStoreWithConfig(
        middleware.RateLimiterMemoryStoreConfig{
            Rate: 10,
            Burst: 30,
            ExpiresIn: 3 * time.Minute,
        },
    ),
    IdentifierExtractor: func(ctx echo.Context) (string, error) {
        return ctx.RealIP(), nil
    },
}
e.Use(middleware.RateLimiterWithConfig(config))
```

### Security Headers

Add security headers to all responses:

```go
e.Use(middleware.SecureWithConfig(middleware.SecureConfig{
    XSSProtection:         "1; mode=block",
    ContentTypeNosniff:    "nosniff",
    XFrameOptions:         "SAMEORIGIN",
    HSTSMaxAge:            31536000,
    ContentSecurityPolicy: "default-src 'self'",
}))
```

## Production Deployment

### Environment Variables

```bash
export ENVIRONMENT=production
export PORT=8080
```

### Docker Deployment

Create a `Dockerfile`:

```dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o server .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/server .

EXPOSE 8080
CMD ["./server"]
```

Build and run:
```bash
docker build -t echo-server .
docker run -p 8080:8080 echo-server
```

### Kubernetes Deployment

Example deployment with health checks:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-server
spec:
  replicas: 3
  selector:
    matchLabels:
      app: echo-server
  template:
    metadata:
      labels:
        app: echo-server
    spec:
      containers:
      - name: echo-server
        image: echo-server:latest
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: echo-server
spec:
  selector:
    app: echo-server
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

### Monitoring Setup

#### Prometheus Configuration

Add to `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'echo-server'
    static_configs:
      - targets: ['localhost:8080']
    metrics_path: '/metrics'
    scrape_interval: 15s
```

#### Grafana Dashboard

Import metrics and create visualizations for:
- Request rate (requests/second)
- Error rate (errors/second)
- Response time (p50, p95, p99)
- Active connections
- Request/response sizes

## Best Practices

### 1. Middleware Order

The order of middleware is important:

```go
e.Use(middleware.RequestID())        // 1. Generate request ID first
e.Use(TracingMiddleware())           // 2. Add tracing context
e.Use(PrometheusMiddleware())        // 3. Collect metrics
e.Use(middleware.Logger())           // 4. Log with full context
e.Use(middleware.Recover())          // 5. Catch panics early
e.Use(middleware.Secure())           // 6. Add security headers
e.Use(middleware.CORS())             // 7. Handle CORS
e.Use(middleware.Gzip())             // 8. Compress responses
e.Use(middleware.RateLimiter())      // 9. Rate limiting
e.Use(middleware.Timeout())          // 10. Request timeout
```

### 2. Error Handling

Always return structured errors:

```go
if err != nil {
    return echo.NewHTTPError(http.StatusBadRequest, map[string]string{
        "error": "invalid input",
        "field": "email",
    })
}
```

### 3. Context Propagation

Pass trace context to downstream services:

```go
trace := GetTraceContext(c)
req.Header.Set("X-Trace-ID", trace.TraceID)
req.Header.Set("X-Parent-Span-ID", trace.SpanID)
```

### 4. Graceful Shutdown

Always implement graceful shutdown:

```go
quit := make(chan os.Signal, 1)
signal.Notify(quit, os.Interrupt)
<-quit

ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
defer cancel()
e.Shutdown(ctx)
```

## Performance Tuning

### 1. Compression Settings

```go
e.Use(middleware.GzipWithConfig(middleware.GzipConfig{
    Level: 5, // Balance between speed and compression ratio
}))
```

### 2. Rate Limiting

```go
// Adjust based on your capacity
e.Use(middleware.RateLimiter(middleware.NewRateLimiterMemoryStore(100)))
```

### 3. Timeouts

```go
e.Use(middleware.TimeoutWithConfig(middleware.TimeoutConfig{
    Timeout: 30 * time.Second, // Adjust based on your use case
}))
```

## Troubleshooting

### High Memory Usage

1. Check active connections: `curl http://localhost:8080/metrics | grep http_requests_active`
2. Review rate limiting configuration
3. Monitor response sizes

### Slow Requests

1. Check Prometheus metrics for request duration
2. Enable debug logging
3. Review timeout configurations

### Missing Trace IDs

1. Ensure `TracingMiddleware()` is registered
2. Check middleware order
3. Verify header propagation

## Additional Resources

- [Echo Framework Documentation](https://echo.labstack.com/)
- [Prometheus Go Client](https://github.com/prometheus/client_golang)
- [OpenTelemetry Go](https://opentelemetry.io/docs/instrumentation/go/)
- [Twelve-Factor App](https://12factor.net/)
- [Kubernetes Health Checks](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

## Contributing

Contributions are welcome! Please ensure:
- All tests pass: `go test -v`
- Code is formatted: `go fmt ./...`
- No lint errors: `go vet ./...`
- Documentation is updated
