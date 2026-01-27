from flask import Blueprint
from flask_restx import Api

from .users import api as users_ns
from .tasks import api as tasks_ns
from .health import api as health_ns

# Create Blueprint
blueprint = Blueprint('api', __name__, url_prefix='/api/v1')

# Create API with Swagger documentation
api = Api(
    blueprint,
    title='Production Flask API',
    version='1.0',
    description='A production-ready Flask REST API with Swagger documentation',
    doc='/docs'
)

# Register namespaces
api.add_namespace(health_ns, path='/health')
api.add_namespace(users_ns, path='/users')
api.add_namespace(tasks_ns, path='/tasks')
