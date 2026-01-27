import graphene
from graphene import relay
from graphene_sqlalchemy import SQLAlchemyObjectType
from app.models import db, User as UserModel, Task as TaskModel


# GraphQL Types
class User(SQLAlchemyObjectType):
    class Meta:
        model = UserModel
        interfaces = (relay.Node,)


class Task(SQLAlchemyObjectType):
    class Meta:
        model = TaskModel
        interfaces = (relay.Node,)


# Queries
class Query(graphene.ObjectType):
    node = relay.Node.Field()
    all_users = graphene.List(User)
    all_tasks = graphene.List(Task)
    user = graphene.Field(User, id=graphene.Int())
    task = graphene.Field(Task, id=graphene.Int())
    
    def resolve_all_users(self, info):
        return UserModel.query.all()
    
    def resolve_all_tasks(self, info):
        return TaskModel.query.all()
    
    def resolve_user(self, info, id):
        return UserModel.query.get(id)
    
    def resolve_task(self, info, id):
        return TaskModel.query.get(id)


# Mutations
class CreateUser(graphene.Mutation):
    class Arguments:
        username = graphene.String(required=True)
        email = graphene.String(required=True)
    
    user = graphene.Field(lambda: User)
    
    def mutate(self, info, username, email):
        user = UserModel(username=username, email=email)
        db.session.add(user)
        db.session.commit()
        return CreateUser(user=user)


class CreateTask(graphene.Mutation):
    class Arguments:
        title = graphene.String(required=True)
        description = graphene.String()
        completed = graphene.Boolean()
        user_id = graphene.Int()
    
    task = graphene.Field(lambda: Task)
    
    def mutate(self, info, title, description=None, completed=False, user_id=None):
        task = TaskModel(
            title=title,
            description=description,
            completed=completed,
            user_id=user_id
        )
        db.session.add(task)
        db.session.commit()
        return CreateTask(task=task)


class UpdateTask(graphene.Mutation):
    class Arguments:
        id = graphene.Int(required=True)
        title = graphene.String()
        description = graphene.String()
        completed = graphene.Boolean()
    
    task = graphene.Field(lambda: Task)
    
    def mutate(self, info, id, title=None, description=None, completed=None):
        task = TaskModel.query.get(id)
        if not task:
            raise Exception('Task not found')
        
        if title is not None:
            task.title = title
        if description is not None:
            task.description = description
        if completed is not None:
            task.completed = completed
        
        db.session.commit()
        return UpdateTask(task=task)


class Mutation(graphene.ObjectType):
    create_user = CreateUser.Field()
    create_task = CreateTask.Field()
    update_task = UpdateTask.Field()


# Schema
schema = graphene.Schema(query=Query, mutation=Mutation)
