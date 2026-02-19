# k6 Load Testing for C# Backend

[← Back to C# Samples](../../README.md)

## Overview

This directory contains k6 load testing samples for C# backend applications, specifically designed for DSE-BD (Data Service Engineering - Backend) and CSE-BD (Customer Service Engineering - Backend) load testing scenarios.

## What is k6?

k6 is a modern open-source load testing tool built for developer and performance testing teams. It's written in Go and uses JavaScript as the scripting language, making it easy to write and maintain test scripts.

### Key Features
- **Open Source & Free**: No licensing costs for the CLI version
- **Developer-Friendly**: Write tests in JavaScript
- **CI/CD Integration**: Easy to integrate into automated pipelines
- **Metrics & Analysis**: Rich metrics and threshold-based pass/fail criteria
- **Protocol Support**: HTTP/1.1, HTTP/2, WebSockets, gRPC

## Contents

- **load-test.js**: Main k6 test script with concurrent user scenarios
- **SampleBackendApi.cs**: Sample C# backend API for testing
- **K6LoadTestSample.csproj**: .NET project file
- **README.md**: This file

## Prerequisites

1. **k6 Installation**
   ```bash
   # On macOS
   brew install k6
   
   # On Debian/Ubuntu
   sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
   echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
   sudo apt-get update
   sudo apt-get install k6
   
   # On Windows (using Chocolatey)
   choco install k6
   
   # Or download from https://k6.io/docs/getting-started/installation/
   ```

2. **.NET SDK 6.0+**
   ```bash
   # Verify installation
   dotnet --version
   ```

## Quick Start

### 1. Start the Sample C# Backend

```bash
# Build and run the sample API
dotnet run --project K6LoadTestSample.csproj

# The API will start on http://localhost:5000
```

### 2. Run k6 Load Tests

In a new terminal:

```bash
# Basic test run
k6 run load-test.js

# Custom configuration
k6 run --vus 50 --duration 2m load-test.js

# With custom base URL
k6 run -e BASE_URL=http://your-api-url load-test.js

# Generate HTML report
k6 run --out json=results.json load-test.js
```

## Test Scenarios

The load test script includes the following scenarios:

### 1. **Ramp-Up Testing**
- Start with 50 concurrent users
- Gradually increase to 100 users
- Maintain load for extended period
- Spike to 200 users to test limits
- Ramp down gracefully

### 2. **API Operations Testing**
- Health checks and readiness probes
- GET requests (read operations)
- POST requests (create operations)
- Database query simulations
- Cache operations

### 3. **Bottleneck Detection**
- Response time thresholds
- Error rate monitoring
- Database query performance
- Cache efficiency
- Connection pooling

## Metrics & Thresholds

The test includes production-ready thresholds:

| Metric | Threshold | Purpose |
|--------|-----------|---------|
| http_req_duration (p95) | < 500ms | 95% of requests must be fast |
| http_req_duration (p99) | < 1s | 99% of requests acceptable |
| errors | < 1% | Error rate within limits |
| http_req_failed | < 5% | Request failure rate |
| checks | > 95% | Overall success rate |

## Production Bottleneck Checking

### Key Bottleneck Indicators

1. **High Response Times**
   - p95 > 500ms: Backend processing bottleneck
   - p99 > 1s: Severe performance degradation

2. **High Error Rates**
   - Error rate > 1%: Application or infrastructure issues
   - HTTP 500 errors: Backend server problems
   - HTTP 504 errors: Gateway timeouts

3. **Database Bottlenecks**
   - Query times > 1s: Database performance issues
   - Connection pool exhaustion
   - Slow query optimization needed

4. **Cache Bottlenecks**
   - Cache read > 100ms: Cache infrastructure issues
   - High cache miss rate
   - Memory pressure

### Bottleneck Analysis Workflow

```bash
# 1. Run baseline test
k6 run load-test.js > baseline-results.txt

# 2. Analyze metrics
cat baseline-results.txt | grep "http_req_duration"

# 3. Run stress test
k6 run --vus 500 --duration 5m load-test.js

# 4. Compare results
# Look for:
# - Increased response times
# - Higher error rates
# - Failed thresholds
```

## Interpreting Results

### Successful Test Output
```
✓ health check status is 200
✓ GET status is 200
✓ POST status is 201 or 200
✓ Database query time < 1s

http_req_duration.............: avg=245ms  p(95)=450ms  p(99)=800ms
errors......................: 0.45% of total
http_req_failed.............: 2.3% of total
```

### Bottleneck Indicators
```
✗ health check response time < 100ms  (failed: 15%)
✗ GET response time < 300ms          (failed: 25%)

⚠️  95th percentile response time exceeds 500ms
⚠️  Database query took 1500ms
```

## DSE-BD / CSE-BD Specific Guidance

### For Data Service Engineering (DSE-BD)

Focus on:
- **Data ingestion rates**: Can your API handle high write loads?
- **Query performance**: Are database queries optimized?
- **Batch operations**: Test bulk data operations
- **Connection pooling**: Monitor database connection usage

### For Customer Service Engineering (CSE-BD)

Focus on:
- **User concurrent access**: Simulate real user patterns
- **Session management**: Test user session handling
- **API rate limiting**: Verify rate limiters work under load
- **Response consistency**: Ensure consistent user experience

## k6 Cloud vs Open Source

### Open Source k6 (Free)
✅ **Pros:**
- Completely free
- Run on your own infrastructure
- Full control over test execution
- Great for CI/CD integration

✖ **Cons:**
- Must manage load generation infrastructure
- Limited built-in reporting
- Manual result analysis

### k6 Cloud (Commercial)
✅ **Pros:**
- Hosted load generation
- Rich dashboards and reporting
- Distributed testing from multiple locations
- Historical test comparison

✖ **Cons:**
- Pricing: ~$299-$1299/month
- Requires internet connectivity
- Vendor dependency

**Recommendation for SE Teams**: Start with open-source k6 for development and CI/CD, consider k6 Cloud for large-scale production validation.

## Pricing Comparison

For 10,000 concurrent users:

| Tool | Type | Estimated Cost |
|------|------|----------------|
| **k6 Open Source** | Self-hosted | Infrastructure cost only (~$100-500/month for VMs) |
| **k6 Cloud** | Hosted | ~$699+ per month |
| **NBomber Cloud** | Hosted | ~$199/month (Essential plan) |
| **Locust Open Source** | Self-hosted | Infrastructure cost only |
| **Locust.cloud** | Hosted | ~$399+ per month |

## Advanced Usage

### Generate Custom Reports

```bash
# JSON output
k6 run --out json=results.json load-test.js

# InfluxDB + Grafana
k6 run --out influxdb=http://localhost:8086/k6 load-test.js

# Cloud output (requires k6 cloud account)
k6 run --out cloud load-test.js
```

### Environment Variables

```bash
# Custom target URL
BASE_URL=https://staging-api.example.com k6 run load-test.js

# Test duration
k6 run --duration 10m load-test.js

# Virtual users
k6 run --vus 1000 load-test.js
```

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Run k6 Load Test
  run: |
    k6 run --quiet --out json=results.json load-test.js
    
- name: Check Thresholds
  run: |
    if grep -q "✗" results.json; then
      echo "Load test thresholds failed"
      exit 1
    fi
```

## Troubleshooting

### Common Issues

1. **Connection Refused**
   - Ensure the C# backend is running
   - Check the BASE_URL environment variable
   - Verify firewall settings

2. **High Error Rates**
   - Check backend logs for errors
   - Verify database connectivity
   - Monitor resource usage (CPU, memory)

3. **Slow Response Times**
   - Profile the backend application
   - Check database query performance
   - Monitor network latency

## Best Practices

1. **Start Small**: Begin with low VU counts and gradually increase
2. **Monitor Resources**: Watch CPU, memory, and network on both client and server
3. **Use Realistic Data**: Test with production-like data volumes
4. **Test Incrementally**: Test each component before full end-to-end tests
5. **Automate**: Integrate load tests into your CI/CD pipeline
6. **Document Baselines**: Keep records of performance baselines

## Resources

- [k6 Official Documentation](https://k6.io/docs/)
- [k6 Examples](https://k6.io/docs/examples/)
- [k6 Best Practices](https://k6.io/docs/misc/fine-tuning-os/)
- [Performance Testing Guide](https://k6.io/docs/testing-guides/)

## Contributing

When adding new test scenarios:
1. Follow JavaScript best practices
2. Add appropriate checks and thresholds
3. Document the test purpose
4. Include expected results
5. Update this README

## License

This sample is provided as-is for educational and testing purposes.
