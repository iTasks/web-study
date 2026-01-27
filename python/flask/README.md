# Production-Ready Flask Application

A comprehensive, production-ready Flask application with REST API, gRPC, GraphQL, database integration, observability, and testing tools.

## 🚀 Features

- **REST API** - Full-featured REST API with Swagger/OpenAPI documentation
- **gRPC Service** - High-performance gRPC server for efficient communication
- **GraphQL API** - Flexible GraphQL API with GraphiQL interface
- **Database** - SQLAlchemy ORM with migration support
- **Observability** - Prometheus metrics and health checks
- **Logging** - Structured JSON logging for production
- **Security** - Rate limiting, CORS, and security headers
- **CLI Tools** - Console-based API testing tools
- **GUI** - Web-based API testing interface
- **Docker** - Containerization with Docker and Docker Compose

## 📋 Prerequisites

- Python 3.8 or higher
- pip package manager
- Virtual environment (recommended)
- Docker (optional, for containerized deployment)

## 🔧 Installation

### 1. Clone and Navigate
```bash
cd python/flask
```

### 2. Create Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Setup Environment Variables
```bash
cp .env.example .env
# Edit .env file with your configuration
```

### 5. Generate gRPC Files
```bash
cd app/grpc_service
python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. service.proto
cd ../..
```

## 🏃 Running the Application

### Development Server (REST & GraphQL)
```bash
python run.py
```

The server will start on `http://localhost:5000`

### Production Server
```bash
gunicorn -w 4 -b 0.0.0.0:5000 --timeout 120 run:app
```

### gRPC Server (separate terminal)
```bash
python -m app.grpc_service.server
```

The gRPC server will start on `localhost:50051`

### Docker Deployment
```bash
# Build and run with Docker Compose
docker-compose up --build

# Run in detached mode
docker-compose up -d
```

## 📚 API Documentation

### REST API
- **Swagger UI**: http://localhost:5000/api/v1/docs
- **Health Check**: http://localhost:5000/api/v1/health
- **Users Endpoint**: http://localhost:5000/api/v1/users
- **Tasks Endpoint**: http://localhost:5000/api/v1/tasks

### GraphQL
- **GraphiQL Interface**: http://localhost:5000/graphql

Example Query:
```graphql
{
  allUsers {
    id
    username
    email
  }
}
```

Example Mutation:
```graphql
mutation {
  createUser(username: "john", email: "john@example.com") {
    user {
      id
      username
      email
    }
  }
}
```

### gRPC
gRPC service running on `localhost:50051` with:
- UserService (GetUser, ListUsers, CreateUser)
- TaskService (GetTask, ListTasks, CreateTask)

## 🧪 Testing APIs

### Web GUI
Visit http://localhost:5000/api-tester for an interactive API testing interface

### CLI Tools

#### REST API Testing
```bash
# List all users
python -m app.cli.api_client rest list-users

# Create a user
python -m app.cli.api_client rest create-user

# List tasks
python -m app.cli.api_client rest list-tasks

# Create a task
python -m app.cli.api_client rest create-task

# Health check
python -m app.cli.api_client health
```

#### GraphQL Testing
```bash
# Query users via GraphQL
python -m app.cli.api_client graphql query-users

# Create user via GraphQL mutation
python -m app.cli.api_client graphql create-user-mutation
```

#### gRPC Testing
```bash
# List users via gRPC
python -m app.cli.grpc_client list-users

# Create user via gRPC
python -m app.cli.grpc_client create-user

# List tasks via gRPC
python -m app.cli.grpc_client list-tasks
```

## 📊 Monitoring & Observability

### Prometheus Metrics
Access metrics at: http://localhost:5000/metrics

### Health Checks
- **Liveness**: http://localhost:5000/api/v1/health
- **Readiness**: http://localhost:5000/api/v1/health/ready

### Logs
Logs are stored in the `logs/` directory with structured JSON format for easy parsing.

## 🏗️ Project Structure

```
flask/
├── app/
│   ├── __init__.py           # Application factory
│   ├── api/                  # REST API endpoints
│   │   ├── __init__.py
│   │   ├── health.py
│   │   ├── users.py
│   │   └── tasks.py
│   ├── models/               # Database models
│   │   ├── __init__.py
│   │   └── models.py
│   ├── grpc_service/         # gRPC service
│   │   ├── service.proto
│   │   └── server.py
│   ├── graphql_service/      # GraphQL service
│   │   ├── __init__.py
│   │   └── schema.py
│   ├── cli/                  # CLI tools
│   │   ├── api_client.py
│   │   └── grpc_client.py
│   └── templates/            # HTML templates
│       ├── index.html
│       └── api_tester.html
├── config/
│   ├── __init__.py
│   └── config.py             # Configuration management
├── tests/                    # Test files
├── run.py                    # Application entry point
├── requirements.txt          # Python dependencies
├── Dockerfile               # Docker configuration
├── docker-compose.yml       # Docker Compose configuration
├── .env.example             # Environment variables template
└── README.md                # This file
```

## 🔒 Security Features

- **Rate Limiting**: Prevents API abuse
- **CORS**: Configurable cross-origin resource sharing
- **Security Headers**: Talisman for security headers
- **Input Validation**: Marshmallow for data validation
- **SQL Injection Prevention**: SQLAlchemy ORM

## 🛠️ Development

### Code Formatting
```bash
black .
```

### Linting
```bash
flake8 .
```

### Running Tests
```bash
pytest
pytest --cov=app tests/
```

## 📖 API Examples

### REST API

**Create a User:**
```bash
curl -X POST http://localhost:5000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"username": "john_doe", "email": "john@example.com"}'
```

**Get All Users:**
```bash
curl http://localhost:5000/api/v1/users
```

**Create a Task:**
```bash
curl -X POST http://localhost:5000/api/v1/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Sample Task", "description": "This is a sample task"}'
```

### GraphQL

**Query:**
```bash
curl -X POST http://localhost:5000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ allUsers { id username email } }"}'
```

**Mutation:**
```bash
curl -X POST http://localhost:5000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "mutation { createUser(username: \"jane\", email: \"jane@example.com\") { user { id username } } }"}'
```

## 🌟 Key Technologies

- **Flask** - Web framework
- **Flask-RESTX** - REST API with Swagger
- **SQLAlchemy** - ORM
- **Alembic** - Database migrations
- **gRPC** - RPC framework
- **Graphene** - GraphQL
- **Gunicorn** - WSGI server
- **Prometheus** - Metrics
- **Rich** - CLI formatting
- **Click** - CLI framework

## 📝 Configuration

Edit `.env` file to configure:
- Database connection
- Server ports
- Security settings
- Logging level
- CORS origins
- Rate limits

## 🤝 Contributing

1. Follow PEP 8 style guide
2. Write tests for new features
3. Update documentation
4. Format code with Black
5. Check with Flake8

## 📄 License

This project is part of the web-study repository.

## 🔗 Resources

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Flask-RESTX](https://flask-restx.readthedocs.io/)
- [SQLAlchemy](https://www.sqlalchemy.org/)
- [gRPC Python](https://grpc.io/docs/languages/python/)
- [Graphene](https://graphene-python.org/)
- [Gunicorn](https://gunicorn.org/)