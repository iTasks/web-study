# Simple Flask Web Application Example

[← Back to Docker Introduction](../../README.md) | [Level 1: Fundamentals](../../../README.md) | [DevOps & AWS](../../../../README.md)

This example demonstrates a basic containerized Python Flask application.

## Files

- `app.py` - Simple Flask web application with multiple endpoints
- `requirements.txt` - Python dependencies
- `Dockerfile` - Docker image definition

## Building and Running

### Build the Docker image
```bash
docker build -t flask-app:1.0 .
```

### Run the container
```bash
# Run in foreground
docker run -p 5000:5000 flask-app:1.0

# Run in background
docker run -d -p 5000:5000 --name my-flask-app flask-app:1.0
```

### Test the application
```bash
# Home endpoint
curl http://localhost:5000/

# Health check
curl http://localhost:5000/health

# Info endpoint
curl http://localhost:5000/info

# Echo endpoint
curl -X POST -H "Content-Type: application/json" \
     -d '{"message":"Hello Docker"}' \
     http://localhost:5000/echo
```

## Environment Variables

You can customize the application behavior:
```bash
docker run -p 8080:8080 \
    -e PORT=8080 \
    -e ENV=development \
    flask-app:1.0
```

## Viewing Logs
```bash
docker logs my-flask-app
docker logs -f my-flask-app  # Follow logs
```

## Stopping and Removing
```bash
docker stop my-flask-app
docker rm my-flask-app
```

## Learning Points

- Basic Dockerfile structure
- Layer caching optimization (requirements copied separately)
- Environment variables in containers
- Health checks
- Port mapping
- Container lifecycle management
