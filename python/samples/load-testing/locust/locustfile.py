"""
Locust Load Testing Script for Python Backend Applications

This script demonstrates load testing for DSE-BD and CSE-BD systems with:
- Concurrent user simulation
- Performance metrics collection
- Bottleneck detection
- Custom reporting

Usage:
    locust -f locustfile.py
    locust -f locustfile.py --headless -u 100 -r 10 --run-time 5m
    locust -f locustfile.py --host=http://your-api-url
"""

import time
import json
import random
from datetime import datetime
from locust import HttpUser, task, between, events
from locust.runners import MasterRunner, WorkerRunner

# Custom metrics for bottleneck detection
slow_requests = []
error_counts = {"total": 0, "timeout": 0, "server_error": 0}


class DSEBDUser(HttpUser):
    """
    Simulates a DSE-BD (Data Service Engineering - Backend) user
    performing typical data operations with realistic wait times.
    """
    
    # Wait between 1 and 3 seconds between tasks
    wait_time = between(1, 3)
    
    # User metadata
    user_id = None
    
    def on_start(self):
        """Called when a user starts - initialization code here"""
        self.user_id = f"user_{random.randint(1000, 9999)}"
        print(f"Starting user: {self.user_id}")
        
        # Perform initial health check
        self.health_check()
    
    def on_stop(self):
        """Called when a user stops"""
        print(f"Stopping user: {self.user_id}")
    
    def health_check(self):
        """Initial health check"""
        with self.client.get("/health", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Health check failed with status {response.status_code}")
    
    @task(3)
    def get_data(self):
        """
        GET request - Read operation (most common, weight=3)
        Simulates retrieving data from the API
        """
        start_time = time.time()
        
        with self.client.get("/api/data", catch_response=True, name="GET /api/data") as response:
            response_time = (time.time() - start_time) * 1000
            
            if response.status_code == 200:
                response.success()
                
                # Bottleneck detection: slow response
                if response_time > 500:
                    slow_requests.append({
                        "endpoint": "/api/data",
                        "method": "GET",
                        "response_time": response_time,
                        "timestamp": datetime.now().isoformat()
                    })
                    print(f"⚠️  Slow request detected: GET /api/data took {response_time:.2f}ms")
            else:
                response.failure(f"GET failed with status {response.status_code}")
                error_counts["total"] += 1
    
    @task(2)
    def create_data(self):
        """
        POST request - Create operation (weight=2)
        Simulates creating new data via the API
        """
        start_time = time.time()
        
        payload = {
            "name": f"Test_{self.user_id}_{int(time.time())}",
            "value": random.uniform(0, 1000),
            "timestamp": datetime.now().isoformat()
        }
        
        with self.client.post(
            "/api/data",
            json=payload,
            catch_response=True,
            name="POST /api/data"
        ) as response:
            response_time = (time.time() - start_time) * 1000
            
            if response.status_code in [200, 201]:
                response.success()
                
                # Bottleneck detection: slow write operation
                if response_time > 1000:
                    slow_requests.append({
                        "endpoint": "/api/data",
                        "method": "POST",
                        "response_time": response_time,
                        "timestamp": datetime.now().isoformat()
                    })
                    print(f"⚠️  Slow write detected: POST /api/data took {response_time:.2f}ms")
            else:
                response.failure(f"POST failed with status {response.status_code}")
                error_counts["total"] += 1
    
    @task(1)
    def database_query(self):
        """
        Database query operation (weight=1)
        Tests database performance - potential bottleneck
        """
        start_time = time.time()
        
        with self.client.get(
            "/api/database/query",
            catch_response=True,
            name="GET /api/database/query"
        ) as response:
            response_time = (time.time() - start_time) * 1000
            
            if response.status_code == 200:
                response.success()
                
                # Bottleneck detection: slow database query
                if response_time > 1000:
                    slow_requests.append({
                        "endpoint": "/api/database/query",
                        "method": "GET",
                        "response_time": response_time,
                        "timestamp": datetime.now().isoformat()
                    })
                    print(f"⚠️  Database bottleneck detected: Query took {response_time:.2f}ms")
            elif response.status_code == 504:
                response.failure("Database query timeout")
                error_counts["timeout"] += 1
                error_counts["total"] += 1
            else:
                response.failure(f"Database query failed with status {response.status_code}")
                error_counts["total"] += 1
    
    @task(2)
    def cache_operation(self):
        """
        Cache read operation (weight=2)
        Tests cache performance - should be very fast
        """
        start_time = time.time()
        
        with self.client.get(
            "/api/cache/data",
            catch_response=True,
            name="GET /api/cache/data"
        ) as response:
            response_time = (time.time() - start_time) * 1000
            
            if response.status_code == 200:
                response.success()
                
                # Bottleneck detection: slow cache (should be < 50ms)
                if response_time > 100:
                    slow_requests.append({
                        "endpoint": "/api/cache/data",
                        "method": "GET",
                        "response_time": response_time,
                        "timestamp": datetime.now().isoformat()
                    })
                    print(f"⚠️  Cache bottleneck detected: Read took {response_time:.2f}ms")
            else:
                response.failure(f"Cache operation failed with status {response.status_code}")
                error_counts["total"] += 1


class CSEBDUser(HttpUser):
    """
    Simulates a CSE-BD (Customer Service Engineering - Backend) user
    performing customer-facing operations with realistic patterns.
    """
    
    wait_time = between(2, 5)
    
    session_id = None
    
    def on_start(self):
        """Called when a user starts"""
        self.session_id = f"session_{random.randint(10000, 99999)}"
        print(f"Starting customer session: {self.session_id}")
    
    @task(5)
    def browse_data(self):
        """Browse operation - most common for customers (weight=5)"""
        with self.client.get("/api/data", name="Customer Browse") as response:
            if response.status_code != 200:
                print(f"Browse failed for session {self.session_id}")
    
    @task(2)
    def search_operation(self):
        """Search operation (weight=2)"""
        query = f"search_{random.choice(['product', 'service', 'info'])}"
        with self.client.get(f"/api/data?q={query}", name="Customer Search") as response:
            pass
    
    @task(1)
    def update_profile(self):
        """Update operation - less frequent (weight=1)"""
        payload = {
            "session": self.session_id,
            "action": "update",
            "timestamp": datetime.now().isoformat()
        }
        with self.client.post("/api/data", json=payload, name="Customer Update") as response:
            pass


# Event listeners for custom metrics and bottleneck analysis

@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    """Called when test starts"""
    print("=" * 80)
    print("🚀 Load Test Starting")
    print("=" * 80)
    print(f"Target host: {environment.host}")
    print(f"Test mode: {'Distributed' if isinstance(environment.runner, MasterRunner) else 'Local'}")
    print("=" * 80)


@events.test_stop.add_listener
def on_test_stop(environment, **kwargs):
    """Called when test stops - perform bottleneck analysis"""
    print("\n" + "=" * 80)
    print("📊 Load Test Complete - Bottleneck Analysis")
    print("=" * 80)
    
    # Analyze slow requests
    if slow_requests:
        print(f"\n⚠️  BOTTLENECKS DETECTED: {len(slow_requests)} slow requests")
        print("\nTop 5 Slowest Requests:")
        sorted_requests = sorted(slow_requests, key=lambda x: x["response_time"], reverse=True)[:5]
        for req in sorted_requests:
            print(f"  {req['method']} {req['endpoint']}: {req['response_time']:.2f}ms")
    else:
        print("\n✅ No significant bottlenecks detected")
    
    # Analyze errors
    print(f"\n📈 Error Summary:")
    print(f"  Total Errors: {error_counts['total']}")
    print(f"  Timeout Errors: {error_counts['timeout']}")
    print(f"  Server Errors: {error_counts['server_error']}")
    
    # Calculate stats from environment
    stats = environment.stats
    print(f"\n📊 Performance Summary:")
    print(f"  Total Requests: {stats.total.num_requests}")
    print(f"  Failure Rate: {stats.total.fail_ratio * 100:.2f}%")
    print(f"  Average Response Time: {stats.total.avg_response_time:.2f}ms")
    print(f"  95th Percentile: {stats.total.get_response_time_percentile(0.95):.2f}ms")
    print(f"  99th Percentile: {stats.total.get_response_time_percentile(0.99):.2f}ms")
    
    # Production readiness check
    print(f"\n🎯 Production Readiness Check:")
    p95 = stats.total.get_response_time_percentile(0.95)
    p99 = stats.total.get_response_time_percentile(0.99)
    fail_rate = stats.total.fail_ratio
    
    checks = []
    checks.append(("95th percentile < 500ms", p95 < 500, f"{p95:.2f}ms"))
    checks.append(("99th percentile < 1000ms", p99 < 1000, f"{p99:.2f}ms"))
    checks.append(("Failure rate < 1%", fail_rate < 0.01, f"{fail_rate * 100:.2f}%"))
    
    for check_name, passed, value in checks:
        status = "✅" if passed else "❌"
        print(f"  {status} {check_name}: {value}")
    
    # Save detailed report
    save_bottleneck_report(environment)
    
    print("=" * 80)


def save_bottleneck_report(environment):
    """Save detailed bottleneck report to file"""
    report_data = {
        "timestamp": datetime.now().isoformat(),
        "summary": {
            "total_requests": environment.stats.total.num_requests,
            "failure_rate": environment.stats.total.fail_ratio,
            "avg_response_time": environment.stats.total.avg_response_time,
            "p95": environment.stats.total.get_response_time_percentile(0.95),
            "p99": environment.stats.total.get_response_time_percentile(0.99),
        },
        "bottlenecks": {
            "slow_requests": len(slow_requests),
            "slow_request_details": slow_requests[:10],  # Top 10
        },
        "errors": error_counts
    }
    
    filename = f"locust_report_{int(time.time())}.json"
    with open(filename, 'w') as f:
        json.dump(report_data, f, indent=2)
    
    print(f"\n💾 Detailed report saved to: {filename}")


# Custom shape for advanced load patterns (optional)
from locust import LoadTestShape

class StagesLoadShape(LoadTestShape):
    """
    A custom load shape that follows k6-style stages pattern.
    Useful for simulating realistic load patterns.
    """
    
    stages = [
        {"duration": 60, "users": 50, "spawn_rate": 5},    # Ramp to 50 users
        {"duration": 180, "users": 100, "spawn_rate": 5},  # Ramp to 100 users
        {"duration": 300, "users": 100, "spawn_rate": 5},  # Stay at 100 users
        {"duration": 120, "users": 200, "spawn_rate": 10}, # Spike to 200 users
        {"duration": 120, "users": 200, "spawn_rate": 10}, # Stay at 200 users
        {"duration": 120, "users": 0, "spawn_rate": 10},   # Ramp down
    ]
    
    def tick(self):
        """Define the load pattern"""
        run_time = self.get_run_time()
        
        for stage in self.stages:
            if run_time < stage["duration"]:
                return (stage["users"], stage["spawn_rate"])
            run_time -= stage["duration"]
        
        return None
