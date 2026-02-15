using System.Collections.Concurrent;
using System.Data;
using Npgsql;

namespace RestFixClient.Samples.QueueProcessing
{
    /// <summary>
    /// PostgreSQL Queue Processor with Batch Insert Operations
    /// 
    /// Demonstrates efficient queue processing with PostgreSQL batch inserts:
    /// - Batch consumption from concurrent queue
    /// - Batch insert operations with Npgsql
    /// - Connection pooling
    /// - Performance monitoring
    /// </summary>
    public class PostgreSQLQueueProcessor : IDisposable
    {
        private readonly string _connectionString;
        private readonly string _tableName;
        private readonly ConcurrentQueue<MarketOrder> _queue;
        private int _processedCount;
        private int _errorCount;
        private double _totalTime;
        private readonly object _statsLock = new();
        private bool _initialized;

        public PostgreSQLQueueProcessor(
            string connectionString = "Host=localhost;Port=5432;Database=market_data;Username=postgres;Password=password",
            string tableName = "orders")
        {
            _connectionString = connectionString;
            _tableName = tableName;
            _queue = new ConcurrentQueue<MarketOrder>();
        }

        /// <summary>
        /// Initialize database (create table and indexes)
        /// </summary>
        private async Task InitializeDatabaseAsync()
        {
            if (_initialized) return;

            await using var connection = new NpgsqlConnection(_connectionString);
            await connection.OpenAsync();

            var createTableSql = $@"
                CREATE TABLE IF NOT EXISTS {_tableName} (
                    id SERIAL PRIMARY KEY,
                    order_id VARCHAR(50) UNIQUE NOT NULL,
                    symbol VARCHAR(10) NOT NULL,
                    quantity INTEGER NOT NULL,
                    price NUMERIC(10, 2) NOT NULL,
                    side VARCHAR(4) NOT NULL,
                    order_type VARCHAR(20) NOT NULL,
                    timestamp DOUBLE PRECISION NOT NULL,
                    trader_id VARCHAR(50),
                    account_id VARCHAR(50),
                    exchange VARCHAR(20),
                    status VARCHAR(20),
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )";

            await using (var cmd = new NpgsqlCommand(createTableSql, connection))
            {
                await cmd.ExecuteNonQueryAsync();
            }

            // Create indexes
            var indexSqls = new[]
            {
                $"CREATE INDEX IF NOT EXISTS idx_{_tableName}_symbol ON {_tableName}(symbol)",
                $"CREATE INDEX IF NOT EXISTS idx_{_tableName}_timestamp ON {_tableName}(timestamp)"
            };

            foreach (var indexSql in indexSqls)
            {
                await using var cmd = new NpgsqlCommand(indexSql, connection);
                await cmd.ExecuteNonQueryAsync();
            }

            _initialized = true;
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
        /// Batch insert using parameterized query
        /// </summary>
        public async Task<int> BatchInsertAsync(List<MarketOrder> documents)
        {
            if (documents == null || documents.Count == 0)
                return 0;

            await InitializeDatabaseAsync();

            await using var connection = new NpgsqlConnection(_connectionString);
            await connection.OpenAsync();

            try
            {
                var startTime = DateTime.UtcNow;

                await using var transaction = await connection.BeginTransactionAsync();

                var sql = $@"
                    INSERT INTO {_tableName} 
                    (order_id, symbol, quantity, price, side, order_type, timestamp, trader_id, account_id, exchange, status)
                    VALUES (@order_id, @symbol, @quantity, @price, @side, @order_type, @timestamp, @trader_id, @account_id, @exchange, @status)
                    ON CONFLICT (order_id) DO NOTHING";

                int inserted = 0;
                foreach (var doc in documents)
                {
                    await using var cmd = new NpgsqlCommand(sql, connection, transaction);
                    cmd.Parameters.AddWithValue("order_id", doc.OrderId);
                    cmd.Parameters.AddWithValue("symbol", doc.Symbol);
                    cmd.Parameters.AddWithValue("quantity", doc.Quantity);
                    cmd.Parameters.AddWithValue("price", doc.Price);
                    cmd.Parameters.AddWithValue("side", doc.Side);
                    cmd.Parameters.AddWithValue("order_type", doc.OrderType);
                    cmd.Parameters.AddWithValue("timestamp", doc.Timestamp);
                    cmd.Parameters.AddWithValue("trader_id", doc.TraderId ?? (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("account_id", doc.AccountId ?? (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("exchange", doc.Exchange ?? (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("status", doc.Status ?? (object)DBNull.Value);

                    inserted += await cmd.ExecuteNonQueryAsync();
                }

                await transaction.CommitAsync();

                var elapsed = (DateTime.UtcNow - startTime).TotalSeconds;

                lock (_statsLock)
                {
                    _totalTime += elapsed;
                    _processedCount += inserted;
                }

                return inserted;
            }
            catch (Exception ex)
            {
                lock (_statsLock)
                {
                    _errorCount += documents.Count;
                }
                Console.WriteLine($"Batch insert error: {ex.Message}");
                return 0;
            }
        }

        /// <summary>
        /// Insert single document (for small queues)
        /// </summary>
        public async Task<bool> SingleInsertAsync(MarketOrder document)
        {
            await InitializeDatabaseAsync();

            await using var connection = new NpgsqlConnection(_connectionString);
            await connection.OpenAsync();

            try
            {
                var startTime = DateTime.UtcNow;

                var sql = $@"
                    INSERT INTO {_tableName} 
                    (order_id, symbol, quantity, price, side, order_type, timestamp, trader_id, account_id, exchange, status)
                    VALUES (@order_id, @symbol, @quantity, @price, @side, @order_type, @timestamp, @trader_id, @account_id, @exchange, @status)
                    ON CONFLICT (order_id) DO NOTHING";

                await using var cmd = new NpgsqlCommand(sql, connection);
                cmd.Parameters.AddWithValue("order_id", document.OrderId);
                cmd.Parameters.AddWithValue("symbol", document.Symbol);
                cmd.Parameters.AddWithValue("quantity", document.Quantity);
                cmd.Parameters.AddWithValue("price", document.Price);
                cmd.Parameters.AddWithValue("side", document.Side);
                cmd.Parameters.AddWithValue("order_type", document.OrderType);
                cmd.Parameters.AddWithValue("timestamp", document.Timestamp);
                cmd.Parameters.AddWithValue("trader_id", document.TraderId ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("account_id", document.AccountId ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("exchange", document.Exchange ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("status", document.Status ?? (object)DBNull.Value);

                await cmd.ExecuteNonQueryAsync();

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
                            await BatchInsertAsync(batch);
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
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// Run demonstration
        /// </summary>
        public static async Task RunSampleAsync()
        {
            Console.WriteLine("=== PostgreSQL Queue Processor Demo (C#) ===\n");

            using var processor = new PostgreSQLQueueProcessor(
                "Host=localhost;Port=5432;Database=market_data;Username=postgres;Password=password",
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
                    OrderId = $"PG_ORD{i:D10}",
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
