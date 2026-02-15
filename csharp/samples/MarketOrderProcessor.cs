using System.Diagnostics;

namespace RestFixClient.Samples.QueueProcessing
{
    /// <summary>
    /// Market Order Processor - Large-Scale Stock Exchange (SE) Order Processing
    /// 
    /// Demonstrates processing of high-volume market orders with:
    /// - Dual database persistence (MongoDB + PostgreSQL)
    /// - Intelligent cache management
    /// - Adaptive batching based on order volume
    /// - Performance optimization for throughput
    /// - Realistic market order simulation
    /// </summary>
    public class MarketOrderProcessor : IDisposable
    {
        private readonly MongoDBQueueProcessor? _mongodbProcessor;
        private readonly PostgreSQLQueueProcessor? _postgresqlProcessor;
        private readonly MarketDataCache? _cache;
        private readonly bool _enableCache;
        private int _totalOrdersProcessed;
        private DateTime? _startTime;

        public MarketOrderProcessor(
            string? mongodbUri = "mongodb://localhost:27017",
            string? postgresqlUri = "Host=localhost;Port=5432;Database=market_data;Username=postgres;Password=password",
            int cacheSize = 10000,
            bool enableCache = true)
        {
            // Initialize database processors
            if (!string.IsNullOrEmpty(mongodbUri))
            {
                _mongodbProcessor = new MongoDBQueueProcessor(
                    mongodbUri,
                    "market_data",
                    "market_orders"
                );
            }

            if (!string.IsNullOrEmpty(postgresqlUri))
            {
                _postgresqlProcessor = new PostgreSQLQueueProcessor(
                    postgresqlUri,
                    "market_orders"
                );
            }

            // Initialize cache
            _enableCache = enableCache;
            if (enableCache)
            {
                _cache = new MarketDataCache(cacheSize);
            }
        }

        /// <summary>
        /// Generate realistic market order
        /// </summary>
        public static MarketOrder GenerateMarketOrder(int orderId, string symbol)
        {
            var random = new Random();
            return new MarketOrder
            {
                OrderId = $"MKT{orderId:D10}",
                Symbol = symbol,
                Quantity = random.Next(100, 10000),
                Price = (decimal)(random.NextDouble() * 950 + 50),
                Side = random.Next(2) == 0 ? "BUY" : "SELL",
                OrderType = "MARKET",
                Timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds(),
                TraderId = $"TRADER{random.Next(1, 1001):D4}",
                AccountId = $"ACC{random.Next(1, 501):D6}",
                Exchange = new[] { "NYSE", "NASDAQ", "LSE" }[random.Next(3)],
                Status = "PENDING"
            };
        }

        /// <summary>
        /// Cache order data
        /// </summary>
        private void CacheOrder(MarketOrder order)
        {
            if (_enableCache && _cache != null)
            {
                _cache.SetOrder(order.OrderId, order);
                _cache.SetSymbolPrice(order.Symbol, order.Price);
            }
        }

        /// <summary>
        /// Retrieve order from cache
        /// </summary>
        public MarketOrder? GetCachedOrder(string orderId)
        {
            if (_enableCache && _cache != null)
            {
                return _cache.GetOrder(orderId);
            }
            return null;
        }

        /// <summary>
        /// Process batch of orders
        /// </summary>
        public void ProcessOrderBatch(
            List<MarketOrder> orders,
            bool useMongodb = true,
            bool usePostgresql = true)
        {
            // Cache orders
            foreach (var order in orders)
            {
                CacheOrder(order);
            }

            // Enqueue to databases
            if (useMongodb && _mongodbProcessor != null)
            {
                _mongodbProcessor.EnqueueBatch(orders);
            }

            if (usePostgresql && _postgresqlProcessor != null)
            {
                _postgresqlProcessor.EnqueueBatch(orders);
            }

            Interlocked.Add(ref _totalOrdersProcessed, orders.Count);
        }

        /// <summary>
        /// Simulate high-volume market order processing
        /// </summary>
        public async Task<Dictionary<string, object>> SimulateMarketOrdersAsync(
            int numOrders = 100000,
            int workers = 8,
            bool useCache = true,
            string[]? symbols = null)
        {
            symbols ??= new[] { "AAPL", "GOOGL", "MSFT", "AMZN", "TSLA", "META", "NVDA", "AMD", "NFLX", "INTC" };

            Console.WriteLine("\n=== Market Order Simulation ===");
            Console.WriteLine($"Orders to process: {numOrders:N0}");
            Console.WriteLine($"Worker threads: {workers}");
            Console.WriteLine($"Cache enabled: {useCache}");
            Console.WriteLine($"Symbols: {symbols.Length}");
            Console.WriteLine($"Databases: MongoDB={_mongodbProcessor != null}, PostgreSQL={_postgresqlProcessor != null}");

            _startTime = DateTime.UtcNow;
            _enableCache = useCache;

            // Generate and process orders in batches
            const int batchSize = 1000;
            var totalBatches = (numOrders + batchSize - 1) / batchSize;

            Console.WriteLine($"\nGenerating and processing {totalBatches} batches...");

            var random = new Random();
            for (int batchNum = 0; batchNum < totalBatches; batchNum++)
            {
                var batchOrders = new List<MarketOrder>();
                var batchStart = batchNum * batchSize;
                var batchEnd = Math.Min(batchStart + batchSize, numOrders);

                // Generate batch
                for (int i = batchStart; i < batchEnd; i++)
                {
                    var symbol = symbols[random.Next(symbols.Length)];
                    var order = GenerateMarketOrder(i, symbol);
                    batchOrders.Add(order);
                }

                // Process batch
                ProcessOrderBatch(batchOrders);

                // Progress update
                if ((batchNum + 1) % 10 == 0)
                {
                    var progress = ((batchNum + 1) / (double)totalBatches) * 100;
                    Console.WriteLine($"  Progress: {progress:F1}% ({batchEnd:N0} orders)");
                }
            }

            // Process database queues
            Console.WriteLine("\nProcessing database queues...");

            var tasks = new List<Task>();

            if (_mongodbProcessor != null)
            {
                tasks.Add(_mongodbProcessor.ProcessQueueAsync(
                    batchSize: 1000,
                    workers: Math.Max(1, workers / 2),
                    adaptive: true
                ));
            }

            if (_postgresqlProcessor != null)
            {
                tasks.Add(_postgresqlProcessor.ProcessQueueAsync(
                    batchSize: 1000,
                    workers: Math.Max(1, workers / 2),
                    adaptive: true
                ));
            }

            await Task.WhenAll(tasks);

            var elapsed = (DateTime.UtcNow - _startTime.Value).TotalSeconds;

            // Collect statistics
            var stats = new Dictionary<string, object>
            {
                ["total_orders"] = numOrders,
                ["processed_orders"] = _totalOrdersProcessed,
                ["elapsed_seconds"] = Math.Round(elapsed, 2),
                ["throughput_per_second"] = Math.Round(numOrders / elapsed, 2),
                ["workers"] = workers,
                ["cache_enabled"] = useCache
            };

            if (_cache != null)
            {
                stats["cache_stats"] = _cache.GetStats();
            }

            if (_mongodbProcessor != null)
            {
                stats["mongodb_stats"] = _mongodbProcessor.GetStats();
            }

            if (_postgresqlProcessor != null)
            {
                stats["postgresql_stats"] = _postgresqlProcessor.GetStats();
            }

            return stats;
        }

        /// <summary>
        /// Print detailed performance report
        /// </summary>
        public static void PrintPerformanceReport(Dictionary<string, object> stats)
        {
            Console.WriteLine("\n" + new string('=', 60));
            Console.WriteLine("PERFORMANCE REPORT");
            Console.WriteLine(new string('=', 60));

            Console.WriteLine("\nOrder Processing:");
            Console.WriteLine($"  Total Orders: {stats["total_orders"]:N0}");
            Console.WriteLine($"  Processed: {stats["processed_orders"]:N0}");
            Console.WriteLine($"  Duration: {stats["elapsed_seconds"]} seconds");
            Console.WriteLine($"  Throughput: {stats["throughput_per_second"]:N0} orders/sec");

            if (stats.ContainsKey("cache_stats") && stats["cache_stats"] is Dictionary<string, object> cs)
            {
                Console.WriteLine("\nCache Performance:");
                foreach (var kvp in cs)
                {
                    Console.WriteLine($"  {kvp.Key}: {kvp.Value}");
                }
            }

            if (stats.ContainsKey("mongodb_stats") && stats["mongodb_stats"] is Dictionary<string, object> ms)
            {
                Console.WriteLine("\nMongoDB Performance:");
                foreach (var kvp in ms)
                {
                    Console.WriteLine($"  {kvp.Key}: {kvp.Value}");
                }
            }

            if (stats.ContainsKey("postgresql_stats") && stats["postgresql_stats"] is Dictionary<string, object> ps)
            {
                Console.WriteLine("\nPostgreSQL Performance:");
                foreach (var kvp in ps)
                {
                    Console.WriteLine($"  {kvp.Key}: {kvp.Value}");
                }
            }

            Console.WriteLine("\n" + new string('=', 60));
        }

        public void Dispose()
        {
            _mongodbProcessor?.Dispose();
            _postgresqlProcessor?.Dispose();
            _cache?.Dispose();
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// Run demonstration
        /// </summary>
        public static async Task RunSampleAsync()
        {
            Console.WriteLine("=== Stock Exchange Market Order Processing Demo (C#) ===");

            using var processor = new MarketOrderProcessor(
                mongodbUri: "mongodb://localhost:27017",
                postgresqlUri: "Host=localhost;Port=5432;Database=market_data;Username=postgres;Password=password",
                cacheSize: 10000,
                enableCache: true
            );

            // Simulate large-scale market order processing
            var stats = await processor.SimulateMarketOrdersAsync(
                numOrders: 50000,
                workers: 8,
                useCache: true
            );

            // Print performance report
            PrintPerformanceReport(stats);

            Console.WriteLine("\nDemo completed!");
        }
    }
}
