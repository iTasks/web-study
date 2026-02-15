/**
 * PostgreSQL Queue Processor with Batch Insert Operations
 * 
 * Demonstrates efficient queue processing with PostgreSQL batch inserts:
 * - Batch consumption from queue
 * - Batch and COPY operations
 * - Connection pooling
 * - Performance monitoring
 */

const { Pool } = require('pg');

class PostgreSQLQueueProcessor {
  /**
   * Initialize PostgreSQL queue processor
   * @param {Object} options - Configuration options
   * @param {string} options.connectionString - PostgreSQL connection string
   * @param {string} options.tableName - Target table name
   */
  constructor({
    connectionString = 'postgresql://postgres:password@localhost:5432/market_data',
    tableName = 'orders'
  } = {}) {
    this.connectionString = connectionString;
    this.tableName = tableName;
    this.queue = [];
    this.processedCount = 0;
    this.errorCount = 0;
    this.totalTime = 0;
    
    // Create connection pool
    this.pool = new Pool({
      connectionString: this.connectionString,
      max: 20,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000
    });
    
    this.initialized = false;
  }

  /**
   * Initialize database (create table and indexes)
   */
  async initDatabase() {
    if (this.initialized) return;

    const client = await this.pool.connect();
    try {
      await client.query(`
        CREATE TABLE IF NOT EXISTS ${this.tableName} (
          id SERIAL PRIMARY KEY,
          order_id VARCHAR(50) UNIQUE NOT NULL,
          symbol VARCHAR(10) NOT NULL,
          quantity INTEGER NOT NULL,
          price NUMERIC(10, 2) NOT NULL,
          side VARCHAR(4) NOT NULL,
          order_type VARCHAR(20) NOT NULL,
          timestamp DOUBLE PRECISION NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);

      // Create indexes for better performance
      await client.query(`
        CREATE INDEX IF NOT EXISTS idx_${this.tableName}_symbol 
        ON ${this.tableName}(symbol)
      `);
      
      await client.query(`
        CREATE INDEX IF NOT EXISTS idx_${this.tableName}_timestamp 
        ON ${this.tableName}(timestamp)
      `);

      this.initialized = true;
    } finally {
      client.release();
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
   * Batch insert using parameterized query
   * @param {Array} documents - Documents to insert
   * @returns {number} Number of documents inserted
   */
  async batchInsert(documents) {
    if (!documents || documents.length === 0) {
      return 0;
    }

    await this.initDatabase();
    const client = await this.pool.connect();

    try {
      const startTime = Date.now();

      // Build values array
      const values = [];
      const placeholders = [];
      let paramIndex = 1;

      documents.forEach((doc, i) => {
        const rowPlaceholders = [];
        
        values.push(
          doc.order_id,
          doc.symbol,
          doc.quantity,
          doc.price,
          doc.side,
          doc.order_type,
          doc.timestamp
        );

        for (let j = 0; j < 7; j++) {
          rowPlaceholders.push(`$${paramIndex++}`);
        }
        
        placeholders.push(`(${rowPlaceholders.join(', ')})`);
      });

      const query = `
        INSERT INTO ${this.tableName} 
        (order_id, symbol, quantity, price, side, order_type, timestamp)
        VALUES ${placeholders.join(', ')}
        ON CONFLICT (order_id) DO NOTHING
      `;

      const result = await client.query(query, values);

      const elapsed = (Date.now() - startTime) / 1000;
      this.totalTime += elapsed;
      this.processedCount += result.rowCount;

      return result.rowCount;
    } catch (error) {
      this.errorCount += documents.length;
      console.error('Batch insert error:', error.message);
      return 0;
    } finally {
      client.release();
    }
  }

  /**
   * Insert single document (for small queues)
   * @param {Object} document - Document to insert
   * @returns {boolean} True if successful
   */
  async singleInsert(document) {
    await this.initDatabase();
    const client = await this.pool.connect();

    try {
      const startTime = Date.now();

      await client.query(
        `
        INSERT INTO ${this.tableName} 
        (order_id, symbol, quantity, price, side, order_type, timestamp)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        ON CONFLICT (order_id) DO NOTHING
        `,
        [
          document.order_id,
          document.symbol,
          document.quantity,
          document.price,
          document.side,
          document.order_type,
          document.timestamp
        ]
      );

      this.totalTime += (Date.now() - startTime) / 1000;
      this.processedCount++;
      return true;
    } catch (error) {
      this.errorCount++;
      console.error('Insert error:', error.message);
      return false;
    } finally {
      client.release();
    }
  }

  /**
   * Process queue with optional adaptive batching
   * @param {Object} options - Processing options
   * @param {number} options.batchSize - Maximum batch size
   * @param {number} options.workers - Number of worker threads (simplified)
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
        await this.batchInsert(batch);
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
   * Close database connection pool
   */
  async close() {
    await this.pool.end();
  }
}

// Example usage and demonstration
async function main() {
  console.log('=== PostgreSQL Queue Processor Demo ===\n');

  // Initialize processor
  const processor = new PostgreSQLQueueProcessor({
    connectionString: 'postgresql://postgres:password@localhost:5432/market_data',
    tableName: 'orders'
  });

  // Generate sample market orders
  console.log('Generating sample market orders...');
  const symbols = ['AAPL', 'GOOGL', 'MSFT', 'AMZN', 'TSLA'];

  for (let i = 0; i < 5000; i++) {
    const order = {
      order_id: `PG_ORD${String(i).padStart(6, '0')}`,
      symbol: symbols[Math.floor(Math.random() * symbols.length)],
      quantity: Math.floor(Math.random() * 1000) + 1,
      price: parseFloat((Math.random() * 400 + 100).toFixed(2)),
      side: Math.random() > 0.5 ? 'BUY' : 'SELL',
      order_type: 'MARKET',
      timestamp: Date.now() / 1000
    };
    processor.enqueue(order);
  }

  console.log(`Enqueued ${processor.queue.length} orders`);

  // Process with adaptive batching
  console.log('\nProcessing queue with adaptive batching...');
  const start = Date.now();
  await processor.processQueue({
    batchSize: 1000,
    workers: 4,
    adaptive: true
  });

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

module.exports = { PostgreSQLQueueProcessor };
