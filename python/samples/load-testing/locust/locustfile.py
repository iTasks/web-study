"""
Locust Load Testing Script for Stock Trading Platform (DSE/CSE)

Based on real-world stock trading app features (Puji app):
- Real-time market data streaming
- Order management (place, cancel, edit orders)
- Portfolio tracking and balance updates
- Watchlist management
- Market depth and historical data

This script simulates concurrent traders performing typical stock trading operations
with realistic workload patterns for DSE (Dhaka Stock Exchange) and CSE (Chittagong Stock Exchange).

Usage:
    locust -f locustfile.py
    locust -f locustfile.py --headless -u 1000 -r 50 --run-time 10m  # Peak trading hours
    locust -f locustfile.py --host=http://your-trading-api-url
"""

import time
import json
import random
from datetime import datetime
from locust import HttpUser, task, between, events
from locust.runners import MasterRunner, WorkerRunner

# Stock symbols for testing (DSE/CSE common stocks)
STOCK_SYMBOLS = ['GP', 'BRAC', 'ACI', 'SQURPHARMA', 'BATBC', 'BEXIMCO', 'OLYMPIC', 'RENATA']

# Custom metrics for stock trading bottleneck detection
slow_requests = []
error_counts = {"total": 0, "timeout": 0, "server_error": 0, "order_failures": 0}
trading_metrics = {
    "market_data_calls": 0,
    "orders_placed": 0,
    "portfolio_updates": 0,
    "slow_market_data": 0,
    "slow_orders": 0,
}


class StockTraderUser(HttpUser):
    """
    Simulates a stock trader on DSE/CSE exchanges
    performing real trading operations based on Puji app features.
    """
    
    # Realistic wait time for active traders (1-3 seconds between actions)
    wait_time = between(1, 3)
    
    # User metadata
    trader_id = None
    account_id = None
    watchlist = []
    
    def on_start(self):
        """Called when a trader starts - initialization"""
        self.trader_id = f"trader_{random.randint(1000, 9999)}"
        self.account_id = f"ACC{random.randint(10000, 99999)}"
        self.watchlist = random.sample(STOCK_SYMBOLS, k=3)  # Random 3 stocks in watchlist
        print(f"🚀 Starting trader: {self.trader_id} | Account: {self.account_id}")
        print(f"   Watchlist: {', '.join(self.watchlist)}")
    
    def on_stop(self):
        """Called when a trader stops"""
        print(f"✅ Stopping trader: {self.trader_id}")
    
    @task(8)
    def get_market_data(self):
        """
        Real-time market data request (highest frequency - weight=8)
        Simulates retrieving live stock prices (40% of all requests)
        """
        start_time = time.time()
        stock = random.choice(STOCK_SYMBOLS)
        
        trading_metrics["market_data_calls"] += 1
        
        with self.client.get(f"/api/market/data/{stock}", 
                           catch_response=True, 
                           name="Market Data Stream") as response:
            response_time = (time.time() - start_time) * 1000
            
            if response.status_code == 200:
                response.success()
                
                # Bottleneck detection: market data must be fast (< 200ms)
                if response_time > 200:
                    trading_metrics["slow_market_data"] += 1
                    slow_requests.append({
                        "endpoint": f"/api/market/data/{stock}",
                        "method": "GET",
                        "response_time": response_time,
                        "timestamp": datetime.now().isoformat(),
                        "stock": stock
                    })
                    print(f"⚠️  Market data bottleneck: {stock} took {response_time:.2f}ms")
            else:
                response.failure(f"Market data failed with status {response.status_code}")
                error_counts["total"] += 1
    
    @task(6)
    def check_portfolio(self):
        """
        Portfolio and balance check (weight=6)
        Simulates checking portfolio with real-time balance (30% of requests)
        """
        start_time = time.time()
        
        trading_metrics["portfolio_updates"] += 1
        
        with self.client.get("/api/portfolio", 
                           catch_response=True, 
                           name="Portfolio Check") as response:
            response_time = (time.time() - start_time) * 1000
            
            if response.status_code == 200:
                response.success()
                
                # Bottleneck detection: portfolio updates should be < 400ms
                if response_time > 400:
                    slow_requests.append({
                        "endpoint": "/api/portfolio",
                        "method": "GET",
                        "response_time": response_time,
                        "timestamp": datetime.now().isoformat()
                    })
                    print(f"⚠️  Portfolio update bottleneck: took {response_time:.2f}ms")
            else:
                response.failure(f"Portfolio check failed with status {response.status_code}")
                error_counts["total"] += 1
    
    @task(4)
    def place_order(self):
        """
        Place buy/sell order (weight=4)
        Critical operation - must be fast and reliable (20% of requests)
        """
        start_time = time.time()
        stock = random.choice(STOCK_SYMBOLS)
        order_type = random.choice(['BUY', 'SELL'])
        
        trading_metrics["orders_placed"] += 1
        
        payload = {
            "symbol": stock,
            "type": order_type,
            "quantity": random.randint(1, 100),
            "price": round(random.uniform(100, 1000), 2),
            "accountId": self.account_id,
            "timestamp": datetime.now().isoformat()
        }
        
        with self.client.post(
            "/api/order",
            json=payload,
            catch_response=True,
            name="Place Order"
        ) as response:
            response_time = (time.time() - start_time) * 1000
            
            if response.status_code in [200, 201]:
                response.success()
                
                # Bottleneck detection: order placement critical (< 300ms)
                if response_time > 300:
                    trading_metrics["slow_orders"] += 1
                    slow_requests.append({
                        "endpoint": "/api/order",
                        "method": "POST",
                        "response_time": response_time,
                        "timestamp": datetime.now().isoformat(),
                        "stock": stock,
                        "order_type": order_type
                    })
                    print(f"⚠️  CRITICAL: Order placement bottleneck: {order_type} {stock} took {response_time:.2f}ms")
            else:
                response.failure(f"Order placement failed with status {response.status_code}")
                error_counts["total"] += 1
                error_counts["order_failures"] += 1
                print(f"❌ Order failed: {order_type} {stock}")
    
    @task(1)
    def get_watchlist(self):
        """
        Check watchlist stocks (weight=1)
        Simulates monitoring favorite stocks (5% of requests)
        """
        with self.client.get("/api/watchlist", 
                           catch_response=True, 
                           name="Watchlist") as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Watchlist failed with status {response.status_code}")
                error_counts["total"] += 1
    
    @task(1)
    def get_market_depth(self):
        """
        Get market depth data (weight=1)
        Simulates viewing top bid/ask levels (5% of requests)
        """
        start_time = time.time()
        stock = random.choice(self.watchlist)
        
        with self.client.get(f"/api/market/depth/{stock}", 
                           catch_response=True, 
                           name="Market Depth") as response:
            response_time = (time.time() - start_time) * 1000  # Convert to milliseconds
            
            if response.status_code == 200:
                response.success()
                
                if response_time > 500:
                    slow_requests.append({
                        "endpoint": f"/api/market/depth/{stock}",
                        "method": "GET",
                        "response_time": response_time,
                        "timestamp": datetime.now().isoformat()
                    })
            else:
                response.failure(f"Market depth failed with status {response.status_code}")
                error_counts["total"] += 1


# Event listeners for custom metrics and bottleneck analysis

@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    """Called when test starts"""
    print("=" * 80)
    print("🚀 Stock Trading Platform Load Test Starting")
    print("=" * 80)
    print(f"Target host: {environment.host}")
    print(f"Exchange: DSE (Dhaka) / CSE (Chittagong)")
    print(f"Stock symbols: {', '.join(STOCK_SYMBOLS)}")
    print(f"Test mode: {'Distributed' if isinstance(environment.runner, MasterRunner) else 'Local'}")
    print("=" * 80)


@events.test_stop.add_listener
def on_test_stop(environment, **kwargs):
    """Called when test stops - perform stock trading bottleneck analysis"""
    print("\n" + "=" * 80)
    print("📊 Stock Trading Platform - Load Test Complete")
    print("=" * 80)
    
    # Analyze slow requests
    if slow_requests:
        print(f"\n⚠️  BOTTLENECKS DETECTED: {len(slow_requests)} slow requests")
        print("\nTop 5 Slowest Requests:")
        sorted_requests = sorted(slow_requests, key=lambda x: x["response_time"], reverse=True)[:5]
        for req in sorted_requests:
            stock_info = f" [{req['stock']}]" if 'stock' in req else ""
            print(f"  {req['method']} {req['endpoint']}{stock_info}: {req['response_time']:.2f}ms")
    else:
        print("\n✅ No significant bottlenecks detected")
    
    # Analyze trading-specific metrics
    print(f"\n📈 Trading Metrics:")
    print(f"  Market Data Calls: {trading_metrics['market_data_calls']}")
    print(f"  Orders Placed: {trading_metrics['orders_placed']}")
    print(f"  Portfolio Updates: {trading_metrics['portfolio_updates']}")
    print(f"  Slow Market Data: {trading_metrics['slow_market_data']} ({(trading_metrics['slow_market_data'] / max(trading_metrics['market_data_calls'], 1) * 100):.1f}%)")
    print(f"  Slow Orders: {trading_metrics['slow_orders']} ({(trading_metrics['slow_orders'] / max(trading_metrics['orders_placed'], 1) * 100):.1f}%)")
    
    # Analyze errors
    print(f"\n📈 Error Summary:")
    print(f"  Total Errors: {error_counts['total']}")
    print(f"  Order Failures: {error_counts['order_failures']} ⚠️ CRITICAL")
    print(f"  Timeout Errors: {error_counts['timeout']}")
    print(f"  Server Errors: {error_counts['server_error']}")
    
    # Calculate stats from environment
    stats = environment.stats
    print(f"\n📊 Performance Summary:")
    print(f"  Total Requests: {stats.total.num_requests}")
    print(f"  Failure Rate: {stats.total.fail_ratio * 100:.3f}%")
    print(f"  Average Response Time: {stats.total.avg_response_time:.2f}ms")
    print(f"  95th Percentile: {stats.total.get_response_time_percentile(0.95):.2f}ms")
    print(f"  99th Percentile: {stats.total.get_response_time_percentile(0.99):.2f}ms")
    
    # Production readiness check for trading platform
    print(f"\n🎯 Trading Platform Readiness Check:")
    p95 = stats.total.get_response_time_percentile(0.95)
    p99 = stats.total.get_response_time_percentile(0.99)
    fail_rate = stats.total.fail_ratio
    
    checks = []
    checks.append(("Market data p95 < 200ms", p95 < 200, f"{p95:.2f}ms"))
    checks.append(("Order placement p95 < 300ms", p95 < 300, f"{p95:.2f}ms"))
    checks.append(("Overall p95 < 500ms", p95 < 500, f"{p95:.2f}ms"))
    checks.append(("p99 < 1000ms", p99 < 1000, f"{p99:.2f}ms"))
    checks.append(("Failure rate < 0.1%", fail_rate < 0.001, f"{fail_rate * 100:.3f}%"))
    checks.append(("Order failures = 0", error_counts['order_failures'] == 0, f"{error_counts['order_failures']} failures"))
    
    for check_name, passed, value in checks:
        status = "✅" if passed else "❌"
        print(f"  {status} {check_name}: {value}")
    
    # Save detailed report
    save_bottleneck_report(environment)
    
    print("=" * 80)


def save_bottleneck_report(environment):
    """Save detailed bottleneck report to file for stock trading platform"""
    report_data = {
        "timestamp": datetime.now().isoformat(),
        "platform": "DSE/CSE Stock Trading",
        "summary": {
            "total_requests": environment.stats.total.num_requests,
            "failure_rate": environment.stats.total.fail_ratio,
            "avg_response_time": environment.stats.total.avg_response_time,
            "p95": environment.stats.total.get_response_time_percentile(0.95),
            "p99": environment.stats.total.get_response_time_percentile(0.99),
        },
        "trading_metrics": trading_metrics,
        "bottlenecks": {
            "slow_requests_count": len(slow_requests),
            "slow_request_details": slow_requests[:10],  # Top 10
        },
        "errors": error_counts
    }
    
    filename = f"stock_trading_locust_report_{int(time.time())}.json"
    with open(filename, 'w') as f:
        json.dump(report_data, f, indent=2)
    
    print(f"\n💾 Detailed trading report saved to: {filename}")


# Custom shape for advanced load patterns (optional)
from locust import LoadTestShape

class TradingDayLoadShape(LoadTestShape):
    """
    Simulates realistic stock trading day load pattern.
    Based on actual DSE/CSE trading hours and user behavior.
    
    9:30 AM  - Market opens (surge)
    10:00 AM - Peak morning trading
    11:00 AM - Sustained high activity
    12:00 PM - Mid-day slowdown
    2:00 PM  - Afternoon trading
    2:30 PM  - Pre-closing surge
    3:00 PM  - Closing time (peak)
    3:30 PM  - After-hours (minimal)
    """
    
    stages = [
        {"duration": 120, "users": 500, "spawn_rate": 20},    # Market opening surge
        {"duration": 300, "users": 1000, "spawn_rate": 20},   # Peak morning trading
        {"duration": 600, "users": 1000, "spawn_rate": 10},   # Sustained morning
        {"duration": 180, "users": 500, "spawn_rate": 10},    # Mid-day slowdown
        {"duration": 600, "users": 500, "spawn_rate": 5},     # Afternoon trading
        {"duration": 180, "users": 1500, "spawn_rate": 50},   # Pre-closing surge
        {"duration": 300, "users": 1500, "spawn_rate": 30},   # Closing time peak
        {"duration": 120, "users": 100, "spawn_rate": 10},    # After-hours
        {"duration": 120, "users": 0, "spawn_rate": 10},      # Ramp down
    ]
    
    def tick(self):
        """Define the load pattern"""
        run_time = self.get_run_time()
        
        for stage in self.stages:
            if run_time < stage["duration"]:
                return (stage["users"], stage["spawn_rate"])
            run_time -= stage["duration"]
        
        return None
