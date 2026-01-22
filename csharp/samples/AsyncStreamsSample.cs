namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates IAsyncEnumerable and async streams in C# 8.0+
    /// </summary>
    public class AsyncStreamsSample
    {
        /// <summary>
        /// Basic IAsyncEnumerable example - generates numbers asynchronously
        /// </summary>
        public async IAsyncEnumerable<int> GenerateNumbersAsync(int count)
        {
            for (int i = 0; i < count; i++)
            {
                // Simulate async work
                await Task.Delay(100);
                yield return i;
            }
        }

        /// <summary>
        /// Async stream with cancellation support
        /// </summary>
        public async IAsyncEnumerable<string> FetchDataStreamAsync(
            [System.Runtime.CompilerServices.EnumeratorCancellation] CancellationToken cancellationToken = default)
        {
            int page = 0;
            while (!cancellationToken.IsCancellationRequested)
            {
                // Simulate fetching paginated data
                await Task.Delay(500, cancellationToken);
                
                yield return $"Page {page} data";
                
                page++;
                if (page >= 5) // Stop after 5 pages
                    break;
            }
        }

        /// <summary>
        /// Filtering async stream using LINQ
        /// </summary>
        public async IAsyncEnumerable<int> GetEvenNumbersAsync(int count)
        {
            await foreach (var number in GenerateNumbersAsync(count))
            {
                if (number % 2 == 0)
                {
                    yield return number;
                }
            }
        }

        /// <summary>
        /// Async stream from a data source (simulated)
        /// </summary>
        public async IAsyncEnumerable<StockPrice> StreamStockPricesAsync(string symbol)
        {
            var random = new Random();
            var basePrice = 100.0;
            
            for (int i = 0; i < 10; i++)
            {
                await Task.Delay(1000); // Simulate real-time updates
                
                // Simulate price fluctuation
                var change = (random.NextDouble() - 0.5) * 5;
                basePrice += change;
                
                yield return new StockPrice
                {
                    Symbol = symbol,
                    Price = Math.Round(basePrice, 2),
                    Timestamp = DateTime.UtcNow
                };
            }
        }

        /// <summary>
        /// Combining multiple async streams
        /// </summary>
        public async IAsyncEnumerable<string> MergeStreamsAsync()
        {
            var stream1 = GenerateMessagesAsync("Stream1", 3);
            var stream2 = GenerateMessagesAsync("Stream2", 3);
            
            await foreach (var item in stream1)
            {
                yield return item;
            }
            
            await foreach (var item in stream2)
            {
                yield return item;
            }
        }

        /// <summary>
        /// Async stream with error handling
        /// </summary>
        public async IAsyncEnumerable<int> GenerateWithErrorHandlingAsync(int count)
        {
            for (int i = 0; i < count; i++)
            {
                await Task.Delay(100);
                
                if (i == 5)
                {
                    // Simulate an error condition
                    throw new InvalidOperationException($"Error at index {i}");
                }
                
                yield return i;
            }
        }

        /// <summary>
        /// Buffered async stream - processes items in batches
        /// </summary>
        public async IAsyncEnumerable<List<int>> BufferedStreamAsync(int itemCount, int bufferSize)
        {
            var buffer = new List<int>(bufferSize);
            
            await foreach (var number in GenerateNumbersAsync(itemCount))
            {
                buffer.Add(number);
                
                if (buffer.Count >= bufferSize)
                {
                    yield return new List<int>(buffer);
                    buffer.Clear();
                }
            }
            
            // Return remaining items
            if (buffer.Count > 0)
            {
                yield return buffer;
            }
        }

        /// <summary>
        /// Async stream with transformation
        /// </summary>
        public async IAsyncEnumerable<string> TransformStreamAsync()
        {
            await foreach (var number in GenerateNumbersAsync(10))
            {
                var transformed = $"Number: {number}, Square: {number * number}";
                yield return transformed;
            }
        }

        #region Helper Methods

        private async IAsyncEnumerable<string> GenerateMessagesAsync(string source, int count)
        {
            for (int i = 0; i < count; i++)
            {
                await Task.Delay(200);
                yield return $"{source}: Message {i}";
            }
        }

        #endregion

        /// <summary>
        /// Demonstrates running async stream samples
        /// </summary>
        public static async Task RunSamplesAsync()
        {
            var sample = new AsyncStreamsSample();
            
            Console.WriteLine("=== Async Streams Sample ===\n");
            
            // Basic async enumerable
            Console.WriteLine("1. Basic async enumerable:");
            await foreach (var number in sample.GenerateNumbersAsync(5))
            {
                Console.WriteLine($"   Generated: {number}");
            }
            Console.WriteLine();
            
            // Filtering async stream
            Console.WriteLine("2. Filtering async stream (even numbers):");
            await foreach (var even in sample.GetEvenNumbersAsync(10))
            {
                Console.WriteLine($"   Even number: {even}");
            }
            Console.WriteLine();
            
            // Stock price streaming
            Console.WriteLine("3. Stock price streaming:");
            await foreach (var price in sample.StreamStockPricesAsync("AAPL"))
            {
                Console.WriteLine($"   {price.Symbol}: ${price.Price} at {price.Timestamp:HH:mm:ss}");
            }
            Console.WriteLine();
            
            // Buffered stream
            Console.WriteLine("4. Buffered stream (batches of 3):");
            await foreach (var batch in sample.BufferedStreamAsync(10, 3))
            {
                Console.WriteLine($"   Batch: [{string.Join(", ", batch)}]");
            }
            Console.WriteLine();
            
            // Async stream with cancellation
            Console.WriteLine("5. Async stream with cancellation:");
            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(3));
            try
            {
                await foreach (var data in sample.FetchDataStreamAsync(cts.Token))
                {
                    Console.WriteLine($"   Received: {data}");
                }
            }
            catch (OperationCanceledException)
            {
                Console.WriteLine("   Stream cancelled");
            }
            Console.WriteLine();
        }

        /// <summary>
        /// Stock price data model
        /// </summary>
        public class StockPrice
        {
            public string Symbol { get; set; } = string.Empty;
            public double Price { get; set; }
            public DateTime Timestamp { get; set; }
        }
    }
}
