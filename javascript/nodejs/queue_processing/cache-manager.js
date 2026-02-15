/**
 * Cache Manager with LRU Eviction Policy
 * 
 * Provides efficient in-memory caching with automatic eviction based on:
 * - Least Recently Used (LRU) policy
 * - Maximum size limits
 */

const { LRUCache } = require('lru-cache');

class CacheManager {
  /**
   * Initialize cache manager
   * @param {number} maxSize - Maximum number of items in cache
   * @param {number} ttl - Time-to-live in milliseconds (optional)
   */
  constructor(maxSize = 10000, ttl = null) {
    this.maxSize = maxSize;
    this.ttl = ttl;
    
    const options = {
      max: maxSize
    };
    
    if (ttl) {
      options.ttl = ttl;
    }
    
    this.cache = new LRUCache(options);
    this.hits = 0;
    this.misses = 0;
  }

  /**
   * Retrieve item from cache
   * @param {string} key - Cache key
   * @returns {*} Cached value or undefined if not found
   */
  get(key) {
    const value = this.cache.get(key);
    
    if (value !== undefined) {
      this.hits++;
      return value;
    }
    
    this.misses++;
    return undefined;
  }

  /**
   * Add or update item in cache
   * @param {string} key - Cache key
   * @param {*} value - Value to cache
   */
  set(key, value) {
    this.cache.set(key, value);
  }

  /**
   * Remove item from cache
   * @param {string} key - Cache key
   * @returns {boolean} True if item was removed
   */
  delete(key) {
    return this.cache.delete(key);
  }

  /**
   * Clear all items from cache
   */
  clear() {
    this.cache.clear();
    this.hits = 0;
    this.misses = 0;
  }

  /**
   * Get current cache size
   * @returns {number} Current size
   */
  size() {
    return this.cache.size;
  }

  /**
   * Get cache statistics
   * @returns {Object} Cache statistics
   */
  getStats() {
    const totalRequests = this.hits + this.misses;
    const hitRate = totalRequests > 0 ? (this.hits / totalRequests * 100) : 0;

    return {
      size: this.cache.size,
      maxSize: this.maxSize,
      hits: this.hits,
      misses: this.misses,
      hitRate: `${hitRate.toFixed(2)}%`,
      totalRequests
    };
  }
}

class MarketDataCache extends CacheManager {
  /**
   * Specialized cache for market data with symbol-based keys
   */
  
  /**
   * Get order by ID
   * @param {string} orderId - Order ID
   * @returns {Object|undefined} Order data
   */
  getOrder(orderId) {
    return this.get(`order:${orderId}`);
  }

  /**
   * Cache order data
   * @param {string} orderId - Order ID
   * @param {Object} orderData - Order data
   */
  setOrder(orderId, orderData) {
    this.set(`order:${orderId}`, orderData);
  }

  /**
   * Get cached price for symbol
   * @param {string} symbol - Stock symbol
   * @returns {number|undefined} Price
   */
  getSymbolPrice(symbol) {
    return this.get(`price:${symbol}`);
  }

  /**
   * Cache symbol price
   * @param {string} symbol - Stock symbol
   * @param {number} price - Price
   */
  setSymbolPrice(symbol, price) {
    this.set(`price:${symbol}`, price);
  }
}

// Example usage
if (require.main === module) {
  console.log('=== Basic Cache Operations ===');
  const cache = new CacheManager(5);

  cache.set('key1', 'value1');
  cache.set('key2', 'value2');
  cache.set('key3', 'value3');

  console.log('Get key1:', cache.get('key1'));
  console.log('Get key2:', cache.get('key2'));
  console.log('Get missing:', cache.get('missing'));

  console.log('\nCache stats:', cache.getStats());

  // LRU eviction demo
  console.log('\n=== LRU Eviction Demo ===');
  for (let i = 0; i < 10; i++) {
    cache.set(`key${i}`, `value${i}`);
  }

  console.log(`Cache size: ${cache.size()} (max: ${cache.maxSize})`);
  console.log('Oldest keys evicted, newest keys remain');

  // Market data cache
  console.log('\n=== Market Data Cache ===');
  const marketCache = new MarketDataCache(1000);

  marketCache.setOrder('ORD001', {
    symbol: 'AAPL',
    quantity: 100,
    price: 150.50,
    side: 'BUY'
  });

  marketCache.setSymbolPrice('AAPL', 150.75);

  console.log('Order:', marketCache.getOrder('ORD001'));
  console.log('Price:', marketCache.getSymbolPrice('AAPL'));
  console.log('\nStats:', marketCache.getStats());
}

module.exports = { CacheManager, MarketDataCache };
