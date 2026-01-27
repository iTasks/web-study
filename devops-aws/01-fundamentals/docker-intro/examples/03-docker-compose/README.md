# Docker Compose Multi-Container Application

[← Back to Docker Introduction](../../README.md) | [Level 1: Fundamentals](../../../README.md) | [DevOps & AWS](../../../../README.md)

This example demonstrates a complete multi-container application using Docker Compose.

## Architecture

```
┌──────────┐     ┌──────────┐
│  Nginx   │────▶│   Web    │
│  :80     │     │   :5000  │
└──────────┘     └────┬─────┘
                      │
              ┌───────┴────────┐
              │                │
         ┌────▼────┐     ┌────▼────┐
         │  Redis  │     │PostgreSQL│
         │  :6379  │     │  :5432   │
         └─────────┘     └──────────┘
```

## Components

1. **Web Application** - Python Flask app
2. **PostgreSQL** - Database
3. **Redis** - Cache
4. **Nginx** - Reverse proxy

## Usage

### Start all services
```bash
docker-compose up -d
```

### View logs
```bash
docker-compose logs -f
docker-compose logs web  # Specific service
```

### Stop all services
```bash
docker-compose down
```

### Stop and remove volumes (data)
```bash
docker-compose down -v
```

### Scale a service
```bash
docker-compose up -d --scale web=3
```

## Testing

```bash
# Access via Nginx
curl http://localhost/

# Direct web access
curl http://localhost:8080/

# Check all services are running
docker-compose ps
```

## Learning Points

- Multi-container orchestration
- Service dependencies
- Network isolation (frontend/backend)
- Volume management for data persistence
- Environment variable configuration
- Service scaling
- Health checks and restart policies
