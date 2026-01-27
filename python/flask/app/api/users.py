from flask import request
from flask_restx import Namespace, Resource, fields
from app.models import db, User

api = Namespace('users', description='User operations')

# Define models for Swagger documentation
user_model = api.model('User', {
    'id': fields.Integer(readonly=True, description='User ID'),
    'username': fields.String(required=True, description='Username'),
    'email': fields.String(required=True, description='Email address'),
    'created_at': fields.DateTime(readonly=True, description='Creation timestamp'),
    'updated_at': fields.DateTime(readonly=True, description='Last update timestamp')
})

user_input = api.model('UserInput', {
    'username': fields.String(required=True, description='Username'),
    'email': fields.String(required=True, description='Email address')
})


@api.route('')
class UserList(Resource):
    @api.doc('list_users')
    @api.marshal_list_with(user_model)
    def get(self):
        """List all users"""
        users = User.query.all()
        return [user.to_dict() for user in users]
    
    @api.doc('create_user')
    @api.expect(user_input)
    @api.marshal_with(user_model, code=201)
    def post(self):
        """Create a new user"""
        data = request.json
        user = User(username=data['username'], email=data['email'])
        db.session.add(user)
        db.session.commit()
        return user.to_dict(), 201


@api.route('/<int:id>')
@api.param('id', 'User identifier')
class UserDetail(Resource):
    @api.doc('get_user')
    @api.marshal_with(user_model)
    def get(self, id):
        """Get a user by ID"""
        user = User.query.get_or_404(id)
        return user.to_dict()
    
    @api.doc('update_user')
    @api.expect(user_input)
    @api.marshal_with(user_model)
    def put(self, id):
        """Update a user"""
        user = User.query.get_or_404(id)
        data = request.json
        user.username = data.get('username', user.username)
        user.email = data.get('email', user.email)
        db.session.commit()
        return user.to_dict()
    
    @api.doc('delete_user')
    @api.response(204, 'User deleted')
    def delete(self, id):
        """Delete a user"""
        user = User.query.get_or_404(id)
        db.session.delete(user)
        db.session.commit()
        return '', 204
