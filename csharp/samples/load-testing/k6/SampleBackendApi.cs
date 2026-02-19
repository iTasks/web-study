using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace K6LoadTestSample
{
    /// <summary>
    /// Sample C# backend API for k6 load testing
    /// Demonstrates a typical DSE-BD/CSE-BD microservice with:
    /// - Health checks
    /// - CRUD operations
    /// - Database simulation
    /// - Caching layer
    /// - Metrics endpoints
    /// </summary>
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                    webBuilder.UseUrls("http://localhost:5000");
                });
    }

    public class Startup
    {
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllers();
            services.AddMemoryCache();
            services.AddSingleton<DataService>();
            services.AddHealthChecks();
            
            // Add CORS for k6 testing
            services.AddCors(options =>
            {
                options.AddDefaultPolicy(builder =>
                {
                    builder.AllowAnyOrigin()
                           .AllowAnyMethod()
                           .AllowAnyHeader();
                });
            });
        }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, ILogger<Startup> logger)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseRouting();
            app.UseCors();

            app.UseEndpoints(endpoints =>
            {
                // Health check endpoint
                endpoints.MapGet("/health", async context =>
                {
                    await context.Response.WriteAsJsonAsync(new
                    {
                        status = "healthy",
                        timestamp = DateTime.UtcNow
                    });
                });

                // Readiness check endpoint
                endpoints.MapGet("/ready", async context =>
                {
                    await context.Response.WriteAsJsonAsync(new
                    {
                        ready = true,
                        timestamp = DateTime.UtcNow
                    });
                });

                // GET: Retrieve data
                endpoints.MapGet("/api/data", async (HttpContext context, DataService dataService) =>
                {
                    // Simulate some processing time
                    await Task.Delay(Random.Shared.Next(10, 50));
                    
                    var data = dataService.GetAll();
                    await context.Response.WriteAsJsonAsync(new
                    {
                        count = data.Count,
                        data = data.Take(10)
                    });
                });

                // POST: Create data
                endpoints.MapPost("/api/data", async (HttpContext context, DataService dataService) =>
                {
                    try
                    {
                        var payload = await JsonSerializer.DeserializeAsync<DataItem>(context.Request.Body);
                        
                        // Simulate some processing time
                        await Task.Delay(Random.Shared.Next(20, 100));
                        
                        dataService.Add(payload);
                        
                        context.Response.StatusCode = 201;
                        await context.Response.WriteAsJsonAsync(new
                        {
                            success = true,
                            id = payload.Id
                        });
                    }
                    catch (Exception ex)
                    {
                        context.Response.StatusCode = 400;
                        await context.Response.WriteAsJsonAsync(new
                        {
                            error = ex.Message
                        });
                    }
                });

                // GET: Database query simulation
                endpoints.MapGet("/api/database/query", async context =>
                {
                    // Simulate database query time (potential bottleneck)
                    var queryTime = Random.Shared.Next(100, 300);
                    await Task.Delay(queryTime);
                    
                    await context.Response.WriteAsJsonAsync(new
                    {
                        records = Random.Shared.Next(100, 1000),
                        queryTime = queryTime,
                        timestamp = DateTime.UtcNow
                    });
                });

                // GET: Cache operations
                endpoints.MapGet("/api/cache/data", async (HttpContext context, DataService dataService) =>
                {
                    // Simulate fast cache read
                    await Task.Delay(Random.Shared.Next(5, 20));
                    
                    var cachedData = dataService.GetFromCache();
                    await context.Response.WriteAsJsonAsync(new
                    {
                        cached = true,
                        data = cachedData
                    });
                });

                // GET: Metrics endpoint
                endpoints.MapGet("/metrics", async (HttpContext context, DataService dataService) =>
                {
                    var metrics = dataService.GetMetrics();
                    await context.Response.WriteAsJsonAsync(metrics);
                });

                // Map health checks
                endpoints.MapHealthChecks("/healthz");
            });

            logger.LogInformation("Sample C# backend API started on http://localhost:5000");
            logger.LogInformation("Ready for k6 load testing");
        }
    }

    public class DataItem
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string Name { get; set; }
        public double Value { get; set; }
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    }

    public class DataService
    {
        private readonly ConcurrentDictionary<Guid, DataItem> _data = new();
        private readonly ConcurrentDictionary<string, object> _cache = new();
        private long _requestCount = 0;
        private long _errorCount = 0;

        public DataService()
        {
            // Initialize with some sample data
            for (int i = 0; i < 100; i++)
            {
                var item = new DataItem
                {
                    Name = $"Item_{i}",
                    Value = Random.Shared.NextDouble() * 1000
                };
                _data.TryAdd(item.Id, item);
            }

            // Initialize cache
            _cache.TryAdd("sample", new { message = "cached data" });
        }

        public List<DataItem> GetAll()
        {
            System.Threading.Interlocked.Increment(ref _requestCount);
            return _data.Values.ToList();
        }

        public void Add(DataItem item)
        {
            System.Threading.Interlocked.Increment(ref _requestCount);
            _data.TryAdd(item.Id, item);
        }

        public object GetFromCache()
        {
            System.Threading.Interlocked.Increment(ref _requestCount);
            return _cache.GetValueOrDefault("sample", new { message = "no cache" });
        }

        public object GetMetrics()
        {
            return new
            {
                totalRequests = _requestCount,
                totalErrors = _errorCount,
                dataCount = _data.Count,
                cacheSize = _cache.Count,
                timestamp = DateTime.UtcNow
            };
        }

        public void RecordError()
        {
            System.Threading.Interlocked.Increment(ref _errorCount);
        }
    }
}
