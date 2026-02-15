using System.Collections.Concurrent;
using Microsoft.Extensions.Caching.Memory;

namespace RestFixClient.Samples.QueueProcessing
{
    /// <summary>
    /// Cache Manager with LRU Eviction Policy
    /// 
    /// Provides efficient in-memory caching with automatic eviction based on:
    /// - Least Recently Used (LRU) policy via MemoryCache
    /// - Maximum size limits
    /// - Memory usage thresholds
    /// </summary>
    public class CacheManager : IDisposable
    {
        private readonly MemoryCache _cache;
        private readonly int _maxSize;
        private long _hits;
        private long _misses;

        public CacheManager(int maxSize = 10000, int expirationMinutes = 60)
        {
            _maxSize = maxSize;
            _cache = new MemoryCache(new MemoryCacheOptions
            {
                SizeLimit = maxSize
            });
        }

        /// <summary>
        /// Retrieve item from cache
        /// </summary>
        public T? Get<T>(string key)
        {
            if (_cache.TryGetValue(key, out T? value))
            {
                Interlocked.Increment(ref _hits);
                return value;
            }

            Interlocked.Increment(ref _misses);
            return default;
        }

        /// <summary>
        /// Add or update item in cache
        /// </summary>
        public void Set<T>(string key, T value, int expirationMinutes = 60)
        {
            var cacheEntryOptions = new MemoryCacheEntryOptions()
                .SetSize(1)
                .SetSlidingExpiration(TimeSpan.FromMinutes(expirationMinutes));

            _cache.Set(key, value, cacheEntryOptions);
        }

        /// <summary>
        /// Remove item from cache
        /// </summary>
        public void Delete(string key)
        {
            _cache.Remove(key);
        }

        /// <summary>
        /// Clear all items from cache
        /// </summary>
        public void Clear()
        {
            _cache.Dispose();
            Interlocked.Exchange(ref _hits, 0);
            Interlocked.Exchange(ref _misses, 0);
        }

        /// <summary>
        /// Get cache statistics
        /// </summary>
        public Dictionary<string, object> GetStats()
        {
            var totalRequests = _hits + _misses;
            var hitRate = totalRequests > 0 ? (_hits / (double)totalRequests * 100) : 0;

            return new Dictionary<string, object>
            {
                ["max_size"] = _maxSize,
                ["hits"] = _hits,
                ["misses"] = _misses,
                ["hit_rate"] = $"{hitRate:F2}%",
                ["total_requests"] = totalRequests
            };
        }

        public void Dispose()
        {
            _cache?.Dispose();
            GC.SuppressFinalize(this);
        }
    }

    /// <summary>
    /// Specialized cache for market data with symbol-based keys
    /// </summary>
    public class MarketDataCache : CacheManager
    {
        public MarketDataCache(int maxSize = 10000) : base(maxSize) { }

        /// <summary>
        /// Get order by ID
        /// </summary>
        public MarketOrder? GetOrder(string orderId)
        {
            return Get<MarketOrder>($"order:{orderId}");
        }

        /// <summary>
        /// Cache order data
        /// </summary>
        public void SetOrder(string orderId, MarketOrder orderData)
        {
            Set($"order:{orderId}", orderData);
        }

        /// <summary>
        /// Get cached price for symbol
        /// </summary>
        public decimal? GetSymbolPrice(string symbol)
        {
            return Get<decimal?>($"price:{symbol}");
        }

        /// <summary>
        /// Cache symbol price
        /// </summary>
        public void SetSymbolPrice(string symbol, decimal price)
        {
            Set($"price:{symbol}", price);
        }

        /// <summary>
        /// Run demonstration
        /// </summary>
        public static void RunSample()
        {
            Console.WriteLine("=== Cache Manager Demo (C#) ===\n");

            using var cache = new CacheManager(5);

            Console.WriteLine("Basic Cache Operations:");
            cache.Set("key1", "value1");
            cache.Set("key2", "value2");
            cache.Set("key3", "value3");

            Console.WriteLine($"Get key1: {cache.Get<string>("key1")}");
            Console.WriteLine($"Get key2: {cache.Get<string>("key2")}");
            Console.WriteLine($"Get missing: {cache.Get<string>("missing")}");

            Console.WriteLine("\nCache stats:");
            var stats = cache.GetStats();
            foreach (var kvp in stats)
            {
                Console.WriteLine($"  {kvp.Key}: {kvp.Value}");
            }

            // Market data cache
            Console.WriteLine("\n=== Market Data Cache ===");
            using var marketCache = new MarketDataCache(1000);

            marketCache.SetOrder("ORD001", new MarketOrder
            {
                OrderId = "ORD001",
                Symbol = "AAPL",
                Quantity = 100,
                Price = 150.50m,
                Side = "BUY"
            });

            marketCache.SetSymbolPrice("AAPL", 150.75m);

            var order = marketCache.GetOrder("ORD001");
            Console.WriteLine($"Order: {order?.OrderId} - {order?.Symbol} {order?.Side} {order?.Quantity}@{order?.Price}");
            Console.WriteLine($"Price: {marketCache.GetSymbolPrice("AAPL")}");

            Console.WriteLine("\nStats:");
            var marketStats = marketCache.GetStats();
            foreach (var kvp in marketStats)
            {
                Console.WriteLine($"  {kvp.Key}: {kvp.Value}");
            }
        }
    }
}
