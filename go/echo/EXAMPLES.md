# Echo Framework Examples

This document provides practical examples for using the production-ready Echo server with observability and monitoring features.

## Table of Contents

- [Basic Usage](#basic-usage)
- [Health Checks](#health-checks)
- [User Management API](#user-management-api)
- [Distributed Tracing](#distributed-tracing)
- [Monitoring & Metrics](#monitoring--metrics)
- [Error Handling](#error-handling)
- [Advanced Features](#advanced-features)

## Basic Usage

### Starting the Server

```bash
# Run with Go
go run production_server.go monitoring.go tracing.go

# Or using Make
make run-prod

# Or using the built binary
./server
```

### Environment Variables

```bash
# Set environment
export ENVIRONMENT=production
export PORT=8080

# Run server
./server
```

## Health Checks

### Liveness Probe

Used by Kubernetes to determine if the application is alive:

```bash
curl http://localhost:8080/health
```

**Response:**
```json
{
  "status": "healthy",
  "time": "2026-01-26T12:00:00Z"
}
```

### Readiness Probe

Used by Kubernetes to determine if the application is ready to serve traffic:

```bash
curl http://localhost:8080/ready
```

**Response:**
```json
{
  "status": "ready",
  "checks": {
    "database": "ok",
    "cache": "ok"
  },
  "time": "2026-01-26T12:00:00Z"
}
```

### System Information

```bash
curl http://localhost:8080/info
```

**Response:**
```json
{
  "version": "1.0.0",
  "environment": "development",
  "uptime": "2026-01-26T12:00:00Z"
}
```

## User Management API

### List All Users

```bash
curl http://localhost:8080/api/v1/users
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "admin"
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "email": "jane@example.com",
      "role": "user"
    }
  ],
  "count": 2
}
```

### Create a User

```bash
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice Johnson",
    "email": "alice@example.com"
  }'
```

**Response:**
```json
{
  "id": 4,
  "name": "Alice Johnson",
  "email": "alice@example.com",
  "created_at": "2026-01-26T12:00:00Z"
}
```

### Get Specific User

```bash
curl http://localhost:8080/api/v1/users/1
```

**Response:**
```json
{
  "id": "1",
  "name": "John Doe",
  "email": "john@example.com",
  "role": "admin"
}
```

### Update User

```bash
curl -X PUT http://localhost:8080/api/v1/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Updated",
    "email": "john.updated@example.com"
  }'
```

**Response:**
```json
{
  "id": "1",
  "name": "John Updated",
  "email": "john.updated@example.com",
  "updated_at": "2026-01-26T12:00:00Z"
}
```

### Delete User

```bash
curl -X DELETE http://localhost:8080/api/v1/users/1
```

**Response:**
```json
{
  "message": "User deleted successfully",
  "id": "1"
}
```

## Distributed Tracing

### Basic Tracing

Every request automatically gets a trace ID and span ID:

```bash
curl -v http://localhost:8080/api/v1/users
```

**Response Headers:**
```
X-Trace-ID: trace-1737894000123456789-12345
X-Span-ID: span-1737894000123456790-67890
```

### Custom Trace ID

Provide your own trace ID to track requests across services:

```bash
curl -H "X-Trace-ID: my-custom-trace-123" \
     http://localhost:8080/api/v1/users
```

### Parent-Child Tracing

Link requests in a distributed system:

```bash
curl -H "X-Trace-ID: trace-abc-123" \
     -H "X-Parent-Span-ID: span-parent-456" \
     http://localhost:8080/api/v1/users
```

### Trace Information Endpoint

Get detailed trace information:

```bash
curl -H "X-Trace-ID: my-trace-123" \
     -H "X-Parent-Span-ID: parent-456" \
     http://localhost:8080/api/v1/trace
```

**Response:**
```json
{
  "message": "Trace information",
  "trace_id": "my-trace-123",
  "span_id": "span-1737894000123456790-67890",
  "parent_id": "parent-456",
  "start_time": "2026-01-26T12:00:00Z",
  "duration": "123.456µs"
}
```

## Monitoring & Metrics

### Prometheus Metrics

Access all metrics:

```bash
curl http://localhost:8080/metrics
```

### Specific Metrics

#### Request Count

```bash
curl http://localhost:8080/metrics | grep "http_requests_total"
```

**Example Output:**
```
http_requests_total{endpoint="/api/v1/users",method="GET",status="200"} 42
http_requests_total{endpoint="/api/v1/users",method="POST",status="201"} 15
```

#### Request Duration

```bash
curl http://localhost:8080/metrics | grep "http_request_duration_seconds"
```

**Example Output:**
```
http_request_duration_seconds_bucket{endpoint="/api/v1/users",method="GET",le="0.005"} 40
http_request_duration_seconds_sum{endpoint="/api/v1/users",method="GET"} 0.15
http_request_duration_seconds_count{endpoint="/api/v1/users",method="GET"} 42
```

#### Active Requests

```bash
curl http://localhost:8080/metrics | grep "http_requests_active"
```

**Example Output:**
```
http_requests_active 3
```

### Using Prometheus

Query examples in Prometheus:

```promql
# Request rate
rate(http_requests_total[5m])

# Error rate
rate(http_requests_total{status=~"5.."}[5m])

# 95th percentile latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Request rate by endpoint
sum by (endpoint) (rate(http_requests_total[5m]))
```

## Error Handling

### Simulated Error

```bash
curl http://localhost:8080/api/v1/error
```

**Response:**
```json
{
  "message": "Something went wrong"
}
```

**Status Code:** 500

### Panic Recovery

Test the panic recovery middleware:

```bash
curl http://localhost:8080/api/v1/panic
```

**Response:**
```json
{
  "message": "Internal Server Error"
}
```

The server recovers gracefully and logs the panic with stack trace.

### Invalid Request

```bash
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"invalid": "data"}'
```

**Response:**
```json
{
  "error": "name and email are required"
}
```

**Status Code:** 400

## Advanced Features

### Slow Request Testing

Test timeout handling and latency tracking:

```bash
time curl http://localhost:8080/api/v1/slow
```

This endpoint deliberately takes 2 seconds to respond.

### Rate Limiting

The server limits requests to 100 per second. Test with:

```bash
# Send multiple requests quickly
for i in {1..150}; do
  curl -w "%{http_code}\n" -o /dev/null -s http://localhost:8080/api/v1/users
done
```

You'll see some requests return `429 Too Many Requests`.

### CORS Testing

```bash
curl -X OPTIONS http://localhost:8080/api/v1/users \
  -H "Origin: http://example.com" \
  -H "Access-Control-Request-Method: POST"
```

**Response Headers:**
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET,POST,PUT,DELETE
Access-Control-Allow-Headers: Origin,Content-Type,Accept,Authorization
```

### Compression

Request with compression support:

```bash
curl -H "Accept-Encoding: gzip" \
     http://localhost:8080/api/v1/users \
     --compressed -v
```

The response will be gzip-compressed.

### Request ID Tracking

Every request gets a unique ID:

```bash
curl -v http://localhost:8080/api/v1/users 2>&1 | grep "X-Request-Id"
```

**Example:**
```
< X-Request-Id: AbCdEfGhIjKlMnOp
```

### Structured Logging

The server outputs JSON logs. Example log entry:

```json
{
  "time": "2026-01-26 12:00:00.000",
  "id": "AbCdEfGhIjKlMnOp",
  "remote_ip": "127.0.0.1",
  "host": "localhost:8080",
  "method": "GET",
  "uri": "/api/v1/users",
  "user_agent": "curl/7.68.0",
  "status": 200,
  "error": "",
  "latency_ms": 1.234,
  "bytes_in": 0,
  "bytes_out": 256
}
```

## Integration Examples

### With Microservices

Propagate trace context to downstream services:

```go
// In your service call
trace := GetTraceContext(c)
req.Header.Set("X-Trace-ID", trace.TraceID)
req.Header.Set("X-Parent-Span-ID", trace.SpanID)
```

### With Load Testing (Apache Bench)

```bash
# Test with 100 concurrent requests, 10000 total
ab -n 10000 -c 100 http://localhost:8080/api/v1/users
```

### With Load Testing (wrk)

```bash
# Test with 10 threads, 100 connections for 30 seconds
wrk -t10 -c100 -d30s http://localhost:8080/api/v1/users
```

### With cURL Scripts

Create a test script (`test.sh`):

```bash
#!/bin/bash

# Health check
echo "Testing health endpoint..."
curl -s http://localhost:8080/health | jq .

# Create user
echo "Creating user..."
USER_ID=$(curl -s -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}' | jq -r .id)

# Get user
echo "Getting user..."
curl -s http://localhost:8080/api/v1/users/$USER_ID | jq .

# Update user
echo "Updating user..."
curl -s -X PUT http://localhost:8080/api/v1/users/$USER_ID \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated User"}' | jq .

# Delete user
echo "Deleting user..."
curl -s -X DELETE http://localhost:8080/api/v1/users/$USER_ID | jq .
```

## Monitoring Dashboard

### Grafana Queries

Import these queries in Grafana:

**Request Rate:**
```promql
sum(rate(http_requests_total[5m])) by (endpoint)
```

**Error Rate:**
```promql
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))
```

**Latency (95th percentile):**
```promql
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, endpoint))
```

**Active Connections:**
```promql
http_requests_active
```

## Troubleshooting

### Check if server is running

```bash
curl http://localhost:8080/health
```

### View logs

The server outputs structured JSON logs to stdout. In production, these should be collected by your logging system.

### Check metrics

```bash
curl http://localhost:8080/metrics | grep http_requests_active
```

If this shows high numbers, the server might be overloaded.

### Test tracing

```bash
curl -v http://localhost:8080/api/v1/trace 2>&1 | grep "X-Trace-ID"
```

Should return a trace ID in the response headers.

## Performance Tips

1. **Enable Compression**: Already enabled with Gzip middleware
2. **Connection Pooling**: Use HTTP/1.1 keep-alive (default)
3. **Rate Limiting**: Adjust based on your capacity
4. **Timeouts**: Configure appropriate timeouts for your use case
5. **Monitoring**: Use metrics to identify bottlenecks

## Next Steps

- Review [PRODUCTION_GUIDE.md](PRODUCTION_GUIDE.md) for deployment details
- Set up Prometheus and Grafana for monitoring
- Implement authentication and authorization
- Add database integration
- Create custom middleware for your use case
