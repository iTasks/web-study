# Database Integration Guide

This guide covers the GORM database integration, CRUD operations, migrations, and performance analysis features.

## Table of Contents

- [Overview](#overview)
- [Database Configuration](#database-configuration)
- [Models](#models)
- [CRUD Operations](#crud-operations)
- [Database Migrations](#database-migrations)
- [Performance Analysis](#performance-analysis)
- [CLI Tool](#cli-tool)
- [API Reference](#api-reference)

## Overview

The Echo server includes complete database integration using GORM (Go Object-Relational Mapping) with support for:

- **Multiple Databases**: SQLite (default), PostgreSQL, MySQL
- **Auto Migration**: Automatic schema creation and updates
- **CRUD Operations**: Full Create, Read, Update, Delete functionality
- **Connection Pooling**: Optimized connection management
- **Performance Monitoring**: Database statistics and query performance analysis
- **Data Seeding**: Sample data for testing

## Database Configuration

### Environment Variables

Configure the database using environment variables:

```bash
# Database driver (sqlite, postgres, mysql)
export DB_DRIVER=sqlite

# SQLite configuration
export DB_NAME=echo_server.db

# PostgreSQL configuration
export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=postgres
export DB_PASSWORD=secret
export DB_NAME=echo_db
export DB_SSLMODE=disable

# Seed data on startup (true/false)
export DB_SEED=true
```

### Supported Databases

#### SQLite (Default)

```bash
export DB_DRIVER=sqlite
export DB_NAME=echo_server.db
make run-db
```

#### PostgreSQL

```bash
export DB_DRIVER=postgres
export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=postgres
export DB_PASSWORD=mypassword
export DB_NAME=echo_db
export DB_SSLMODE=disable
make run-db
```

#### MySQL

```bash
export DB_DRIVER=mysql
export DB_HOST=localhost
export DB_PORT=3306
export DB_USER=root
export DB_PASSWORD=mypassword
export DB_NAME=echo_db
make run-db
```

## Models

### User Model

```go
type User struct {
    ID        uint           `gorm:"primarykey" json:"id"`
    CreatedAt time.Time      `json:"created_at"`
    UpdatedAt time.Time      `json:"updated_at"`
    DeletedAt gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
    Name      string         `gorm:"size:255;not null" json:"name"`
    Email     string         `gorm:"size:255;uniqueIndex;not null" json:"email"`
    Role      string         `gorm:"size:50;default:user" json:"role"`
    Active    bool           `gorm:"default:true" json:"active"`
}
```

**Features:**
- Soft deletes with `DeletedAt`
- Unique email constraint
- Default role: "user"
- Active status tracking

### Product Model

```go
type Product struct {
    ID          uint           `gorm:"primarykey" json:"id"`
    CreatedAt   time.Time      `json:"created_at"`
    UpdatedAt   time.Time      `json:"updated_at"`
    DeletedAt   gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
    Name        string         `gorm:"size:255;not null" json:"name"`
    Description string         `gorm:"type:text" json:"description"`
    Price       float64        `gorm:"not null" json:"price"`
    Stock       int            `gorm:"not null;default:0" json:"stock"`
    SKU         string         `gorm:"size:100;uniqueIndex" json:"sku"`
}
```

**Features:**
- Soft deletes
- Unique SKU (Stock Keeping Unit)
- Price and stock tracking
- Text description support

## CRUD Operations

### Users API

#### List All Users

```bash
curl http://localhost:8080/api/v1/users
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "created_at": "2026-01-27T05:00:00Z",
      "updated_at": "2026-01-27T05:00:00Z",
      "name": "John Doe",
      "email": "john@example.com",
      "role": "admin",
      "active": true
    }
  ],
  "count": 1
}
```

#### Create User

```bash
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice Smith",
    "email": "alice@example.com",
    "role": "user"
  }'
```

#### Get User by ID

```bash
curl http://localhost:8080/api/v1/users/1
```

#### Update User

```bash
curl -X PUT http://localhost:8080/api/v1/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Updated",
    "role": "moderator"
  }'
```

#### Delete User

```bash
curl -X DELETE http://localhost:8080/api/v1/users/1
```

### Products API

#### List All Products

```bash
curl http://localhost:8080/api/v1/products
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "created_at": "2026-01-27T05:00:00Z",
      "updated_at": "2026-01-27T05:00:00Z",
      "name": "Laptop",
      "description": "High-performance laptop",
      "price": 999.99,
      "stock": 50,
      "sku": "LAP-001"
    }
  ],
  "count": 1
}
```

#### Create Product

```bash
curl -X POST http://localhost:8080/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Wireless Mouse",
    "description": "Ergonomic wireless mouse",
    "price": 29.99,
    "stock": 100,
    "sku": "MOU-002"
  }'
```

#### Get Product by ID

```bash
curl http://localhost:8080/api/v1/products/1
```

#### Update Product

```bash
curl -X PUT http://localhost:8080/api/v1/products/1 \
  -H "Content-Type: application/json" \
  -d '{
    "price": 899.99,
    "stock": 45
  }'
```

#### Delete Product

```bash
curl -X DELETE http://localhost:8080/api/v1/products/1
```

## Database Migrations

### Auto Migration

The server automatically creates and updates database schemas on startup using GORM's AutoMigrate feature.

```go
// Automatically handled in server_with_db.go
dbManager.AutoMigrate()
```

This creates:
- `users` table with appropriate columns and indexes
- `products` table with appropriate columns and indexes
- Indexes for soft deletes, unique constraints

### Manual Migration

To run migrations manually:

```bash
# Start server (migrations run automatically)
make run-db

# Or use the database manager programmatically
dbManager, _ := NewDBManager(config)
dbManager.AutoMigrate()
```

### Data Seeding

Sample data is automatically seeded on first run when `DB_SEED=true`:

**Default Seed Data:**
- 4 sample users (admin, users, moderator)
- 5 sample products (laptop, mouse, keyboard, monitor, headphones)

To disable seeding:
```bash
export DB_SEED=false
make run-db
```

## Performance Analysis

### Database Statistics

Get comprehensive database statistics:

```bash
curl http://localhost:8080/api/v1/db/stats
```

**Response:**
```json
{
  "total_users": 4,
  "active_users": 4,
  "total_products": 5,
  "low_stock_products": 2,
  "max_open_connections": 100,
  "open_connections": 2,
  "in_use": 0,
  "idle": 2
}
```

**Metrics Included:**
- Total and active user counts
- Product inventory statistics
- Low stock alerts (< 50 items)
- Connection pool statistics

### Performance Analysis

Analyze query performance:

```bash
curl http://localhost:8080/api/v1/db/performance
```

**Response:**
```json
{
  "users_query_time_ms": 2,
  "products_query_time_ms": 1,
  "complex_query_time_ms": 1,
  "users_count": 4,
  "products_count": 5
}
```

**Metrics Included:**
- Query execution times in milliseconds
- Simple vs complex query comparison
- Record counts

### Connection Pool Settings

Optimized connection pool configuration:

```go
MaxIdleConns: 10        // Maximum idle connections
MaxOpenConns: 100       // Maximum open connections
ConnMaxLifetime: 1 hour // Maximum connection lifetime
```

## CLI Tool

A comprehensive menu-based CLI tool for interacting with the server.

### Starting the CLI

```bash
# Use default server URL (http://localhost:8080)
make cli

# Or specify custom server URL
export SERVER_URL=http://your-server:8080
make cli
```

### CLI Features

The CLI provides a text-based menu interface with the following sections:

#### 1. Health & Status Checks
- Check server health
- Check readiness
- View system information
- Run all health checks

#### 2. User Management (CRUD)
- List all users
- Get user by ID
- Create new user
- Update existing user
- Delete user

#### 3. Product Management (CRUD)
- List all products
- Get product by ID
- Create new product
- Update existing product
- Delete product

#### 4. Metrics & Monitoring
- View Prometheus metrics
- View HTTP request metrics
- View active requests

#### 5. Database Analysis
- View database statistics
- Analyze performance
- Check connection pool status

#### 6. Server Logs
- Information about viewing server logs

#### 7. Performance Testing
- Test slow endpoint (2s delay)
- Test error handling
- Test panic recovery
- Test distributed tracing

### CLI Usage Example

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

Select an option: 2

╔═══════════════════════════════════════════╗
║   User Management (CRUD)                 ║
╚═══════════════════════════════════════════╝

  [1] List All Users
  [2] Get User by ID
  [3] Create New User
  [4] Update User
  [5] Delete User
  [0] Back to Main Menu

Select an option: 3

--- Create New User ---
Name: Alice Johnson
Email: alice@example.com
Role (admin/user/moderator): user

⏳ Create User...
✅ Status: 201 Created
Response:
{
  "id": 5,
  "name": "Alice Johnson",
  "email": "alice@example.com",
  "role": "user",
  "active": true,
  "created_at": "2026-01-27T05:00:00Z"
}
```

## API Reference

### User Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/users` | List all users |
| POST | `/api/v1/users` | Create a new user |
| GET | `/api/v1/users/:id` | Get user by ID |
| PUT | `/api/v1/users/:id` | Update user |
| DELETE | `/api/v1/users/:id` | Delete user |

### Product Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/products` | List all products |
| POST | `/api/v1/products` | Create a new product |
| GET | `/api/v1/products/:id` | Get product by ID |
| PUT | `/api/v1/products/:id` | Update product |
| DELETE | `/api/v1/products/:id` | Delete product |

### Database Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/db/stats` | Get database statistics |
| GET | `/api/v1/db/performance` | Get performance analysis |

## Best Practices

### 1. Connection Management

Always use connection pooling:
```go
sqlDB.SetMaxIdleConns(10)
sqlDB.SetMaxOpenConns(100)
sqlDB.SetConnMaxLifetime(time.Hour)
```

### 2. Error Handling

Handle database errors gracefully:
```go
if err := db.Create(&user).Error; err != nil {
    return c.JSON(http.StatusInternalServerError, map[string]string{
        "error": "Failed to create user",
    })
}
```

### 3. Soft Deletes

Use soft deletes to preserve data:
```go
// This marks as deleted, doesn't remove from DB
db.Delete(&User{}, id)

// Permanently delete
db.Unscoped().Delete(&User{}, id)

// Query including soft deleted
db.Unscoped().Find(&users)
```

### 4. Transactions

Use transactions for complex operations:
```go
db.Transaction(func(tx *gorm.DB) error {
    if err := tx.Create(&user).Error; err != nil {
        return err
    }
    if err := tx.Create(&product).Error; err != nil {
        return err
    }
    return nil
})
```

### 5. Indexing

Ensure proper indexing for performance:
```go
Email string `gorm:"uniqueIndex"` // Unique index
SKU   string `gorm:"uniqueIndex"` // Unique index
DeletedAt gorm.DeletedAt `gorm:"index"` // Regular index
```

## Troubleshooting

### Database Connection Failed

```bash
# Check database driver
echo $DB_DRIVER

# For PostgreSQL, ensure database exists
createdb echo_db

# Check connection parameters
export DB_HOST=localhost
export DB_PORT=5432
```

### Migration Issues

```bash
# Drop and recreate database (development only!)
dropdb echo_db
createdb echo_db
make run-db
```

### Performance Issues

```bash
# Check database statistics
curl http://localhost:8080/api/v1/db/stats

# Analyze query performance
curl http://localhost:8080/api/v1/db/performance

# Monitor connection pool
curl http://localhost:8080/api/v1/db/stats | grep -i connection
```

## Next Steps

- Add authentication and authorization
- Implement database relationships (foreign keys)
- Add full-text search
- Implement pagination
- Add data validation
- Create database backups
- Set up database replication
