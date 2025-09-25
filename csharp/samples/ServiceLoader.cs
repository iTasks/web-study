using Microsoft.Extensions.Caching.Memory;

namespace RestFixClient.Controllers.Service
{
    public class ServiceLoader
    {
        private static readonly MemoryCacheEntryOptions policy = new MemoryCacheEntryOptions();
        private static readonly LazyCache.IAppCache cache = new LazyCache.CachingService();
        private static readonly IStockClient stockClient = new StockClient();
        public static readonly int FETCH_STATUS_DELAY_MILLI = 3 * 1000;
        public static readonly int EXIT_DELAY_MILLI = 1000;
        public static readonly string MESSAGE_KEY = "message-key";

        public static IStockClient Instance() { return stockClient; }
        
        public static void Push(string key, Object value)
        {
            cache.Add(key, value, policy);
        }

        public static Object Pop(string key)
        {
            return cache.Get<object>(key);
        }

        public static void Clear(string key)
        {
            cache.Remove(key);
        }
    }
}
