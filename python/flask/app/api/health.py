from flask_restx import Namespace, Resource
from datetime import datetime

api = Namespace('health', description='Health check operations')


@api.route('')
class HealthCheck(Resource):
    @api.doc('health_check')
    def get(self):
        """Health check endpoint"""
        return {
            'status': 'healthy',
            'timestamp': datetime.utcnow().isoformat(),
            'service': 'production-flask-api'
        }


@api.route('/ready')
class ReadinessCheck(Resource):
    @api.doc('readiness_check')
    def get(self):
        """Readiness check endpoint"""
        # Add checks for database, external services, etc.
        return {
            'status': 'ready',
            'timestamp': datetime.utcnow().isoformat()
        }
