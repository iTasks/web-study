using System.Diagnostics;

namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates parallel processing using Parallel class and PLINQ
    /// </summary>
    public class ParallelProcessingSample
    {
        /// <summary>
        /// Basic Parallel.For example
        /// </summary>
        public void ParallelForExample()
        {
            var numbers = new int[100];
            
            Parallel.For(0, numbers.Length, i =>
            {
                numbers[i] = i * i;
            });
            
            Console.WriteLine($"Processed {numbers.Length} items in parallel");
        }

        /// <summary>
        /// Parallel.ForEach with collection
        /// </summary>
        public void ParallelForEachExample()
        {
            var items = Enumerable.Range(1, 100).ToList();
            var results = new List<int>();
            var lockObj = new object();
            
            Parallel.ForEach(items, item =>
            {
                var result = ProcessItem(item);
                lock (lockObj)
                {
                    results.Add(result);
                }
            });
            
            Console.WriteLine($"Processed {results.Count} items");
        }

        /// <summary>
        /// Parallel.ForEach with options (degree of parallelism)
        /// </summary>
        public void ParallelForEachWithOptionsExample()
        {
            var items = Enumerable.Range(1, 100).ToList();
            var options = new ParallelOptions
            {
                MaxDegreeOfParallelism = Environment.ProcessorCount / 2 // Use half the cores
            };
            
            Parallel.ForEach(items, options, item =>
            {
                ProcessItem(item);
            });
        }

        /// <summary>
        /// Parallel.ForEach with cancellation
        /// </summary>
        public void ParallelForEachWithCancellation(CancellationToken cancellationToken)
        {
            var items = Enumerable.Range(1, 1000).ToList();
            var options = new ParallelOptions
            {
                CancellationToken = cancellationToken
            };
            
            try
            {
                Parallel.ForEach(items, options, (item, loopState) =>
                {
                    if (cancellationToken.IsCancellationRequested)
                    {
                        loopState.Stop();
                        return;
                    }
                    ProcessItem(item);
                });
            }
            catch (OperationCanceledException)
            {
                Console.WriteLine("Parallel operation was cancelled");
            }
        }

        /// <summary>
        /// Parallel.ForEach with partition-local state
        /// </summary>
        public long ParallelForEachWithLocalStateExample()
        {
            var items = Enumerable.Range(1, 1000).ToList();
            
            long total = Parallel.ForEach(
                source: items,
                localInit: () => 0L, // Initialize thread-local state
                body: (item, loopState, localSum) => localSum + item, // Update local state
                localFinally: localSum => Interlocked.Add(ref total, localSum) // Aggregate results
            ).IsCompleted ? total : 0;
            
            return total;
        }

        /// <summary>
        /// PLINQ - Parallel LINQ example
        /// </summary>
        public void PLinqBasicExample()
        {
            var numbers = Enumerable.Range(1, 1000);
            
            var evenSquares = numbers
                .AsParallel()
                .Where(n => n % 2 == 0)
                .Select(n => n * n)
                .ToList();
            
            Console.WriteLine($"Found {evenSquares.Count} even squares");
        }

        /// <summary>
        /// PLINQ with ordering preserved
        /// </summary>
        public void PLinqWithOrderingExample()
        {
            var numbers = Enumerable.Range(1, 100);
            
            // Preserves order
            var orderedResults = numbers
                .AsParallel()
                .AsOrdered()
                .Select(n => n * 2)
                .ToList();
            
            Console.WriteLine($"First item: {orderedResults[0]}, Last item: {orderedResults[^1]}");
        }

        /// <summary>
        /// PLINQ with custom degree of parallelism
        /// </summary>
        public void PLinqWithDegreeOfParallelismExample()
        {
            var numbers = Enumerable.Range(1, 1000);
            
            var results = numbers
                .AsParallel()
                .WithDegreeOfParallelism(4) // Use 4 threads
                .Select(n => ProcessItem(n))
                .ToList();
            
            Console.WriteLine($"Processed {results.Count} items with 4 threads");
        }

        /// <summary>
        /// PLINQ aggregation
        /// </summary>
        public void PLinqAggregationExample()
        {
            var numbers = Enumerable.Range(1, 1000);
            
            var sum = numbers
                .AsParallel()
                .Sum();
            
            var average = numbers
                .AsParallel()
                .Average();
            
            Console.WriteLine($"Sum: {sum}, Average: {average}");
        }

        /// <summary>
        /// Compares sequential vs parallel performance
        /// </summary>
        public void ComparePerformance()
        {
            var numbers = Enumerable.Range(1, 10000).ToList();
            
            // Sequential
            var sw1 = Stopwatch.StartNew();
            var seqResults = numbers.Select(n => ExpensiveOperation(n)).ToList();
            sw1.Stop();
            
            // Parallel
            var sw2 = Stopwatch.StartNew();
            var parResults = numbers.AsParallel().Select(n => ExpensiveOperation(n)).ToList();
            sw2.Stop();
            
            Console.WriteLine($"Sequential: {sw1.ElapsedMilliseconds}ms");
            Console.WriteLine($"Parallel: {sw2.ElapsedMilliseconds}ms");
            Console.WriteLine($"Speedup: {(double)sw1.ElapsedMilliseconds / sw2.ElapsedMilliseconds:F2}x");
        }

        /// <summary>
        /// Parallel.Invoke for running multiple methods in parallel
        /// </summary>
        public void ParallelInvokeExample()
        {
            Parallel.Invoke(
                () => Console.WriteLine("Task 1 executing"),
                () => Console.WriteLine("Task 2 executing"),
                () => Console.WriteLine("Task 3 executing"),
                () => Console.WriteLine("Task 4 executing")
            );
        }

        /// <summary>
        /// Using Partitioner for custom partitioning
        /// </summary>
        public void PartitionerExample()
        {
            var numbers = Enumerable.Range(1, 1000).ToList();
            var partitioner = Partitioner.Create(numbers, loadBalance: true);
            
            Parallel.ForEach(partitioner, (number, state) =>
            {
                ProcessItem(number);
            });
        }

        #region Helper Methods

        private int ProcessItem(int item)
        {
            // Simulate some processing
            Thread.SpinWait(100);
            return item * 2;
        }

        private int ExpensiveOperation(int n)
        {
            Thread.SpinWait(1000);
            return n * n;
        }

        #endregion

        /// <summary>
        /// Demonstrates running parallel processing samples
        /// </summary>
        public static void RunSamples()
        {
            var sample = new ParallelProcessingSample();
            
            Console.WriteLine("=== Parallel Processing Sample ===\n");
            
            // Basic Parallel.For
            Console.WriteLine("1. Parallel.For:");
            sample.ParallelForExample();
            Console.WriteLine();
            
            // Parallel.ForEach
            Console.WriteLine("2. Parallel.ForEach:");
            sample.ParallelForEachExample();
            Console.WriteLine();
            
            // PLINQ
            Console.WriteLine("3. PLINQ (Parallel LINQ):");
            sample.PLinqBasicExample();
            Console.WriteLine();
            
            // PLINQ with ordering
            Console.WriteLine("4. PLINQ with ordering:");
            sample.PLinqWithOrderingExample();
            Console.WriteLine();
            
            // Parallel.Invoke
            Console.WriteLine("5. Parallel.Invoke:");
            sample.ParallelInvokeExample();
            Console.WriteLine();
            
            // Performance comparison
            Console.WriteLine("6. Performance comparison:");
            sample.ComparePerformance();
            Console.WriteLine();
        }
    }
}
