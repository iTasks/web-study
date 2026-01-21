using System.Diagnostics.Metrics;

namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates System.Diagnostics.Metrics for application metrics
    /// </summary>
    public class MetricsSample
    {
        private static readonly Meter _meter = new Meter("SampleApp", "1.0");
        
        // Counter - monotonically increasing value
        private static readonly Counter<long> _requestCounter = 
            _meter.CreateCounter<long>("requests", "requests", "Total number of requests");
        
        // Histogram - distribution of values
        private static readonly Histogram<double> _requestDuration = 
            _meter.CreateHistogram<double>("request_duration", "ms", "Request duration in milliseconds");
        
        // Observable gauge - point-in-time measurement
        private static readonly ObservableGauge<int> _activeConnections;
        
        private static int _currentConnections = 0;

        static MetricsSample()
        {
            _activeConnections = _meter.CreateObservableGauge("active_connections", 
                () => _currentConnections, "connections", "Number of active connections");
        }

        /// <summary>
        /// Basic counter example
        /// </summary>
        public void CounterExample()
        {
            // Increment counter
            _requestCounter.Add(1);
            
            // Counter with tags/labels
            _requestCounter.Add(1, new KeyValuePair<string, object?>("endpoint", "/api/users"));
            _requestCounter.Add(1, new KeyValuePair<string, object?>("endpoint", "/api/orders"));
            
            Console.WriteLine("Request counters incremented");
        }

        /// <summary>
        /// Histogram example for tracking distributions
        /// </summary>
        public async Task HistogramExampleAsync()
        {
            var random = new Random();
            
            for (int i = 0; i < 10; i++)
            {
                var startTime = DateTime.UtcNow;
                
                // Simulate request processing
                await Task.Delay(random.Next(10, 100));
                
                var duration = (DateTime.UtcNow - startTime).TotalMilliseconds;
                
                // Record duration
                _requestDuration.Record(duration, 
                    new KeyValuePair<string, object?>("endpoint", "/api/data"));
                
                Console.WriteLine($"Recorded duration: {duration:F2}ms");
            }
        }

        /// <summary>
        /// Observable gauge example
        /// </summary>
        public async Task ObservableGaugeExampleAsync()
        {
            Console.WriteLine("Simulating connection lifecycle:");
            
            // Simulate connections coming and going
            for (int i = 0; i < 5; i++)
            {
                _currentConnections++;
                Console.WriteLine($"Connection opened. Active: {_currentConnections}");
                await Task.Delay(500);
            }
            
            await Task.Delay(1000);
            
            for (int i = 0; i < 5; i++)
            {
                _currentConnections--;
                Console.WriteLine($"Connection closed. Active: {_currentConnections}");
                await Task.Delay(500);
            }
        }

        /// <summary>
        /// Multiple metrics with tags
        /// </summary>
        public class ApiMetrics
        {
            private static readonly Meter _apiMeter = new Meter("MyApi", "1.0");
            
            private static readonly Counter<long> _apiCalls = 
                _apiMeter.CreateCounter<long>("api_calls", "calls");
            
            private static readonly Counter<long> _apiErrors = 
                _apiMeter.CreateCounter<long>("api_errors", "errors");
            
            private static readonly Histogram<double> _apiLatency = 
                _apiMeter.CreateHistogram<double>("api_latency", "ms");
            
            public static async Task<bool> CallApiAsync(string endpoint, string method)
            {
                var tags = new KeyValuePair<string, object?>[]
                {
                    new("endpoint", endpoint),
                    new("method", method)
                };
                
                _apiCalls.Add(1, tags);
                
                var startTime = DateTime.UtcNow;
                
                try
                {
                    // Simulate API call
                    await Task.Delay(Random.Shared.Next(50, 200));
                    
                    // 10% chance of error
                    if (Random.Shared.Next(0, 10) == 0)
                    {
                        throw new Exception("API error");
                    }
                    
                    var duration = (DateTime.UtcNow - startTime).TotalMilliseconds;
                    _apiLatency.Record(duration, tags);
                    
                    return true;
                }
                catch (Exception)
                {
                    var errorTags = new KeyValuePair<string, object?>[]
                    {
                        new("endpoint", endpoint),
                        new("method", method),
                        new("status", "error")
                    };
                    _apiErrors.Add(1, errorTags);
                    
                    var duration = (DateTime.UtcNow - startTime).TotalMilliseconds;
                    _apiLatency.Record(duration, errorTags);
                    
                    return false;
                }
            }
        }

        /// <summary>
        /// Custom meter for business metrics
        /// </summary>
        public class BusinessMetrics
        {
            private static readonly Meter _businessMeter = new Meter("BusinessApp", "1.0");
            
            private static readonly Counter<long> _ordersPlaced = 
                _businessMeter.CreateCounter<long>("orders_placed", "orders");
            
            private static readonly Counter<decimal> _revenue = 
                _businessMeter.CreateCounter<decimal>("revenue", "USD");
            
            private static readonly Histogram<int> _orderSize = 
                _businessMeter.CreateHistogram<int>("order_size", "items");
            
            public static void RecordOrder(int itemCount, decimal amount, string category)
            {
                var tags = new KeyValuePair<string, object?>[]
                {
                    new("category", category)
                };
                
                _ordersPlaced.Add(1, tags);
                _revenue.Add(amount, tags);
                _orderSize.Record(itemCount, tags);
                
                Console.WriteLine($"Recorded order: {itemCount} items, ${amount}, category: {category}");
            }
        }

        /// <summary>
        /// UpDownCounter example for values that can increase or decrease
        /// </summary>
        public class QueueMetrics
        {
            private static readonly Meter _queueMeter = new Meter("QueueSystem", "1.0");
            
            private static readonly UpDownCounter<int> _queueSize = 
                _queueMeter.CreateUpDownCounter<int>("queue_size", "items");
            
            public static void EnqueueItem(string queueName)
            {
                _queueSize.Add(1, new KeyValuePair<string, object?>("queue", queueName));
                Console.WriteLine($"Item enqueued to {queueName}");
            }
            
            public static void DequeueItem(string queueName)
            {
                _queueSize.Add(-1, new KeyValuePair<string, object?>("queue", queueName));
                Console.WriteLine($"Item dequeued from {queueName}");
            }
        }

        /// <summary>
        /// Demonstrates running metrics samples
        /// </summary>
        public static async Task RunSamplesAsync()
        {
            var sample = new MetricsSample();
            
            Console.WriteLine("=== Metrics Sample ===\n");
            Console.WriteLine("Note: Metrics are being recorded. Use a metrics collector like Prometheus to view them.\n");
            
            // Counter
            Console.WriteLine("1. Counter example:");
            sample.CounterExample();
            Console.WriteLine();
            
            // Histogram
            Console.WriteLine("2. Histogram example:");
            await sample.HistogramExampleAsync();
            Console.WriteLine();
            
            // Observable gauge
            Console.WriteLine("3. Observable gauge example:");
            await sample.ObservableGaugeExampleAsync();
            Console.WriteLine();
            
            // API metrics
            Console.WriteLine("4. API metrics with tags:");
            for (int i = 0; i < 5; i++)
            {
                await ApiMetrics.CallApiAsync("/api/users", "GET");
                await ApiMetrics.CallApiAsync("/api/orders", "POST");
            }
            Console.WriteLine();
            
            // Business metrics
            Console.WriteLine("5. Business metrics:");
            BusinessMetrics.RecordOrder(3, 99.99m, "Electronics");
            BusinessMetrics.RecordOrder(1, 29.99m, "Books");
            BusinessMetrics.RecordOrder(5, 149.99m, "Clothing");
            Console.WriteLine();
            
            // Queue metrics
            Console.WriteLine("6. UpDownCounter (queue size):");
            QueueMetrics.EnqueueItem("orders");
            QueueMetrics.EnqueueItem("orders");
            QueueMetrics.DequeueItem("orders");
            QueueMetrics.EnqueueItem("notifications");
            Console.WriteLine();
        }
    }
}
