# Simple Python Flask Application
from flask import Flask, jsonify, request
import os
from datetime import datetime

app = Flask(__name__)

# Configuration from environment variables
PORT = int(os.getenv('PORT', 5000))
ENV = os.getenv('ENV', 'development')

@app.route('/')
def home():
    return jsonify({
        'message': 'Hello from Docker!',
        'environment': ENV,
        'timestamp': datetime.now().isoformat(),
        'app': 'Simple Flask App'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/info')
def info():
    return jsonify({
        'hostname': os.getenv('HOSTNAME', 'unknown'),
        'env': ENV,
        'port': PORT
    })

@app.route('/echo', methods=['POST'])
def echo():
    data = request.get_json()
    return jsonify({
        'received': data,
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    print(f"Starting Flask app in {ENV} mode on port {PORT}")
    app.run(host='0.0.0.0', port=PORT, debug=(ENV == 'development'))
