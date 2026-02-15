# Queue Processing Samples with MongoDB and PostgreSQL (Node.js)

This directory contains comprehensive examples of parallel queue processing with efficient batch operations for both MongoDB and PostgreSQL databases using Node.js.

## Overview

These samples demonstrate:
- **Parallel Queue Processing**: Multiple worker threads using Worker Threads API
- **Adaptive Batching**: Automatic switching between bulk and single operations based on queue size
- **Database Bulk Inserts**: Efficient batch operations for MongoDB and PostgreSQL
- **Cache Management**: Memory-efficient caching with LRU eviction
- **Market Order Processing**: Large-scale market order handling (Stock Exchange scenarios)
- **Promise-based Async Operations**: Modern async/await patterns

## Files

### Core Samples
- `mongodb-queue-processor.js` - MongoDB bulk insert with queue processing
- `postgresql-queue-processor.js` - PostgreSQL batch insert with queue processing
- `parallel-queue-workers.js` - Multi-worker parallel queue processing
- `market-order-processor.js` - Large-scale market order processing (SE scenario)
- `adaptive-batch-processor.js` - Intelligent batching based on queue size
- `cache-manager.js` - Efficient cache management with LRU eviction

### Utilities
- `package.json` - Node.js dependencies
- `docker-compose.yml` - Local MongoDB and PostgreSQL setup

## Installation

### 1. Install Dependencies

```bash
npm install
```

### 2. Start Databases (Docker)

```bash
docker-compose up -d
```

Or use the same docker-compose.yml from the Python samples.

## Usage Examples

### MongoDB Bulk Insert with Queue

```javascript
const { MongoDBQueueProcessor } = require('./mongodb-queue-processor');

const processor = new MongoDBQueueProcessor({
  connectionString: 'mongodb://localhost:27017',
  databaseName: 'market_data',
  collectionName: 'orders'
});

// Process queue with automatic batching
await processor.processQueue({ batchSize: 1000, workers: 4 });
```

### PostgreSQL Batch Insert

```javascript
const { PostgreSQLQueueProcessor } = require('./postgresql-queue-processor');

const processor = new PostgreSQLQueueProcessor({
  connectionString: 'postgresql://postgres:password@localhost:5432/market_data'
});

// Process with adaptive batching
await processor.processQueue({ adaptive: true, workers: 4 });
```

### Market Order Processing (SE Scenario)

```javascript
const { MarketOrderProcessor } = require('./market-order-processor');

const processor = new MarketOrderProcessor({
  mongodbUri: 'mongodb://localhost:27017',
  postgresqlUri: 'postgresql://localhost:5432/market_data'
});

// Simulate high-volume trading
const stats = await processor.simulateMarketOrders({
  numOrders: 100000,
  workers: 10,
  useCache: true
});

console.log(stats);
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
6. **Memory Management**: Monitor heap usage and adjust batch sizes accordingly

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

## Running Examples

### Run MongoDB Example

```bash
node mongodb-queue-processor.js
```

### Run PostgreSQL Example

```bash
node postgresql-queue-processor.js
```

### Run Market Order Simulation

```bash
node market-order-processor.js
```

### Run with Different Configurations

```bash
# High-volume scenario
WORKERS=16 BATCH_SIZE=5000 node market-order-processor.js

# Low-latency scenario
WORKERS=4 BATCH_SIZE=100 node market-order-processor.js
```

## Troubleshooting

### Memory Issues
- Reduce batch sizes
- Decrease worker count
- Enable cache eviction
- Monitor with `node --inspect`

### Slow Performance
- Increase worker count
- Adjust batch sizes
- Check database indexes
- Monitor network latency

### Connection Errors
- Verify database is running
- Check connection strings
- Review connection pool settings
- Check firewall rules

## Related Documentation

- [MongoDB Node.js Driver](https://www.mongodb.com/docs/drivers/node/)
- [node-postgres](https://node-postgres.com/)
- [Node.js Worker Threads](https://nodejs.org/api/worker_threads.html)
- [LRU Cache npm package](https://www.npmjs.com/package/lru-cache)
