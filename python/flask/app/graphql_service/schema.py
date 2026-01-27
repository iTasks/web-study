from graphql import (
    GraphQLSchema,
    GraphQLObjectType,
    GraphQLField,
    GraphQLArgument,
    GraphQLList,
    GraphQLInt,
    GraphQLString,
    GraphQLBoolean,
    GraphQLNonNull,
)
from app.models import db, User as UserModel, Task as TaskModel


# User Type
UserType = GraphQLObjectType(
    'User',
    lambda: {
        'id': GraphQLField(GraphQLInt),
        'username': GraphQLField(GraphQLString),
        'email': GraphQLField(GraphQLString),
        'created_at': GraphQLField(GraphQLString),
        'updated_at': GraphQLField(GraphQLString),
    }
)


# Task Type
TaskType = GraphQLObjectType(
    'Task',
    lambda: {
        'id': GraphQLField(GraphQLInt),
        'title': GraphQLField(GraphQLString),
        'description': GraphQLField(GraphQLString),
        'completed': GraphQLField(GraphQLBoolean),
        'user_id': GraphQLField(GraphQLInt),
        'created_at': GraphQLField(GraphQLString),
        'updated_at': GraphQLField(GraphQLString),
    }
)


# Resolvers
def resolve_all_users(obj, info):
    users = db.session.query(UserModel).all()
    return [user.to_dict() for user in users]


def resolve_all_tasks(obj, info):
    tasks = db.session.query(TaskModel).all()
    return [task.to_dict() for task in tasks]


def resolve_user(obj, info, id):
    user = db.session.query(UserModel).get(id)
    return user.to_dict() if user else None


def resolve_task(obj, info, id):
    task = db.session.query(TaskModel).get(id)
    return task.to_dict() if task else None


def resolve_create_user(obj, info, username, email):
    user = UserModel(username=username, email=email)
    db.session.add(user)
    db.session.commit()
    return {'user': user.to_dict()}


def resolve_create_task(obj, info, title, description=None, completed=False, user_id=None):
    task = TaskModel(
        title=title,
        description=description,
        completed=completed,
        user_id=user_id
    )
    db.session.add(task)
    db.session.commit()
    return {'task': task.to_dict()}


# Query Type
QueryType = GraphQLObjectType(
    'Query',
    lambda: {
        'allUsers': GraphQLField(
            GraphQLList(UserType),
            resolve=resolve_all_users
        ),
        'allTasks': GraphQLField(
            GraphQLList(TaskType),
            resolve=resolve_all_tasks
        ),
        'user': GraphQLField(
            UserType,
            args={'id': GraphQLArgument(GraphQLNonNull(GraphQLInt))},
            resolve=resolve_user
        ),
        'task': GraphQLField(
            TaskType,
            args={'id': GraphQLArgument(GraphQLNonNull(GraphQLInt))},
            resolve=resolve_task
        ),
    }
)


# Mutation Result Types
CreateUserResultType = GraphQLObjectType(
    'CreateUserResult',
    lambda: {
        'user': GraphQLField(UserType),
    }
)


CreateTaskResultType = GraphQLObjectType(
    'CreateTaskResult',
    lambda: {
        'task': GraphQLField(TaskType),
    }
)


# Mutation Type
MutationType = GraphQLObjectType(
    'Mutation',
    lambda: {
        'createUser': GraphQLField(
            CreateUserResultType,
            args={
                'username': GraphQLArgument(GraphQLNonNull(GraphQLString)),
                'email': GraphQLArgument(GraphQLNonNull(GraphQLString)),
            },
            resolve=resolve_create_user
        ),
        'createTask': GraphQLField(
            CreateTaskResultType,
            args={
                'title': GraphQLArgument(GraphQLNonNull(GraphQLString)),
                'description': GraphQLArgument(GraphQLString),
                'completed': GraphQLArgument(GraphQLBoolean),
                'user_id': GraphQLArgument(GraphQLInt),
            },
            resolve=resolve_create_task
        ),
    }
)


# Schema
graphql_schema = GraphQLSchema(query=QueryType, mutation=MutationType)
