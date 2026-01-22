using Microsoft.Extensions.Caching.Memory;
using LazyCache;

namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates in-memory caching patterns using IMemoryCache
    /// </summary>
    public class MemoryCacheSample
    {
        private readonly IMemoryCache _cache;
        
        public MemoryCacheSample()
        {
            _cache = new MemoryCache(new MemoryCacheOptions
            {
                SizeLimit = 1024 // Optional size limit
            });
        }

        /// <summary>
        /// Basic cache get/set
        /// </summary>
        public string BasicCacheExample(string key)
        {
            // Try to get from cache
            if (_cache.TryGetValue(key, out string? cachedValue))
            {
                Console.WriteLine($"Cache hit for key: {key}");
                return cachedValue!;
            }
            
            // Not in cache, compute value
            Console.WriteLine($"Cache miss for key: {key}");
            var value = $"Computed value for {key}";
            
            // Store in cache
            _cache.Set(key, value);
            
            return value;
        }

        /// <summary>
        /// Cache with absolute expiration
        /// </summary>
        public void CacheWithAbsoluteExpirationExample()
        {
            var cacheEntryOptions = new MemoryCacheEntryOptions()
                .SetAbsoluteExpiration(TimeSpan.FromSeconds(30));
            
            _cache.Set("key1", "value1", cacheEntryOptions);
            Console.WriteLine("Cached with 30 second absolute expiration");
        }

        /// <summary>
        /// Cache with sliding expiration
        /// </summary>
        public void CacheWithSlidingExpirationExample()
        {
            var cacheEntryOptions = new MemoryCacheEntryOptions()
                .SetSlidingExpiration(TimeSpan.FromSeconds(10));
            
            _cache.Set("key2", "value2", cacheEntryOptions);
            Console.WriteLine("Cached with 10 second sliding expiration");
        }

        /// <summary>
        /// Cache with size tracking
        /// </summary>
        public void CacheWithSizeExample()
        {
            var cacheEntryOptions = new MemoryCacheEntryOptions()
                .SetSize(1) // Size of this entry
                .SetAbsoluteExpiration(TimeSpan.FromMinutes(5));
            
            _cache.Set("key3", "value3", cacheEntryOptions);
        }

        /// <summary>
        /// Cache with priority
        /// </summary>
        public void CacheWithPriorityExample()
        {
            // High priority items are less likely to be evicted
            var highPriority = new MemoryCacheEntryOptions()
                .SetPriority(CacheItemPriority.High);
            
            _cache.Set("important", "critical data", highPriority);
            
            // Low priority items are more likely to be evicted
            var lowPriority = new MemoryCacheEntryOptions()
                .SetPriority(CacheItemPriority.Low);
            
            _cache.Set("temp", "temporary data", lowPriority);
        }

        /// <summary>
        /// Cache with eviction callback
        /// </summary>
        public void CacheWithEvictionCallbackExample()
        {
            var cacheEntryOptions = new MemoryCacheEntryOptions()
                .SetAbsoluteExpiration(TimeSpan.FromSeconds(5))
                .RegisterPostEvictionCallback((key, value, reason, state) =>
                {
                    Console.WriteLine($"Cache entry evicted. Key: {key}, Reason: {reason}");
                });
            
            _cache.Set("key4", "value4", cacheEntryOptions);
        }

        /// <summary>
        /// GetOrCreate pattern for lazy loading
        /// </summary>
        public async Task<string> GetOrCreateAsyncExample(string key)
        {
            return await _cache.GetOrCreateAsync(key, async entry =>
            {
                entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5);
                
                Console.WriteLine($"Creating value for {key}");
                await Task.Delay(1000); // Simulate expensive operation
                
                return $"Generated value for {key}";
            });
        }

        /// <summary>
        /// Typed cache wrapper
        /// </summary>
        public class TypedCache<TKey, TValue> where TKey : notnull
        {
            private readonly IMemoryCache _cache;
            
            public TypedCache(IMemoryCache cache)
            {
                _cache = cache;
            }
            
            public TValue? Get(TKey key)
            {
                return _cache.Get<TValue>(key);
            }
            
            public void Set(TKey key, TValue value, TimeSpan expiration)
            {
                var options = new MemoryCacheEntryOptions()
                    .SetAbsoluteExpiration(expiration);
                
                _cache.Set(key, value, options);
            }
            
            public async Task<TValue> GetOrCreateAsync(TKey key, Func<Task<TValue>> factory, TimeSpan expiration)
            {
                if (_cache.TryGetValue(key, out TValue? value))
                {
                    return value!;
                }
                
                value = await factory();
                
                var options = new MemoryCacheEntryOptions()
                    .SetAbsoluteExpiration(expiration);
                
                _cache.Set(key, value, options);
                
                return value;
            }
        }

        /// <summary>
        /// Using LazyCache for simpler API
        /// </summary>
        public class LazyCacheExample
        {
            private readonly IAppCache _cache;
            
            public LazyCacheExample()
            {
                _cache = new CachingService();
            }
            
            public async Task<string> GetDataAsync(int id)
            {
                return await _cache.GetOrAddAsync($"data_{id}", async () =>
                {
                    Console.WriteLine($"Fetching data for id: {id}");
                    await Task.Delay(1000);
                    return $"Data for {id}";
                }, DateTimeOffset.Now.AddMinutes(5));
            }
            
            public void RemoveData(int id)
            {
                _cache.Remove($"data_{id}");
            }
        }

        /// <summary>
        /// Cache aside pattern
        /// </summary>
        public class CacheAsidePattern
        {
            private readonly IMemoryCache _cache;
            private readonly Dictionary<int, string> _database;
            
            public CacheAsidePattern()
            {
                _cache = new MemoryCache(new MemoryCacheOptions());
                _database = new Dictionary<int, string>
                {
                    { 1, "Data 1" },
                    { 2, "Data 2" },
                    { 3, "Data 3" }
                };
            }
            
            public async Task<string?> GetDataAsync(int id)
            {
                // Try cache first
                if (_cache.TryGetValue(id, out string? cachedData))
                {
                    Console.WriteLine($"Cache hit for id: {id}");
                    return cachedData;
                }
                
                // Cache miss - fetch from database
                Console.WriteLine($"Cache miss for id: {id}, fetching from database");
                await Task.Delay(100); // Simulate database latency
                
                if (_database.TryGetValue(id, out var data))
                {
                    // Store in cache
                    var options = new MemoryCacheEntryOptions()
                        .SetAbsoluteExpiration(TimeSpan.FromMinutes(10));
                    
                    _cache.Set(id, data, options);
                    return data;
                }
                
                return null;
            }
            
            public void UpdateData(int id, string data)
            {
                // Update database
                _database[id] = data;
                
                // Invalidate cache
                _cache.Remove(id);
            }
        }

        /// <summary>
        /// Demonstrates running memory cache samples
        /// </summary>
        public static async Task RunSamplesAsync()
        {
            var sample = new MemoryCacheSample();
            
            Console.WriteLine("=== Memory Cache Sample ===\n");
            
            // Basic cache
            Console.WriteLine("1. Basic cache get/set:");
            sample.BasicCacheExample("test1");
            sample.BasicCacheExample("test1"); // Should hit cache
            Console.WriteLine();
            
            // Cache with expiration
            Console.WriteLine("2. Cache with expiration:");
            sample.CacheWithAbsoluteExpirationExample();
            sample.CacheWithSlidingExpirationExample();
            Console.WriteLine();
            
            // GetOrCreate pattern
            Console.WriteLine("3. GetOrCreate pattern:");
            await sample.GetOrCreateAsyncExample("lazy1");
            await sample.GetOrCreateAsyncExample("lazy1"); // Should use cached value
            Console.WriteLine();
            
            // Eviction callback
            Console.WriteLine("4. Cache with eviction callback:");
            sample.CacheWithEvictionCallbackExample();
            await Task.Delay(6000); // Wait for expiration
            Console.WriteLine();
            
            // LazyCache
            Console.WriteLine("5. LazyCache example:");
            var lazyCache = new LazyCacheExample();
            await lazyCache.GetDataAsync(1);
            await lazyCache.GetDataAsync(1); // Should use cached value
            Console.WriteLine();
            
            // Cache-aside pattern
            Console.WriteLine("6. Cache-aside pattern:");
            var cacheAside = new CacheAsidePattern();
            await cacheAside.GetDataAsync(1);
            await cacheAside.GetDataAsync(1); // Should hit cache
            cacheAside.UpdateData(1, "Updated Data 1");
            await cacheAside.GetDataAsync(1); // Should miss cache after update
            Console.WriteLine();
        }
    }
}
