# Queue Processing Samples with MongoDB and PostgreSQL (C#)

This directory contains comprehensive examples of parallel queue processing with efficient batch operations for both MongoDB and PostgreSQL databases using C# and .NET.

## Overview

These samples demonstrate:
- **Task-based Parallel Processing**: Multiple async workers using Task Parallel Library
- **Adaptive Batching**: Automatic switching between bulk and single operations based on queue size
- **Database Bulk Inserts**: Efficient batch operations for MongoDB and PostgreSQL
- **Cache Management**: Memory-efficient caching with MemoryCache and LRU eviction
- **Market Order Processing**: Large-scale market order handling (Stock Exchange scenarios)
- **Thread-safe Collections**: Using ConcurrentQueue for lock-free operations

## Files

### Core Samples
- `MongoDBQueueProcessor.cs` - MongoDB bulk insert with InsertManyAsync
- `PostgreSQLQueueProcessor.cs` - PostgreSQL batch insert with Npgsql
- `MarketOrderProcessor.cs` - Large-scale market order processing (SE scenario)
- `CacheManager.cs` - Efficient cache management with MemoryCache

### Configuration
- `RestFixClient.csproj` - Project file with NuGet packages

## Installation

### 1. Install Dependencies

The project uses the following NuGet packages (already referenced in `.csproj`):

```xml
<PackageReference Include="MongoDB.Driver" Version="2.23.1" />
<PackageReference Include="Npgsql" Version="8.0.1" />
<PackageReference Include="Microsoft.Extensions.Caching.Memory" Version="8.0.0" />
```

Restore packages:

```bash
dotnet restore
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

```csharp
using var processor = new MongoDBQueueProcessor(
    "mongodb://localhost:27017",
    "market_data",
    "orders"
);

// Enqueue orders
for (int i = 0; i < 1000; i++)
{
    processor.Enqueue(new MarketOrder { /* ... */ });
}

// Process with adaptive batching
await processor.ProcessQueueAsync(
    batchSize: 1000,
    workers: 4,
    adaptive: true
);
```

### PostgreSQL Batch Insert

```csharp
using var processor = new PostgreSQLQueueProcessor(
    "Host=localhost;Port=5432;Database=market_data;Username=postgres;Password=password",
    "orders"
);

// Process with adaptive batching
await processor.ProcessQueueAsync(
    batchSize: 1000,
    workers: 4,
    adaptive: true
);
```

### Market Order Processing (SE Scenario)

```csharp
using var processor = new MarketOrderProcessor(
    mongodbUri: "mongodb://localhost:27017",
    postgresqlUri: "Host=localhost;...",
    cacheSize: 10000,
    enableCache: true
);

// Simulate high-volume trading
var stats = await processor.SimulateMarketOrdersAsync(
    numOrders: 100000,
    workers: 8,
    useCache: true
);

MarketOrderProcessor.PrintPerformanceReport(stats);
```

### Cache Management

```csharp
using var cache = new MarketDataCache(maxSize: 10000);

// Cache order
cache.SetOrder("ORD001", new MarketOrder { /* ... */ });

// Retrieve order
var order = cache.GetOrder("ORD001");

// Cache symbol price
cache.SetSymbolPrice("AAPL", 150.50m);

// Get statistics
var stats = cache.GetStats();
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

- **LRU Eviction**: Automatic via MemoryCache with sliding expiration
- **Max Size**: Configurable (default: 10,000 items)
- **Memory Target**: ~100MB for typical market data
- **Hit Rate**: 70-90% for typical access patterns
- **Thread Safety**: Built-in with MemoryCache

## Best Practices

1. **Async/Await**: Use async methods for all I/O operations
2. **Task Parallel Library**: Leverage TPL for concurrent processing
3. **Connection Pooling**: Npgsql provides automatic connection pooling
4. **CancellationToken**: Use for graceful shutdown
5. **Using Statement**: Properly dispose resources with `using` blocks
6. **Thread Safety**: Use ConcurrentQueue and lock for shared state

## Architecture

```
┌─────────────────┐
│  Market Orders  │
│   (Producers)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ ConcurrentQueue │
│   (Thread-safe) │
└────────┬────────┘
         │
         ├──────┬──────┬──────┐
         ▼      ▼      ▼      ▼
    ┌────────────────────────┐
    │  Task Pool (N=4-16)    │
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
dotnet build
```

### Run Samples

Add to your Program.cs or create a test runner:

```csharp
// MongoDB sample
await MongoDBQueueProcessor.RunSampleAsync();

// PostgreSQL sample
await PostgreSQLQueueProcessor.RunSampleAsync();

// Market order simulation
await MarketOrderProcessor.RunSampleAsync();

// Cache manager demo
MarketDataCache.RunSample();
```

### Run with Docker Databases

```bash
# Start databases
docker-compose up -d

# Run application
dotnet run
```

## Troubleshooting

### Connection Errors
- Verify MongoDB/PostgreSQL are running
- Check connection strings
- Ensure firewall allows connections
- Verify database credentials

### Memory Issues
- Reduce batch size
- Decrease cache size
- Lower worker count
- Monitor with dotMemory or PerfView

### Slow Performance
- Increase worker count
- Adjust batch sizes
- Check database indexes
- Enable connection pooling
- Profile with dotTrace

## Integration with Existing Samples

These queue processing samples complement the existing C# samples:

- **ConcurrentCollectionsSample.cs** - Basic concurrent collections
- **ParallelProcessingSample.cs** - Parallel processing patterns
- **MemoryCacheSample.cs** - Caching patterns
- **MarketInfo.cs** - Market data models
- **StockClient.cs** - Stock trading client

The queue processing samples extend these patterns with production-ready database integration.

## Related Documentation

- [MongoDB C# Driver](https://mongodb.github.io/mongo-csharp-driver/)
- [Npgsql PostgreSQL](https://www.npgsql.org/)
- [MemoryCache](https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.caching.memory.memorycache)
- [Task Parallel Library](https://docs.microsoft.com/en-us/dotnet/standard/parallel-programming/task-parallel-library-tpl)
- [ConcurrentQueue](https://docs.microsoft.com/en-us/dotnet/api/system.collections.concurrent.concurrentqueue-1)

## Docker Compose

Create `docker-compose.yml` in the csharp/samples directory:

```yaml
version: '3.8'

services:
  mongodb:
    image: mongo:latest
    container_name: market_mongodb_csharp
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_DATABASE: market_data
    volumes:
      - mongodb_data:/data/db

  postgres:
    image: postgres:latest
    container_name: market_postgres_csharp
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: market_data
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  mongodb_data:
  postgres_data:
```
