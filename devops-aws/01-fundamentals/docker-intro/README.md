# Docker Introduction

## Introduction

Docker is a platform for developing, shipping, and running applications in containers. Containers package software with all its dependencies, ensuring consistency across different environments. Docker has revolutionized software deployment and is fundamental to modern DevOps practices.

## Learning Objectives

By the end of this module, you will:
- Understand containerization concepts
- Install and configure Docker
- Run and manage Docker containers
- Create custom Docker images
- Write Dockerfiles
- Use Docker volumes for data persistence
- Work with Docker networks
- Apply Docker best practices

## Why Docker?

**Before Docker:**
- "It works on my machine" problem
- Complex deployment processes
- Environment inconsistencies
- Difficult dependency management

**With Docker:**
- ✅ Consistent environments (dev, test, prod)
- ✅ Fast deployment and scaling
- ✅ Isolated applications
- ✅ Efficient resource usage
- ✅ Easy rollback and versioning

## Prerequisites

- Basic Linux command line knowledge
- Understanding of virtualization concepts
- Computer with at least 4GB RAM

## Setup

### Install Docker

**Ubuntu/Debian**:
```bash
# Update package index
sudo apt update

# Install prerequisites
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# Add user to docker group (avoid sudo)
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker run hello-world
```

**macOS**:
```bash
# Download Docker Desktop from https://www.docker.com/products/docker-desktop
# Or use Homebrew
brew install --cask docker
```

**Windows**:
- Download Docker Desktop from https://www.docker.com/products/docker-desktop
- Requires WSL2

### Verify Installation
```bash
docker --version
docker info
docker run hello-world
```

## Docker Architecture

```
┌─────────────────────────────────────┐
│        Docker Client (CLI)          │
│         docker commands             │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│       Docker Daemon (dockerd)       │
│  - Manages containers, images,      │
│    networks, volumes                │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│         Container Runtime           │
│    - containerd, runc               │
└─────────────────────────────────────┘
```

**Key Concepts**:
- **Image**: Read-only template with instructions for creating containers
- **Container**: Runnable instance of an image
- **Dockerfile**: Text file with instructions to build an image
- **Registry**: Repository for Docker images (Docker Hub, ECR, etc.)
- **Volume**: Persistent data storage for containers
- **Network**: Communication between containers

## Essential Docker Commands

### Working with Containers

```bash
# Run a container
docker run nginx                    # Run in foreground
docker run -d nginx                 # Run in background (detached)
docker run -d --name my-nginx nginx # Name the container
docker run -p 8080:80 nginx         # Port mapping (host:container)
docker run -it ubuntu bash          # Interactive terminal

# List containers
docker ps                           # Running containers
docker ps -a                        # All containers (including stopped)
docker ps -q                        # Only container IDs

# Container operations
docker start container-name         # Start stopped container
docker stop container-name          # Stop running container
docker restart container-name       # Restart container
docker pause container-name         # Pause processes
docker unpause container-name       # Resume processes

# Remove containers
docker rm container-name            # Remove stopped container
docker rm -f container-name         # Force remove running container
docker container prune              # Remove all stopped containers

# View container details
docker logs container-name          # View logs
docker logs -f container-name       # Follow logs (real-time)
docker logs --tail 100 container-name # Last 100 lines

docker inspect container-name       # Detailed information (JSON)
docker stats                        # Resource usage
docker stats container-name         # Specific container stats

# Execute commands in running container
docker exec container-name ls -la   # Run command
docker exec -it container-name bash # Interactive shell
```

**Hands-On Lab 1**: Running Your First Containers
```bash
# Run nginx web server
docker run -d -p 8080:80 --name my-web nginx

# Check it's running
docker ps
curl http://localhost:8080

# View logs
docker logs my-web

# Get a shell inside
docker exec -it my-web bash
# Inside container:
ls /usr/share/nginx/html
exit

# Stop and remove
docker stop my-web
docker rm my-web
```

### Working with Images

```bash
# List images
docker images
docker image ls

# Pull image from registry
docker pull ubuntu
docker pull ubuntu:20.04            # Specific tag
docker pull nginx:alpine            # Lightweight version

# Search for images
docker search nginx

# Remove images
docker rmi image-name
docker rmi image-id
docker image prune                  # Remove unused images
docker image prune -a               # Remove all unused images

# View image details
docker inspect image-name
docker history image-name           # Image layers

# Tag images
docker tag source-image:tag new-image:tag
docker tag my-app:latest my-app:v1.0

# Save and load images
docker save -o myimage.tar image-name
docker load -i myimage.tar

# Export and import containers
docker export container-name > container.tar
docker import container.tar new-image:tag
```

## Creating Docker Images

### Writing Dockerfiles

A Dockerfile is a script that contains instructions to build a Docker image.

**Basic Dockerfile Structure**:
```dockerfile
# Use a base image
FROM ubuntu:20.04

# Set metadata
LABEL maintainer="your.email@example.com"
LABEL version="1.0"
LABEL description="My application"

# Set environment variables
ENV APP_HOME=/app
ENV NODE_ENV=production

# Set working directory
WORKDIR /app

# Copy files from host to container
COPY package.json .
COPY src/ ./src/

# Run commands during build
RUN apt-get update && \
    apt-get install -y python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Expose ports
EXPOSE 8080

# Define default command
CMD ["python3", "app.py"]
# Or use ENTRYPOINT for fixed commands
# ENTRYPOINT ["python3", "app.py"]
```

**Common Dockerfile Instructions**:

| Instruction | Purpose | Example |
|------------|---------|---------|
| FROM | Base image | `FROM python:3.9` |
| RUN | Execute commands | `RUN pip install flask` |
| COPY | Copy files | `COPY . /app` |
| ADD | Copy files (supports URLs and tar) | `ADD file.tar.gz /app` |
| WORKDIR | Set working directory | `WORKDIR /app` |
| ENV | Environment variables | `ENV PORT=8080` |
| EXPOSE | Document port usage | `EXPOSE 8080` |
| CMD | Default command | `CMD ["python", "app.py"]` |
| ENTRYPOINT | Fixed command | `ENTRYPOINT ["nginx"]` |
| VOLUME | Mount point for volumes | `VOLUME /data` |
| USER | Set user context | `USER appuser` |
| ARG | Build-time variables | `ARG VERSION=1.0` |

### Building Images

```bash
# Build image from Dockerfile
docker build -t my-app:latest .
docker build -t my-app:v1.0 -f Dockerfile.prod .

# Build with arguments
docker build --build-arg VERSION=1.0 -t my-app:1.0 .

# Build without cache
docker build --no-cache -t my-app:latest .

# View build history
docker history my-app:latest
```

**Hands-On Lab 2**: Build a Python Web Application

Create `app.py`:
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from Docker!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

Create `requirements.txt`:
```
flask==2.0.1
```

Create `Dockerfile`:
```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
```

Build and run:
```bash
# Build image
docker build -t flask-app:1.0 .

# Run container
docker run -d -p 5000:5000 --name my-flask-app flask-app:1.0

# Test
curl http://localhost:5000

# View logs
docker logs my-flask-app

# Clean up
docker stop my-flask-app
docker rm my-flask-app
```

## Docker Volumes

Volumes provide persistent storage for containers.

```bash
# Create volume
docker volume create my-data

# List volumes
docker volume ls

# Inspect volume
docker volume inspect my-data

# Use volume in container
docker run -d -v my-data:/app/data nginx

# Mount host directory (bind mount)
docker run -d -v /host/path:/container/path nginx
docker run -d -v $(pwd):/app python:3.9

# Anonymous volume
docker run -d -v /app/data nginx

# Remove volumes
docker volume rm my-data
docker volume prune                 # Remove unused volumes
```

**Hands-On Lab 3**: Persistent Database
```bash
# Run MySQL with persistent storage
docker run -d \
  --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=secret \
  -v mysql-data:/var/lib/mysql \
  -p 3306:3306 \
  mysql:8.0

# Verify
docker exec mysql-db mysql -uroot -psecret -e "SHOW DATABASES;"

# Even after container removal, data persists
docker rm -f mysql-db
docker volume ls | grep mysql-data

# Start new container with same volume
docker run -d \
  --name mysql-db-2 \
  -e MYSQL_ROOT_PASSWORD=secret \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0
```

## Docker Networks

Networks enable communication between containers.

```bash
# List networks
docker network ls

# Create network
docker network create my-network
docker network create --driver bridge my-bridge

# Inspect network
docker network inspect my-network

# Run container in network
docker run -d --network my-network --name web nginx
docker run -d --network my-network --name db mysql:8.0

# Connect/disconnect containers
docker network connect my-network container-name
docker network disconnect my-network container-name

# Remove network
docker network rm my-network
docker network prune                # Remove unused networks
```

**Network Types**:
- **bridge**: Default, isolated network on host
- **host**: Share host's network stack
- **none**: No networking
- **overlay**: Multi-host networking (Swarm)

**Hands-On Lab 4**: Multi-Container Application
```bash
# Create network
docker network create app-network

# Run database
docker run -d \
  --name postgres \
  --network app-network \
  -e POSTGRES_PASSWORD=secret \
  postgres:13

# Run application (can connect to postgres by name)
docker run -d \
  --name webapp \
  --network app-network \
  -p 8080:80 \
  -e DATABASE_HOST=postgres \
  nginx
```

## Docker Compose

Docker Compose manages multi-container applications using YAML files.

**Install Docker Compose**:
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

**docker-compose.yml Example**:
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    networks:
      - frontend
    depends_on:
      - api

  api:
    build: ./api
    ports:
      - "5000:5000"
    environment:
      - DATABASE_URL=postgresql://db:5432/mydb
    networks:
      - frontend
      - backend
    depends_on:
      - db

  db:
    image: postgres:13
    environment:
      - POSTGRES_PASSWORD=secret
      - POSTGRES_DB=mydb
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend

volumes:
  db-data:

networks:
  frontend:
  backend:
```

**Docker Compose Commands**:
```bash
# Start services
docker-compose up
docker-compose up -d                # Detached mode

# Stop services
docker-compose down
docker-compose down -v              # Remove volumes too

# View logs
docker-compose logs
docker-compose logs -f web          # Follow specific service

# List services
docker-compose ps

# Execute command
docker-compose exec web sh

# Build/rebuild services
docker-compose build
docker-compose up --build

# Scale services
docker-compose up -d --scale api=3
```

## Best Practices

### Dockerfile Best Practices

1. **Use specific base images**:
   ```dockerfile
   # Good
   FROM python:3.9-slim
   
   # Avoid
   FROM python:latest
   ```

2. **Minimize layers**:
   ```dockerfile
   # Good - single RUN command
   RUN apt-get update && \
       apt-get install -y package1 package2 && \
       apt-get clean && \
       rm -rf /var/lib/apt/lists/*
   
   # Avoid - multiple RUN commands
   RUN apt-get update
   RUN apt-get install -y package1
   RUN apt-get install -y package2
   ```

3. **Use .dockerignore**:
   ```
   .git
   .gitignore
   node_modules
   npm-debug.log
   Dockerfile
   .dockerignore
   .env
   ```

4. **Don't run as root**:
   ```dockerfile
   RUN useradd -m appuser
   USER appuser
   ```

5. **Use multi-stage builds**:
   ```dockerfile
   # Build stage
   FROM node:16 AS builder
   WORKDIR /app
   COPY package*.json ./
   RUN npm install
   COPY . .
   RUN npm run build
   
   # Production stage
   FROM node:16-alpine
   WORKDIR /app
   COPY --from=builder /app/dist ./dist
   CMD ["node", "dist/index.js"]
   ```

### Security Best Practices

- Don't include secrets in images
- Scan images for vulnerabilities
- Use minimal base images (Alpine)
- Keep images updated
- Run containers as non-root user
- Limit container resources

### Operational Best Practices

- Use health checks
- Implement proper logging
- Tag images meaningfully
- Use volumes for persistent data
- Clean up regularly (prune)
- Monitor resource usage

## Assessment Checklist

Before moving forward, ensure you can:

- [ ] Install and configure Docker
- [ ] Run containers from Docker Hub
- [ ] Map ports and access containerized applications
- [ ] Execute commands in running containers
- [ ] View container logs and stats
- [ ] Create Dockerfiles
- [ ] Build custom Docker images
- [ ] Use environment variables in containers
- [ ] Work with Docker volumes for persistence
- [ ] Create and use Docker networks
- [ ] Write docker-compose.yml files
- [ ] Run multi-container applications
- [ ] Apply Docker best practices

## Additional Resources

- [Official Docker Documentation](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Play with Docker](https://labs.play-with-docker.com/) - Free online playground
- [Docker Curriculum](https://docker-curriculum.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

## Next Steps

Once you're comfortable with Docker, move on to:
- [AWS Basics](../aws-basics/) - Cloud computing fundamentals

---

**Practice makes perfect!** Create Dockerfiles for your own projects and experiment with different configurations.
