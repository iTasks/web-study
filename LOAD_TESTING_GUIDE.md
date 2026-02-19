# Load Testing Comparison Guide

[← Back to Main](../../../README.md) | [k6 Samples](./k6/) | [Locust Samples](./locust/)

## Overview

This guide provides a comprehensive comparison of popular load testing tools for backend services (DSE-BD and CSE-BD), including pricing information, features, and best practices for concurrent user load testing and production bottleneck checking.

## Quick Tool Selection

| Your Need | Recommended Tool | Reason |
|-----------|-----------------|--------|
| .NET backend with C# team | k6 (OSS) | Great REST/WebSocket support, easy CI/CD integration |
| Python backend with Python team | Locust (OSS) | Native Python, full language power |
| Budget-conscious, self-hosted | k6 or Locust (OSS) | Free, only infrastructure costs |
| Need hosted/managed solution | k6 Cloud or Locust.cloud | No infrastructure management |
| .NET native testing | NBomber | .NET-first design (requires commercial license) |
| Classic/protocol heavy | Apache JMeter | Free, mature, many protocols |

## Open-Source Tools (Free)

### 1. k6 (Open Source)

**Language**: JavaScript (Go runtime)  
**Pricing**: Free (OSS)  
**Best For**: REST/WebSocket, CI/CD integration, modern APIs

#### ✅ Pros
- Completely free and open source
- Easy to write tests in JavaScript
- Excellent CI/CD integration
- Built-in metrics and thresholds
- Great documentation and community
- Low resource consumption

#### ❌ Cons
- Must provide your own load generation infrastructure
- Limited built-in UI (web UI requires extensions)
- JavaScript knowledge required
- Advanced scenarios may need Go knowledge

#### Example Use Case
```javascript
// k6 test for 100 concurrent users
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  vus: 100,
  duration: '5m',
};

export default function() {
  const res = http.get('http://api.example.com/data');
  check(res, { 'status is 200': (r) => r.status === 200 });
}
```

**Infrastructure Cost** (self-hosted): ~$100-500/month for load generation VMs

---

### 2. Locust (Open Source)

**Language**: Python  
**Pricing**: Free (OSS)  
**Best For**: Python teams, complex user scenarios, distributed testing

#### ✅ Pros
- Completely free and open source
- Write tests in pure Python
- Built-in web UI for real-time monitoring
- Easy distributed testing
- Full power of Python ecosystem
- Great for complex user behaviors

#### ❌ Cons
- Must host yourself
- Python overhead can impact performance
- Requires Python knowledge
- Resource-intensive at very high loads

#### Example Use Case
```python
# Locust test for 100 concurrent users
from locust import HttpUser, task, between

class APIUser(HttpUser):
    wait_time = between(1, 3)
    
    @task
    def get_data(self):
        self.client.get("/data")
```

**Infrastructure Cost** (self-hosted): ~$100-500/month for load generation VMs

---

### 3. Apache JMeter

**Language**: Java (GUI + CLI)  
**Pricing**: Free (OSS)  
**Best For**: Protocol testing, heavy customization, enterprise environments

#### ✅ Pros
- Completely free and open source
- Very mature and stable
- Supports many protocols (HTTP, FTP, SOAP, JDBC, etc.)
- Rich GUI for test creation
- Extensive plugin ecosystem

#### ❌ Cons
- Steep learning curve
- Heavy resource usage
- GUI can be cumbersome
- Not developer-friendly for CI/CD
- Java/XML knowledge helpful

**Infrastructure Cost** (self-hosted): ~$100-500/month for load generation VMs

---

### 4. Artillery (Open Source)

**Language**: Node.js  
**Pricing**: Free (OSS)  
**Best For**: Node.js teams, WebSocket testing, scenario scripting

#### ✅ Pros
- Free and open source
- YAML-based scenarios (easy to read)
- Good WebSocket support
- Plugin system
- Modern design

#### ❌ Cons
- Smaller community than k6/Locust
- Limited advanced features
- Node.js overhead
- Less mature than alternatives

**Infrastructure Cost** (self-hosted): ~$100-500/month for load generation VMs

---

## Commercial / Hosted Services

### 1. k6 Cloud

**Provider**: Grafana Labs  
**Best For**: Teams wanting managed k6 infrastructure

| Tier | Monthly Price | Concurrent Users | Features |
|------|--------------|------------------|----------|
| Free | $0 | Limited | Small tests only |
| 1000 users | ~$299 | 1,000 | Hosted load generation, reporting |
| 3000 users | ~$699 | 3,000 | Multi-region testing |
| 8000+ users | ~$1,299+ | 8,000+ | Custom quote, enterprise support |

#### ✅ Pros
- No infrastructure management
- Distributed testing from multiple regions
- Rich dashboards and historical comparison
- Same k6 scripts as OSS
- Great integration with Grafana

#### ❌ Cons
- Recurring costs
- Must have internet connectivity
- Vendor lock-in for advanced features

**Best For**: Teams using k6 OSS wanting to scale testing without infrastructure management

**Source**: [GetApp Pricing Guide](https://www.getapp.com/it-management-software/a/load-impact-load-testing-tool/pricing/)

---

### 2. Locust.cloud

**Provider**: Locust maintainers  
**Best For**: Teams wanting managed Locust infrastructure

| Tier | Monthly Price | Max Concurrent Users | Features |
|------|--------------|---------------------|----------|
| Free | $0 | Small scale | Limited tests |
| Premium | ~$399 | ~1,000 VUs | Hosted, managed |
| Enterprise | Custom | Millions | Custom infrastructure |

#### ✅ Pros
- No infrastructure to manage
- Use same Locust scripts
- Managed distributed testing
- Support from Locust team

#### ❌ Cons
- Recurring costs
- Smaller ecosystem than k6 Cloud
- Less mature than k6 Cloud

**Best For**: Python teams wanting hosted Locust without infrastructure

**Source**: [Locust Cloud Pricing](https://www.locust.cloud/pricing)

---

### 3. NBomber (Commercial)

**Language**: C# / F# / .NET  
**Pricing**: Commercial license required  
**Best For**: .NET teams wanting native load testing

| Plan | Monthly Price (approx) | Concurrent Users | License Type |
|------|----------------------|------------------|--------------|
| Free | $0 | Unlimited | Personal/non-commercial only |
| Business | ~$99 | ~10,000 | Small teams |
| Essential | ~$199 | ~50,000 | Medium organizations |
| Premium | ~$499 | 500,000+ | Large enterprises |

#### ✅ Pros
- .NET native (C#/F#)
- Familiar syntax for .NET developers
- Good integration with .NET ecosystem
- Performance monitoring built-in

#### ❌ Cons
- **⚠️ Free version NOT for commercial use** - requires business license
- Smaller community than k6/Locust
- Limited to .NET ecosystem
- Commercial license required for company use

**Important Note**: NBomber free version cannot be used in commercial/organization settings. Business license required.

**Best For**: .NET-first organizations with budget for commercial tools

**Source**: [NBomber Pricing](https://nbomber.com/) and [License Info](https://nbomber.com/docs/getting-started/license/)

---

### 4. Artillery Cloud

**Provider**: Artillery.io (AWS Marketplace)  
**Best For**: Teams wanting managed Artillery on AWS

| Plan | Annual Cost | Monthly Equivalent |
|------|------------|-------------------|
| Team | ~$2,388/yr | ~$200/mo |
| Business | ~$5,988/yr | ~$499/mo |
| Enterprise | ~$19,500/yr | ~$1,625/mo |

**Note**: AWS infrastructure costs are separate

#### ✅ Pros
- Managed service on AWS
- YAML-based scenarios
- Good WebSocket support

#### ❌ Cons
- Highest pricing tier
- Additional AWS costs
- Smaller community

**Source**: [AWS Marketplace - Artillery Cloud](https://aws.amazon.com/marketplace/pp/prodview-orh5vfijdmga)

---

## Cost Comparison Summary

### Simulating 10,000 Concurrent Users

| Tool | Type | Estimated Monthly Cost | Notes |
|------|------|----------------------|-------|
| **k6 Open Source** | Self-hosted | $100-500 | VMs only |
| **Locust Open Source** | Self-hosted | $100-500 | VMs only |
| **JMeter** | Self-hosted | $100-500 | VMs only |
| **k6 Cloud** | Hosted | $699+ | Fully managed |
| **Locust.cloud** | Hosted | $399+ | Fully managed |
| **NBomber Essential** | Hosted | $199 | Up to 50k users |
| **Artillery Cloud** | Hosted | $499+ | Plus AWS costs |

### Cost-Benefit Analysis

**For Small Teams / Startups:**
- ✅ **Recommended**: k6 or Locust (OSS)
- **Why**: Free, flexible, only infrastructure costs
- **Cost**: $100-500/month for VMs

**For Medium Organizations:**
- ✅ **Recommended**: k6 Cloud or Locust.cloud (if Python)
- **Why**: Balance of cost and features, no infrastructure management
- **Cost**: $400-700/month

**For Large Enterprises:**
- ✅ **Recommended**: k6 Cloud Enterprise or custom infrastructure
- **Why**: Scale, support, compliance requirements
- **Cost**: $1,000+/month

---

## Feature Comparison Matrix

| Feature | k6 | Locust | JMeter | Artillery | NBomber |
|---------|-----|---------|--------|-----------|---------|
| **Open Source** | ✅ | ✅ | ✅ | ✅ | ⚠️ Limited |
| **Web UI** | Via extensions | ✅ Built-in | ✅ GUI | ❌ | ✅ |
| **Distributed Testing** | Via Cloud | ✅ Native | ✅ | Via Cloud | Via Cloud |
| **CI/CD Friendly** | ✅ Excellent | ✅ Good | ⚠️ Moderate | ✅ Good | ✅ Good |
| **Scripting Language** | JavaScript | Python | Java/XML | YAML/JS | C#/F# |
| **Learning Curve** | Easy | Easy | Steep | Easy | Easy (if .NET) |
| **Resource Usage** | Low | Medium | High | Medium | Low |
| **Protocol Support** | HTTP/WS/gRPC | HTTP/WS | Many | HTTP/WS | HTTP/WS |
| **Real-time Metrics** | Via extensions | ✅ | Via plugins | ❌ | ✅ |
| **Cloud Option** | ✅ | ✅ | ❌ | ✅ | ✅ |

---

## DSE-BD / CSE-BD Recommendations

### For Data Service Engineering (DSE-BD)

**Primary Focus**: Data ingestion, query performance, batch operations

#### Recommended Tools:
1. **k6** (First Choice)
   - Excellent for API load testing
   - Low overhead, high throughput
   - Great CI/CD integration
   - Perfect for REST APIs

2. **Locust** (Python teams)
   - Full Python power for complex scenarios
   - Great for custom data generation
   - Easy to test batch operations

#### Key Metrics to Track:
- Data ingestion rate (records/second)
- Query response times (p95, p99)
- Database connection pool utilization
- Error rates under high write loads

#### Sample Test Scenario:
```javascript
// k6 for DSE-BD
export const options = {
  stages: [
    { duration: '2m', target: 100 },   // Normal load
    { duration: '5m', target: 100 },   // Sustained
    { duration: '2m', target: 500 },   // Peak load
    { duration: '1m', target: 0 },     // Ramp down
  ],
  thresholds: {
    'http_req_duration': ['p(95)<500', 'p(99)<1000'],
    'http_req_failed': ['rate<0.01'],
  },
};
```

---

### For Customer Service Engineering (CSE-BD)

**Primary Focus**: User experience, session handling, response consistency

#### Recommended Tools:
1. **Locust** (First Choice)
   - Excellent for simulating user journeys
   - Python allows complex user behavior
   - Built-in web UI for real-time monitoring
   - Great for session-based testing

2. **k6** (Alternative)
   - Good for API-focused customer services
   - Easy threshold definition
   - Great for SLA validation

#### Key Metrics to Track:
- User response time consistency
- Session handling under load
- API rate limiting effectiveness
- Error rates during peak customer hours
- User concurrency patterns

#### Sample Test Scenario:
```python
# Locust for CSE-BD
class CustomerUser(HttpUser):
    wait_time = between(2, 5)  # Realistic user think time
    
    def on_start(self):
        self.login()
    
    @task(5)
    def browse_products(self):
        self.client.get("/api/products")
    
    @task(2)
    def search(self):
        self.client.get("/api/search?q=item")
    
    @task(1)
    def update_cart(self):
        self.client.post("/api/cart", json={"item": "123"})
```

---

## Production Bottleneck Checking

### Common Bottleneck Types

#### 1. Application/Backend Bottlenecks
**Symptoms:**
- High response times (p95 > 500ms)
- Increasing memory usage
- High CPU utilization

**Detection:**
```javascript
// k6 threshold
thresholds: {
  'http_req_duration': ['p(95)<500'],  // Alert if exceeded
}
```

**Solutions:**
- Code profiling and optimization
- Caching layer implementation
- Horizontal scaling (add more instances)
- Async processing for heavy operations

#### 2. Database Bottlenecks
**Symptoms:**
- Query times > 1 second
- Connection pool exhaustion
- Lock contentions

**Detection:**
```python
# Locust custom check
if response.elapsed.total_seconds() > 1.0:
    print(f"⚠️  Slow query: {response.elapsed.total_seconds()}s")
```

**Solutions:**
- Add database indexes
- Optimize slow queries
- Implement read replicas
- Use connection pooling
- Consider caching layer

#### 3. Network/Infrastructure Bottlenecks
**Symptoms:**
- High latency (> 100ms)
- Timeouts (HTTP 504)
- Connection refused errors

**Detection:**
- Monitor network latency metrics
- Track timeout rates
- Check connection success rates

**Solutions:**
- Use CDN for static content
- Enable HTTP/2
- Implement request compression
- Add load balancers
- Increase network bandwidth

#### 4. Memory Bottlenecks
**Symptoms:**
- OOM (Out of Memory) errors
- Garbage collection pauses
- Swap usage

**Detection:**
- Monitor memory usage during load tests
- Track GC frequency and duration

**Solutions:**
- Fix memory leaks
- Optimize data structures
- Increase available memory
- Implement object pooling

---

## Load Testing Best Practices

### 1. Planning Phase
- Define clear objectives and success criteria
- Identify critical user journeys
- Determine realistic load patterns
- Set performance SLAs/SLOs

### 2. Test Design
- Start with smoke tests (low load)
- Progress to load tests (normal load)
- Conduct stress tests (peak load)
- Run spike tests (sudden load increase)
- Perform soak tests (sustained load)

### 3. Execution
- Monitor both client and server metrics
- Run tests from production-like environment
- Use realistic test data
- Simulate network conditions if needed

### 4. Analysis
- Compare against baseline
- Identify performance degradation
- Document bottlenecks
- Prioritize fixes by impact

### 5. Continuous Testing
- Integrate into CI/CD pipeline
- Run regression tests regularly
- Track performance trends
- Alert on threshold violations

---

## Test Progression Strategy

### Phase 1: Smoke Test
**Purpose**: Verify system works under minimal load  
**Load**: 1-5 users  
**Duration**: 5-10 minutes

```bash
# k6
k6 run --vus 5 --duration 5m load-test.js

# Locust
locust -f locustfile.py --headless -u 5 -r 1 --run-time 5m
```

### Phase 2: Load Test
**Purpose**: Test normal expected load  
**Load**: Expected concurrent users  
**Duration**: 15-30 minutes

```bash
# k6
k6 run --vus 100 --duration 30m load-test.js

# Locust
locust -f locustfile.py --headless -u 100 -r 10 --run-time 30m
```

### Phase 3: Stress Test
**Purpose**: Find system limits  
**Load**: 2-3x expected load  
**Duration**: 10-20 minutes

```bash
# k6
k6 run --vus 300 --duration 20m load-test.js

# Locust
locust -f locustfile.py --headless -u 300 -r 20 --run-time 20m
```

### Phase 4: Spike Test
**Purpose**: Test sudden load increases  
**Load**: Rapid ramp-up to high load  
**Duration**: 10-15 minutes

```javascript
// k6 spike test
export const options = {
  stages: [
    { duration: '2m', target: 50 },   // Normal
    { duration: '30s', target: 500 }, // Spike!
    { duration: '2m', target: 500 },  // Sustained spike
    { duration: '2m', target: 50 },   // Recovery
  ],
};
```

### Phase 5: Soak Test
**Purpose**: Find memory leaks and degradation  
**Load**: Normal load  
**Duration**: 2-8 hours

```bash
# k6
k6 run --vus 100 --duration 4h load-test.js

# Locust
locust -f locustfile.py --headless -u 100 -r 10 --run-time 4h
```

---

## CI/CD Integration Examples

### GitHub Actions - k6

```yaml
name: Load Test
on: [push, pull_request]

jobs:
  load-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run k6 test
        uses: grafana/k6-action@v0.3.1
        with:
          filename: load-test.js
          flags: --vus 50 --duration 2m
      
      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: k6-results
          path: results.json
```

### GitHub Actions - Locust

```yaml
name: Load Test
on: [push, pull_request]

jobs:
  load-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: pip install locust
      
      - name: Run Locust test
        run: |
          locust -f locustfile.py --headless \
            -u 50 -r 10 --run-time 2m \
            --host=http://test-api
```

---

## Conclusion

### Quick Decision Guide

**Choose k6 if:**
- ✅ You want low overhead and high performance
- ✅ Your team knows JavaScript
- ✅ You need great CI/CD integration
- ✅ You're testing REST APIs or WebSockets

**Choose Locust if:**
- ✅ Your team knows Python
- ✅ You need complex user behavior simulation
- ✅ You want built-in web UI
- ✅ You need full Python ecosystem access

**Choose JMeter if:**
- ✅ You need many protocol support
- ✅ You have existing JMeter expertise
- ✅ You need GUI-based test creation
- ✅ Enterprise environment requirement

**Choose Commercial (k6 Cloud/Locust.cloud) if:**
- ✅ You don't want to manage infrastructure
- ✅ You need multi-region testing
- ✅ You want rich dashboards and reports
- ✅ Budget allows ($400-700/month)

---

## Resources & References

### Documentation
- [k6 Documentation](https://k6.io/docs/)
- [Locust Documentation](https://docs.locust.io/)
- [JMeter Documentation](https://jmeter.apache.org/usermanual/)
- [Load Testing Tools Comparison](https://www.ramotion.com/blog/load-testing-tools-for-web-applications/)

### Pricing Sources
- [k6 Cloud Pricing - GetApp](https://www.getapp.com/it-management-software/a/load-impact-load-testing-tool/pricing/)
- [Locust Cloud Pricing](https://www.locust.cloud/pricing)
- [NBomber Pricing](https://nbomber.com/) and [License](https://nbomber.com/docs/getting-started/license/)
- [Artillery Cloud - AWS Marketplace](https://aws.amazon.com/marketplace/pp/prodview-orh5vfijdmga)
- [Load Testing Tools Overview - Ramotion](https://www.ramotion.com/blog/load-testing-tools-for-web-applications/)

### Sample Code
- [k6 Examples - This Repo](./k6/)
- [Locust Examples - This Repo](./locust/)

---

**Last Updated**: 2026-02-19  
**Maintained By**: iTasks/web-study contributors
