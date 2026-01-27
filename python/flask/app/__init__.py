import os
import logging
from logging.handlers import RotatingFileHandler
from pythonjsonlogger import jsonlogger
from flask import Flask, render_template
from flask_cors import CORS
from flask_migrate import Migrate
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_talisman import Talisman
from prometheus_flask_exporter import PrometheusMetrics

from config import config
from app.models import db
from app.api import blueprint as api_blueprint


def setup_logging(app):
    """Configure structured logging"""
    if app.config['LOG_FORMAT'] == 'json':
        formatter = jsonlogger.JsonFormatter(
            '%(asctime)s %(name)s %(levelname)s %(message)s'
        )
    else:
        formatter = logging.Formatter(
            '[%(asctime)s] %(levelname)s in %(module)s: %(message)s'
        )
    
    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    console_handler.setLevel(getattr(logging, app.config['LOG_LEVEL']))
    
    # File handler
    if not os.path.exists('logs'):
        os.makedirs('logs')
    file_handler = RotatingFileHandler(
        'logs/app.log',
        maxBytes=10485760,  # 10MB
        backupCount=10
    )
    file_handler.setFormatter(formatter)
    file_handler.setLevel(getattr(logging, app.config['LOG_LEVEL']))
    
    # Configure app logger
    app.logger.addHandler(console_handler)
    app.logger.addHandler(file_handler)
    app.logger.setLevel(getattr(logging, app.config['LOG_LEVEL']))


def create_app(config_name='default'):
    """Application factory pattern"""
    app = Flask(__name__)
    
    # Load configuration
    app.config.from_object(config[config_name])
    
    # Setup logging
    setup_logging(app)
    app.logger.info(f'Starting application with {config_name} configuration')
    
    # Initialize extensions
    db.init_app(app)
    migrate = Migrate(app, db)
    
    # CORS
    CORS(app, origins=app.config['CORS_ORIGINS'].split(','))
    
    # Rate limiting
    limiter = Limiter(
        app=app,
        key_func=get_remote_address,
        default_limits=["100 per hour"],
        storage_uri=app.config['RATELIMIT_STORAGE_URL']
    )
    
    # Security headers (disable in development for easier testing)
    if not app.config['DEBUG']:
        Talisman(app, force_https=False)  # Set force_https=True in production with HTTPS
    
    # Prometheus metrics
    if app.config['ENABLE_METRICS']:
        metrics = PrometheusMetrics(app)
        metrics.info('app_info', 'Application info', version='1.0.0')
    
    # Register blueprints
    app.register_blueprint(api_blueprint)
    
    # GraphQL endpoint
    from flask import request, jsonify
    from graphql import graphql_sync
    from app.graphql_service import graphql_schema
    
    @app.route('/graphql', methods=['GET', 'POST'])
    def graphql_endpoint():
        # Get GraphQL query from request
        if request.method == 'POST':
            data = request.get_json()
            query = data.get('query', '')
            variables = data.get('variables')
        else:
            query = request.args.get('query', '')
            variables = None
        
        # Execute query
        result = graphql_sync(graphql_schema, query, variable_values=variables)
        
        # Return response
        response = {}
        if result.data:
            response['data'] = result.data
        if result.errors:
            response['errors'] = [str(error) for error in result.errors]
        
        return jsonify(response)
    
    # Main routes
    @app.route('/')
    def index():
        return render_template('index.html')
    
    @app.route('/api-tester')
    def api_tester():
        """GUI for testing APIs"""
        return render_template('api_tester.html')
    
    # Error handlers
    @app.errorhandler(404)
    def not_found(error):
        return {'error': 'Not found'}, 404
    
    @app.errorhandler(500)
    def internal_error(error):
        app.logger.error(f'Internal error: {error}')
        db.session.rollback()
        return {'error': 'Internal server error'}, 500
    
    # Create tables
    with app.app_context():
        db.create_all()
        app.logger.info('Database tables created')
    
    return app
