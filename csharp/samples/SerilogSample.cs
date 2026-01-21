using Serilog;
using Serilog.Events;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates Serilog integration and advanced features
    /// </summary>
    public class SerilogSample
    {
        /// <summary>
        /// Basic Serilog configuration
        /// </summary>
        public static void BasicSerilogConfiguration()
        {
            Log.Logger = new LoggerConfiguration()
                .MinimumLevel.Debug()
                .WriteTo.Console()
                .WriteTo.File("logs/app.log", rollingInterval: RollingInterval.Day)
                .CreateLogger();
            
            Log.Information("Serilog is configured");
            Log.Debug("Debug message");
            Log.Warning("Warning message");
            Log.Error("Error message");
        }

        /// <summary>
        /// Serilog with structured logging
        /// </summary>
        public static void StructuredLoggingWithSerilog()
        {
            var position = new { Latitude = 25, Longitude = 134 };
            var elapsedMs = 34;
            
            Log.Information("Processed {@Position} in {Elapsed} ms", position, elapsedMs);
            
            // @ symbol destructures the object
            var user = new { Username = "john_doe", UserId = 123 };
            Log.Information("User {@User} logged in", user);
        }

        /// <summary>
        /// Serilog with enrichment
        /// </summary>
        public static void SerilogWithEnrichment()
        {
            Log.Logger = new LoggerConfiguration()
                .MinimumLevel.Information()
                .Enrich.FromLogContext()
                .Enrich.WithProperty("Application", "SampleApp")
                .Enrich.WithProperty("Environment", "Development")
                .Enrich.WithMachineName()
                .Enrich.WithThreadId()
                .WriteTo.Console()
                .CreateLogger();
            
            using (LogContext.PushProperty("RequestId", Guid.NewGuid()))
            using (LogContext.PushProperty("UserId", 123))
            {
                Log.Information("Processing user request");
                Log.Information("Request completed");
            }
        }

        /// <summary>
        /// Serilog with different log levels
        /// </summary>
        public static void SerilogLogLevels()
        {
            Log.Logger = new LoggerConfiguration()
                .MinimumLevel.Verbose()
                .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
                .WriteTo.Console()
                .CreateLogger();
            
            Log.Verbose("Verbose message");
            Log.Debug("Debug message");
            Log.Information("Information message");
            Log.Warning("Warning message");
            Log.Error("Error message");
            Log.Fatal("Fatal message");
        }

        /// <summary>
        /// Serilog with multiple sinks
        /// </summary>
        public static void SerilogMultipleSinks()
        {
            Log.Logger = new LoggerConfiguration()
                .MinimumLevel.Debug()
                .WriteTo.Console(
                    outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj}{NewLine}{Exception}")
                .WriteTo.File(
                    "logs/app.log",
                    rollingInterval: RollingInterval.Day,
                    outputTemplate: "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] {Message:lj}{NewLine}{Exception}")
                .WriteTo.File(
                    "logs/errors.log",
                    restrictedToMinimumLevel: LogEventLevel.Error,
                    rollingInterval: RollingInterval.Day)
                .CreateLogger();
            
            Log.Information("This goes to console and app.log");
            Log.Error("This goes to console, app.log, and errors.log");
        }

        /// <summary>
        /// Serilog with filtering
        /// </summary>
        public static void SerilogWithFiltering()
        {
            Log.Logger = new LoggerConfiguration()
                .MinimumLevel.Debug()
                .Filter.ByExcluding(logEvent => 
                    logEvent.Properties.ContainsKey("SensitiveData"))
                .WriteTo.Console()
                .CreateLogger();
            
            Log.Information("Normal log");
            
            using (LogContext.PushProperty("SensitiveData", true))
            {
                Log.Information("This will be filtered out");
            }
        }

        /// <summary>
        /// Integration with Microsoft.Extensions.Logging
        /// </summary>
        public static void SerilogWithMicrosoftLogging()
        {
            Log.Logger = new LoggerConfiguration()
                .MinimumLevel.Debug()
                .WriteTo.Console()
                .CreateLogger();
            
            var serviceProvider = new ServiceCollection()
                .AddLogging(builder =>
                {
                    builder.ClearProviders();
                    builder.AddSerilog(dispose: true);
                })
                .BuildServiceProvider();
            
            var logger = serviceProvider.GetRequiredService<ILogger<SerilogSample>>();
            logger.LogInformation("Logging through Microsoft.Extensions.Logging with Serilog backend");
        }

        /// <summary>
        /// Serilog sub-logger pattern
        /// </summary>
        public static void SerilogSubLogger()
        {
            Log.Logger = new LoggerConfiguration()
                .MinimumLevel.Debug()
                .WriteTo.Console()
                .CreateLogger();
            
            var orderLogger = Log.ForContext("Component", "OrderService");
            orderLogger.Information("Processing order");
            
            var paymentLogger = Log.ForContext("Component", "PaymentService");
            paymentLogger.Information("Processing payment");
        }

        /// <summary>
        /// Serilog with custom properties
        /// </summary>
        public static void SerilogCustomProperties()
        {
            Log.Logger = new LoggerConfiguration()
                .MinimumLevel.Debug()
                .WriteTo.Console()
                .CreateLogger();
            
            var orderInfo = new
            {
                OrderId = Guid.NewGuid(),
                CustomerId = 123,
                Total = 99.99m
            };
            
            Log.Information("Order created: {@OrderInfo}", orderInfo);
            
            // Scalar values (not destructured)
            Log.Information("Order ID: {$OrderId}", orderInfo.OrderId);
        }

        /// <summary>
        /// Serilog exception logging
        /// </summary>
        public static void SerilogExceptionLogging()
        {
            Log.Logger = new LoggerConfiguration()
                .MinimumLevel.Debug()
                .WriteTo.Console()
                .CreateLogger();
            
            try
            {
                throw new InvalidOperationException("Test exception")
                {
                    Data = { ["CustomProperty"] = "CustomValue" }
                };
            }
            catch (Exception ex)
            {
                Log.Error(ex, "Error occurred while processing order {OrderId}", Guid.NewGuid());
            }
        }

        /// <summary>
        /// Demonstrates running Serilog samples
        /// </summary>
        public static void RunSamples()
        {
            Console.WriteLine("=== Serilog Sample ===\n");
            
            try
            {
                // Basic configuration
                Console.WriteLine("1. Basic Serilog configuration:");
                BasicSerilogConfiguration();
                Log.CloseAndFlush();
                Console.WriteLine();
                
                // Structured logging
                Console.WriteLine("2. Structured logging:");
                BasicSerilogConfiguration(); // Reconfigure
                StructuredLoggingWithSerilog();
                Log.CloseAndFlush();
                Console.WriteLine();
                
                // Enrichment
                Console.WriteLine("3. Serilog with enrichment:");
                SerilogWithEnrichment();
                Log.CloseAndFlush();
                Console.WriteLine();
                
                // Multiple sinks
                Console.WriteLine("4. Multiple sinks:");
                SerilogMultipleSinks();
                Log.CloseAndFlush();
                Console.WriteLine();
                
                // Sub-logger
                Console.WriteLine("5. Sub-logger pattern:");
                SerilogSubLogger();
                Log.CloseAndFlush();
                Console.WriteLine();
                
                // Exception logging
                Console.WriteLine("6. Exception logging:");
                BasicSerilogConfiguration(); // Reconfigure
                SerilogExceptionLogging();
                Log.CloseAndFlush();
                Console.WriteLine();
            }
            finally
            {
                Log.CloseAndFlush();
            }
        }
    }
}
