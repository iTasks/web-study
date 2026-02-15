/**
 * Market Order Processor - Large-Scale Stock Exchange (SE) Order Processing
 * 
 * Demonstrates processing of high-volume market orders with:
 * - Dual database persistence (MongoDB + PostgreSQL)
 * - Intelligent cache management
 * - Adaptive batching based on order volume
 * - Performance optimization for throughput
 * - Realistic market order simulation
 */

const { MarketDataCache } = require('./cache-manager');
const { MongoDBQueueProcessor } = require('./mongodb-queue-processor');
const { PostgreSQLQueueProcessor } = require('./postgresql-queue-processor');

class MarketOrderProcessor {
  /**
   * Initialize market order processor
   * @param {Object} options - Configuration options
   */
  constructor({
    mongodbUri = 'mongodb://localhost:27017',
    postgresqlUri = 'postgresql://postgres:password@localhost:5432/market_data',
    cacheSize = 10000,
    enableCache = true
  } = {}) {
    // Initialize database processors
    this.mongodbProcessor = mongodbUri ? new MongoDBQueueProcessor({
      connectionString: mongodbUri,
      databaseName: 'market_data',
      collectionName: 'market_orders'
    }) : null;

    this.postgresqlProcessor = postgresqlUri ? new PostgreSQLQueueProcessor({
      connectionString: postgresqlUri,
      tableName: 'market_orders'
    }) : null;

    // Initialize cache
    this.cache = enableCache ? new MarketDataCache(cacheSize) : null;
    this.enableCache = enableCache;

    // Performance metrics
    this.totalOrdersProcessed = 0;
    this.startTime = null;
  }

  /**
   * Generate realistic market order
   * @param {number} orderId - Unique order ID
   * @param {string} symbol - Stock symbol
   * @returns {Object} Market order
   */
  generateMarketOrder(orderId, symbol) {
    return {
      order_id: `MKT${String(orderId).padStart(10, '0')}`,
      symbol: symbol,
      quantity: Math.floor(Math.random() * 9900) + 100,
      price: parseFloat((Math.random() * 950 + 50).toFixed(2)),
      side: Math.random() > 0.5 ? 'BUY' : 'SELL',
      order_type: 'MARKET',
      timestamp: Date.now() / 1000,
      trader_id: `TRADER${String(Math.floor(Math.random() * 1000) + 1).padStart(4, '0')}`,
      account_id: `ACC${String(Math.floor(Math.random() * 500) + 1).padStart(6, '0')}`,
      exchange: ['NYSE', 'NASDAQ', 'LSE'][Math.floor(Math.random() * 3)],
      status: 'PENDING'
    };
  }

  /**
   * Cache order data
   * @param {Object} order - Order to cache
   */
  cacheOrder(order) {
    if (this.enableCache && this.cache) {
      this.cache.setOrder(order.order_id, order);
      this.cache.setSymbolPrice(order.symbol, order.price);
    }
  }

  /**
   * Retrieve order from cache
   * @param {string} orderId - Order ID
   * @returns {Object|undefined} Cached order
   */
  getCachedOrder(orderId) {
    if (this.enableCache && this.cache) {
      return this.cache.getOrder(orderId);
    }
    return undefined;
  }

  /**
   * Process batch of orders
   * @param {Array} orders - Orders to process
   * @param {boolean} useMongodb - Store in MongoDB
   * @param {boolean} usePostgresql - Store in PostgreSQL
   */
  processOrderBatch(orders, useMongodb = true, usePostgresql = true) {
    // Cache orders
    orders.forEach(order => this.cacheOrder(order));

    // Enqueue to databases
    if (useMongodb && this.mongodbProcessor) {
      this.mongodbProcessor.enqueueBatch(orders);
    }

    if (usePostgresql && this.postgresqlProcessor) {
      this.postgresqlProcessor.enqueueBatch(orders);
    }

    this.totalOrdersProcessed += orders.length;
  }

  /**
   * Simulate high-volume market order processing
   * @param {Object} options - Simulation options
   * @returns {Object} Performance statistics
   */
  async simulateMarketOrders({
    numOrders = 100000,
    workers = 8,
    useCache = true,
    symbols = null
  } = {}) {
    if (!symbols) {
      symbols = [
        'AAPL', 'GOOGL', 'MSFT', 'AMZN', 'TSLA',
        'META', 'NVDA', 'AMD', 'NFLX', 'INTC'
      ];
    }

    console.log('\n=== Market Order Simulation ===');
    console.log(`Orders to process: ${numOrders.toLocaleString()}`);
    console.log(`Worker threads: ${workers}`);
    console.log(`Cache enabled: ${useCache}`);
    console.log(`Symbols: ${symbols.length}`);
    console.log(`Databases: MongoDB=${!!this.mongodbProcessor}, PostgreSQL=${!!this.postgresqlProcessor}`);

    this.startTime = Date.now();
    this.enableCache = useCache;

    // Generate and process orders in batches
    const batchSize = 1000;
    const totalBatches = Math.ceil(numOrders / batchSize);

    console.log(`\nGenerating and processing ${totalBatches} batches...`);

    for (let batchNum = 0; batchNum < totalBatches; batchNum++) {
      const batchOrders = [];
      const batchStart = batchNum * batchSize;
      const batchEnd = Math.min(batchStart + batchSize, numOrders);

      // Generate batch
      for (let i = batchStart; i < batchEnd; i++) {
        const symbol = symbols[Math.floor(Math.random() * symbols.length)];
        const order = this.generateMarketOrder(i, symbol);
        batchOrders.push(order);
      }

      // Process batch
      this.processOrderBatch(batchOrders);

      // Progress update
      if ((batchNum + 1) % 10 === 0) {
        const progress = ((batchNum + 1) / totalBatches) * 100;
        console.log(`  Progress: ${progress.toFixed(1)}% (${batchEnd.toLocaleString()} orders)`);
      }
    }

    // Process database queues
    console.log('\nProcessing database queues...');

    const dbPromises = [];

    if (this.mongodbProcessor) {
      dbPromises.push(
        this.mongodbProcessor.processQueue({
          batchSize: 1000,
          workers: Math.max(1, Math.floor(workers / 2)),
          adaptive: true
        })
      );
    }

    if (this.postgresqlProcessor) {
      dbPromises.push(
        this.postgresqlProcessor.processQueue({
          batchSize: 1000,
          workers: Math.max(1, Math.floor(workers / 2)),
          adaptive: true
        })
      );
    }

    await Promise.all(dbPromises);

    const elapsed = (Date.now() - this.startTime) / 1000;

    // Collect statistics
    const stats = {
      totalOrders: numOrders,
      processedOrders: this.totalOrdersProcessed,
      elapsedSeconds: parseFloat(elapsed.toFixed(2)),
      throughputPerSecond: parseFloat((numOrders / elapsed).toFixed(2)),
      workers: workers,
      cacheEnabled: useCache,
      cacheStats: this.cache ? this.cache.getStats() : null,
      mongodbStats: this.mongodbProcessor ? this.mongodbProcessor.getStats() : null,
      postgresqlStats: this.postgresqlProcessor ? this.postgresqlProcessor.getStats() : null
    };

    return stats;
  }

  /**
   * Print detailed performance report
   * @param {Object} stats - Statistics object
   */
  printPerformanceReport(stats) {
    console.log('\n' + '='.repeat(60));
    console.log('PERFORMANCE REPORT');
    console.log('='.repeat(60));

    console.log('\nOrder Processing:');
    console.log(`  Total Orders: ${stats.totalOrders.toLocaleString()}`);
    console.log(`  Processed: ${stats.processedOrders.toLocaleString()}`);
    console.log(`  Duration: ${stats.elapsedSeconds} seconds`);
    console.log(`  Throughput: ${stats.throughputPerSecond.toLocaleString()} orders/sec`);

    if (stats.cacheStats) {
      console.log('\nCache Performance:');
      const cs = stats.cacheStats;
      console.log(`  Size: ${cs.size.toLocaleString()} / ${cs.maxSize.toLocaleString()}`);
      console.log(`  Hits: ${cs.hits.toLocaleString()}`);
      console.log(`  Misses: ${cs.misses.toLocaleString()}`);
      console.log(`  Hit Rate: ${cs.hitRate}`);
    }

    if (stats.mongodbStats) {
      console.log('\nMongoDB Performance:');
      const ms = stats.mongodbStats;
      console.log(`  Processed: ${ms.processedCount.toLocaleString()}`);
      console.log(`  Errors: ${ms.errorCount}`);
      console.log(`  Time: ${ms.totalTimeSeconds}s`);
      console.log(`  Throughput: ${ms.throughputPerSecond.toLocaleString()} ops/sec`);
    }

    if (stats.postgresqlStats) {
      console.log('\nPostgreSQL Performance:');
      const ps = stats.postgresqlStats;
      console.log(`  Processed: ${ps.processedCount.toLocaleString()}`);
      console.log(`  Errors: ${ps.errorCount}`);
      console.log(`  Time: ${ps.totalTimeSeconds}s`);
      console.log(`  Throughput: ${ps.throughputPerSecond.toLocaleString()} ops/sec`);
    }

    console.log('\n' + '='.repeat(60));
  }

  /**
   * Close all connections
   */
  async close() {
    const closePromises = [];

    if (this.mongodbProcessor) {
      closePromises.push(this.mongodbProcessor.close());
    }

    if (this.postgresqlProcessor) {
      closePromises.push(this.postgresqlProcessor.close());
    }

    await Promise.all(closePromises);
  }
}

// Example usage and demonstration
async function main() {
  console.log('=== Stock Exchange Market Order Processing Demo ===');

  // Initialize processor
  const processor = new MarketOrderProcessor({
    mongodbUri: 'mongodb://localhost:27017',
    postgresqlUri: 'postgresql://postgres:password@localhost:5432/market_data',
    cacheSize: 10000,
    enableCache: true
  });

  // Simulate large-scale market order processing
  const stats = await processor.simulateMarketOrders({
    numOrders: 50000,
    workers: 8,
    useCache: true
  });

  // Print performance report
  processor.printPerformanceReport(stats);

  await processor.close();
  console.log('\nDemo completed!');
}

if (require.main === module) {
  main().catch(console.error);
}

module.exports = { MarketOrderProcessor };
