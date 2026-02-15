# Queue Processing Samples with MongoDB and PostgreSQL (Go)

This directory contains comprehensive examples of parallel queue processing with efficient batch operations for both MongoDB and PostgreSQL databases using Go.

## Overview

These samples demonstrate:
- **Channel-based Queue Processing**: Goroutines with channels for concurrent processing
- **Adaptive Batching**: Automatic switching between bulk and single operations based on queue size
- **Database Bulk Inserts**: Efficient batch operations for MongoDB and PostgreSQL
- **Cache Management**: Memory-efficient caching with LRU eviction
- **Market Order Processing**: Large-scale market order handling (Stock Exchange scenarios)
- **Goroutine Pool Management**: Efficient worker pool patterns

## Files

### Core Samples
- `mongodb_processor.go` - MongoDB bulk insert with queue processing
- `postgresql_processor.go` - PostgreSQL batch insert with queue processing
- `parallel_workers.go` - Multi-worker parallel queue processing with goroutines
- `market_order_processor.go` - Large-scale market order processing (SE scenario)
- `cache_manager.go` - Efficient cache management with LRU eviction
- `main.go` - Main entry point and examples

### Utilities
- `go.mod` - Go module definition
- `docker-compose.yml` - Local MongoDB and PostgreSQL setup
- `README.md` - This file

## Installation

### 1. Install Dependencies

```bash
go mod download
```

### 2. Start Databases (Docker)

```bash
docker-compose up -d
```

## Usage Examples

### MongoDB Bulk Insert with Queue

```go
processor := NewMongoDBQueueProcessor(
    "mongodb://localhost:27017",
    "market_data",
    "orders",
)

// Process queue with automatic batching
processor.ProcessQueue(1000, 4, true)
```

### PostgreSQL Batch Insert

```go
processor := NewPostgreSQLQueueProcessor(
    "postgresql://postgres:password@localhost:5432/market_data",
    "orders",
)

// Process with adaptive batching
processor.ProcessQueue(1000, 4, true)
```

### Market Order Processing (SE Scenario)

```go
processor := NewMarketOrderProcessor(
    "mongodb://localhost:27017",
    "postgresql://postgres:password@localhost:5432/market_data",
)

// Simulate high-volume trading
stats := processor.SimulateMarketOrders(100000, 10, true)
processor.PrintPerformanceReport(stats)
```

## Performance Characteristics

### Batching Thresholds

| Queue Size | Strategy | Batch Size | Expected Throughput |
|-----------|----------|------------|-------------------|
| < 100 | Single Insert | 1 | ~1K ops/sec |
| 100-1000 | Small Batch | 100 | ~10K ops/sec |
| 1000-10000 | Medium Batch | 500 | ~50K ops/sec |
| > 10000 | Large Batch | 1000+ | ~100K+ ops/sec |

### Cache Management

- **LRU Eviction**: Least recently used items removed first
- **Max Size**: Configurable (default: 10,000 items)
- **Memory Target**: ~100MB for typical market data
- **Hit Rate**: 70-90% for typical access patterns
- **Concurrent Access**: Thread-safe with sync.RWMutex

## Best Practices

1. **Goroutine Pool**: Use worker pools to limit concurrent goroutines
2. **Channel Buffering**: Buffer channels appropriately for throughput
3. **Connection Pooling**: Reuse database connections across goroutines
4. **Error Handling**: Use error channels for non-blocking error handling
5. **Context**: Use context for cancellation and timeout
6. **Memory Management**: Monitor with pprof and adjust batch sizes

## Architecture

```
┌─────────────────┐
│  Market Orders  │
│   (Producers)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Channel Queue   │
│   (Buffered)    │
└────────┬────────┘
         │
         ├──────┬──────┬──────┐
         ▼      ▼      ▼      ▼
    ┌────────────────────────┐
    │  Goroutine Pool (N)    │
    │  - Adaptive Batching   │
    │  - Cache Management    │
    └──────────┬─────────────┘
               │
         ┌─────┴─────┐
         ▼           ▼
    ┌────────┐  ┌──────────┐
    │ MongoDB│  │PostgreSQL│
    │ Bulk   │  │  Batch   │
    │ Insert │  │  Insert  │
    └────────┘  └──────────┘
```

## Running Examples

### Build

```bash
go build -o queue_processor .
```

### Run Examples

```bash
# Run MongoDB example
./queue_processor -mode=mongodb

# Run PostgreSQL example
./queue_processor -mode=postgresql

# Run market order simulation
./queue_processor -mode=market

# Run with custom settings
./queue_processor -mode=market -orders=100000 -workers=16 -batch=5000
```

## Troubleshooting

### Too Many Goroutines
- Reduce worker count
- Increase batch size
- Use goroutine pools

### Memory Issues
- Reduce batch sizes
- Decrease cache size
- Use `GOGC` environment variable
- Profile with `go tool pprof`

### Slow Performance
- Increase worker count
- Adjust batch sizes
- Check database indexes
- Profile with pprof

## Related Documentation

- [MongoDB Go Driver](https://pkg.go.dev/go.mongodb.org/mongo-driver/mongo)
- [pgx PostgreSQL Driver](https://pkg.go.dev/github.com/jackc/pgx/v5)
- [Go Channels](https://go.dev/tour/concurrency/2)
- [Go Goroutines](https://go.dev/tour/concurrency/1)
