import grpc
from concurrent import futures
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from app.models import db, User, Task
from app import create_app

# Import generated protobuf files
try:
    import service_pb2
    import service_pb2_grpc
except ImportError:
    print("Error: gRPC files not generated. Run: python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. service.proto")
    sys.exit(1)


class UserServicer(service_pb2_grpc.UserServiceServicer):
    def __init__(self, app):
        self.app = app
    
    def GetUser(self, request, context):
        with self.app.app_context():
            user = User.query.get(request.id)
            if not user:
                context.set_code(grpc.StatusCode.NOT_FOUND)
                context.set_details('User not found')
                return service_pb2.UserResponse()
            
            user_msg = service_pb2.User(
                id=user.id,
                username=user.username,
                email=user.email,
                created_at=user.created_at.isoformat() if user.created_at else ''
            )
            return service_pb2.UserResponse(user=user_msg)
    
    def ListUsers(self, request, context):
        with self.app.app_context():
            users = User.query.all()
            user_list = []
            for user in users:
                user_msg = service_pb2.User(
                    id=user.id,
                    username=user.username,
                    email=user.email,
                    created_at=user.created_at.isoformat() if user.created_at else ''
                )
                user_list.append(user_msg)
            return service_pb2.ListUsersResponse(users=user_list)
    
    def CreateUser(self, request, context):
        with self.app.app_context():
            user = User(username=request.username, email=request.email)
            db.session.add(user)
            db.session.commit()
            
            user_msg = service_pb2.User(
                id=user.id,
                username=user.username,
                email=user.email,
                created_at=user.created_at.isoformat() if user.created_at else ''
            )
            return service_pb2.UserResponse(user=user_msg)


class TaskServicer(service_pb2_grpc.TaskServiceServicer):
    def __init__(self, app):
        self.app = app
    
    def GetTask(self, request, context):
        with self.app.app_context():
            task = Task.query.get(request.id)
            if not task:
                context.set_code(grpc.StatusCode.NOT_FOUND)
                context.set_details('Task not found')
                return service_pb2.TaskResponse()
            
            task_msg = service_pb2.Task(
                id=task.id,
                title=task.title,
                description=task.description or '',
                completed=task.completed,
                user_id=task.user_id or 0,
                created_at=task.created_at.isoformat() if task.created_at else ''
            )
            return service_pb2.TaskResponse(task=task_msg)
    
    def ListTasks(self, request, context):
        with self.app.app_context():
            tasks = Task.query.all()
            task_list = []
            for task in tasks:
                task_msg = service_pb2.Task(
                    id=task.id,
                    title=task.title,
                    description=task.description or '',
                    completed=task.completed,
                    user_id=task.user_id or 0,
                    created_at=task.created_at.isoformat() if task.created_at else ''
                )
                task_list.append(task_msg)
            return service_pb2.ListTasksResponse(tasks=task_list)
    
    def CreateTask(self, request, context):
        with self.app.app_context():
            task = Task(
                title=request.title,
                description=request.description,
                completed=request.completed,
                user_id=request.user_id if request.user_id > 0 else None
            )
            db.session.add(task)
            db.session.commit()
            
            task_msg = service_pb2.Task(
                id=task.id,
                title=task.title,
                description=task.description or '',
                completed=task.completed,
                user_id=task.user_id or 0,
                created_at=task.created_at.isoformat() if task.created_at else ''
            )
            return service_pb2.TaskResponse(task=task_msg)


def serve(app, port=50051):
    """Start the gRPC server"""
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    service_pb2_grpc.add_UserServiceServicer_to_server(UserServicer(app), server)
    service_pb2_grpc.add_TaskServiceServicer_to_server(TaskServicer(app), server)
    server.add_insecure_port(f'[::]:{port}')
    server.start()
    print(f'gRPC server started on port {port}')
    return server


if __name__ == '__main__':
    app = create_app()
    server = serve(app)
    try:
        server.wait_for_termination()
    except KeyboardInterrupt:
        print('\nShutting down gRPC server...')
        server.stop(0)
