using System.Threading.Channels;

namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates System.Threading.Channels for producer-consumer scenarios
    /// Channels provide a modern, high-performance alternative to BlockingCollection
    /// </summary>
    public class ChannelsSample
    {
        /// <summary>
        /// Basic unbounded channel example
        /// </summary>
        public async Task UnboundedChannelExampleAsync()
        {
            var channel = Channel.CreateUnbounded<int>();
            
            // Producer
            var producer = Task.Run(async () =>
            {
                for (int i = 0; i < 10; i++)
                {
                    await channel.Writer.WriteAsync(i);
                    Console.WriteLine($"Produced: {i}");
                    await Task.Delay(100);
                }
                channel.Writer.Complete();
            });
            
            // Consumer
            var consumer = Task.Run(async () =>
            {
                await foreach (var item in channel.Reader.ReadAllAsync())
                {
                    Console.WriteLine($"Consumed: {item}");
                    await Task.Delay(150);
                }
            });
            
            await Task.WhenAll(producer, consumer);
        }

        /// <summary>
        /// Bounded channel with backpressure
        /// </summary>
        public async Task BoundedChannelExampleAsync()
        {
            var options = new BoundedChannelOptions(5)
            {
                FullMode = BoundedChannelFullMode.Wait
            };
            var channel = Channel.CreateBounded<string>(options);
            
            // Producer
            var producer = Task.Run(async () =>
            {
                for (int i = 0; i < 20; i++)
                {
                    await channel.Writer.WriteAsync($"Item {i}");
                    Console.WriteLine($"Produced: Item {i}");
                    await Task.Delay(50);
                }
                channel.Writer.Complete();
            });
            
            // Consumer (slower than producer)
            var consumer = Task.Run(async () =>
            {
                await foreach (var item in channel.Reader.ReadAllAsync())
                {
                    Console.WriteLine($"Consumed: {item}");
                    await Task.Delay(200);
                }
            });
            
            await Task.WhenAll(producer, consumer);
        }

        /// <summary>
        /// Multiple producers, single consumer
        /// </summary>
        public async Task MultipleProducersExampleAsync()
        {
            var channel = Channel.CreateUnbounded<string>();
            
            // Multiple producers
            var producers = Enumerable.Range(0, 3).Select(producerId =>
                Task.Run(async () =>
                {
                    for (int i = 0; i < 5; i++)
                    {
                        await channel.Writer.WriteAsync($"Producer {producerId}: Item {i}");
                        await Task.Delay(Random.Shared.Next(50, 150));
                    }
                })
            ).ToList();
            
            // Signal completion when all producers are done
            _ = Task.Run(async () =>
            {
                await Task.WhenAll(producers);
                channel.Writer.Complete();
            });
            
            // Single consumer
            await foreach (var item in channel.Reader.ReadAllAsync())
            {
                Console.WriteLine($"Consumed: {item}");
            }
        }

        /// <summary>
        /// Single producer, multiple consumers
        /// </summary>
        public async Task MultipleConsumersExampleAsync()
        {
            var channel = Channel.CreateUnbounded<int>();
            
            // Producer
            var producer = Task.Run(async () =>
            {
                for (int i = 0; i < 20; i++)
                {
                    await channel.Writer.WriteAsync(i);
                    await Task.Delay(100);
                }
                channel.Writer.Complete();
            });
            
            // Multiple consumers
            var consumers = Enumerable.Range(0, 3).Select(consumerId =>
                Task.Run(async () =>
                {
                    await foreach (var item in channel.Reader.ReadAllAsync())
                    {
                        Console.WriteLine($"Consumer {consumerId} processed: {item}");
                        await Task.Delay(50);
                    }
                })
            ).ToList();
            
            await Task.WhenAll(consumers);
        }

        /// <summary>
        /// Channel with cancellation
        /// </summary>
        public async Task ChannelWithCancellationAsync(CancellationToken cancellationToken)
        {
            var channel = Channel.CreateUnbounded<int>();
            
            try
            {
                // Producer with cancellation
                var producer = Task.Run(async () =>
                {
                    int i = 0;
                    while (!cancellationToken.IsCancellationRequested)
                    {
                        await channel.Writer.WriteAsync(i++, cancellationToken);
                        await Task.Delay(100, cancellationToken);
                    }
                }, cancellationToken);
                
                // Consumer with cancellation
                var consumer = Task.Run(async () =>
                {
                    await foreach (var item in channel.Reader.ReadAllAsync(cancellationToken))
                    {
                        Console.WriteLine($"Consumed: {item}");
                    }
                }, cancellationToken);
                
                await Task.WhenAll(producer, consumer);
            }
            catch (OperationCanceledException)
            {
                channel.Writer.Complete();
                Console.WriteLine("Channel operations cancelled");
            }
        }

        /// <summary>
        /// Pipeline pattern using channels
        /// </summary>
        public async Task ChannelPipelineExampleAsync()
        {
            var channel1 = Channel.CreateUnbounded<int>();
            var channel2 = Channel.CreateUnbounded<int>();
            
            // Stage 1: Generator
            var generator = Task.Run(async () =>
            {
                for (int i = 0; i < 10; i++)
                {
                    await channel1.Writer.WriteAsync(i);
                    await Task.Delay(50);
                }
                channel1.Writer.Complete();
            });
            
            // Stage 2: Transformer
            var transformer = Task.Run(async () =>
            {
                await foreach (var item in channel1.Reader.ReadAllAsync())
                {
                    var transformed = item * item;
                    await channel2.Writer.WriteAsync(transformed);
                    Console.WriteLine($"Transformed {item} to {transformed}");
                }
                channel2.Writer.Complete();
            });
            
            // Stage 3: Consumer
            var consumer = Task.Run(async () =>
            {
                await foreach (var item in channel2.Reader.ReadAllAsync())
                {
                    Console.WriteLine($"Final result: {item}");
                }
            });
            
            await Task.WhenAll(generator, transformer, consumer);
        }

        /// <summary>
        /// Priority-based channel processing
        /// </summary>
        public async Task PriorityChannelExampleAsync()
        {
            var highPriorityChannel = Channel.CreateUnbounded<string>();
            var lowPriorityChannel = Channel.CreateUnbounded<string>();
            
            // Producers
            var highPriorityProducer = Task.Run(async () =>
            {
                for (int i = 0; i < 5; i++)
                {
                    await highPriorityChannel.Writer.WriteAsync($"HIGH: Item {i}");
                    await Task.Delay(300);
                }
                highPriorityChannel.Writer.Complete();
            });
            
            var lowPriorityProducer = Task.Run(async () =>
            {
                for (int i = 0; i < 10; i++)
                {
                    await lowPriorityChannel.Writer.WriteAsync($"LOW: Item {i}");
                    await Task.Delay(100);
                }
                lowPriorityChannel.Writer.Complete();
            });
            
            // Consumer that prioritizes high priority items
            var consumer = Task.Run(async () =>
            {
                while (await highPriorityChannel.Reader.WaitToReadAsync() || 
                       await lowPriorityChannel.Reader.WaitToReadAsync())
                {
                    // Try high priority first
                    if (highPriorityChannel.Reader.TryRead(out var highItem))
                    {
                        Console.WriteLine($"Processed: {highItem}");
                    }
                    else if (lowPriorityChannel.Reader.TryRead(out var lowItem))
                    {
                        Console.WriteLine($"Processed: {lowItem}");
                    }
                    
                    await Task.Delay(100);
                }
            });
            
            await Task.WhenAll(highPriorityProducer, lowPriorityProducer, consumer);
        }

        /// <summary>
        /// Demonstrates running channels samples
        /// </summary>
        public static async Task RunSamplesAsync()
        {
            var sample = new ChannelsSample();
            
            Console.WriteLine("=== Channels Sample ===\n");
            
            // Unbounded channel
            Console.WriteLine("1. Unbounded channel:");
            await sample.UnboundedChannelExampleAsync();
            Console.WriteLine();
            
            // Bounded channel
            Console.WriteLine("2. Bounded channel with backpressure:");
            await sample.BoundedChannelExampleAsync();
            Console.WriteLine();
            
            // Multiple producers
            Console.WriteLine("3. Multiple producers, single consumer:");
            await sample.MultipleProducersExampleAsync();
            Console.WriteLine();
            
            // Pipeline
            Console.WriteLine("4. Channel pipeline:");
            await sample.ChannelPipelineExampleAsync();
            Console.WriteLine();
            
            // Priority channels
            Console.WriteLine("5. Priority-based processing:");
            await sample.PriorityChannelExampleAsync();
            Console.WriteLine();
        }
    }
}
