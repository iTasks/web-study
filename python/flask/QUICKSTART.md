# Quick Start Guide

## Installation

1. **Create virtual environment**:
   ```bash
   cd python/flask
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Setup environment**:
   ```bash
   cp .env.example .env
   ```

4. **Generate gRPC files**:
   ```bash
   cd app/grpc_service
   python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. service.proto
   cd ../..
   ```

## Running the Application

### Option 1: Quick Setup Script
```bash
chmod +x setup.sh
./setup.sh
```

### Option 2: Manual Setup

**Start REST API Server**:
```bash
python run.py
```

The server will be available at http://localhost:5000

**Start gRPC Server** (in a separate terminal):
```bash
source venv/bin/activate
python -m app.grpc_service.server
```

The gRPC server will be available at localhost:50051

## Testing the APIs

### Web Interface
- **Homepage**: http://localhost:5000
- **Swagger/OpenAPI Docs**: http://localhost:5000/api/v1/docs
- **GraphQL Interface**: http://localhost:5000/graphql
- **API Tester GUI**: http://localhost:5000/api-tester

### CLI Tools

**REST API**:
```bash
# List users
python -m app.cli.api_client rest list-users

# Create user
python -m app.cli.api_client rest create-user

# List tasks
python -m app.cli.api_client rest list-tasks

# Create task
python -m app.cli.api_client rest create-task
```

**GraphQL**:
```bash
# Query users
python -m app.cli.api_client graphql query-users

# Create user
python -m app.cli.api_client graphql create-user-mutation
```

**gRPC**:
```bash
# List users
python -m app.cli.grpc_client list-users

# Create user
python -m app.cli.grpc_client create-user

# List tasks
python -m app.cli.grpc_client list-tasks
```

### Using curl

**REST API**:
```bash
# Health check
curl http://localhost:5000/api/v1/health

# Create user
curl -X POST http://localhost:5000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"username": "john", "email": "john@example.com"}'

# List users
curl http://localhost:5000/api/v1/users
```

**GraphQL**:
```bash
# Query
curl -X POST http://localhost:5000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ allUsers { id username email } }"}'

# Mutation
curl -X POST http://localhost:5000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "mutation { createUser(username: \"jane\", email: \"jane@example.com\") { user { id username } } }"}'
```

## Docker Deployment

```bash
# Build and run
docker-compose up --build

# Run in detached mode
docker-compose up -d

# Stop containers
docker-compose down
```

## Running Tests

```bash
pytest tests/ -v
```

## Production Deployment

Use Gunicorn for production:
```bash
gunicorn -w 4 -b 0.0.0.0:5000 --timeout 120 run:app
```

Or use Docker Compose as shown above.
