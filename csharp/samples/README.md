# C# Advanced Features Samples

[← Back to C#](../README.md) | [Main README](../../README.md)

This directory contains comprehensive examples demonstrating modern C# features, patterns, and best practices.

## Overview

The samples cover a wide range of topics including:
- **Asynchronous Programming**: async/await, Task-based patterns, async streams
- **Concurrency**: Thread-safe collections, parallel processing, channels
- **Locking & Synchronization**: Various locking mechanisms and thread safety patterns
- **Caching**: Memory caching strategies and patterns
- **Logging**: Structured logging with ILogger and Serilog
- **Observability**: Metrics, distributed tracing, and health checks
- **Advanced Language Features**: Pattern matching, records, nullable reference types, Span<T>/Memory<T>
- **FIX Protocol**: Financial Information eXchange protocol implementation (legacy)

## Quick Start

### Running All Samples

```bash
cd csharp/samples
dotnet restore
dotnet run
```

### Running Specific Samples

```bash
# Run async samples only
dotnet run async

# Run logging samples only
dotnet run logging

# Run pattern matching samples
dotnet run patterns
```

## Available Samples

### Async Programming

#### AsyncPatternsSample.cs
Demonstrates async/await patterns and best practices:
- Basic async/await
- Parallel async operations with Task.WhenAll
- Task.WhenAny for racing tasks
- Async with timeout and cancellation
- ValueTask for performance
- ConfigureAwait for library code
- Progress reporting

**Key Topics**: Task, async/await, CancellationToken, ValueTask, IProgress<T>

#### AsyncStreamsSample.cs
Shows IAsyncEnumerable for async streaming data:
- Basic IAsyncEnumerable
- Async streams with cancellation
- Filtering and transforming async streams
- Buffered streams
- Real-time data streaming

**Key Topics**: IAsyncEnumerable, yield return, async foreach

### Concurrency

#### ConcurrentCollectionsSample.cs
Thread-safe collections for concurrent scenarios:
- ConcurrentBag<T> - unordered collection
- ConcurrentQueue<T> - FIFO queue
- ConcurrentStack<T> - LIFO stack
- ConcurrentDictionary<TKey, TValue> - thread-safe dictionary
- BlockingCollection<T> - producer-consumer pattern

**Key Topics**: Thread safety, concurrent data structures

#### ParallelProcessingSample.cs
Parallel processing using TPL:
- Parallel.For and Parallel.ForEach
- PLINQ (Parallel LINQ)
- Degree of parallelism control
- Parallel.Invoke
- Performance comparisons

**Key Topics**: Parallel processing, PLINQ, data parallelism

#### ChannelsSample.cs
Modern producer-consumer using System.Threading.Channels:
- Unbounded and bounded channels
- Multiple producers/consumers
- Channel pipelines
- Backpressure handling
- Priority-based processing

**Key Topics**: Channels, producer-consumer, async pipelines

### Locking & Thread Safety

#### LockingPatternsSample.cs
Various synchronization primitives:
- lock statement
- SemaphoreSlim for limiting concurrency
- ReaderWriterLockSlim for read/write scenarios
- Mutex for cross-process synchronization
- Monitor for advanced locking
- ManualResetEventSlim and CountdownEvent
- Barrier for phase synchronization

**Key Topics**: Locking, synchronization, mutual exclusion

#### ThreadSafetySample.cs
Thread safety without locks:
- Interlocked operations (Increment, CompareExchange)
- volatile keyword
- ThreadLocal<T> and AsyncLocal<T>
- Lock-free data structures
- Memory barriers

**Key Topics**: Lock-free programming, atomic operations

### Caching

#### MemoryCacheSample.cs
In-memory caching patterns:
- IMemoryCache basics
- Absolute and sliding expiration
- Cache priorities and eviction
- GetOrCreate pattern
- Cache-aside pattern
- LazyCache integration

**Key Topics**: Caching, cache policies, performance optimization

### Logging

#### LoggingSample.cs
Structured logging with Microsoft.Extensions.Logging:
- Log levels (Trace, Debug, Info, Warning, Error, Critical)
- Structured logging with message templates
- Logging scopes for correlation
- High-performance logging with LoggerMessage
- Exception logging

**Key Topics**: Logging, structured logging, log levels

#### SerilogSample.cs
Advanced logging with Serilog:
- Serilog configuration
- Structured logging
- Enrichment and context
- Multiple sinks (Console, File)
- Filtering and log levels
- Integration with Microsoft.Extensions.Logging

**Key Topics**: Serilog, log enrichment, sinks

### Observability

#### MetricsSample.cs
Application metrics using System.Diagnostics.Metrics:
- Counters for monotonically increasing values
- Histograms for value distributions
- Observable gauges
- Metrics with tags/dimensions
- Business and API metrics

**Key Topics**: Metrics, observability, monitoring

#### TracingSample.cs
Distributed tracing with System.Diagnostics.Activity:
- Activity (span) creation
- Nested activities (parent-child)
- Activity events and tags
- Activity status and error tracking
- Baggage for context propagation
- Distributed trace correlation

**Key Topics**: Distributed tracing, spans, trace correlation

#### HealthChecksSample.cs
Health check patterns:
- IHealthCheck implementation
- Liveness and readiness probes
- Health check with custom data
- External dependency checks
- Health check aggregation

**Key Topics**: Health checks, Kubernetes probes, monitoring

### Advanced Language Features

#### PatternMatchingSample.cs
Modern pattern matching (C# 7.0 - 11.0):
- Type patterns
- Switch expressions
- Property patterns
- Positional patterns
- Tuple patterns
- Relational patterns (< > >= <=)
- Logical patterns (and, or, not)
- List patterns

**Key Topics**: Pattern matching, switch expressions

#### RecordsSample.cs
Record types and features (C# 9.0+):
- Record declarations
- Value equality
- With expressions (non-destructive mutation)
- Record inheritance
- Record structs
- Init-only properties
- Records as DTOs

**Key Topics**: Records, immutability, value equality

#### NullabilityFeaturesSample.cs
Nullable reference types (C# 8.0+):
- Nullable vs non-nullable reference types
- Null-conditional operator (?.)
- Null-coalescing operator (?? and ??=)
- Null-forgiving operator (!)
- Nullable annotations in APIs
- Required properties (C# 11.0)

**Key Topics**: Null safety, nullable reference types

#### SpanAndMemorySample.cs
High-performance with Span<T> and Memory<T>:
- Span<T> for stack-allocated arrays
- ReadOnlySpan<T> for read-only views
- Memory<T> for async scenarios
- ArrayPool for buffer reuse
- MemoryPool<T>
- Zero-allocation string operations
- Performance optimizations

**Key Topics**: Span<T>, Memory<T>, performance, zero-allocation

## FIX Protocol (Legacy)

### Rest-FIX-Client API application
Financial Information eXchange protocol implementation:

#### Dependencies:
1. QuickFIXn 4.2, 4.4, 5.0 (only 4.2 implemented)
2. FIXImulator_0.41 as demo exchange server
3. ASP.NET Core 6.0

#### Steps:
1. Run Simulator
2. Configure Client Server
3. Use Swagger API for testing

## Project Structure

```
samples/
├── AsyncPatternsSample.cs           # Async/await patterns
├── AsyncStreamsSample.cs            # IAsyncEnumerable examples
├── ChannelsSample.cs                # System.Threading.Channels
├── ConcurrentCollectionsSample.cs   # Thread-safe collections
├── ParallelProcessingSample.cs      # Parallel processing
├── LockingPatternsSample.cs         # Locking mechanisms
├── ThreadSafetySample.cs            # Lock-free patterns
├── MemoryCacheSample.cs             # Caching strategies
├── LoggingSample.cs                 # ILogger patterns
├── SerilogSample.cs                 # Serilog integration
├── MetricsSample.cs                 # Application metrics
├── TracingSample.cs                 # Distributed tracing
├── HealthChecksSample.cs            # Health checks
├── PatternMatchingSample.cs         # Pattern matching
├── RecordsSample.cs                 # Record types
├── NullabilityFeaturesSample.cs     # Nullable reference types
├── SpanAndMemorySample.cs           # Span<T> and Memory<T>
├── SampleRunner.cs                  # Sample executor
├── RestFixClient.csproj             # Project file
└── README.md                        # This file
```

## Learning Path

### Beginner
1. Start with **AsyncPatternsSample** - Learn async/await fundamentals
2. Explore **LoggingSample** - Understand structured logging
3. Review **PatternMatchingSample** - Modern C# syntax

### Intermediate
1. **ConcurrentCollectionsSample** - Thread-safe collections
2. **MemoryCacheSample** - Caching strategies
3. **RecordsSample** - Immutable data types
4. **NullabilityFeaturesSample** - Null safety

### Advanced
1. **ChannelsSample** - Advanced async patterns
2. **ParallelProcessingSample** - Performance optimization
3. **ThreadSafetySample** - Lock-free programming
4. **SpanAndMemorySample** - Zero-allocation code
5. **MetricsSample** & **TracingSample** - Production observability

## Best Practices

### Async Programming
- Use async/await for I/O-bound operations
- Avoid async void (except event handlers)
- Use ConfigureAwait(false) in library code
- Prefer Task.WhenAll over sequential await
- Use CancellationToken for long-running operations

### Concurrency
- Use concurrent collections for thread-safe access
- Prefer Task Parallel Library over manual threading
- Use channels for producer-consumer scenarios
- Minimize lock contention
- Use appropriate synchronization primitives

### Caching
- Set appropriate expiration policies
- Use cache priorities for important data
- Handle cache eviction gracefully
- Consider distributed caching for scale-out scenarios

### Logging
- Use structured logging with message templates
- Include correlation IDs for request tracing
- Log at appropriate levels
- Avoid logging sensitive data
- Use scopes for contextual information

### Observability
- Instrument critical paths with metrics
- Use distributed tracing for microservices
- Implement health checks for all dependencies
- Monitor and alert on key metrics

## References

### Official Documentation
- [Async Programming](https://docs.microsoft.com/en-us/dotnet/csharp/async)
- [Task Parallel Library](https://docs.microsoft.com/en-us/dotnet/standard/parallel-programming/)
- [System.Threading.Channels](https://docs.microsoft.com/en-us/dotnet/api/system.threading.channels)
- [Memory and Span](https://docs.microsoft.com/en-us/dotnet/standard/memory-and-spans/)
- [Pattern Matching](https://docs.microsoft.com/en-us/dotnet/csharp/pattern-matching)
- [Nullable Reference Types](https://docs.microsoft.com/en-us/dotnet/csharp/nullable-references)

### Libraries
- [Serilog](https://serilog.net/)
- [LazyCache](https://github.com/alastairtree/LazyCache)
- [OpenTelemetry](https://opentelemetry.io/)
- [QuickFIX/n](https://github.com/connamara/quickfixn)

### Learning Resources
- [C# Language Documentation](https://docs.microsoft.com/en-us/dotnet/csharp/)
- [.NET API Browser](https://docs.microsoft.com/en-us/dotnet/api/)
- [Performance Tips](https://docs.microsoft.com/en-us/dotnet/framework/performance/)

## Contributing

When adding new samples:
1. Follow the existing code structure
2. Include comprehensive XML documentation
3. Add a RunSamples() or RunSamplesAsync() method
4. Update this README with sample description
5. Add to SampleRunner.cs
6. Include references and learning resources
