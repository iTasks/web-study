# Queue Processing Samples with MongoDB and PostgreSQL

[← Back to Python](../../README.md) | [Main README](../../../README.md)

This directory contains comprehensive examples of parallel queue processing with efficient batch operations for both MongoDB and PostgreSQL databases.

## Overview

These samples demonstrate:
- **Parallel Queue Processing**: Multiple worker threads consuming from queues
- **Adaptive Batching**: Automatic switching between bulk and single operations based on queue size
- **Database Bulk Inserts**: Efficient batch operations for MongoDB and PostgreSQL
- **Cache Management**: Memory-efficient caching with automatic eviction
- **Market Order Processing**: Large-scale market order handling (Stock Exchange scenarios)
- **Throughput Optimization**: Balanced processor, memory, and I/O utilization

## Files

### Core Samples
- `mongodb_queue_processor.py` - MongoDB bulk insert with queue processing
- `postgresql_queue_processor.py` - PostgreSQL batch insert with queue processing
- `parallel_queue_workers.py` - Multi-worker parallel queue processing
- `market_order_processor.py` - Large-scale market order processing (SE scenario)
- `adaptive_batch_processor.py` - Intelligent batching based on queue size
- `cache_manager.py` - Efficient cache management with LRU eviction

### Utilities
- `requirements.txt` - Python dependencies
- `docker-compose.yml` - Local MongoDB and PostgreSQL setup
- `performance_test.py` - Performance benchmarking tool

## Installation

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Start Databases (Docker)

```bash
docker-compose up -d
```

Or manually:
- MongoDB: `docker run -d -p 27017:27017 --name mongo mongo:latest`
- PostgreSQL: `docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=password --name postgres postgres:latest`

## Usage Examples

### MongoDB Bulk Insert with Queue

```python
from mongodb_queue_processor import MongoDBQueueProcessor

processor = MongoDBQueueProcessor(
    connection_string="mongodb://localhost:27017",
    database_name="market_data",
    collection_name="orders"
)

# Process queue with automatic batching
processor.process_queue(batch_size=1000, workers=4)
```

### PostgreSQL Batch Insert

```python
from postgresql_queue_processor import PostgreSQLQueueProcessor

processor = PostgreSQLQueueProcessor(
    connection_string="postgresql://postgres:password@localhost:5432/market_data"
)

# Process with adaptive batching
processor.process_queue(adaptive=True, workers=4)
```

### Parallel Queue Workers

```python
from parallel_queue_workers import ParallelQueueProcessor

processor = ParallelQueueProcessor(
    queue_name="market_orders",
    num_workers=8,
    db_type="mongodb"  # or "postgresql"
)

processor.start()
```

### Market Order Processing (SE Scenario)

```python
from market_order_processor import MarketOrderProcessor

# Process large-scale market orders
processor = MarketOrderProcessor(
    mongodb_uri="mongodb://localhost:27017",
    postgresql_uri="postgresql://localhost:5432/market_data"
)

# Simulate high-volume trading
processor.simulate_market_orders(
    num_orders=100000,
    workers=10,
    use_cache=True
)
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

## Best Practices

1. **Queue Size Monitoring**: Regularly check queue depth to adjust worker count
2. **Batch Size Tuning**: Start with conservative sizes and increase based on performance
3. **Connection Pooling**: Reuse database connections across workers
4. **Error Handling**: Implement retry logic with exponential backoff
5. **Metrics Collection**: Track throughput, latency, and error rates

## Architecture

```
┌─────────────────┐
│  Market Orders  │
│   (Producers)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Queue Manager  │
│   (In-Memory)   │
└────────┬────────┘
         │
         ├──────┬──────┬──────┐
         ▼      ▼      ▼      ▼
    ┌────────────────────────┐
    │  Worker Pool (N=4-16)  │
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

## Monitoring

Track these metrics:
- Queue depth over time
- Processing throughput (ops/sec)
- Batch sizes used
- Cache hit rate
- Database latency
- Memory usage per worker

## Troubleshooting

### Slow Performance
- Increase worker count
- Adjust batch sizes
- Check database indexes
- Monitor network latency

### High Memory Usage
- Reduce cache size
- Lower batch sizes
- Decrease worker count
- Enable cache eviction

### Connection Errors
- Check connection strings
- Verify database is running
- Review connection pool settings
- Check network connectivity

## Related Documentation

- [MongoDB Bulk Write Operations](https://docs.mongodb.com/manual/core/bulk-write-operations/)
- [PostgreSQL COPY Command](https://www.postgresql.org/docs/current/sql-copy.html)
- [Python Queue Module](https://docs.python.org/3/library/queue.html)
- [Multiprocessing Best Practices](https://docs.python.org/3/library/multiprocessing.html)
