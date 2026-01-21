using System.Diagnostics;

namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates distributed tracing using System.Diagnostics.Activity
    /// </summary>
    public class TracingSample
    {
        private static readonly ActivitySource _activitySource = new ActivitySource("SampleApp", "1.0");

        /// <summary>
        /// Basic activity (span) example
        /// </summary>
        public async Task BasicActivityExampleAsync()
        {
            using var activity = _activitySource.StartActivity("ProcessOrder");
            
            activity?.SetTag("order.id", Guid.NewGuid());
            activity?.SetTag("customer.id", 123);
            
            // Simulate work
            await Task.Delay(100);
            
            activity?.SetTag("order.status", "completed");
            
            Console.WriteLine($"Activity: {activity?.DisplayName}, TraceId: {activity?.TraceId}");
        }

        /// <summary>
        /// Nested activities for distributed tracing
        /// </summary>
        public async Task NestedActivitiesExampleAsync()
        {
            using var parentActivity = _activitySource.StartActivity("HandleRequest");
            parentActivity?.SetTag("request.id", Guid.NewGuid());
            
            Console.WriteLine($"Parent Activity: {parentActivity?.DisplayName}");
            Console.WriteLine($"  TraceId: {parentActivity?.TraceId}");
            Console.WriteLine($"  SpanId: {parentActivity?.SpanId}");
            
            await ValidateRequestAsync();
            await ProcessDataAsync();
            await SaveResultAsync();
        }

        private async Task ValidateRequestAsync()
        {
            using var activity = _activitySource.StartActivity("ValidateRequest");
            activity?.SetTag("validation.type", "schema");
            
            await Task.Delay(50);
            
            activity?.SetTag("validation.result", "passed");
            Console.WriteLine($"  Child Activity: {activity?.DisplayName}");
        }

        private async Task ProcessDataAsync()
        {
            using var activity = _activitySource.StartActivity("ProcessData");
            activity?.SetTag("data.size", 1024);
            
            await Task.Delay(100);
            
            Console.WriteLine($"  Child Activity: {activity?.DisplayName}");
        }

        private async Task SaveResultAsync()
        {
            using var activity = _activitySource.StartActivity("SaveResult");
            activity?.SetTag("database", "postgresql");
            
            await Task.Delay(75);
            
            Console.WriteLine($"  Child Activity: {activity?.DisplayName}");
        }

        /// <summary>
        /// Activity with events
        /// </summary>
        public async Task ActivityWithEventsExampleAsync()
        {
            using var activity = _activitySource.StartActivity("OrderWorkflow");
            
            activity?.AddEvent(new ActivityEvent("OrderReceived"));
            await Task.Delay(50);
            
            activity?.AddEvent(new ActivityEvent("PaymentProcessed", 
                tags: new ActivityTagsCollection
                {
                    { "payment.method", "credit_card" },
                    { "amount", 99.99m }
                }));
            await Task.Delay(50);
            
            activity?.AddEvent(new ActivityEvent("OrderShipped"));
            
            Console.WriteLine($"Activity with {activity?.Events.Count()} events");
        }

        /// <summary>
        /// Activity status for error tracking
        /// </summary>
        public async Task ActivityWithStatusExampleAsync()
        {
            using var activity = _activitySource.StartActivity("RiskyOperation");
            
            try
            {
                await Task.Delay(50);
                
                // Simulate an error
                if (Random.Shared.Next(0, 2) == 0)
                {
                    throw new InvalidOperationException("Operation failed");
                }
                
                activity?.SetStatus(ActivityStatusCode.Ok);
                Console.WriteLine("Operation succeeded");
            }
            catch (Exception ex)
            {
                activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
                // Note: RecordException is not available in .NET 6
                activity?.SetTag("exception.type", ex.GetType().FullName);
                activity?.SetTag("exception.message", ex.Message);
                Console.WriteLine($"Operation failed: {ex.Message}");
            }
        }

        /// <summary>
        /// Activity baggage for cross-service context
        /// </summary>
        public async Task ActivityWithBaggageExampleAsync()
        {
            using var activity = _activitySource.StartActivity("ServiceA");
            
            // Add baggage that will flow to downstream services
            activity?.SetBaggage("user.id", "123");
            activity?.SetBaggage("tenant.id", "acme-corp");
            
            Console.WriteLine("Baggage items:");
            foreach (var item in activity?.Baggage ?? Enumerable.Empty<KeyValuePair<string, string?>>())
            {
                Console.WriteLine($"  {item.Key}: {item.Value}");
            }
            
            await CallDownstreamServiceAsync();
        }

        private async Task CallDownstreamServiceAsync()
        {
            using var activity = _activitySource.StartActivity("ServiceB");
            
            // Baggage automatically flows from parent
            Console.WriteLine("Downstream service received baggage:");
            foreach (var item in activity?.Baggage ?? Enumerable.Empty<KeyValuePair<string, string?>>())
            {
                Console.WriteLine($"  {item.Key}: {item.Value}");
            }
            
            await Task.Delay(50);
        }

        /// <summary>
        /// Custom activity listener for processing spans
        /// </summary>
        public class CustomActivityListener : IDisposable
        {
            private readonly ActivityListener _listener;
            
            public CustomActivityListener()
            {
                _listener = new ActivityListener
                {
                    ShouldListenTo = source => source.Name == "SampleApp",
                    Sample = (ref ActivityCreationOptions<ActivityContext> options) => 
                        ActivitySamplingResult.AllData,
                    ActivityStarted = activity =>
                    {
                        Console.WriteLine($"[START] {activity.DisplayName} - {activity.SpanId}");
                    },
                    ActivityStopped = activity =>
                    {
                        Console.WriteLine($"[STOP]  {activity.DisplayName} - Duration: {activity.Duration.TotalMilliseconds:F2}ms");
                    }
                };
                
                ActivitySource.AddActivityListener(_listener);
            }
            
            public void Dispose()
            {
                _listener.Dispose();
            }
        }

        /// <summary>
        /// Complex distributed trace example
        /// </summary>
        public async Task DistributedTraceExampleAsync()
        {
            using var listener = new CustomActivityListener();
            
            using var rootActivity = _activitySource.StartActivity("ApiRequest");
            rootActivity?.SetTag("http.method", "POST");
            rootActivity?.SetTag("http.url", "/api/orders");
            
            await AuthenticateUserAsync();
            await LoadUserDataAsync();
            await CreateOrderAsync();
            await SendNotificationAsync();
        }

        private async Task AuthenticateUserAsync()
        {
            using var activity = _activitySource.StartActivity("Authenticate");
            await Task.Delay(30);
        }

        private async Task LoadUserDataAsync()
        {
            using var activity = _activitySource.StartActivity("LoadUserData");
            await Task.Delay(40);
        }

        private async Task CreateOrderAsync()
        {
            using var activity = _activitySource.StartActivity("CreateOrder");
            
            using var dbActivity = _activitySource.StartActivity("DatabaseInsert");
            dbActivity?.SetTag("db.system", "postgresql");
            await Task.Delay(60);
        }

        private async Task SendNotificationAsync()
        {
            using var activity = _activitySource.StartActivity("SendNotification");
            activity?.SetTag("notification.type", "email");
            await Task.Delay(20);
        }

        /// <summary>
        /// Demonstrates running tracing samples
        /// </summary>
        public static async Task RunSamplesAsync()
        {
            var sample = new TracingSample();
            
            Console.WriteLine("=== Tracing Sample ===\n");
            Console.WriteLine("Note: Traces are being recorded. Use a tracing backend like Jaeger or Zipkin to visualize them.\n");
            
            // Basic activity
            Console.WriteLine("1. Basic activity:");
            await sample.BasicActivityExampleAsync();
            Console.WriteLine();
            
            // Nested activities
            Console.WriteLine("2. Nested activities (parent-child):");
            await sample.NestedActivitiesExampleAsync();
            Console.WriteLine();
            
            // Activity with events
            Console.WriteLine("3. Activity with events:");
            await sample.ActivityWithEventsExampleAsync();
            Console.WriteLine();
            
            // Activity with status
            Console.WriteLine("4. Activity with status (error handling):");
            await sample.ActivityWithStatusExampleAsync();
            Console.WriteLine();
            
            // Activity with baggage
            Console.WriteLine("5. Activity with baggage:");
            await sample.ActivityWithBaggageExampleAsync();
            Console.WriteLine();
            
            // Distributed trace
            Console.WriteLine("6. Distributed trace:");
            await sample.DistributedTraceExampleAsync();
            Console.WriteLine();
        }
    }
}
