#!/usr/bin/env python3
"""
Main application entry point
"""
import os
from app import create_app

# Get configuration from environment
config_name = os.getenv('FLASK_ENV', 'development')

# Create application instance
app = create_app(config_name)

if __name__ == '__main__':
    host = app.config['HOST']
    port = app.config['PORT']
    debug = app.config['DEBUG']
    
    app.logger.info(f'Starting Flask server on {host}:{port}')
    app.run(host=host, port=port, debug=debug)
