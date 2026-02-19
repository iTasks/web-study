"""
Sample Python Backend API for Locust Load Testing

A Flask-based API that simulates typical DSE-BD/CSE-BD microservice operations:
- Health checks
- CRUD operations
- Database simulation
- Caching layer
- Metrics endpoints

Run with:
    python sample_backend_api.py
    
Or with production server:
    gunicorn -w 4 -b 0.0.0.0:5000 sample_backend_api:app
"""

from flask import Flask, request, jsonify
from datetime import datetime
import time
import random
import uuid
import threading

app = Flask(__name__)

# In-memory data store (simulates database)
data_store = {}
cache_store = {}

# Metrics tracking
metrics = {
    "total_requests": 0,
    "total_errors": 0,
    "request_times": [],
}
metrics_lock = threading.Lock()


def record_metric(response_time):
    """Record request metrics"""
    with metrics_lock:
        metrics["total_requests"] += 1
        metrics["request_times"].append(response_time)
        # Keep only last 1000 entries
        if len(metrics["request_times"]) > 1000:
            metrics["request_times"] = metrics["request_times"][-1000:]


def record_error():
    """Record error"""
    with metrics_lock:
        metrics["total_errors"] += 1


# Initialize with sample data
def init_data():
    """Initialize data store with sample data"""
    for i in range(100):
        item_id = str(uuid.uuid4())
        data_store[item_id] = {
            "id": item_id,
            "name": f"Item_{i}",
            "value": random.random() * 1000,
            "timestamp": datetime.utcnow().isoformat()
        }
    
    # Initialize cache
    cache_store["sample"] = {"message": "cached data", "timestamp": datetime.utcnow().isoformat()}


init_data()


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat()
    }), 200


@app.route('/ready', methods=['GET'])
def readiness_check():
    """Readiness check endpoint"""
    return jsonify({
        "ready": True,
        "timestamp": datetime.utcnow().isoformat()
    }), 200


@app.route('/api/data', methods=['GET'])
def get_data():
    """
    GET endpoint - Retrieve data
    Simulates read operations with realistic processing time
    """
    start_time = time.time()
    
    # Simulate some processing time (10-50ms)
    time.sleep(random.uniform(0.01, 0.05))
    
    # Get query parameters
    query = request.args.get('q', '')
    limit = int(request.args.get('limit', 10))
    
    # Filter data if query provided
    if query:
        filtered_data = [
            item for item in data_store.values()
            if query.lower() in item["name"].lower()
        ]
    else:
        filtered_data = list(data_store.values())
    
    # Limit results
    result = filtered_data[:limit]
    
    response_time = (time.time() - start_time) * 1000
    record_metric(response_time)
    
    return jsonify({
        "count": len(result),
        "data": result,
        "timestamp": datetime.utcnow().isoformat()
    }), 200


@app.route('/api/data', methods=['POST'])
def create_data():
    """
    POST endpoint - Create data
    Simulates write operations with realistic processing time
    """
    start_time = time.time()
    
    try:
        # Simulate some processing time (20-100ms)
        time.sleep(random.uniform(0.02, 0.1))
        
        payload = request.get_json()
        
        if not payload:
            record_error()
            return jsonify({"error": "No data provided"}), 400
        
        # Create new item
        item_id = str(uuid.uuid4())
        data_store[item_id] = {
            "id": item_id,
            "name": payload.get("name", "Unnamed"),
            "value": payload.get("value", 0),
            "timestamp": datetime.utcnow().isoformat()
        }
        
        response_time = (time.time() - start_time) * 1000
        record_metric(response_time)
        
        return jsonify({
            "success": True,
            "id": item_id,
            "timestamp": datetime.utcnow().isoformat()
        }), 201
        
    except Exception as e:
        record_error()
        return jsonify({"error": str(e)}), 500


@app.route('/api/database/query', methods=['GET'])
def database_query():
    """
    Database query simulation - potential bottleneck
    Simulates database query with variable response time
    """
    start_time = time.time()
    
    # Simulate database query time (100-300ms)
    query_time = random.uniform(0.1, 0.3)
    time.sleep(query_time)
    
    response_time = (time.time() - start_time) * 1000
    record_metric(response_time)
    
    return jsonify({
        "records": random.randint(100, 1000),
        "query_time_ms": query_time * 1000,
        "timestamp": datetime.utcnow().isoformat()
    }), 200


@app.route('/api/cache/data', methods=['GET'])
def cache_operation():
    """
    Cache operation - should be very fast
    Simulates cache read with minimal latency
    """
    start_time = time.time()
    
    # Simulate fast cache read (5-20ms)
    time.sleep(random.uniform(0.005, 0.02))
    
    cached_data = cache_store.get("sample", {})
    
    response_time = (time.time() - start_time) * 1000
    record_metric(response_time)
    
    return jsonify({
        "cached": True,
        "data": cached_data,
        "timestamp": datetime.utcnow().isoformat()
    }), 200


@app.route('/metrics', methods=['GET'])
def get_metrics():
    """
    Metrics endpoint
    Returns application metrics for monitoring
    """
    with metrics_lock:
        avg_response_time = sum(metrics["request_times"]) / len(metrics["request_times"]) if metrics["request_times"] else 0
        
        return jsonify({
            "total_requests": metrics["total_requests"],
            "total_errors": metrics["total_errors"],
            "avg_response_time_ms": avg_response_time,
            "data_count": len(data_store),
            "cache_count": len(cache_store),
            "timestamp": datetime.utcnow().isoformat()
        }), 200


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    record_error()
    return jsonify({"error": "Not found"}), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    record_error()
    return jsonify({"error": "Internal server error"}), 500


if __name__ == '__main__':
    print("=" * 80)
    print("🚀 Starting Sample Python Backend API")
    print("=" * 80)
    print("Server: http://localhost:5000")
    print("Health: http://localhost:5000/health")
    print("Metrics: http://localhost:5000/metrics")
    print("=" * 80)
    print("\nReady for Locust load testing!")
    print("Run: locust -f locustfile.py --host=http://localhost:5000")
    print("=" * 80)
    
    # Run Flask development server
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
