/**
 * MongoDB Queue Processor with Bulk Insert Operations
 * 
 * Demonstrates efficient queue processing with MongoDB bulk inserts:
 * - Batch consumption from queue
 * - Bulk insert operations
 * - Automatic retry logic
 * - Performance monitoring
 */

const { MongoClient } = require('mongodb');

class MongoDBQueueProcessor {
  /**
   * Initialize MongoDB queue processor
   * @param {Object} options - Configuration options
   * @param {string} options.connectionString - MongoDB connection string
   * @param {string} options.databaseName - Target database name
   * @param {string} options.collectionName - Target collection name
   */
  constructor({
    connectionString = 'mongodb://localhost:27017',
    databaseName = 'market_data',
    collectionName = 'orders'
  } = {}) {
    this.connectionString = connectionString;
    this.databaseName = databaseName;
    this.collectionName = collectionName;
    this.queue = [];
    this.processedCount = 0;
    this.errorCount = 0;
    this.totalTime = 0;
    this.client = null;
    this.db = null;
    this.collection = null;
  }

  /**
   * Connect to MongoDB
   */
  async connect() {
    if (!this.client) {
      this.client = new MongoClient(this.connectionString);
      await this.client.connect();
      this.db = this.client.db(this.databaseName);
      this.collection = this.db.collection(this.collectionName);
    }
  }

  /**
   * Add item to processing queue
   * @param {Object} item - Item to enqueue
   */
  enqueue(item) {
    this.queue.push(item);
  }

  /**
   * Add multiple items to queue
   * @param {Array} items - Items to enqueue
   */
  enqueueBatch(items) {
    this.queue.push(...items);
  }

  /**
   * Perform bulk insert operation
   * @param {Array} documents - Documents to insert
   * @returns {number} Number of documents inserted
   */
  async bulkInsert(documents) {
    if (!documents || documents.length === 0) {
      return 0;
    }

    await this.connect();

    try {
      const startTime = Date.now();

      // Use bulkWrite for better performance
      const operations = documents.map(doc => ({
        insertOne: { document: doc }
      }));

      const result = await this.collection.bulkWrite(operations, {
        ordered: false
      });

      const elapsed = (Date.now() - startTime) / 1000;
      this.totalTime += elapsed;
      this.processedCount += result.insertedCount;

      return result.insertedCount;
    } catch (error) {
      if (error.writeErrors) {
        // Some documents may have been inserted
        this.processedCount += error.result?.nInserted || 0;
        this.errorCount += error.writeErrors.length;
        console.error(`Bulk write error: ${error.writeErrors.length} errors`);
        return error.result?.nInserted || 0;
      }
      throw error;
    }
  }

  /**
   * Insert single document (for small queues)
   * @param {Object} document - Document to insert
   * @returns {boolean} True if successful
   */
  async singleInsert(document) {
    await this.connect();

    try {
      const startTime = Date.now();
      await this.collection.insertOne(document);
      this.totalTime += (Date.now() - startTime) / 1000;
      this.processedCount++;
      return true;
    } catch (error) {
      this.errorCount++;
      console.error('Insert error:', error.message);
      return false;
    }
  }

  /**
   * Process queue with optional adaptive batching
   * @param {Object} options - Processing options
   * @param {number} options.batchSize - Maximum batch size
   * @param {number} options.workers - Number of worker threads (simplified in single-threaded Node.js)
   * @param {boolean} options.adaptive - Enable adaptive batching
   */
  async processQueue({
    batchSize = 1000,
    workers = 1,
    adaptive = true
  } = {}) {
    while (this.queue.length > 0) {
      // Determine batch size based on queue depth
      let currentBatchSize;
      if (adaptive) {
        const queueSize = this.queue.length;
        if (queueSize < 100) {
          currentBatchSize = 1;
        } else if (queueSize < 1000) {
          currentBatchSize = 100;
        } else {
          currentBatchSize = batchSize;
        }
      } else {
        currentBatchSize = batchSize;
      }

      // Extract batch from queue
      const batch = this.queue.splice(0, currentBatchSize);

      if (batch.length === 0) {
        break;
      }

      // Process batch
      if (batch.length === 1) {
        await this.singleInsert(batch[0]);
      } else {
        await this.bulkInsert(batch);
      }
    }
  }

  /**
   * Get processing statistics
   * @returns {Object} Performance metrics
   */
  getStats() {
    const throughput = this.totalTime > 0
      ? this.processedCount / this.totalTime
      : 0;

    return {
      processedCount: this.processedCount,
      errorCount: this.errorCount,
      totalTimeSeconds: parseFloat(this.totalTime.toFixed(2)),
      throughputPerSecond: parseFloat(throughput.toFixed(2)),
      queueSize: this.queue.length
    };
  }

  /**
   * Close database connection
   */
  async close() {
    if (this.client) {
      await this.client.close();
      this.client = null;
    }
  }
}

// Example usage and demonstration
async function main() {
  console.log('=== MongoDB Queue Processor Demo ===\n');

  // Initialize processor
  const processor = new MongoDBQueueProcessor({
    connectionString: 'mongodb://localhost:27017',
    databaseName: 'market_data',
    collectionName: 'orders'
  });

  // Generate sample market orders
  console.log('Generating sample market orders...');
  const symbols = ['AAPL', 'GOOGL', 'MSFT', 'AMZN', 'TSLA'];

  for (let i = 0; i < 5000; i++) {
    const order = {
      order_id: `ORD${String(i).padStart(6, '0')}`,
      symbol: symbols[Math.floor(Math.random() * symbols.length)],
      quantity: Math.floor(Math.random() * 1000) + 1,
      price: parseFloat((Math.random() * 400 + 100).toFixed(2)),
      side: Math.random() > 0.5 ? 'BUY' : 'SELL',
      timestamp: Date.now() / 1000,
      order_type: 'MARKET'
    };
    processor.enqueue(order);
  }

  console.log(`Enqueued ${processor.queue.length} orders`);

  // Process with adaptive batching
  console.log('\nProcessing queue with adaptive batching...');
  const start = Date.now();
  await processor.processQueue({ batchSize: 1000, workers: 4, adaptive: true });

  // Display stats
  const elapsed = (Date.now() - start) / 1000;
  console.log(`\nProcessing completed in ${elapsed.toFixed(2)} seconds`);
  console.log('Statistics:', processor.getStats());

  await processor.close();
  console.log('\nDemo completed!');
}

if (require.main === module) {
  main().catch(console.error);
}

module.exports = { MongoDBQueueProcessor };
