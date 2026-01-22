namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates thread safety patterns using Interlocked and volatile
    /// </summary>
    public class ThreadSafetySample
    {
        private int _counter;
        private volatile bool _stopRequested;
        private long _longCounter;

        /// <summary>
        /// Interlocked.Increment for thread-safe increment
        /// </summary>
        public void InterlockedIncrementExample()
        {
            _counter = 0;
            
            Parallel.For(0, 10000, i =>
            {
                Interlocked.Increment(ref _counter);
            });
            
            Console.WriteLine($"Counter (Interlocked.Increment): {_counter}");
        }

        /// <summary>
        /// Interlocked.Add for thread-safe addition
        /// </summary>
        public void InterlockedAddExample()
        {
            _counter = 0;
            
            Parallel.For(0, 1000, i =>
            {
                Interlocked.Add(ref _counter, 5);
            });
            
            Console.WriteLine($"Counter (Interlocked.Add): {_counter}");
        }

        /// <summary>
        /// Interlocked.CompareExchange for lock-free updates
        /// </summary>
        public void InterlockedCompareExchangeExample()
        {
            _counter = 0;
            
            Parallel.For(0, 100, i =>
            {
                int currentValue, newValue;
                do
                {
                    currentValue = _counter;
                    newValue = currentValue + 1;
                }
                while (Interlocked.CompareExchange(ref _counter, newValue, currentValue) != currentValue);
            });
            
            Console.WriteLine($"Counter (CompareExchange): {_counter}");
        }

        /// <summary>
        /// Interlocked.Exchange for atomic swap
        /// </summary>
        public void InterlockedExchangeExample()
        {
            _counter = 100;
            
            var oldValue = Interlocked.Exchange(ref _counter, 200);
            
            Console.WriteLine($"Old value: {oldValue}, New value: {_counter}");
        }

        /// <summary>
        /// Volatile keyword for preventing compiler optimizations
        /// </summary>
        public void VolatileExample()
        {
            _stopRequested = false;
            
            var worker = Task.Run(() =>
            {
                int iterations = 0;
                while (!_stopRequested)
                {
                    iterations++;
                    Thread.SpinWait(100);
                }
                Console.WriteLine($"Worker stopped after {iterations} iterations");
            });
            
            Thread.Sleep(1000);
            _stopRequested = true;
            
            worker.Wait();
        }

        /// <summary>
        /// Volatile.Read and Volatile.Write for explicit volatile operations
        /// </summary>
        public void VolatileReadWriteExample()
        {
            _longCounter = 0;
            
            var writer = Task.Run(() =>
            {
                for (int i = 0; i < 1000; i++)
                {
                    Volatile.Write(ref _longCounter, i);
                    Thread.Sleep(1);
                }
            });
            
            var reader = Task.Run(() =>
            {
                long lastValue = -1;
                while (writer.Status != TaskStatus.RanToCompletion || Volatile.Read(ref _longCounter) < 999)
                {
                    var currentValue = Volatile.Read(ref _longCounter);
                    if (currentValue != lastValue)
                    {
                        Console.WriteLine($"Read: {currentValue}");
                        lastValue = currentValue;
                    }
                    Thread.Sleep(100);
                }
            });
            
            Task.WaitAll(writer, reader);
        }

        /// <summary>
        /// Thread-local storage using ThreadLocal<T>
        /// </summary>
        public void ThreadLocalExample()
        {
            var threadLocal = new ThreadLocal<int>(() =>
            {
                Console.WriteLine($"Initializing for thread {Thread.CurrentThread.ManagedThreadId}");
                return Thread.CurrentThread.ManagedThreadId;
            });
            
            Parallel.For(0, 5, i =>
            {
                Console.WriteLine($"Task {i} on thread {threadLocal.Value}");
                Thread.Sleep(100);
            });
            
            threadLocal.Dispose();
        }

        /// <summary>
        /// AsyncLocal<T> for async context flow
        /// </summary>
        public async Task AsyncLocalExampleAsync()
        {
            var asyncLocal = new AsyncLocal<string>();
            
            asyncLocal.Value = "Parent";
            Console.WriteLine($"Parent context: {asyncLocal.Value}");
            
            await Task.Run(() =>
            {
                Console.WriteLine($"Child context before: {asyncLocal.Value}");
                asyncLocal.Value = "Child";
                Console.WriteLine($"Child context after: {asyncLocal.Value}");
            });
            
            Console.WriteLine($"Parent context after child: {asyncLocal.Value}");
        }

        /// <summary>
        /// Lock-free stack implementation using Interlocked
        /// </summary>
        public class LockFreeStack<T>
        {
            private class Node
            {
                public T Value { get; set; }
                public Node? Next { get; set; }
                
                public Node(T value)
                {
                    Value = value;
                }
            }
            
            private Node? _head;
            
            public void Push(T item)
            {
                var newNode = new Node(item);
                
                while (true)
                {
                    newNode.Next = _head;
                    if (Interlocked.CompareExchange(ref _head, newNode, newNode.Next) == newNode.Next)
                    {
                        return;
                    }
                }
            }
            
            public bool TryPop(out T? result)
            {
                while (true)
                {
                    var currentHead = _head;
                    if (currentHead == null)
                    {
                        result = default;
                        return false;
                    }
                    
                    if (Interlocked.CompareExchange(ref _head, currentHead.Next, currentHead) == currentHead)
                    {
                        result = currentHead.Value;
                        return true;
                    }
                }
            }
        }

        /// <summary>
        /// Double-checked locking pattern
        /// </summary>
        public class DoubleCheckedLockingSingleton
        {
            private static volatile DoubleCheckedLockingSingleton? _instance;
            private static readonly object _lock = new object();
            
            private DoubleCheckedLockingSingleton()
            {
                Console.WriteLine("Singleton instance created");
            }
            
            public static DoubleCheckedLockingSingleton Instance
            {
                get
                {
                    if (_instance == null)
                    {
                        lock (_lock)
                        {
                            if (_instance == null)
                            {
                                _instance = new DoubleCheckedLockingSingleton();
                            }
                        }
                    }
                    return _instance;
                }
            }
        }

        /// <summary>
        /// Memory barriers using Thread.MemoryBarrier
        /// </summary>
        public void MemoryBarrierExample()
        {
            int value1 = 0;
            int value2 = 0;
            bool ready = false;
            
            var writer = Task.Run(() =>
            {
                value1 = 1;
                value2 = 2;
                Thread.MemoryBarrier(); // Ensure all writes complete before setting ready
                ready = true;
            });
            
            var reader = Task.Run(() =>
            {
                while (!ready)
                {
                    Thread.Sleep(1);
                }
                Thread.MemoryBarrier(); // Ensure ready is read before reading values
                Console.WriteLine($"value1: {value1}, value2: {value2}");
            });
            
            Task.WaitAll(writer, reader);
        }

        /// <summary>
        /// Demonstrates running thread safety samples
        /// </summary>
        public static async Task RunSamplesAsync()
        {
            var sample = new ThreadSafetySample();
            
            Console.WriteLine("=== Thread Safety Sample ===\n");
            
            // Interlocked operations
            Console.WriteLine("1. Interlocked.Increment:");
            sample.InterlockedIncrementExample();
            Console.WriteLine();
            
            Console.WriteLine("2. Interlocked.CompareExchange:");
            sample.InterlockedCompareExchangeExample();
            Console.WriteLine();
            
            Console.WriteLine("3. Interlocked.Exchange:");
            sample.InterlockedExchangeExample();
            Console.WriteLine();
            
            // Volatile
            Console.WriteLine("4. Volatile keyword:");
            sample.VolatileExample();
            Console.WriteLine();
            
            // ThreadLocal
            Console.WriteLine("5. ThreadLocal<T>:");
            sample.ThreadLocalExample();
            Console.WriteLine();
            
            // AsyncLocal
            Console.WriteLine("6. AsyncLocal<T>:");
            await sample.AsyncLocalExampleAsync();
            Console.WriteLine();
            
            // Lock-free stack
            Console.WriteLine("7. Lock-free stack:");
            var stack = new LockFreeStack<int>();
            Parallel.For(0, 10, i => stack.Push(i));
            while (stack.TryPop(out int value))
            {
                Console.WriteLine($"   Popped: {value}");
            }
            Console.WriteLine();
            
            // Double-checked locking singleton
            Console.WriteLine("8. Double-checked locking singleton:");
            Parallel.For(0, 5, i =>
            {
                var instance = DoubleCheckedLockingSingleton.Instance;
            });
            Console.WriteLine();
        }
    }
}
