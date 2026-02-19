/**
 * k6 Load Testing Script for C# Backend Applications
 * 
 * This script demonstrates load testing for DSE-BD and CSE-BD systems with:
 * - Concurrent user simulation
 * - Performance metrics collection
 * - Bottleneck detection
 * - Custom thresholds for production readiness
 * 
 * Usage:
 *   k6 run load-test.js
 *   k6 run --vus 100 --duration 5m load-test.js
 */

import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend, Counter, Gauge } from 'k6/metrics';

// Custom metrics for bottleneck detection
const errorRate = new Rate('errors');
const apiResponseTime = new Trend('api_response_time');
const activeConnections = new Gauge('active_connections');
const requestsPerSecond = new Counter('requests_per_second');

// Test configuration
export const options = {
  // Concurrent users load testing scenarios
  stages: [
    { duration: '1m', target: 50 },   // Ramp-up to 50 users
    { duration: '3m', target: 100 },  // Ramp-up to 100 users
    { duration: '5m', target: 100 },  // Stay at 100 users
    { duration: '2m', target: 200 },  // Spike to 200 users
    { duration: '2m', target: 200 },  // Stay at 200 users
    { duration: '2m', target: 0 },    // Ramp-down to 0 users
  ],
  
  // Production bottleneck checking thresholds
  thresholds: {
    // 95% of requests must complete within 500ms
    'http_req_duration': ['p(95)<500'],
    
    // 99% of requests must complete within 1s
    'http_req_duration{staticAsset:yes}': ['p(99)<1000'],
    
    // Error rate must be less than 1%
    'errors': ['rate<0.01'],
    
    // API response time must be acceptable
    'api_response_time': ['p(95)<300', 'p(99)<500'],
    
    // HTTP request failure rate must be less than 5%
    'http_req_failed': ['rate<0.05'],
    
    // Check success rate must be above 95%
    'checks': ['rate>0.95'],
  },
  
  // Additional configurations
  noConnectionReuse: false,
  userAgent: 'k6-LoadTest/1.0',
  
  // Tags for metrics grouping
  tags: {
    environment: 'load-test',
    service: 'backend-api',
  },
};

// Base URL configuration - modify for your C# backend
const BASE_URL = __ENV.BASE_URL || 'http://localhost:5000';

// Test data
const TEST_USER = {
  username: `testuser_${__VU}_${Date.now()}`,
  email: `test${__VU}@example.com`,
  password: 'TestPassword123!',
};

/**
 * Setup function - runs once before all VUs
 */
export function setup() {
  console.log('Starting load test setup...');
  console.log(`Base URL: ${BASE_URL}`);
  console.log('Test will simulate real user behavior with concurrent requests');
  
  return {
    baseUrl: BASE_URL,
    testData: TEST_USER,
  };
}

/**
 * Main test function - runs for each VU iteration
 */
export default function (data) {
  const baseUrl = data.baseUrl;
  
  // Group: Health Check & Readiness
  group('Health Check', () => {
    const healthRes = http.get(`${baseUrl}/health`);
    
    check(healthRes, {
      'health check status is 200': (r) => r.status === 200,
      'health check response time < 100ms': (r) => r.timings.duration < 100,
    });
    
    errorRate.add(healthRes.status !== 200);
    apiResponseTime.add(healthRes.timings.duration);
  });
  
  sleep(1);
  
  // Group: API Operations (simulating DSE-BD/CSE-BD operations)
  group('API Operations', () => {
    // Simulate GET request (Read operation)
    const getRes = http.get(`${baseUrl}/api/data`, {
      tags: { name: 'GetData' },
    });
    
    check(getRes, {
      'GET status is 200': (r) => r.status === 200,
      'GET response has data': (r) => r.body.length > 0,
      'GET response time < 300ms': (r) => r.timings.duration < 300,
    });
    
    errorRate.add(getRes.status !== 200);
    apiResponseTime.add(getRes.timings.duration);
    requestsPerSecond.add(1);
    
    sleep(1);
    
    // Simulate POST request (Create operation)
    const payload = JSON.stringify({
      name: `Test_${__VU}_${__ITER}`,
      value: Math.random() * 1000,
      timestamp: new Date().toISOString(),
    });
    
    const postRes = http.post(`${baseUrl}/api/data`, payload, {
      headers: { 'Content-Type': 'application/json' },
      tags: { name: 'CreateData' },
    });
    
    check(postRes, {
      'POST status is 201 or 200': (r) => r.status === 201 || r.status === 200,
      'POST response time < 500ms': (r) => r.timings.duration < 500,
    });
    
    errorRate.add(!(postRes.status === 201 || postRes.status === 200));
    apiResponseTime.add(postRes.timings.duration);
    requestsPerSecond.add(1);
  });
  
  sleep(2);
  
  // Group: Database Operations (bottleneck detection)
  group('Database Operations', () => {
    const dbRes = http.get(`${baseUrl}/api/database/query`, {
      tags: { name: 'DatabaseQuery' },
    });
    
    check(dbRes, {
      'Database query status is 200': (r) => r.status === 200,
      'Database query time < 1s': (r) => r.timings.duration < 1000,
      'No timeout errors': (r) => r.status !== 504,
    });
    
    // Bottleneck detection: slow database queries
    if (dbRes.timings.duration > 1000) {
      console.warn(`Bottleneck detected: Database query took ${dbRes.timings.duration}ms`);
    }
    
    errorRate.add(dbRes.status !== 200);
    apiResponseTime.add(dbRes.timings.duration);
  });
  
  sleep(1);
  
  // Group: Cache Operations
  group('Cache Operations', () => {
    const cacheRes = http.get(`${baseUrl}/api/cache/data`, {
      tags: { name: 'CacheRead' },
    });
    
    check(cacheRes, {
      'Cache read status is 200': (r) => r.status === 200,
      'Cache read time < 50ms': (r) => r.timings.duration < 50,
    });
    
    // Bottleneck detection: cache misses or slow cache
    if (cacheRes.timings.duration > 100) {
      console.warn(`Bottleneck detected: Cache operation took ${cacheRes.timings.duration}ms`);
    }
    
    errorRate.add(cacheRes.status !== 200);
    apiResponseTime.add(cacheRes.timings.duration);
  });
  
  // Update active connections gauge
  activeConnections.add(__VU);
  
  sleep(2);
}

/**
 * Teardown function - runs once after all VUs complete
 */
export function teardown(data) {
  console.log('Load test completed!');
  console.log('Check the metrics summary for bottlenecks and performance issues.');
}

/**
 * Custom summary for bottleneck analysis
 */
export function handleSummary(data) {
  const bottlenecks = [];
  
  // Analyze metrics for bottlenecks
  if (data.metrics.http_req_duration?.values?.['p(95)'] > 500) {
    bottlenecks.push('⚠️  95th percentile response time exceeds 500ms - possible backend bottleneck');
  }
  
  if (data.metrics.errors?.values?.rate > 0.01) {
    bottlenecks.push('⚠️  Error rate exceeds 1% - investigate error causes');
  }
  
  if (data.metrics.http_req_failed?.values?.rate > 0.05) {
    bottlenecks.push('⚠️  HTTP failure rate exceeds 5% - check network/server stability');
  }
  
  console.log('\n=== Bottleneck Analysis ===');
  if (bottlenecks.length === 0) {
    console.log('✅ No significant bottlenecks detected');
  } else {
    bottlenecks.forEach(b => console.log(b));
  }
  
  return {
    'stdout': JSON.stringify(data, null, 2),
    'summary.json': JSON.stringify(data),
    'summary.html': htmlReport(data),
  };
}

/**
 * Generate HTML report
 */
function htmlReport(data) {
  return `
<!DOCTYPE html>
<html>
<head>
  <title>k6 Load Test Report</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
    .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
    h1 { color: #333; }
    .metric { background: #f9f9f9; padding: 15px; margin: 10px 0; border-left: 4px solid #4CAF50; }
    .warning { border-left-color: #ff9800; }
    .error { border-left-color: #f44336; }
    .metric-name { font-weight: bold; font-size: 18px; }
    .metric-value { font-size: 24px; color: #666; margin: 10px 0; }
  </style>
</head>
<body>
  <div class="container">
    <h1>k6 Load Test Report</h1>
    <p><strong>Test Date:</strong> ${new Date().toISOString()}</p>
    
    <h2>Summary Metrics</h2>
    <div class="metric">
      <div class="metric-name">Total Requests</div>
      <div class="metric-value">${data.metrics.http_reqs?.values?.count || 0}</div>
    </div>
    
    <div class="metric">
      <div class="metric-name">Request Duration (95th percentile)</div>
      <div class="metric-value">${(data.metrics.http_req_duration?.values?.['p(95)'] || 0).toFixed(2)} ms</div>
    </div>
    
    <div class="metric ${data.metrics.errors?.values?.rate > 0.01 ? 'error' : ''}">
      <div class="metric-name">Error Rate</div>
      <div class="metric-value">${((data.metrics.errors?.values?.rate || 0) * 100).toFixed(2)}%</div>
    </div>
    
    <div class="metric">
      <div class="metric-name">Requests per Second</div>
      <div class="metric-value">${(data.metrics.http_reqs?.values?.rate || 0).toFixed(2)}</div>
    </div>
  </div>
</body>
</html>
  `;
}
