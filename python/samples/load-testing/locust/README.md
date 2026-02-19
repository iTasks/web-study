# Locust Load Testing for Python Backend

[← Back to Python Samples](../../README.md)

## Overview

This directory contains Locust load testing samples for Python backend applications, specifically designed for DSE-BD (Data Service Engineering - Backend) and CSE-BD (Customer Service Engineering - Backend) load testing scenarios.

## What is Locust?

Locust is an open-source load testing tool written in Python. It allows you to define user behavior with Python code and swarm your system with millions of simultaneous users.

### Key Features
- **Open Source & Free**: No licensing costs
- **Python-Based**: Write test scenarios in Python
- **Distributed Testing**: Easy to scale across multiple machines
- **Web UI**: Real-time monitoring via web interface
- **Flexibility**: Full power of Python for complex scenarios

## Contents

- **locustfile.py**: Main Locust test script with user behaviors
- **sample_backend_api.py**: Sample Python Flask backend for testing
- **requirements.txt**: Python package dependencies
- **README.md**: This file

## Prerequisites

1. **Python 3.8+**
   ```bash
   python3 --version
   ```

2. **pip (Python package installer)**
   ```bash
   pip3 --version
   ```

## Installation

```bash
# Create virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Or install manually
pip install locust flask gunicorn requests
```

## Quick Start

### 1. Start the Sample Python Backend

```bash
# Option 1: Development server
python sample_backend_api.py

# Option 2: Production server (gunicorn)
gunicorn -w 4 -b 0.0.0.0:5000 sample_backend_api:app

# The API will start on http://localhost:5000
```

### 2. Run Locust Load Tests

In a new terminal:

```bash
# Activate virtual environment
source venv/bin/activate

# Web UI mode (recommended for interactive testing)
locust -f locustfile.py --host=http://localhost:5000

# Then open http://localhost:8089 in your browser
# Set number of users and spawn rate

# Headless mode (for CI/CD)
locust -f locustfile.py --host=http://localhost:5000 --headless -u 100 -r 10 --run-time 5m

# With custom master/worker setup
locust -f locustfile.py --master
locust -f locustfile.py --worker --master-host=127.0.0.1
```

## Test Scenarios

The locustfile includes two user types:

### 1. **DSEBDUser** (Data Service Engineering)
Simulates backend data operations:
- **GET data** (weight: 3) - Most common operation
- **POST data** (weight: 2) - Create operations
- **Database queries** (weight: 1) - Heavy operations
- **Cache operations** (weight: 2) - Fast reads

### 2. **CSEBDUser** (Customer Service Engineering)
Simulates customer-facing operations:
- **Browse** (weight: 5) - Most common for customers
- **Search** (weight: 2) - Search operations
- **Update profile** (weight: 1) - Less frequent

## Load Patterns

### Using Custom Load Shape (StagesLoadShape)

The included `StagesLoadShape` class provides a k6-style load pattern:

```python
stages = [
    {"duration": 60, "users": 50, "spawn_rate": 5},    # Ramp to 50 users
    {"duration": 180, "users": 100, "spawn_rate": 5},  # Ramp to 100 users
    {"duration": 300, "users": 100, "spawn_rate": 5},  # Maintain 100 users
    {"duration": 120, "users": 200, "spawn_rate": 10}, # Spike to 200 users
    {"duration": 120, "users": 200, "spawn_rate": 10}, # Maintain spike
    {"duration": 120, "users": 0, "spawn_rate": 10},   # Ramp down
]
```

To use this shape, uncomment the class at the bottom of locustfile.py.

## Performance Metrics & Bottleneck Detection

### Automatic Bottleneck Detection

The test automatically detects and reports:

1. **Slow Requests**
   - GET requests > 500ms
   - POST requests > 1000ms
   - Database queries > 1000ms
   - Cache operations > 100ms

2. **Error Tracking**
   - Total errors
   - Timeout errors (504)
   - Server errors (500)

3. **Performance Thresholds**
   - 95th percentile < 500ms
   - 99th percentile < 1000ms
   - Failure rate < 1%

### Example Output

```
⚠️  BOTTLENECKS DETECTED: 15 slow requests

Top 5 Slowest Requests:
  GET /api/database/query: 1523.45ms
  POST /api/data: 1102.33ms
  GET /api/data: 678.21ms

📈 Error Summary:
  Total Errors: 5
  Timeout Errors: 2
  Server Errors: 1

📊 Performance Summary:
  Total Requests: 10000
  Failure Rate: 0.50%
  Average Response Time: 245.67ms
  95th Percentile: 450.23ms
  99th Percentile: 892.11ms

🎯 Production Readiness Check:
  ✅ 95th percentile < 500ms: 450.23ms
  ✅ 99th percentile < 1000ms: 892.11ms
  ✅ Failure rate < 1%: 0.50%
```

## Interpreting Results

### Locust Web UI Metrics

When running with the web UI (http://localhost:8089):

1. **Statistics Tab**
   - Request counts and failure rates
   - Response times (min, max, median, percentiles)
   - Requests per second
   - Content size

2. **Charts Tab**
   - Real-time visualization of:
     - Total requests per second
     - Response times
     - Number of users

3. **Failures Tab**
   - Detailed error information
   - Occurrence counts

4. **Download Data**
   - Export results as CSV
   - Stats history
   - Exceptions

## DSE-BD / CSE-BD Specific Guidance

### For Data Service Engineering (DSE-BD)

```python
# Focus on data operations
class DSEBDUser(HttpUser):
    @task(3)
    def high_volume_reads(self):
        # Test read scalability
        pass
    
    @task(2)
    def batch_writes(self):
        # Test write throughput
        pass
    
    @task(1)
    def complex_queries(self):
        # Test database performance
        pass
```

**Key Metrics:**
- Data ingestion rate (writes/second)
- Query response times
- Batch operation performance
- Database connection pooling

### For Customer Service Engineering (CSE-BD)

```python
# Focus on user experience
class CSEBDUser(HttpUser):
    wait_time = between(2, 5)  # Realistic user think time
    
    @task(5)
    def customer_journey(self):
        # Simulate realistic user flow
        pass
```

**Key Metrics:**
- User response time consistency
- Session handling under load
- API rate limiting effectiveness
- Error rates during peak usage

## Production Bottleneck Checking

### Common Bottlenecks

1. **Backend Processing**
   - Symptom: High average response times
   - Solution: Optimize algorithms, add caching, scale horizontally

2. **Database**
   - Symptom: Slow query times, timeouts
   - Solution: Add indexes, optimize queries, use connection pooling

3. **Network**
   - Symptom: High latency, timeouts
   - Solution: Use CDN, optimize payload size, enable compression

4. **Memory**
   - Symptom: Increasing response times, crashes
   - Solution: Fix memory leaks, increase resources, optimize data structures

### Bottleneck Detection Workflow

```bash
# 1. Run baseline test with low load
locust -f locustfile.py --headless -u 10 -r 1 --run-time 2m

# 2. Analyze baseline results
cat locust_report_*.json

# 3. Run stress test with high load
locust -f locustfile.py --headless -u 500 -r 50 --run-time 5m

# 4. Compare and identify degradation
```

## Advanced Usage

### Distributed Load Testing

```bash
# On master machine
locust -f locustfile.py --master --master-bind-host=0.0.0.0 --expect-workers=3

# On worker machines (can be multiple)
locust -f locustfile.py --worker --master-host=<master-ip>
```

### Custom Reports

Locust automatically generates:
- JSON report: `locust_report_<timestamp>.json`
- HTML report (via UI): Download from web interface
- CSV data: Available in web UI

### Environment Variables

```bash
# Custom host
export LOCUST_HOST=https://staging-api.example.com
locust -f locustfile.py

# Custom web port
locust -f locustfile.py --web-port=8090
```

### CI/CD Integration

```yaml
# GitHub Actions example
- name: Run Locust Load Test
  run: |
    pip install -r requirements.txt
    locust -f locustfile.py --headless -u 100 -r 10 --run-time 5m --host=http://test-api || true
    
- name: Check Results
  run: |
    python analyze_results.py locust_report_*.json
```

## Locust vs k6 Comparison

| Feature | Locust | k6 |
|---------|--------|-----|
| **Language** | Python | JavaScript |
| **Learning Curve** | Easy (if you know Python) | Easy (if you know JS) |
| **Web UI** | Built-in, real-time | Via k6 Cloud or extensions |
| **Distributed** | Native support | Via k6 Cloud |
| **Scripting Power** | Full Python ecosystem | JavaScript with Go extensions |
| **Best For** | Python teams, complex scenarios | Go/JS teams, CI/CD |

## Pricing Comparison

### Open Source (Free)
- ✅ Locust: Completely free, self-hosted
- ✅ k6: Completely free, self-hosted
- Infrastructure cost: ~$100-500/month for VMs

### Commercial/Hosted

For 10,000 concurrent users:

| Service | Monthly Cost | Features |
|---------|--------------|----------|
| **Locust.cloud Premium** | ~$399+ | Hosted, managed infrastructure |
| **k6 Cloud** | ~$699+ | Hosted, distributed testing |
| **NBomber Essential** | ~$199 | .NET native, 50k users |

**Recommendation**: Use open-source Locust for development and CI/CD. Consider Locust.cloud for large-scale production validation requiring distributed infrastructure.

## Best Practices

1. **Start Small**
   - Begin with 10-20 users
   - Gradually increase load
   - Monitor backend resources

2. **Realistic User Behavior**
   - Add wait times between requests
   - Simulate real user flows
   - Use realistic data

3. **Monitor Backend**
   - Track CPU, memory, disk I/O
   - Monitor database connections
   - Check log files for errors

4. **Iterate**
   - Run multiple test cycles
   - Compare results
   - Track improvements

5. **Automate**
   - Integrate into CI/CD
   - Run regular regression tests
   - Alert on performance degradation

## Troubleshooting

### Common Issues

1. **Connection Errors**
   ```
   Error: Connection refused
   ```
   - Check backend is running
   - Verify host URL
   - Check firewall settings

2. **Timeout Errors**
   ```
   Error: Request timeout
   ```
   - Backend overloaded
   - Increase backend resources
   - Reduce load

3. **Import Errors**
   ```
   ModuleNotFoundError: No module named 'locust'
   ```
   - Activate virtual environment
   - Install requirements: `pip install -r requirements.txt`

4. **High Failure Rates**
   - Check backend logs
   - Verify API endpoints
   - Monitor resource usage

## Resources

### Official Documentation
- [Locust Documentation](https://docs.locust.io/)
- [Writing Locustfiles](https://docs.locust.io/en/stable/writing-a-locustfile.html)
- [Running Distributed](https://docs.locust.io/en/stable/running-distributed.html)
- [Flask Documentation](https://flask.palletsprojects.com/)

### Tutorials & Guides
- [Locust Quick Start](https://docs.locust.io/en/stable/quickstart.html)
- [Load Testing Best Practices](https://docs.locust.io/en/stable/testing-other-systems.html)
- [Performance Testing Guide](https://martinfowler.com/articles/practical-test-pyramid.html)

### Community
- [Locust GitHub](https://github.com/locustio/locust)
- [Locust Discussions](https://github.com/locustio/locust/discussions)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/locust)

## Contributing

When adding new test scenarios:
1. Follow Python PEP 8 style guide
2. Add appropriate error handling
3. Document test purpose and expected behavior
4. Include realistic wait times
5. Update this README

## License

This sample is provided as-is for educational and testing purposes.
