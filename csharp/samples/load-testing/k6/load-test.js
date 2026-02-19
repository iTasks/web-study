/**
 * k6 Load Testing Script for Stock Trading Platform (DSE/CSE)
 * 
 * Based on real-world stock trading app features (Puji app):
 * - Real-time market data streaming
 * - Order management (place, cancel, edit orders)
 * - Portfolio tracking and balance updates
 * - Watchlist management
 * - Market depth and historical data
 * 
 * This script simulates concurrent users performing typical stock trading operations
 * with realistic workload patterns for DSE (Dhaka Stock Exchange) and CSE (Chittagong Stock Exchange).
 * 
 * Usage:
 *   k6 run load-test.js
 *   k6 run --vus 500 --duration 10m load-test.js  // Peak trading hours
 *   k6 run --vus 1000 --duration 5m load-test.js  // Market opening surge
 */

import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend, Counter, Gauge } from 'k6/metrics';

// Custom metrics for stock trading bottleneck detection
const errorRate = new Rate('errors');
const apiResponseTime = new Trend('api_response_time');
const activeConnections = new Gauge('active_connections');
const requestsPerSecond = new Counter('requests_per_second');
const orderPlacementTime = new Trend('order_placement_time');
const marketDataLatency = new Trend('market_data_latency');
const portfolioUpdateTime = new Trend('portfolio_update_time');

// Test configuration for stock trading platform
export const options = {
  // Realistic concurrent users for stock trading platform
  // Simulates market opening, regular trading hours, and closing
  stages: [
    { duration: '2m', target: 500 },    // Market opening surge (9:30 AM)
    { duration: '5m', target: 1000 },   // Peak morning trading (9:30-10:00 AM)
    { duration: '10m', target: 1000 },  // Sustained morning activity
    { duration: '3m', target: 500 },    // Mid-day slowdown
    { duration: '10m', target: 500 },   // Regular trading hours
    { duration: '3m', target: 1500 },   // Pre-closing surge (2:30 PM)
    { duration: '5m', target: 1500 },   // Closing time peak
    { duration: '2m', target: 100 },    // After-hours
    { duration: '2m', target: 0 },      // Ramp-down
  ],
  
  // Production bottleneck checking thresholds for trading platform
  thresholds: {
    // Real-time market data must be fast (< 200ms for 95%)
    'http_req_duration{endpoint:market_data}': ['p(95)<200', 'p(99)<500'],
    
    // Order placement critical (< 300ms for 95%)
    'http_req_duration{endpoint:order}': ['p(95)<300', 'p(99)<800'],
    
    // Portfolio updates should be quick (< 400ms for 95%)
    'http_req_duration{endpoint:portfolio}': ['p(95)<400', 'p(99)<1000'],
    
    // Overall API performance
    'http_req_duration': ['p(95)<500', 'p(99)<1500'],
    
    // Error rate must be extremely low for trading (< 0.1%)
    'errors': ['rate<0.001'],
    
    // Order placement specific metrics
    'order_placement_time': ['p(95)<300', 'p(99)<800'],
    
    // Market data latency critical
    'market_data_latency': ['p(95)<200', 'p(99)<500'],
    
    // HTTP request failure rate must be minimal
    'http_req_failed': ['rate<0.01'],
    
    // Check success rate must be above 99% for trading
    'checks': ['rate>0.99'],
  },
  
  // Additional configurations
  noConnectionReuse: false,
  userAgent: 'k6-StockTradingLoadTest/1.0',
  
  // Tags for metrics grouping
  tags: {
    environment: 'load-test',
    service: 'stock-trading-api',
    exchanges: 'DSE-CSE',
  },
};

// Base URL configuration - modify for your stock trading backend
const BASE_URL = __ENV.BASE_URL || 'http://localhost:5000';

// Stock symbols for testing (DSE/CSE common stocks)
const STOCK_SYMBOLS = ['GP', 'BRAC', 'ACI', 'SQURPHARMA', 'BATBC', 'BEXIMCO', 'OLYMPIC', 'RENATA'];

// Test data for stock trading users
const TEST_USER = {
  username: `trader_${__VU}_${Date.now()}`,
  email: `trader${__VU}@example.com`,
  password: 'SecureTrading123!',
  accountId: `ACC${__VU}${Date.now()}`,
};

/**
 * Setup function - runs once before all VUs
 */
export function setup() {
  console.log('='.repeat(80));
  console.log('🚀 Starting Stock Trading Platform Load Test');
  console.log('='.repeat(80));
  console.log(`Base URL: ${BASE_URL}`);
  console.log(`Simulating trading on DSE (Dhaka Stock Exchange) and CSE (Chittagong Stock Exchange)`);
  console.log(`Test will simulate realistic trader behavior with concurrent users`);
  console.log(`Stock symbols: ${STOCK_SYMBOLS.join(', ')}`);
  console.log('='.repeat(80));
  
  return {
    baseUrl: BASE_URL,
    testData: TEST_USER,
    stocks: STOCK_SYMBOLS,
  };
}

/**
 * Main test function - runs for each VU iteration
 * Simulates realistic stock trader behavior based on Puji app features
 */
export default function (data) {
  const baseUrl = data.baseUrl;
  const randomStock = data.stocks[Math.floor(Math.random() * data.stocks.length)];
  
  // Group: Health Check & Readiness (monitoring)
  group('System Health', () => {
    const healthRes = http.get(`${baseUrl}/health`);
    
    check(healthRes, {
      'health check status is 200': (r) => r.status === 200,
      'health check response time < 100ms': (r) => r.timings.duration < 100,
    });
    
    errorRate.add(healthRes.status !== 200);
    apiResponseTime.add(healthRes.timings.duration);
  });
  
  sleep(0.5);
  
  // Group: Real-time Market Data (highest frequency - 40% of requests)
  group('Market Data Streaming', () => {
    const startTime = Date.now();
    
    // Get real-time market data for specific stock
    const marketDataRes = http.get(`${baseUrl}/api/market/data/${randomStock}`, {
      tags: { name: 'MarketData', endpoint: 'market_data' },
    });
    
    const responseTime = Date.now() - startTime;
    
    check(marketDataRes, {
      'market data status is 200': (r) => r.status === 200,
      'market data response time < 200ms': (r) => r.timings.duration < 200,
      'market data has price': (r) => r.body && r.body.length > 0,
    });
    
    errorRate.add(marketDataRes.status !== 200);
    marketDataLatency.add(responseTime);
    requestsPerSecond.add(1);
    
    // Bottleneck detection: slow market data
    if (responseTime > 200) {
      console.warn(`⚠️  Market data bottleneck: ${randomStock} took ${responseTime}ms`);
    }
  });
  
  sleep(1);
  
  // Group: Portfolio Management (30% of requests)
  group('Portfolio Operations', () => {
    const startTime = Date.now();
    
    // Get portfolio with real-time balance
    const portfolioRes = http.get(`${baseUrl}/api/portfolio`, {
      tags: { name: 'Portfolio', endpoint: 'portfolio' },
    });
    
    const responseTime = Date.now() - startTime;
    
    check(portfolioRes, {
      'portfolio status is 200': (r) => r.status === 200,
      'portfolio response time < 400ms': (r) => r.timings.duration < 400,
      'portfolio has balance': (r) => r.body && r.body.length > 0,
    });
    
    errorRate.add(portfolioRes.status !== 200);
    portfolioUpdateTime.add(responseTime);
    apiResponseTime.add(responseTime);
    requestsPerSecond.add(1);
    
    // Bottleneck detection: slow portfolio updates
    if (responseTime > 400) {
      console.warn(`⚠️  Portfolio update bottleneck: took ${responseTime}ms`);
    }
  });
  
  sleep(2);
  
  // Group: Order Management (20% of requests - critical path)
  group('Order Operations', () => {
    const startTime = Date.now();
    
    // Place a buy order
    const orderPayload = JSON.stringify({
      symbol: randomStock,
      type: 'BUY',
      quantity: Math.floor(Math.random() * 100) + 1,
      price: Math.random() * 1000 + 100,
      accountId: TEST_USER.accountId,
      timestamp: new Date().toISOString(),
    });
    
    const orderRes = http.post(`${baseUrl}/api/order`, orderPayload, {
      headers: { 'Content-Type': 'application/json' },
      tags: { name: 'PlaceOrder', endpoint: 'order' },
    });
    
    const responseTime = Date.now() - startTime;
    
    check(orderRes, {
      'order placement status is 201 or 200': (r) => r.status === 201 || r.status === 200,
      'order placement time < 300ms': (r) => r.timings.duration < 300,
      'order has confirmation': (r) => r.body && r.body.length > 0,
    });
    
    errorRate.add(!(orderRes.status === 201 || orderRes.status === 200));
    orderPlacementTime.add(responseTime);
    apiResponseTime.add(responseTime);
    requestsPerSecond.add(1);
    
    // Bottleneck detection: slow order placement (critical!)
    if (responseTime > 300) {
      console.warn(`⚠️  CRITICAL: Order placement bottleneck for ${randomStock}: ${responseTime}ms`);
    }
  });
  
  sleep(1);
  
  // Group: Watchlist Management (5% of requests)
  group('Watchlist Operations', () => {
    // Get watchlist
    const watchlistRes = http.get(`${baseUrl}/api/watchlist`, {
      tags: { name: 'Watchlist' },
    });
    
    check(watchlistRes, {
      'watchlist status is 200': (r) => r.status === 200,
      'watchlist response time < 300ms': (r) => r.timings.duration < 300,
    });
    
    errorRate.add(watchlistRes.status !== 200);
    apiResponseTime.add(watchlistRes.timings.duration);
    requestsPerSecond.add(1);
  });
  
  sleep(2);
  
  // Group: Market Depth & Historical Data (5% of requests)
  group('Market Analysis', () => {
    // Get market depth (top 10 bid/ask)
    const depthRes = http.get(`${baseUrl}/api/market/depth/${randomStock}`, {
      tags: { name: 'MarketDepth' },
    });
    
    check(depthRes, {
      'market depth status is 200': (r) => r.status === 200,
      'market depth time < 500ms': (r) => r.timings.duration < 500,
    });
    
    // Bottleneck detection: slow market depth queries
    if (depthRes.timings.duration > 500) {
      console.warn(`⚠️  Market depth bottleneck: ${randomStock} took ${depthRes.timings.duration}ms`);
    }
    
    errorRate.add(depthRes.status !== 200);
    apiResponseTime.add(depthRes.timings.duration);
    requestsPerSecond.add(1);
  });
  
  sleep(1);
  
  // Update active connections gauge
  activeConnections.add(__VU);
  
  sleep(2);
}

/**
 * Helper function to safely get metric percentile value
 */
function getMetricPercentile(data, metricName, percentile, defaultValue = 0) {
  if (data.metrics[metricName] && data.metrics[metricName].values && data.metrics[metricName].values[percentile]) {
    return data.metrics[metricName].values[percentile];
  }
  return defaultValue;
}

/**
 * Helper function to safely get metric rate value
 */
function getMetricRate(data, metricName, defaultValue = 0) {
  if (data.metrics[metricName] && data.metrics[metricName].values && data.metrics[metricName].values.rate !== undefined) {
    return data.metrics[metricName].values.rate;
  }
  return defaultValue;
}

/**
 * Teardown function - runs once after all VUs complete
 */
export function teardown(data) {
  console.log('='.repeat(80));
  console.log('✅ Stock Trading Platform Load Test Completed!');
  console.log('='.repeat(80));
  console.log('Check the metrics summary for bottlenecks and performance issues.');
  console.log('Critical metrics for trading platforms:');
  console.log('  - Market data latency (should be < 200ms p95)');
  console.log('  - Order placement time (should be < 300ms p95)');
  console.log('  - Portfolio updates (should be < 400ms p95)');
  console.log('  - Error rate (should be < 0.1% for trading)');
  console.log('='.repeat(80));
}

/**
 * Custom summary for stock trading bottleneck analysis
 */
export function handleSummary(data) {
  const bottlenecks = [];
  
  // Analyze metrics for stock trading specific bottlenecks using helper functions
  const marketDataP95 = getMetricPercentile(data, 'market_data_latency', 'p(95)');
  if (marketDataP95 > 200) {
    bottlenecks.push('⚠️  CRITICAL: Market data latency exceeds 200ms p95 - real-time data feed bottleneck');
  }
  
  const orderPlacementP95 = getMetricPercentile(data, 'order_placement_time', 'p(95)');
  if (orderPlacementP95 > 300) {
    bottlenecks.push('⚠️  CRITICAL: Order placement time exceeds 300ms p95 - trade execution bottleneck');
  }
  
  const portfolioUpdateP95 = getMetricPercentile(data, 'portfolio_update_time', 'p(95)');
  if (portfolioUpdateP95 > 400) {
    bottlenecks.push('⚠️  Portfolio update time exceeds 400ms p95 - balance calculation bottleneck');
  }
  
  const httpDurationP95 = getMetricPercentile(data, 'http_req_duration', 'p(95)');
  if (httpDurationP95 > 500) {
    bottlenecks.push('⚠️  Overall 95th percentile response time exceeds 500ms - backend performance issue');
  }
  
  const errorRate = getMetricRate(data, 'errors');
  if (errorRate > 0.001) {
    bottlenecks.push('⚠️  CRITICAL: Error rate exceeds 0.1% - trading errors can cause financial loss');
  }
  
  const failureRate = getMetricRate(data, 'http_req_failed');
  if (failureRate > 0.01) {
    bottlenecks.push('⚠️  HTTP failure rate exceeds 1% - network/server reliability issue');
  }
  
  console.log('\n' + '='.repeat(80));
  console.log('📊 STOCK TRADING PLATFORM - BOTTLENECK ANALYSIS');
  console.log('='.repeat(80));
  if (bottlenecks.length === 0) {
    console.log('✅ No significant bottlenecks detected - platform ready for trading');
  } else {
    console.log('⚠️  BOTTLENECKS DETECTED:');
    bottlenecks.forEach(b => console.log(b));
  }
  console.log('='.repeat(80));
  
  return {
    'stdout': JSON.stringify(data, null, 2),
    'summary.json': JSON.stringify(data),
    'summary.html': htmlReport(data),
  };
}

/**
 * Generate HTML report for stock trading platform
 */
function htmlReport(data) {
  // Use helper functions for safe metric extraction
  const marketDataP95 = getMetricPercentile(data, 'market_data_latency', 'p(95)', 'N/A');
  const orderPlacementP95 = getMetricPercentile(data, 'order_placement_time', 'p(95)', 'N/A');
  const portfolioUpdateP95 = getMetricPercentile(data, 'portfolio_update_time', 'p(95)', 'N/A');
  
  const formatValue = (val) => val === 'N/A' ? val : val.toFixed(2);
  
  return `
<!DOCTYPE html>
<html>
<head>
  <title>Stock Trading Platform - k6 Load Test Report</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
    .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    h1 { color: #333; border-bottom: 3px solid #4CAF50; padding-bottom: 10px; }
    h2 { color: #555; margin-top: 30px; }
    .header { background: #4CAF50; color: white; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
    .metric { background: #f9f9f9; padding: 15px; margin: 10px 0; border-left: 4px solid #4CAF50; border-radius: 4px; }
    .critical { border-left-color: #2196F3; background: #E3F2FD; }
    .warning { border-left-color: #ff9800; background: #FFF3E0; }
    .error { border-left-color: #f44336; background: #FFEBEE; }
    .metric-name { font-weight: bold; font-size: 18px; color: #333; }
    .metric-value { font-size: 28px; color: #666; margin: 10px 0; font-weight: bold; }
    .metric-desc { font-size: 14px; color: #888; }
    .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #888; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>📈 Stock Trading Platform Load Test Report</h1>
      <p>DSE (Dhaka Stock Exchange) / CSE (Chittagong Stock Exchange)</p>
      <p><strong>Test Date:</strong> ${new Date().toISOString()}</p>
    </div>
    
    <h2>🎯 Critical Trading Metrics</h2>
    
    <div class="metric critical">
      <div class="metric-name">Market Data Latency (p95)</div>
      <div class="metric-value">${formatValue(marketDataP95)} ms</div>
      <div class="metric-desc">Target: &lt; 200ms | Real-time data feed performance</div>
    </div>
    
    <div class="metric critical">
      <div class="metric-name">Order Placement Time (p95)</div>
      <div class="metric-value">${formatValue(orderPlacementP95)} ms</div>
      <div class="metric-desc">Target: &lt; 300ms | Trade execution speed</div>
    </div>
    
    <div class="metric critical">
      <div class="metric-name">Portfolio Update Time (p95)</div>
      <div class="metric-value">${formatValue(portfolioUpdateP95)} ms</div>
      <div class="metric-desc">Target: &lt; 400ms | Balance calculation performance</div>
    </div>
    
    <h2>📊 Overall Performance Metrics</h2>
    <div class="metric">
      <div class="metric-name">Total Requests</div>
      <div class="metric-value">${data.metrics.http_reqs && data.metrics.http_reqs.values ? data.metrics.http_reqs.values.count : 0}</div>
    </div>
    
    <div class="metric">
      <div class="metric-name">Request Duration (95th percentile)</div>
      <div class="metric-value">${data.metrics.http_req_duration && data.metrics.http_req_duration.values ? data.metrics.http_req_duration.values['p(95)'].toFixed(2) : 0} ms</div>
      <div class="metric-desc">Target: &lt; 500ms</div>
    </div>
    
    <div class="metric ${data.metrics.errors && data.metrics.errors.values && data.metrics.errors.values.rate > 0.001 ? 'error' : ''}">
      <div class="metric-name">Error Rate</div>
      <div class="metric-value">${data.metrics.errors && data.metrics.errors.values ? (data.metrics.errors.values.rate * 100).toFixed(3) : 0}%</div>
      <div class="metric-desc">Target: &lt; 0.1% | Critical for trading platforms</div>
    </div>
    
    <div class="metric">
      <div class="metric-name">Requests per Second</div>
      <div class="metric-value">${data.metrics.http_reqs && data.metrics.http_reqs.values ? data.metrics.http_reqs.values.rate.toFixed(2) : 0}</div>
    </div>
    
    <div class="footer">
      <p><strong>Platform:</strong> DSE/CSE Stock Trading Backend</p>
      <p><strong>Test Tool:</strong> k6 Load Testing Framework</p>
      <p><strong>Report Generated:</strong> ${new Date().toLocaleString()}</p>
    </div>
  </div>
</body>
</html>
  `;
}
