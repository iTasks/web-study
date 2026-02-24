# CI/CD & Deployment

[← Back to Phase 5](README.md) | [Roadmap](../README.md)

## GitHub Actions Pipeline

```yaml
# .github/workflows/ci.yml
name: CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  # ── Frontend ──────────────────────────────────────
  test-frontend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./frontend
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
          cache-dependency-path: frontend/package-lock.json
      - run: npm ci
      - run: npm run type-check
      - run: npm run lint
      - run: npm run test -- --run --coverage
      - run: npm run build
        env:
          VITE_API_URL: https://api.example.com

  # ── Backend ───────────────────────────────────────
  test-backend:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: testdb
        ports: ["5432:5432"]
        options: --health-cmd pg_isready --health-interval 10s
    defaults:
      run:
        working-directory: ./backend
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
      - run: pip install -r requirements.txt -r requirements-dev.txt
      - run: ruff check .
      - run: mypy .
      - run: pytest --cov=app --cov-report=xml
        env:
          DATABASE_URL: postgresql://test:test@localhost:5432/testdb
          JWT_SECRET: test-secret-key

  # ── Build & Push Docker Images ────────────────────
  build-push:
    needs: [test-frontend, test-backend]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4

      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - uses: docker/build-push-action@v5
        with:
          context: ./frontend
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/frontend:${{ github.sha }}
          build-args: VITE_API_URL=${{ secrets.VITE_API_URL }}

      - uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/backend:${{ github.sha }}

  # ── Deploy ────────────────────────────────────────
  deploy:
    needs: build-push
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy to server via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
          script: |
            cd /opt/myapp
            echo ${{ secrets.GITHUB_TOKEN }} | docker login ghcr.io -u ${{ github.actor }} --password-stdin
            docker pull ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/frontend:${{ github.sha }}
            docker pull ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/backend:${{ github.sha }}
            FRONTEND_TAG=${{ github.sha }} BACKEND_TAG=${{ github.sha }} docker compose up -d
            docker system prune -f
```

---

## Deployment Targets

### DigitalOcean App Platform

```yaml
# .do/app.yaml
name: myapp
services:
  - name: backend
    source_dir: backend
    github:
      repo: username/myapp
      branch: main
    run_command: uvicorn app.main:app --host 0.0.0.0 --port 8080
    environment_slug: python
    instance_size_slug: basic-xxs
    envs:
      - key: DATABASE_URL
        scope: RUN_TIME
        type: SECRET
  - name: frontend
    source_dir: frontend
    build_command: npm run build
    output_dir: dist
    environment_slug: node-js
    envs:
      - key: VITE_API_URL
        value: ${backend.PUBLIC_URL}
databases:
  - name: db
    engine: PG
    version: "15"
```

### Railway

```toml
# railway.toml
[build]
builder = "DOCKERFILE"
dockerfilePath = "backend/Dockerfile"

[deploy]
startCommand = "uvicorn app.main:app --host 0.0.0.0 --port $PORT"
healthcheckPath = "/health"
healthcheckTimeout = 300
```

### AWS (ECS Fargate)

```yaml
# Key components:
# - ECS Cluster + Task Definitions
# - Application Load Balancer
# - RDS PostgreSQL
# - ElastiCache Redis
# - ECR for container images
# - CloudFront CDN for frontend
# - Route53 for DNS
```

---

## Environment Configuration

```bash
# .env.example — commit this (no secrets)
# Copy to .env and fill in values

# Database
DATABASE_URL=postgresql+asyncpg://user:password@db:5432/mydb

# JWT
JWT_SECRET=change-me-in-production
JWT_REFRESH_SECRET=change-me-in-production-refresh

# Redis
REDIS_URL=redis://:password@redis:6379/0
REDIS_PASSWORD=change-me

# S3 / Object Storage
S3_ENDPOINT=https://s3.amazonaws.com
S3_BUCKET=myapp-assets
S3_KEY=
S3_SECRET=
CDN_URL=https://cdn.example.com

# CORS
ALLOWED_ORIGINS=http://localhost:5173,https://app.example.com
```

---

## Resources

- [GitHub Actions](https://docs.github.com/en/actions)
- [Docker Hub](https://hub.docker.com/)
- [Railway](https://railway.app/docs)
- [DigitalOcean App Platform](https://docs.digitalocean.com/products/app-platform/)
- [AWS ECS](https://docs.aws.amazon.com/ecs/)

---

→ [Phase 5 Overview](README.md) | [Phase 6 – Advanced](../phase-6-advanced/README.md)
