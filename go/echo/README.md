# Echo Framework - Production-Ready Examples

[← Back to Go](../README.md) | [Main README](../../README.md)

## Purpose

This directory contains production-ready Echo framework examples with comprehensive observability and monitoring middlewares. Echo is a high performance, minimalist Go web framework that provides an optimized HTTP router which smartly prioritizes routes and supports extensive middleware.

## 🚀 Quick Start

### Basic Server (No Database)

```bash
# Install dependencies
cd go/echo
go mod download

# Run the production server
make run-prod
```

### Server with Database

```bash
# Run server with database integration
make run-db

# The server will create a SQLite database and seed it with sample data
```

### CLI Tool

```bash
# Start the interactive CLI tool
make cli

# Or build and run manually
make build-cli
./cli-tool
```

The server will start on `http://localhost:8080`

## 📁 Contents

### Production-Ready Features

This implementation includes:

- **Production Server** (`production_server.go`) - Complete server with all production middlewares
- **Database Server** (`server_with_db.go`) - Server with GORM database integration
- **Database Models** (`models.go`) - User and Product models with GORM
- **Database Manager** (`database.go`) - Database operations, migrations, and analytics
- **CLI Tool** (`cli.go`) - Interactive menu-based tool for API testing
- **Prometheus Monitoring** (`monitoring.go`) - Comprehensive metrics collection
- **Distributed Tracing** (`tracing.go`) - Request tracing with trace/span IDs
- **Comprehensive Tests** (`main_test.go`) - Unit and integration tests
- **Production Guide** (`PRODUCTION_GUIDE.md`) - Detailed deployment documentation
- **Database Guide** (`DATABASE_GUIDE.md`) - Complete database integration guide
- **Examples** (`EXAMPLES.md`) - Practical usage examples
- **Docker Support** (`Dockerfile`, `docker-compose.yml`) - Container deployment
- **Development Tools** (`Makefile`) - Common development tasks

### Middleware Stack

All servers include a complete production-ready middleware stack:

1. **Request ID** - Unique identifier for each request
2. **Distributed Tracing** - Trace ID and Span ID tracking
3. **Prometheus Metrics** - Request/response metrics collection
4. **Structured Logging** - JSON-formatted logs with context
5. **Panic Recovery** - Graceful recovery from panics
6. **Security Headers** - HSTS, XSS protection, CSP
7. **CORS** - Cross-origin resource sharing
8. **Gzip Compression** - Response compression
9. **Rate Limiting** - Request rate limiting (100 req/s)
10. **Request Timeout** - Configurable timeouts (30s)

### Observability Endpoints

- `GET /health` - Health check (Kubernetes liveness probe)
- `GET /ready` - Readiness check (Kubernetes readiness probe)
- `GET /metrics` - Prometheus metrics endpoint
- `GET /info` - System information

### API Endpoints

**User Management (CRUD):**
- `GET /api/v1/users` - List all users
- `POST /api/v1/users` - Create a user
- `GET /api/v1/users/:id` - Get specific user
- `PUT /api/v1/users/:id` - Update user
- `DELETE /api/v1/users/:id` - Delete user

**Product Management (CRUD):**
- `GET /api/v1/products` - List all products
- `POST /api/v1/products` - Create a product
- `GET /api/v1/products/:id` - Get specific product
- `PUT /api/v1/products/:id` - Update product
- `DELETE /api/v1/products/:id` - Delete product

**Database Analysis:**
- `GET /api/v1/db/stats` - Database statistics and metrics
- `GET /api/v1/db/performance` - Query performance analysis

**Testing endpoints:**
- `GET /api/v1/slow` - Test timeout handling (2s delay)
- `GET /api/v1/error` - Test error handling
- `GET /api/v1/panic` - Test panic recovery
- `GET /api/v1/trace` - Test distributed tracing

## 💾 Database Integration

### GORM Support

Full database integration with GORM ORM:

- **Supported Databases**: SQLite (default), PostgreSQL, MySQL
- **Auto Migration**: Automatic schema creation and updates
- **Connection Pooling**: Optimized connection management
- **Soft Deletes**: Data preservation with deleted_at timestamps
- **Performance Monitoring**: Query performance tracking and analysis

### Database Models

**User Model:**
```go
type User struct {
    ID        uint
    Name      string
    Email     string  // Unique index
    Role      string  // admin, user, moderator
    Active    bool
    CreatedAt time.Time
    UpdatedAt time.Time
    DeletedAt gorm.DeletedAt
}
```

**Product Model:**
```go
type Product struct {
    ID          uint
    Name        string
    Description string
    Price       float64
    Stock       int
    SKU         string  // Unique index
    CreatedAt   time.Time
    UpdatedAt   time.Time
    DeletedAt   gorm.DeletedAt
}
```

### Quick Database Setup

```bash
# Using SQLite (default)
make run-db

# Using PostgreSQL
export DB_DRIVER=postgres
export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=postgres
export DB_PASSWORD=secret
export DB_NAME=echo_db
make run-db
```

See **[DATABASE_GUIDE.md](DATABASE_GUIDE.md)** for complete database documentation.

## 🖥️ CLI Tool

Interactive menu-based CLI for testing and managing the server:

### Features

1. **Health & Status Checks** - Test server health and readiness
2. **User Management** - Complete CRUD operations for users
3. **Product Management** - Complete CRUD operations for products
4. **Metrics & Monitoring** - View Prometheus metrics
5. **Database Analysis** - Database statistics and performance
6. **Server Logs** - View server log information
7. **Performance Testing** - Test various server features

### Usage

```bash
# Start the CLI
make cli

# Or build and run manually
make build-cli
./cli-tool
```

### CLI Example

```
╔═══════════════════════════════════════════╗
║   Echo Server CLI - Main Menu            ║
╚═══════════════════════════════════════════╝

  [1] Health & Status Checks
  [2] User Management (CRUD)
  [3] Product Management (CRUD)
  [4] Metrics & Monitoring
  [5] Database Analysis
  [6] Server Logs
  [7] Performance Testing
  [0] Exit

Select an option: _
```

## 🛠️ Setup Instructions

### Prerequisites
- Go 1.19 or higher
- Docker (optional, for containerized deployment)
- Docker Compose (optional, for monitoring stack)

### Installation

```bash
# Navigate to the echo directory
cd go/echo

# Install dependencies
go mod download

# Run tests
go test -v

# Build the server
go build -o server production_server.go monitoring.go tracing.go

# Run the server
./server
```

### Using Make

```bash
make install      # Install dependencies
make test         # Run tests
make run-prod     # Run production server (no database)
make run-db       # Run server with database
make cli          # Run CLI tool
make build        # Build server binary
make build-db     # Build database server binary
make build-cli    # Build CLI tool binary
make docker-build # Build Docker image
```

### Available Make Targets

| Target | Description |
|--------|-------------|
| `make install` | Install Go dependencies |
| `make run-prod` | Run production server without database |
| `make run-db` | Run server with database integration |
| `make cli` | Start interactive CLI tool |
| `make test` | Run all tests with coverage |
| `make bench` | Run benchmarks |
| `make build` | Build production server binary |
| `make build-db` | Build database server binary |
| `make build-cli` | Build CLI tool binary |
| `make fmt` | Format code with go fmt |
| `make vet` | Run go vet |
| `make clean` | Clean build artifacts and database files |
| `make docker-build` | Build Docker image |
| `make docker-run` | Run Docker container |
| `make check` | Run fmt, vet, and tests |

## 📊 Monitoring & Observability

### Prometheus Metrics

The server exposes Prometheus metrics at `/metrics`:

```bash
curl http://localhost:8080/metrics
```

Available metrics:
- `http_requests_total` - Total HTTP requests by method, endpoint, status
- `http_request_duration_seconds` - Request duration histogram
- `http_request_size_bytes` - Request size summary
- `http_response_size_bytes` - Response size summary
- `http_requests_active` - Currently active requests

### Distributed Tracing

Trace requests across services using trace headers:

```bash
curl -H "X-Trace-ID: my-trace-123" \
     -H "X-Parent-Span-ID: parent-456" \
     http://localhost:8080/api/v1/trace
```

Response includes:
- `trace_id` - Unique trace identifier
- `span_id` - Current span identifier
- `parent_id` - Parent span identifier
- `duration` - Request duration

### Health Checks

```bash
# Health check
curl http://localhost:8080/health

# Readiness check (for Kubernetes)
curl http://localhost:8080/ready

# System info
curl http://localhost:8080/info
```

## 🐳 Docker Deployment

### Build and Run

```bash
# Build Docker image
docker build -t echo-server .

# Run container
docker run -p 8080:8080 echo-server
```

### Docker Compose (with Monitoring)

Run the complete stack with Prometheus and Grafana:

```bash
docker-compose up -d
```

Access:
- Echo Server: http://localhost:8080
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)

## 📖 Documentation

- **[PRODUCTION_GUIDE.md](PRODUCTION_GUIDE.md)** - Comprehensive production deployment guide
  - Detailed middleware configuration
  - Kubernetes deployment examples
  - Performance tuning
  - Best practices
  - Troubleshooting

## 🧪 Testing

```bash
# Run all tests
go test -v

# Run with coverage
go test -v -cover

# Run benchmarks
go test -bench=. -benchmem
```

## 🔑 Key Features

### High Performance
- Optimized HTTP router with smart route prioritization
- Gzip compression for reduced bandwidth
- Connection pooling and keep-alive support

### Production-Ready Middleware
- Comprehensive error handling and recovery
- Rate limiting to prevent abuse
- Security headers (HSTS, CSP, XSS protection)
- Request timeouts to prevent hanging requests

### Observability
- Structured JSON logging with full context
- Prometheus metrics for monitoring
- Distributed tracing support
- Health and readiness probes

### Cloud-Native
- Graceful shutdown for zero-downtime deployments
- Kubernetes-compatible health checks
- Docker and container-ready
- Horizontal scaling support

### Database Integration
- GORM ORM with multiple database support
- Auto-migration and schema management
- Connection pooling and optimization
- Performance monitoring and analysis
- CRUD operations with soft deletes

### Developer Tools
- Interactive CLI for API testing
- Menu-based interface for all operations
- Built-in database analysis tools
- Performance testing utilities

## 📚 Learning Topics

This implementation demonstrates:

1. **Echo Server Setup** - Complete production configuration
2. **Middleware Stack** - Layered middleware architecture
3. **Error Handling** - Structured error responses
4. **Logging** - JSON-formatted structured logging
5. **Metrics** - Prometheus integration
6. **Tracing** - Distributed tracing patterns
7. **Database Integration** - GORM ORM with migrations
8. **CRUD Operations** - RESTful API design
9. **Testing** - Unit and integration testing
10. **CLI Development** - Interactive command-line tools
11. **Docker** - Containerization and deployment
12. **Kubernetes** - Cloud-native patterns
13. **Graceful Shutdown** - Clean application termination
14. **Performance Analysis** - Database and query optimization

## 📖 Documentation

- **[README.md](README.md)** - This file: Overview and quick start
- **[PRODUCTION_GUIDE.md](PRODUCTION_GUIDE.md)** - Production deployment guide
  - Middleware configuration details
  - Kubernetes deployment examples
  - Performance tuning recommendations
  - Best practices and troubleshooting
- **[DATABASE_GUIDE.md](DATABASE_GUIDE.md)** - Complete database integration guide
  - Database configuration and setup
  - Model definitions and relationships
  - CRUD operations examples
  - Migration and seeding
  - Performance analysis tools
  - CLI tool usage
- **[EXAMPLES.md](EXAMPLES.md)** - Practical usage examples
  - curl commands for all endpoints
  - Prometheus query examples
  - Load testing patterns

## 🔗 Resources

- [Echo Framework Documentation](https://echo.labstack.com/)
- [Echo GitHub Repository](https://github.com/labstack/echo)
- [Echo Cookbook](https://echo.labstack.com/cookbook/)
- [GORM Documentation](https://gorm.io/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Go Web Development](https://golang.org/doc/articles/wiki/)
- [Twelve-Factor App](https://12factor.net/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

## 📝 Examples

### Basic Request

```bash
curl http://localhost:8080/api/v1/users
```

### Create User

```bash
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'
```

### With Tracing

```bash
curl -H "X-Trace-ID: my-trace-123" \
     http://localhost:8080/api/v1/users
```

### Check Metrics

```bash
curl http://localhost:8080/metrics | grep http_requests_total
```

## 🤝 Contributing

Contributions are welcome! Please ensure:
- All tests pass: `make test`
- Code is formatted: `make fmt`
- No lint errors: `make vet`
- Documentation is updated

## 📄 License

This is part of the web-study repository for educational purposes.