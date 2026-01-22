using System.Collections.Concurrent;

namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates thread-safe concurrent collections in C#
    /// </summary>
    public class ConcurrentCollectionsSample
    {
        /// <summary>
        /// Demonstrates ConcurrentBag<T> - unordered collection
        /// </summary>
        public void ConcurrentBagExample()
        {
            var bag = new ConcurrentBag<int>();
            
            // Multiple threads adding items
            Parallel.For(0, 100, i =>
            {
                bag.Add(i);
            });
            
            Console.WriteLine($"ConcurrentBag contains {bag.Count} items");
            
            // TryTake is thread-safe
            if (bag.TryTake(out int item))
            {
                Console.WriteLine($"Took item: {item}");
            }
        }

        /// <summary>
        /// Demonstrates ConcurrentQueue<T> - FIFO collection
        /// </summary>
        public async Task ConcurrentQueueExampleAsync()
        {
            var queue = new ConcurrentQueue<string>();
            
            // Producer task
            var producer = Task.Run(() =>
            {
                for (int i = 0; i < 10; i++)
                {
                    queue.Enqueue($"Item {i}");
                    Thread.Sleep(100);
                }
            });
            
            // Consumer task
            var consumer = Task.Run(() =>
            {
                while (!producer.IsCompleted || !queue.IsEmpty)
                {
                    if (queue.TryDequeue(out string? item))
                    {
                        Console.WriteLine($"Dequeued: {item}");
                    }
                    Thread.Sleep(150);
                }
            });
            
            await Task.WhenAll(producer, consumer);
        }

        /// <summary>
        /// Demonstrates ConcurrentStack<T> - LIFO collection
        /// </summary>
        public void ConcurrentStackExample()
        {
            var stack = new ConcurrentStack<int>();
            
            // Push items
            Parallel.For(0, 10, i =>
            {
                stack.Push(i);
                Console.WriteLine($"Pushed: {i}");
            });
            
            // Pop items
            while (stack.TryPop(out int item))
            {
                Console.WriteLine($"Popped: {item}");
            }
        }

        /// <summary>
        /// Demonstrates ConcurrentDictionary<TKey, TValue> - thread-safe dictionary
        /// </summary>
        public void ConcurrentDictionaryExample()
        {
            var dict = new ConcurrentDictionary<string, int>();
            
            // AddOrUpdate - atomic operation
            dict.AddOrUpdate("counter", 1, (key, oldValue) => oldValue + 1);
            
            // GetOrAdd - atomic operation
            var value = dict.GetOrAdd("counter", 0);
            Console.WriteLine($"Counter value: {value}");
            
            // TryUpdate - conditional update
            if (dict.TryUpdate("counter", 10, 1))
            {
                Console.WriteLine("Updated counter to 10");
            }
            
            // Parallel operations
            Parallel.For(0, 100, i =>
            {
                dict.AddOrUpdate($"key{i}", 1, (key, oldValue) => oldValue + 1);
            });
            
            Console.WriteLine($"Dictionary contains {dict.Count} items");
        }

        /// <summary>
        /// Demonstrates BlockingCollection<T> for producer-consumer scenarios
        /// </summary>
        public async Task BlockingCollectionExampleAsync()
        {
            using var collection = new BlockingCollection<int>(boundedCapacity: 5);
            
            // Producer
            var producer = Task.Run(() =>
            {
                for (int i = 0; i < 10; i++)
                {
                    collection.Add(i);
                    Console.WriteLine($"Produced: {i}");
                    Thread.Sleep(100);
                }
                collection.CompleteAdding();
            });
            
            // Consumer
            var consumer = Task.Run(() =>
            {
                foreach (var item in collection.GetConsumingEnumerable())
                {
                    Console.WriteLine($"Consumed: {item}");
                    Thread.Sleep(200);
                }
            });
            
            await Task.WhenAll(producer, consumer);
        }

        /// <summary>
        /// Demonstrates using ConcurrentBag for parallel processing results
        /// </summary>
        public ConcurrentBag<int> ParallelProcessingWithConcurrentBag(int[] numbers)
        {
            var results = new ConcurrentBag<int>();
            
            Parallel.ForEach(numbers, number =>
            {
                var result = number * number; // Square the number
                results.Add(result);
            });
            
            return results;
        }

        /// <summary>
        /// Demonstrates thread-safe cache using ConcurrentDictionary
        /// </summary>
        public class ThreadSafeCache<TKey, TValue> where TKey : notnull
        {
            private readonly ConcurrentDictionary<TKey, TValue> _cache = new();
            
            public TValue GetOrAdd(TKey key, Func<TKey, TValue> valueFactory)
            {
                return _cache.GetOrAdd(key, valueFactory);
            }
            
            public bool TryRemove(TKey key, out TValue? value)
            {
                return _cache.TryRemove(key, out value);
            }
            
            public void Clear()
            {
                _cache.Clear();
            }
        }

        /// <summary>
        /// Demonstrates running concurrent collections samples
        /// </summary>
        public static async Task RunSamplesAsync()
        {
            var sample = new ConcurrentCollectionsSample();
            
            Console.WriteLine("=== Concurrent Collections Sample ===\n");
            
            // ConcurrentBag
            Console.WriteLine("1. ConcurrentBag (unordered collection):");
            sample.ConcurrentBagExample();
            Console.WriteLine();
            
            // ConcurrentQueue
            Console.WriteLine("2. ConcurrentQueue (FIFO):");
            await sample.ConcurrentQueueExampleAsync();
            Console.WriteLine();
            
            // ConcurrentStack
            Console.WriteLine("3. ConcurrentStack (LIFO):");
            sample.ConcurrentStackExample();
            Console.WriteLine();
            
            // ConcurrentDictionary
            Console.WriteLine("4. ConcurrentDictionary:");
            sample.ConcurrentDictionaryExample();
            Console.WriteLine();
            
            // BlockingCollection
            Console.WriteLine("5. BlockingCollection (producer-consumer):");
            await sample.BlockingCollectionExampleAsync();
            Console.WriteLine();
            
            // Thread-safe cache
            Console.WriteLine("6. Thread-safe cache:");
            var cache = new ThreadSafeCache<string, int>();
            Parallel.For(0, 10, i =>
            {
                var key = $"key{i}";
                var value = cache.GetOrAdd(key, k => i * 10);
                Console.WriteLine($"   Cached value for {key}: {value}");
            });
            Console.WriteLine();
        }
    }
}
