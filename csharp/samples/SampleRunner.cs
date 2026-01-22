namespace RestFixClient.Samples
{
    /// <summary>
    /// Entry point for running all C# feature samples
    /// </summary>
    public class SampleRunner
    {
        public static async Task Main(string[] args)
        {
            Console.WriteLine("============================================");
            Console.WriteLine("C# Advanced Features Sample Application");
            Console.WriteLine("============================================\n");
            
            if (args.Length > 0)
            {
                await RunSpecificSample(args[0]);
            }
            else
            {
                await RunAllSamples();
            }
            
            Console.WriteLine("\n============================================");
            Console.WriteLine("All samples completed!");
            Console.WriteLine("============================================");
        }

        private static async Task RunAllSamples()
        {
            // Async Patterns
            await AsyncPatternsSample.RunSamplesAsync();
            await Task.Delay(1000);
            
            await AsyncStreamsSample.RunSamplesAsync();
            await Task.Delay(1000);
            
            // Concurrency
            await ConcurrentCollectionsSample.RunSamplesAsync();
            await Task.Delay(1000);
            
            ParallelProcessingSample.RunSamples();
            await Task.Delay(1000);
            
            await ChannelsSample.RunSamplesAsync();
            await Task.Delay(1000);
            
            // Locking and Thread Safety
            await LockingPatternsSample.RunSamplesAsync();
            await Task.Delay(1000);
            
            await ThreadSafetySample.RunSamplesAsync();
            await Task.Delay(1000);
            
            // Caching
            await MemoryCacheSample.RunSamplesAsync();
            await Task.Delay(1000);
            
            // Logging
            await LoggingSample.RunSamplesAsync();
            await Task.Delay(1000);
            
            SerilogSample.RunSamples();
            await Task.Delay(1000);
            
            // Observability
            await MetricsSample.RunSamplesAsync();
            await Task.Delay(1000);
            
            await TracingSample.RunSamplesAsync();
            await Task.Delay(1000);
            
            await HealthChecksSample.RunSamplesAsync();
            await Task.Delay(1000);
            
            // Advanced Language Features
            PatternMatchingSample.RunSamples();
            await Task.Delay(1000);
            
            RecordsSample.RunSamples();
            await Task.Delay(1000);
            
            NullabilityFeaturesSample.RunSamples();
            await Task.Delay(1000);
            
            await SpanAndMemorySample.RunSamplesAsync();
        }

        private static async Task RunSpecificSample(string sampleName)
        {
            switch (sampleName.ToLower())
            {
                case "async":
                    await AsyncPatternsSample.RunSamplesAsync();
                    break;
                case "asyncstreams":
                    await AsyncStreamsSample.RunSamplesAsync();
                    break;
                case "concurrent":
                    await ConcurrentCollectionsSample.RunSamplesAsync();
                    break;
                case "parallel":
                    ParallelProcessingSample.RunSamples();
                    break;
                case "channels":
                    await ChannelsSample.RunSamplesAsync();
                    break;
                case "locking":
                    await LockingPatternsSample.RunSamplesAsync();
                    break;
                case "threadsafety":
                    await ThreadSafetySample.RunSamplesAsync();
                    break;
                case "cache":
                    await MemoryCacheSample.RunSamplesAsync();
                    break;
                case "logging":
                    await LoggingSample.RunSamplesAsync();
                    break;
                case "serilog":
                    SerilogSample.RunSamples();
                    break;
                case "metrics":
                    await MetricsSample.RunSamplesAsync();
                    break;
                case "tracing":
                    await TracingSample.RunSamplesAsync();
                    break;
                case "health":
                    await HealthChecksSample.RunSamplesAsync();
                    break;
                case "patterns":
                    PatternMatchingSample.RunSamples();
                    break;
                case "records":
                    RecordsSample.RunSamples();
                    break;
                case "nullable":
                    NullabilityFeaturesSample.RunSamples();
                    break;
                case "span":
                    await SpanAndMemorySample.RunSamplesAsync();
                    break;
                default:
                    Console.WriteLine($"Unknown sample: {sampleName}");
                    PrintUsage();
                    break;
            }
        }

        private static void PrintUsage()
        {
            Console.WriteLine("\nUsage: dotnet run [sample-name]");
            Console.WriteLine("\nAvailable samples:");
            Console.WriteLine("  async          - Async/await patterns");
            Console.WriteLine("  asyncstreams   - IAsyncEnumerable");
            Console.WriteLine("  concurrent     - Concurrent collections");
            Console.WriteLine("  parallel       - Parallel processing");
            Console.WriteLine("  channels       - System.Threading.Channels");
            Console.WriteLine("  locking        - Locking patterns");
            Console.WriteLine("  threadsafety   - Thread safety with Interlocked");
            Console.WriteLine("  cache          - Memory caching");
            Console.WriteLine("  logging        - ILogger patterns");
            Console.WriteLine("  serilog        - Serilog integration");
            Console.WriteLine("  metrics        - Application metrics");
            Console.WriteLine("  tracing        - Distributed tracing");
            Console.WriteLine("  health         - Health checks");
            Console.WriteLine("  patterns       - Pattern matching");
            Console.WriteLine("  records        - Record types");
            Console.WriteLine("  nullable       - Nullable reference types");
            Console.WriteLine("  span           - Span<T> and Memory<T>");
            Console.WriteLine("\nRun without arguments to execute all samples.");
        }
    }
}
