from flask import request
from flask_restx import Namespace, Resource, fields
from app.models import db, Task

api = Namespace('tasks', description='Task operations')

# Define models for Swagger documentation
task_model = api.model('Task', {
    'id': fields.Integer(readonly=True, description='Task ID'),
    'title': fields.String(required=True, description='Task title'),
    'description': fields.String(description='Task description'),
    'completed': fields.Boolean(description='Completion status'),
    'user_id': fields.Integer(description='Associated user ID'),
    'created_at': fields.DateTime(readonly=True, description='Creation timestamp'),
    'updated_at': fields.DateTime(readonly=True, description='Last update timestamp')
})

task_input = api.model('TaskInput', {
    'title': fields.String(required=True, description='Task title'),
    'description': fields.String(description='Task description'),
    'completed': fields.Boolean(description='Completion status', default=False),
    'user_id': fields.Integer(description='Associated user ID')
})


@api.route('')
class TaskList(Resource):
    @api.doc('list_tasks')
    @api.marshal_list_with(task_model)
    def get(self):
        """List all tasks"""
        tasks = Task.query.all()
        return [task.to_dict() for task in tasks]
    
    @api.doc('create_task')
    @api.expect(task_input)
    @api.marshal_with(task_model, code=201)
    def post(self):
        """Create a new task"""
        data = request.json
        task = Task(
            title=data['title'],
            description=data.get('description'),
            completed=data.get('completed', False),
            user_id=data.get('user_id')
        )
        db.session.add(task)
        db.session.commit()
        return task.to_dict(), 201


@api.route('/<int:id>')
@api.param('id', 'Task identifier')
class TaskDetail(Resource):
    @api.doc('get_task')
    @api.marshal_with(task_model)
    def get(self, id):
        """Get a task by ID"""
        task = Task.query.get_or_404(id)
        return task.to_dict()
    
    @api.doc('update_task')
    @api.expect(task_input)
    @api.marshal_with(task_model)
    def put(self, id):
        """Update a task"""
        task = Task.query.get_or_404(id)
        data = request.json
        task.title = data.get('title', task.title)
        task.description = data.get('description', task.description)
        task.completed = data.get('completed', task.completed)
        task.user_id = data.get('user_id', task.user_id)
        db.session.commit()
        return task.to_dict()
    
    @api.doc('delete_task')
    @api.response(204, 'Task deleted')
    def delete(self, id):
        """Delete a task"""
        task = Task.query.get_or_404(id)
        db.session.delete(task)
        db.session.commit()
        return '', 204
