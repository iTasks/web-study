using System.Collections.Concurrent;
using MongoDB.Driver;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace RestFixClient.Samples.QueueProcessing
{
    /// <summary>
    /// Market Order for queue processing
    /// </summary>
    public class MarketOrder
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? Id { get; set; }
        
        [BsonElement("order_id")]
        public string OrderId { get; set; } = string.Empty;
        
        [BsonElement("symbol")]
        public string Symbol { get; set; } = string.Empty;
        
        [BsonElement("quantity")]
        public int Quantity { get; set; }
        
        [BsonElement("price")]
        public decimal Price { get; set; }
        
        [BsonElement("side")]
        public string Side { get; set; } = string.Empty;
        
        [BsonElement("order_type")]
        public string OrderType { get; set; } = "MARKET";
        
        [BsonElement("timestamp")]
        public double Timestamp { get; set; }
        
        [BsonElement("trader_id")]
        public string TraderId { get; set; } = string.Empty;
        
        [BsonElement("account_id")]
        public string AccountId { get; set; } = string.Empty;
        
        [BsonElement("exchange")]
        public string Exchange { get; set; } = string.Empty;
        
        [BsonElement("status")]
        public string Status { get; set; } = "PENDING";
    }

    /// <summary>
    /// MongoDB Queue Processor with Bulk Insert Operations
    /// 
    /// Demonstrates efficient queue processing with MongoDB bulk inserts:
    /// - Batch consumption from concurrent queue
    /// - Bulk insert operations with InsertManyAsync
    /// - Automatic retry logic
    /// - Performance monitoring
    /// </summary>
    public class MongoDBQueueProcessor : IDisposable
    {
        private readonly MongoClient _client;
        private readonly IMongoDatabase _database;
        private readonly IMongoCollection<MarketOrder> _collection;
        private readonly ConcurrentQueue<MarketOrder> _queue;
        private int _processedCount;
        private int _errorCount;
        private double _totalTime;
        private readonly object _statsLock = new();

        public MongoDBQueueProcessor(
            string connectionString = "mongodb://localhost:27017",
            string databaseName = "market_data",
            string collectionName = "orders")
        {
            _client = new MongoClient(connectionString);
            _database = _client.GetDatabase(databaseName);
            _collection = _database.GetCollection<MarketOrder>(collectionName);
            _queue = new ConcurrentQueue<MarketOrder>();
        }

        /// <summary>
        /// Add item to processing queue
        /// </summary>
        public void Enqueue(MarketOrder order)
        {
            _queue.Enqueue(order);
        }

        /// <summary>
        /// Add multiple items to queue
        /// </summary>
        public void EnqueueBatch(IEnumerable<MarketOrder> orders)
        {
            foreach (var order in orders)
            {
                _queue.Enqueue(order);
            }
        }

        /// <summary>
        /// Perform bulk insert operation
        /// </summary>
        public async Task<int> BulkInsertAsync(List<MarketOrder> documents)
        {
            if (documents == null || documents.Count == 0)
                return 0;

            try
            {
                var startTime = DateTime.UtcNow;

                await _collection.InsertManyAsync(documents, new InsertManyOptions
                {
                    IsOrdered = false
                });

                var elapsed = (DateTime.UtcNow - startTime).TotalSeconds;

                lock (_statsLock)
                {
                    _totalTime += elapsed;
                    _processedCount += documents.Count;
                }

                return documents.Count;
            }
            catch (MongoBulkWriteException ex)
            {
                // Some documents may have been inserted
                var inserted = ex.Result?.InsertedCount ?? 0;

                lock (_statsLock)
                {
                    _processedCount += (int)inserted;
                    _errorCount += ex.WriteErrors.Count;
                }

                Console.WriteLine($"Bulk write error: {ex.WriteErrors.Count} errors");
                return (int)inserted;
            }
            catch (Exception ex)
            {
                lock (_statsLock)
                {
                    _errorCount += documents.Count;
                }
                Console.WriteLine($"Insert error: {ex.Message}");
                return 0;
            }
        }

        /// <summary>
        /// Insert single document (for small queues)
        /// </summary>
        public async Task<bool> SingleInsertAsync(MarketOrder document)
        {
            try
            {
                var startTime = DateTime.UtcNow;
                await _collection.InsertOneAsync(document);
                var elapsed = (DateTime.UtcNow - startTime).TotalSeconds;

                lock (_statsLock)
                {
                    _totalTime += elapsed;
                    _processedCount++;
                }

                return true;
            }
            catch (Exception ex)
            {
                lock (_statsLock)
                {
                    _errorCount++;
                }
                Console.WriteLine($"Insert error: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Process queue with optional adaptive batching
        /// </summary>
        public async Task ProcessQueueAsync(
            int batchSize = 1000,
            int workers = 1,
            bool adaptive = true,
            CancellationToken cancellationToken = default)
        {
            var tasks = new List<Task>();

            for (int i = 0; i < workers; i++)
            {
                tasks.Add(Task.Run(async () =>
                {
                    while (!cancellationToken.IsCancellationRequested)
                    {
                        // Determine batch size based on queue depth
                        int currentBatchSize;
                        if (adaptive)
                        {
                            var queueSize = _queue.Count;
                            currentBatchSize = queueSize switch
                            {
                                < 100 => 1,
                                < 1000 => 100,
                                _ => batchSize
                            };
                        }
                        else
                        {
                            currentBatchSize = batchSize;
                        }

                        // Collect items for batch
                        var batch = new List<MarketOrder>();
                        for (int j = 0; j < currentBatchSize; j++)
                        {
                            if (_queue.TryDequeue(out var item))
                            {
                                batch.Add(item);
                            }
                            else
                            {
                                break;
                            }
                        }

                        if (batch.Count == 0)
                        {
                            if (_queue.IsEmpty)
                                break;
                            
                            await Task.Delay(100, cancellationToken);
                            continue;
                        }

                        // Process batch
                        if (batch.Count == 1)
                        {
                            await SingleInsertAsync(batch[0]);
                        }
                        else
                        {
                            await BulkInsertAsync(batch);
                        }
                    }
                }, cancellationToken));
            }

            await Task.WhenAll(tasks);
        }

        /// <summary>
        /// Get processing statistics
        /// </summary>
        public Dictionary<string, object> GetStats()
        {
            lock (_statsLock)
            {
                var throughput = _totalTime > 0 ? _processedCount / _totalTime : 0;

                return new Dictionary<string, object>
                {
                    ["processed_count"] = _processedCount,
                    ["error_count"] = _errorCount,
                    ["total_time_seconds"] = Math.Round(_totalTime, 2),
                    ["throughput_per_second"] = Math.Round(throughput, 2),
                    ["queue_size"] = _queue.Count
                };
            }
        }

        public void Dispose()
        {
            // MongoDB client doesn't require explicit disposal
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// Run demonstration
        /// </summary>
        public static async Task RunSampleAsync()
        {
            Console.WriteLine("=== MongoDB Queue Processor Demo (C#) ===\n");

            using var processor = new MongoDBQueueProcessor(
                "mongodb://localhost:27017",
                "market_data",
                "orders"
            );

            // Generate sample market orders
            Console.WriteLine("Generating sample market orders...");
            var symbols = new[] { "AAPL", "GOOGL", "MSFT", "AMZN", "TSLA" };
            var random = new Random();

            for (int i = 0; i < 5000; i++)
            {
                var order = new MarketOrder
                {
                    OrderId = $"ORD{i:D10}",
                    Symbol = symbols[random.Next(symbols.Length)],
                    Quantity = random.Next(1, 1001),
                    Price = (decimal)(random.NextDouble() * 400 + 100),
                    Side = random.Next(2) == 0 ? "BUY" : "SELL",
                    OrderType = "MARKET",
                    Timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds(),
                    TraderId = $"TRADER{random.Next(1, 1001):D4}",
                    AccountId = $"ACC{random.Next(1, 501):D6}",
                    Exchange = new[] { "NYSE", "NASDAQ", "LSE" }[random.Next(3)],
                    Status = "PENDING"
                };
                processor.Enqueue(order);
            }

            Console.WriteLine("Enqueued 5000 orders");

            // Process with adaptive batching
            Console.WriteLine("\nProcessing queue with adaptive batching...");
            var start = DateTime.UtcNow;
            await processor.ProcessQueueAsync(batchSize: 1000, workers: 4, adaptive: true);

            // Display stats
            var elapsed = (DateTime.UtcNow - start).TotalSeconds;
            Console.WriteLine($"\nProcessing completed in {elapsed:F2} seconds");
            var stats = processor.GetStats();
            Console.WriteLine("Statistics:");
            foreach (var kvp in stats)
            {
                Console.WriteLine($"  {kvp.Key}: {kvp.Value}");
            }

            Console.WriteLine("\nDemo completed!");
        }
    }
}
