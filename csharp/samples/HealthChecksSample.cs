using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.DependencyInjection;

namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates health checks pattern for monitoring application health
    /// </summary>
    public class HealthChecksSample
    {
        /// <summary>
        /// Basic health check implementation
        /// </summary>
        public class DatabaseHealthCheck : IHealthCheck
        {
            public async Task<HealthCheckResult> CheckHealthAsync(
                HealthCheckContext context,
                CancellationToken cancellationToken = default)
            {
                try
                {
                    // Simulate database connectivity check
                    await Task.Delay(50, cancellationToken);
                    
                    // In real scenario, check actual database connection
                    bool isDatabaseHealthy = Random.Shared.Next(0, 10) != 0; // 90% success rate
                    
                    if (isDatabaseHealthy)
                    {
                        return HealthCheckResult.Healthy("Database is responding");
                    }
                    else
                    {
                        return HealthCheckResult.Unhealthy("Database is not responding");
                    }
                }
                catch (Exception ex)
                {
                    return HealthCheckResult.Unhealthy("Database check failed", ex);
                }
            }
        }

        /// <summary>
        /// Health check with custom data
        /// </summary>
        public class MemoryHealthCheck : IHealthCheck
        {
            private const long MemoryThreshold = 100 * 1024 * 1024; // 100 MB
            
            public Task<HealthCheckResult> CheckHealthAsync(
                HealthCheckContext context,
                CancellationToken cancellationToken = default)
            {
                var memoryUsed = GC.GetTotalMemory(false);
                
                var data = new Dictionary<string, object>
                {
                    { "MemoryUsed", memoryUsed },
                    { "MemoryThreshold", MemoryThreshold },
                    { "Gen0Collections", GC.CollectionCount(0) },
                    { "Gen1Collections", GC.CollectionCount(1) },
                    { "Gen2Collections", GC.CollectionCount(2) }
                };
                
                if (memoryUsed < MemoryThreshold)
                {
                    return Task.FromResult(
                        HealthCheckResult.Healthy("Memory usage is normal", data));
                }
                else
                {
                    return Task.FromResult(
                        HealthCheckResult.Degraded("Memory usage is high", data: data));
                }
            }
        }

        /// <summary>
        /// Health check for external dependency
        /// </summary>
        public class ApiHealthCheck : IHealthCheck
        {
            private readonly string _apiUrl;
            
            public ApiHealthCheck(string apiUrl)
            {
                _apiUrl = apiUrl;
            }
            
            public async Task<HealthCheckResult> CheckHealthAsync(
                HealthCheckContext context,
                CancellationToken cancellationToken = default)
            {
                try
                {
                    // Simulate API call
                    await Task.Delay(100, cancellationToken);
                    
                    var data = new Dictionary<string, object>
                    {
                        { "ApiUrl", _apiUrl },
                        { "CheckedAt", DateTime.UtcNow }
                    };
                    
                    bool isApiHealthy = Random.Shared.Next(0, 10) != 0;
                    
                    if (isApiHealthy)
                    {
                        return HealthCheckResult.Healthy($"API {_apiUrl} is responding", data);
                    }
                    else
                    {
                        return HealthCheckResult.Degraded($"API {_apiUrl} is slow", null, data);
                    }
                }
                catch (Exception ex)
                {
                    return HealthCheckResult.Unhealthy($"API {_apiUrl} is not responding", ex);
                }
            }
        }

        /// <summary>
        /// Liveness check (is the app running?)
        /// </summary>
        public class LivenessHealthCheck : IHealthCheck
        {
            public Task<HealthCheckResult> CheckHealthAsync(
                HealthCheckContext context,
                CancellationToken cancellationToken = default)
            {
                // Simple check to see if the application is running
                return Task.FromResult(HealthCheckResult.Healthy("Application is running"));
            }
        }

        /// <summary>
        /// Readiness check (is the app ready to serve traffic?)
        /// </summary>
        public class ReadinessHealthCheck : IHealthCheck
        {
            private bool _isReady = false;
            
            public void SetReady(bool ready)
            {
                _isReady = ready;
            }
            
            public Task<HealthCheckResult> CheckHealthAsync(
                HealthCheckContext context,
                CancellationToken cancellationToken = default)
            {
                if (_isReady)
                {
                    return Task.FromResult(HealthCheckResult.Healthy("Application is ready"));
                }
                else
                {
                    return Task.FromResult(HealthCheckResult.Unhealthy("Application is not ready"));
                }
            }
        }

        /// <summary>
        /// Configures and runs health checks
        /// </summary>
        public static async Task ConfigureHealthChecksAsync()
        {
            var services = new ServiceCollection();
            
            // Register API health check with dependency
            services.AddSingleton(new ApiHealthCheck("https://api.example.com"));
            
            services.AddHealthChecks()
                .AddCheck<DatabaseHealthCheck>("database", 
                    failureStatus: HealthStatus.Unhealthy,
                    tags: new[] { "db", "critical" })
                .AddCheck<MemoryHealthCheck>("memory",
                    failureStatus: HealthStatus.Degraded,
                    tags: new[] { "memory" })
                .AddCheck<ApiHealthCheck>("api_service",
                    tags: new[] { "api", "external" })
                .AddCheck<LivenessHealthCheck>("liveness",
                    tags: new[] { "live" })
                .AddCheck<ReadinessHealthCheck>("readiness",
                    tags: new[] { "ready" });
            
            var serviceProvider = services.BuildServiceProvider();
            var healthCheckService = serviceProvider.GetRequiredService<HealthCheckService>();
            
            // Check all health checks
            Console.WriteLine("1. All health checks:");
            var result = await healthCheckService.CheckHealthAsync();
            PrintHealthCheckResult(result);
            Console.WriteLine();
            
            // Check specific tags
            Console.WriteLine("2. Critical health checks only:");
            var criticalResult = await healthCheckService.CheckHealthAsync(
                check => check.Tags.Contains("critical"));
            PrintHealthCheckResult(criticalResult);
            Console.WriteLine();
            
            // Check liveness
            Console.WriteLine("3. Liveness probe:");
            var livenessResult = await healthCheckService.CheckHealthAsync(
                check => check.Tags.Contains("live"));
            PrintHealthCheckResult(livenessResult);
            Console.WriteLine();
        }

        private static void PrintHealthCheckResult(HealthReport report)
        {
            Console.WriteLine($"  Overall Status: {report.Status}");
            Console.WriteLine($"  Total Duration: {report.TotalDuration.TotalMilliseconds:F2}ms");
            Console.WriteLine("  Individual Checks:");
            
            foreach (var entry in report.Entries)
            {
                Console.WriteLine($"    {entry.Key}:");
                Console.WriteLine($"      Status: {entry.Value.Status}");
                Console.WriteLine($"      Description: {entry.Value.Description}");
                Console.WriteLine($"      Duration: {entry.Value.Duration.TotalMilliseconds:F2}ms");
                
                if (entry.Value.Data.Any())
                {
                    Console.WriteLine("      Data:");
                    foreach (var data in entry.Value.Data)
                    {
                        Console.WriteLine($"        {data.Key}: {data.Value}");
                    }
                }
                
                if (entry.Value.Exception != null)
                {
                    Console.WriteLine($"      Exception: {entry.Value.Exception.Message}");
                }
            }
        }

        /// <summary>
        /// Custom health check publisher
        /// </summary>
        public class ConsoleHealthCheckPublisher : IHealthCheckPublisher
        {
            public Task PublishAsync(HealthReport report, CancellationToken cancellationToken)
            {
                Console.WriteLine($"[Health Check Published] Status: {report.Status}, " +
                    $"Duration: {report.TotalDuration.TotalMilliseconds:F2}ms");
                
                return Task.CompletedTask;
            }
        }

        /// <summary>
        /// Demonstrates running health checks samples
        /// </summary>
        public static async Task RunSamplesAsync()
        {
            Console.WriteLine("=== Health Checks Sample ===\n");
            
            await ConfigureHealthChecksAsync();
            
            Console.WriteLine("\nNote: In a real application, health checks are typically exposed via HTTP endpoints:");
            Console.WriteLine("  - /health - All health checks");
            Console.WriteLine("  - /health/live - Liveness probe (Kubernetes)");
            Console.WriteLine("  - /health/ready - Readiness probe (Kubernetes)");
        }
    }
}
