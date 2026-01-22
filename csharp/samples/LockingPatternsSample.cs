namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates various locking patterns and synchronization primitives in C#
    /// </summary>
    public class LockingPatternsSample
    {
        private readonly object _lockObject = new object();
        private int _counter = 0;

        /// <summary>
        /// Basic lock statement for mutual exclusion
        /// </summary>
        public void BasicLockExample()
        {
            Parallel.For(0, 1000, i =>
            {
                lock (_lockObject)
                {
                    _counter++;
                }
            });
            
            Console.WriteLine($"Counter (with lock): {_counter}");
        }

        /// <summary>
        /// SemaphoreSlim for limiting concurrent access
        /// </summary>
        public async Task SemaphoreSlimExampleAsync()
        {
            var semaphore = new SemaphoreSlim(3); // Allow 3 concurrent operations
            var tasks = new List<Task>();
            
            for (int i = 0; i < 10; i++)
            {
                int taskId = i;
                tasks.Add(Task.Run(async () =>
                {
                    await semaphore.WaitAsync();
                    try
                    {
                        Console.WriteLine($"Task {taskId} entered critical section");
                        await Task.Delay(1000);
                        Console.WriteLine($"Task {taskId} exiting critical section");
                    }
                    finally
                    {
                        semaphore.Release();
                    }
                }));
            }
            
            await Task.WhenAll(tasks);
        }

        /// <summary>
        /// SemaphoreSlim with timeout
        /// </summary>
        public async Task<bool> SemaphoreWithTimeoutAsync(SemaphoreSlim semaphore)
        {
            bool entered = await semaphore.WaitAsync(TimeSpan.FromSeconds(5));
            
            if (entered)
            {
                try
                {
                    Console.WriteLine("Entered critical section");
                    await Task.Delay(1000);
                    return true;
                }
                finally
                {
                    semaphore.Release();
                }
            }
            else
            {
                Console.WriteLine("Timeout: Could not enter critical section");
                return false;
            }
        }

        /// <summary>
        /// ReaderWriterLockSlim for read/write scenarios
        /// </summary>
        public class ReaderWriterLockExample
        {
            private readonly ReaderWriterLockSlim _rwLock = new ReaderWriterLockSlim();
            private readonly Dictionary<string, string> _data = new Dictionary<string, string>();

            public string? Read(string key)
            {
                _rwLock.EnterReadLock();
                try
                {
                    return _data.TryGetValue(key, out var value) ? value : null;
                }
                finally
                {
                    _rwLock.ExitReadLock();
                }
            }

            public void Write(string key, string value)
            {
                _rwLock.EnterWriteLock();
                try
                {
                    _data[key] = value;
                }
                finally
                {
                    _rwLock.ExitWriteLock();
                }
            }

            public bool TryUpgradeableRead(string key, string newValue)
            {
                _rwLock.EnterUpgradeableReadLock();
                try
                {
                    if (!_data.ContainsKey(key))
                    {
                        _rwLock.EnterWriteLock();
                        try
                        {
                            _data[key] = newValue;
                            return true;
                        }
                        finally
                        {
                            _rwLock.ExitWriteLock();
                        }
                    }
                    return false;
                }
                finally
                {
                    _rwLock.ExitUpgradeableReadLock();
                }
            }
        }

        /// <summary>
        /// Mutex for cross-process synchronization
        /// </summary>
        public void MutexExample()
        {
            const string mutexName = "Global\\MyAppMutex";
            
            using var mutex = new Mutex(false, mutexName, out bool createdNew);
            
            if (!createdNew)
            {
                Console.WriteLine("Another instance is already running");
                return;
            }
            
            try
            {
                Console.WriteLine("This is the only instance running");
                Thread.Sleep(5000);
            }
            finally
            {
                mutex.ReleaseMutex();
            }
        }

        /// <summary>
        /// Monitor class for more control than lock
        /// </summary>
        public void MonitorExample()
        {
            var lockObj = new object();
            
            bool lockTaken = false;
            try
            {
                Monitor.TryEnter(lockObj, TimeSpan.FromSeconds(5), ref lockTaken);
                
                if (lockTaken)
                {
                    Console.WriteLine("Lock acquired");
                    // Critical section
                }
                else
                {
                    Console.WriteLine("Could not acquire lock");
                }
            }
            finally
            {
                if (lockTaken)
                {
                    Monitor.Exit(lockObj);
                }
            }
        }

        /// <summary>
        /// Monitor.Wait and Monitor.Pulse for signaling
        /// </summary>
        public void MonitorWaitPulseExample()
        {
            var lockObj = new object();
            var queue = new Queue<int>();
            
            // Producer
            var producer = Task.Run(() =>
            {
                for (int i = 0; i < 10; i++)
                {
                    lock (lockObj)
                    {
                        queue.Enqueue(i);
                        Console.WriteLine($"Produced: {i}");
                        Monitor.Pulse(lockObj); // Signal waiting consumer
                    }
                    Thread.Sleep(100);
                }
            });
            
            // Consumer
            var consumer = Task.Run(() =>
            {
                for (int i = 0; i < 10; i++)
                {
                    lock (lockObj)
                    {
                        while (queue.Count == 0)
                        {
                            Monitor.Wait(lockObj); // Wait for signal
                        }
                        
                        var item = queue.Dequeue();
                        Console.WriteLine($"Consumed: {item}");
                    }
                }
            });
            
            Task.WaitAll(producer, consumer);
        }

        /// <summary>
        /// ManualResetEventSlim for signaling
        /// </summary>
        public async Task ManualResetEventSlimExampleAsync()
        {
            var resetEvent = new ManualResetEventSlim(false);
            
            // Worker task
            var worker = Task.Run(() =>
            {
                Console.WriteLine("Worker waiting for signal...");
                resetEvent.Wait();
                Console.WriteLine("Worker received signal and continuing");
            });
            
            // Simulate some work
            await Task.Delay(2000);
            
            Console.WriteLine("Main thread sending signal");
            resetEvent.Set();
            
            await worker;
        }

        /// <summary>
        /// CountdownEvent for coordinating multiple tasks
        /// </summary>
        public async Task CountdownEventExampleAsync()
        {
            var countdown = new CountdownEvent(5);
            var tasks = new List<Task>();
            
            for (int i = 0; i < 5; i++)
            {
                int taskId = i;
                tasks.Add(Task.Run(async () =>
                {
                    Console.WriteLine($"Task {taskId} starting");
                    await Task.Delay(Random.Shared.Next(1000, 3000));
                    Console.WriteLine($"Task {taskId} completed");
                    countdown.Signal();
                }));
            }
            
            // Wait for all tasks to signal
            await Task.Run(() => countdown.Wait());
            Console.WriteLine("All tasks completed!");
        }

        /// <summary>
        /// Barrier for synchronizing phases of work
        /// </summary>
        public void BarrierExample()
        {
            var barrier = new Barrier(3, b =>
            {
                Console.WriteLine($"Phase {b.CurrentPhaseNumber} completed");
            });
            
            var tasks = new List<Task>();
            
            for (int i = 0; i < 3; i++)
            {
                int taskId = i;
                tasks.Add(Task.Run(() =>
                {
                    for (int phase = 0; phase < 3; phase++)
                    {
                        Console.WriteLine($"Task {taskId} working on phase {phase}");
                        Thread.Sleep(Random.Shared.Next(500, 1500));
                        
                        barrier.SignalAndWait(); // Wait for all tasks to reach this point
                    }
                }));
            }
            
            Task.WaitAll(tasks.ToArray());
            barrier.Dispose();
        }

        /// <summary>
        /// Lazy<T> for thread-safe lazy initialization
        /// </summary>
        public class LazyInitializationExample
        {
            private readonly Lazy<ExpensiveResource> _resource = new Lazy<ExpensiveResource>(
                () => new ExpensiveResource(),
                LazyThreadSafetyMode.ExecutionAndPublication
            );
            
            public ExpensiveResource Resource => _resource.Value;
            
            public bool IsInitialized => _resource.IsValueCreated;
        }

        public class ExpensiveResource
        {
            public ExpensiveResource()
            {
                Console.WriteLine("ExpensiveResource initialized");
                Thread.Sleep(1000); // Simulate expensive initialization
            }
        }

        /// <summary>
        /// Demonstrates running locking patterns samples
        /// </summary>
        public static async Task RunSamplesAsync()
        {
            var sample = new LockingPatternsSample();
            
            Console.WriteLine("=== Locking Patterns Sample ===\n");
            
            // Basic lock
            Console.WriteLine("1. Basic lock statement:");
            sample.BasicLockExample();
            Console.WriteLine();
            
            // SemaphoreSlim
            Console.WriteLine("2. SemaphoreSlim (limit concurrent access):");
            await sample.SemaphoreSlimExampleAsync();
            Console.WriteLine();
            
            // ReaderWriterLockSlim
            Console.WriteLine("3. ReaderWriterLockSlim:");
            var rwLock = new ReaderWriterLockExample();
            rwLock.Write("key1", "value1");
            Console.WriteLine($"   Read: {rwLock.Read("key1")}");
            Console.WriteLine();
            
            // Monitor Wait/Pulse
            Console.WriteLine("4. Monitor.Wait and Monitor.Pulse:");
            sample.MonitorWaitPulseExample();
            Console.WriteLine();
            
            // ManualResetEventSlim
            Console.WriteLine("5. ManualResetEventSlim:");
            await sample.ManualResetEventSlimExampleAsync();
            Console.WriteLine();
            
            // CountdownEvent
            Console.WriteLine("6. CountdownEvent:");
            await sample.CountdownEventExampleAsync();
            Console.WriteLine();
            
            // Lazy initialization
            Console.WriteLine("7. Lazy<T> initialization:");
            var lazyExample = new LazyInitializationExample();
            Console.WriteLine($"   Is initialized: {lazyExample.IsInitialized}");
            var resource = lazyExample.Resource;
            Console.WriteLine($"   Is initialized: {lazyExample.IsInitialized}");
            Console.WriteLine();
        }
    }
}
