namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates async/await patterns and best practices in C#
    /// </summary>
    public class AsyncPatternsSample
    {
        /// <summary>
        /// Example of basic async/await pattern
        /// </summary>
        public async Task<string> BasicAsyncAwaitAsync()
        {
            // Simulate async operation (e.g., network call, file I/O)
            await Task.Delay(1000);
            return "Async operation completed";
        }

        /// <summary>
        /// Example of async method that returns multiple results
        /// </summary>
        public async Task<List<string>> FetchMultipleResourcesAsync()
        {
            var results = new List<string>();
            
            // Sequential execution
            results.Add(await FetchResourceAsync("Resource1"));
            results.Add(await FetchResourceAsync("Resource2"));
            
            return results;
        }

        /// <summary>
        /// Example of parallel async operations using Task.WhenAll
        /// </summary>
        public async Task<List<string>> FetchMultipleResourcesInParallelAsync()
        {
            // Parallel execution - much faster
            var task1 = FetchResourceAsync("Resource1");
            var task2 = FetchResourceAsync("Resource2");
            var task3 = FetchResourceAsync("Resource3");
            
            var results = await Task.WhenAll(task1, task2, task3);
            return results.ToList();
        }

        /// <summary>
        /// Example of Task.WhenAny - returns when the first task completes
        /// </summary>
        public async Task<string> FetchFirstAvailableResourceAsync()
        {
            var task1 = FetchResourceAsync("SlowResource");
            var task2 = FetchResourceAsync("FastResource");
            
            var completedTask = await Task.WhenAny(task1, task2);
            return await completedTask;
        }

        /// <summary>
        /// Example of async with timeout using CancellationToken
        /// </summary>
        public async Task<string> FetchResourceWithTimeoutAsync(int timeoutMs)
        {
            using var cts = new CancellationTokenSource(timeoutMs);
            
            try
            {
                return await FetchResourceWithCancellationAsync("Resource", cts.Token);
            }
            catch (OperationCanceledException)
            {
                return "Operation timed out";
            }
        }

        /// <summary>
        /// Example of async with cancellation support
        /// </summary>
        public async Task<string> FetchResourceWithCancellationAsync(string resourceName, CancellationToken cancellationToken)
        {
            // Simulate long-running operation with cancellation support
            await Task.Delay(5000, cancellationToken);
            return $"Fetched {resourceName}";
        }

        /// <summary>
        /// Example of ValueTask for performance-critical scenarios
        /// </summary>
        public async ValueTask<int> GetCachedValueAsync(int key, Dictionary<int, int> cache)
        {
            // If value is in cache, return synchronously (no heap allocation)
            if (cache.TryGetValue(key, out var value))
            {
                return value;
            }
            
            // If not in cache, perform async operation
            await Task.Delay(100);
            var newValue = key * 2;
            cache[key] = newValue;
            return newValue;
        }

        /// <summary>
        /// Example of ConfigureAwait(false) for library code
        /// </summary>
        public async Task<string> LibraryMethodAsync()
        {
            // ConfigureAwait(false) avoids capturing SynchronizationContext
            // This is important for library code to avoid deadlocks
            await Task.Delay(100).ConfigureAwait(false);
            return "Library operation completed";
        }

        /// <summary>
        /// Example of async error handling
        /// </summary>
        public async Task<string> AsyncErrorHandlingAsync()
        {
            try
            {
                await Task.Run(() => throw new InvalidOperationException("Simulated error"));
                return "Success";
            }
            catch (InvalidOperationException ex)
            {
                Console.WriteLine($"Caught exception: {ex.Message}");
                return "Error handled";
            }
        }

        /// <summary>
        /// Example of async with progress reporting
        /// </summary>
        public async Task<string> ProcessWithProgressAsync(IProgress<int>? progress)
        {
            for (int i = 0; i <= 100; i += 10)
            {
                await Task.Delay(100);
                progress?.Report(i);
            }
            return "Processing completed";
        }

        /// <summary>
        /// Example demonstrating the difference between Task.Run and async/await
        /// </summary>
        public async Task<string> TaskRunVsAsyncAwaitAsync()
        {
            // Task.Run - offloads CPU-bound work to thread pool
            var cpuResult = await Task.Run(() => PerformCpuIntensiveWork());
            
            // async/await - for I/O-bound operations (doesn't use thread pool)
            var ioResult = await PerformIoOperationAsync();
            
            return $"CPU: {cpuResult}, I/O: {ioResult}";
        }

        #region Helper Methods

        private async Task<string> FetchResourceAsync(string resourceName)
        {
            // Simulate network latency
            await Task.Delay(Random.Shared.Next(100, 500));
            return $"Data from {resourceName}";
        }

        private string PerformCpuIntensiveWork()
        {
            // Simulate CPU-bound work
            var sum = 0;
            for (int i = 0; i < 1000000; i++)
            {
                sum += i;
            }
            return $"Sum: {sum}";
        }

        private async Task<string> PerformIoOperationAsync()
        {
            // Simulate I/O operation
            await Task.Delay(100);
            return "I/O completed";
        }

        #endregion

        /// <summary>
        /// Demonstrates running async samples
        /// </summary>
        public static async Task RunSamplesAsync()
        {
            var sample = new AsyncPatternsSample();
            
            Console.WriteLine("=== Async Patterns Sample ===\n");
            
            // Basic async/await
            Console.WriteLine("1. Basic async/await:");
            var result1 = await sample.BasicAsyncAwaitAsync();
            Console.WriteLine($"   {result1}\n");
            
            // Parallel async operations
            Console.WriteLine("2. Parallel async operations:");
            var result2 = await sample.FetchMultipleResourcesInParallelAsync();
            Console.WriteLine($"   Fetched {result2.Count} resources in parallel\n");
            
            // Async with timeout
            Console.WriteLine("3. Async with timeout:");
            var result3 = await sample.FetchResourceWithTimeoutAsync(2000);
            Console.WriteLine($"   {result3}\n");
            
            // Progress reporting
            Console.WriteLine("4. Progress reporting:");
            var progress = new Progress<int>(percent => Console.Write($"\r   Progress: {percent}%"));
            await sample.ProcessWithProgressAsync(progress);
            Console.WriteLine("\n   Completed!\n");
        }
    }
}
