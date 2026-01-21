using Microsoft.Extensions.Logging;
using Microsoft.Extensions.DependencyInjection;

namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates ILogger and structured logging patterns
    /// </summary>
    public class LoggingSample
    {
        private readonly ILogger<LoggingSample> _logger;
        
        public LoggingSample(ILogger<LoggingSample> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Basic logging at different levels
        /// </summary>
        public void BasicLoggingExample()
        {
            _logger.LogTrace("This is a trace message");
            _logger.LogDebug("This is a debug message");
            _logger.LogInformation("This is an information message");
            _logger.LogWarning("This is a warning message");
            _logger.LogError("This is an error message");
            _logger.LogCritical("This is a critical message");
        }

        /// <summary>
        /// Structured logging with message templates
        /// </summary>
        public void StructuredLoggingExample(string username, int userId)
        {
            // Don't use string interpolation - use message templates
            _logger.LogInformation("User {Username} with ID {UserId} logged in", username, userId);
            
            // The properties are preserved for structured logging systems
            _logger.LogInformation("Processing order {OrderId} for customer {CustomerId}", 
                Guid.NewGuid(), 12345);
        }

        /// <summary>
        /// Logging with scopes for correlation
        /// </summary>
        public void LoggingWithScopesExample(string requestId)
        {
            using (_logger.BeginScope("RequestId:{RequestId}", requestId))
            {
                _logger.LogInformation("Processing request");
                
                using (_logger.BeginScope("UserId:{UserId}", 123))
                {
                    _logger.LogInformation("User authentication successful");
                    _logger.LogInformation("Loading user preferences");
                }
                
                _logger.LogInformation("Request completed");
            }
        }

        /// <summary>
        /// Logging exceptions
        /// </summary>
        public void LoggingExceptionsExample()
        {
            try
            {
                throw new InvalidOperationException("Something went wrong");
            }
            catch (Exception ex)
            {
                // Log exception with context
                _logger.LogError(ex, "Error processing request for user {UserId}", 123);
            }
        }

        /// <summary>
        /// High-performance logging with LoggerMessage
        /// </summary>
        public static class HighPerformanceLogging
        {
            private static readonly Action<ILogger, string, int, Exception?> _userLoggedIn =
                LoggerMessage.Define<string, int>(
                    LogLevel.Information,
                    new EventId(1, "UserLoggedIn"),
                    "User {Username} (ID: {UserId}) logged in successfully");

            private static readonly Action<ILogger, Guid, Exception?> _orderProcessed =
                LoggerMessage.Define<Guid>(
                    LogLevel.Information,
                    new EventId(2, "OrderProcessed"),
                    "Order {OrderId} processed");

            public static void UserLoggedIn(ILogger logger, string username, int userId)
            {
                _userLoggedIn(logger, username, userId, null);
            }

            public static void OrderProcessed(ILogger logger, Guid orderId)
            {
                _orderProcessed(logger, orderId, null);
            }
        }

        /// <summary>
        /// Using high-performance logging
        /// </summary>
        public void HighPerformanceLoggingExample()
        {
            HighPerformanceLogging.UserLoggedIn(_logger, "john_doe", 123);
            HighPerformanceLogging.OrderProcessed(_logger, Guid.NewGuid());
        }

        /// <summary>
        /// Conditional logging to avoid unnecessary work
        /// </summary>
        public void ConditionalLoggingExample()
        {
            if (_logger.IsEnabled(LogLevel.Debug))
            {
                var expensiveDebugInfo = GetExpensiveDebugInfo();
                _logger.LogDebug("Debug info: {Info}", expensiveDebugInfo);
            }
        }

        /// <summary>
        /// Custom logger provider example
        /// </summary>
        public class CustomLogger : ILogger
        {
            private readonly string _categoryName;
            
            public CustomLogger(string categoryName)
            {
                _categoryName = categoryName;
            }
            
            public IDisposable? BeginScope<TState>(TState state) where TState : notnull
            {
                return null;
            }
            
            public bool IsEnabled(LogLevel logLevel)
            {
                return logLevel >= LogLevel.Information;
            }
            
            public void Log<TState>(LogLevel logLevel, EventId eventId, TState state, 
                Exception? exception, Func<TState, Exception?, string> formatter)
            {
                if (!IsEnabled(logLevel))
                    return;
                
                var message = formatter(state, exception);
                Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] [{logLevel}] {_categoryName}: {message}");
                
                if (exception != null)
                {
                    Console.WriteLine($"Exception: {exception}");
                }
            }
        }

        /// <summary>
        /// Logging best practices example
        /// </summary>
        public class ServiceWithLogging
        {
            private readonly ILogger<ServiceWithLogging> _logger;
            
            public ServiceWithLogging(ILogger<ServiceWithLogging> logger)
            {
                _logger = logger;
            }
            
            public async Task<bool> ProcessOrderAsync(Guid orderId, int customerId)
            {
                using var scope = _logger.BeginScope(new Dictionary<string, object>
                {
                    ["OrderId"] = orderId,
                    ["CustomerId"] = customerId
                });
                
                _logger.LogInformation("Starting order processing");
                
                try
                {
                    // Simulate processing
                    await Task.Delay(100);
                    
                    _logger.LogInformation("Order validated successfully");
                    
                    await Task.Delay(100);
                    
                    _logger.LogInformation("Order processing completed");
                    return true;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error processing order");
                    return false;
                }
            }
        }

        private string GetExpensiveDebugInfo()
        {
            // Simulate expensive operation
            Thread.Sleep(100);
            return "Expensive debug information";
        }

        /// <summary>
        /// Demonstrates running logging samples
        /// </summary>
        public static async Task RunSamplesAsync()
        {
            // Setup DI container with logging
            var serviceProvider = new ServiceCollection()
                .AddLogging(builder =>
                {
                    builder.AddConsole();
                    builder.SetMinimumLevel(LogLevel.Trace);
                })
                .AddTransient<LoggingSample>()
                .AddTransient<ServiceWithLogging>()
                .BuildServiceProvider();
            
            var logger = serviceProvider.GetRequiredService<ILogger<LoggingSample>>();
            var sample = new LoggingSample(logger);
            
            Console.WriteLine("=== Logging Sample ===\n");
            
            // Basic logging
            Console.WriteLine("1. Basic logging levels:");
            sample.BasicLoggingExample();
            Console.WriteLine();
            
            // Structured logging
            Console.WriteLine("2. Structured logging:");
            sample.StructuredLoggingExample("john_doe", 123);
            Console.WriteLine();
            
            // Logging with scopes
            Console.WriteLine("3. Logging with scopes:");
            sample.LoggingWithScopesExample(Guid.NewGuid().ToString());
            Console.WriteLine();
            
            // Logging exceptions
            Console.WriteLine("4. Logging exceptions:");
            sample.LoggingExceptionsExample();
            Console.WriteLine();
            
            // High-performance logging
            Console.WriteLine("5. High-performance logging:");
            sample.HighPerformanceLoggingExample();
            Console.WriteLine();
            
            // Service with logging
            Console.WriteLine("6. Service with logging best practices:");
            var service = serviceProvider.GetRequiredService<ServiceWithLogging>();
            await service.ProcessOrderAsync(Guid.NewGuid(), 123);
            Console.WriteLine();
        }
    }
}
