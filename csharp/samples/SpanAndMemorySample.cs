using System.Buffers;
using System.Text;

namespace RestFixClient.Samples
{
    /// <summary>
    /// Demonstrates Span<T> and Memory<T> for high-performance, low-allocation code
    /// </summary>
    public class SpanAndMemorySample
    {
        /// <summary>
        /// Basic Span<T> usage
        /// </summary>
        public void BasicSpanExample()
        {
            int[] array = { 1, 2, 3, 4, 5 };
            
            // Span<T> provides a view over the array without allocation
            Span<int> span = array.AsSpan();
            
            Console.WriteLine($"Span length: {span.Length}");
            Console.WriteLine($"First element: {span[0]}");
            
            // Modify through span
            span[0] = 10;
            Console.WriteLine($"Modified array[0]: {array[0]}");
        }

        /// <summary>
        /// Slicing with Span<T>
        /// </summary>
        public void SpanSlicingExample()
        {
            int[] array = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
            
            Span<int> span = array.AsSpan();
            
            // Get middle 5 elements
            Span<int> slice = span.Slice(2, 5);
            
            Console.WriteLine("Slice elements:");
            foreach (var item in slice)
            {
                Console.Write($"{item} ");
            }
            Console.WriteLine();
            
            // Modify slice affects original array
            slice[0] = 100;
            Console.WriteLine($"Original array[2]: {array[2]}");
        }

        /// <summary>
        /// ReadOnlySpan<T> for read-only views
        /// </summary>
        public void ReadOnlySpanExample()
        {
            string text = "Hello, World!";
            
            // ReadOnlySpan<char> for string slicing without allocation
            ReadOnlySpan<char> span = text.AsSpan();
            ReadOnlySpan<char> hello = span.Slice(0, 5);
            ReadOnlySpan<char> world = span.Slice(7, 5);
            
            Console.WriteLine($"Hello: {hello.ToString()}");
            Console.WriteLine($"World: {world.ToString()}");
        }

        /// <summary>
        /// Stack allocation with stackalloc
        /// </summary>
        public void StackAllocExample()
        {
            // Allocate on stack (no GC pressure)
            Span<int> numbers = stackalloc int[10];
            
            for (int i = 0; i < numbers.Length; i++)
            {
                numbers[i] = i * i;
            }
            
            Console.WriteLine("Stack-allocated array:");
            foreach (var num in numbers)
            {
                Console.Write($"{num} ");
            }
            Console.WriteLine();
        }

        /// <summary>
        /// String parsing without allocation using Span<T>
        /// </summary>
        public void SpanStringParsingExample()
        {
            string csv = "John,Doe,30,USA";
            
            ReadOnlySpan<char> span = csv.AsSpan();
            
            int firstComma = span.IndexOf(',');
            int secondComma = span.Slice(firstComma + 1).IndexOf(',') + firstComma + 1;
            int thirdComma = span.Slice(secondComma + 1).IndexOf(',') + secondComma + 1;
            
            ReadOnlySpan<char> firstName = span.Slice(0, firstComma);
            ReadOnlySpan<char> lastName = span.Slice(firstComma + 1, secondComma - firstComma - 1);
            ReadOnlySpan<char> age = span.Slice(secondComma + 1, thirdComma - secondComma - 1);
            ReadOnlySpan<char> country = span.Slice(thirdComma + 1);
            
            Console.WriteLine($"First Name: {firstName.ToString()}");
            Console.WriteLine($"Last Name: {lastName.ToString()}");
            Console.WriteLine($"Age: {age.ToString()}");
            Console.WriteLine($"Country: {country.ToString()}");
        }

        /// <summary>
        /// Memory<T> for async scenarios
        /// </summary>
        public async Task MemoryAsyncExample()
        {
            byte[] buffer = new byte[1024];
            Memory<byte> memory = buffer.AsMemory();
            
            // Simulate async I/O operation
            await WriteAsync(memory.Slice(0, 10));
            
            Console.WriteLine("First 10 bytes:");
            var memorySlice = memory.Slice(0, 10);
            for (int i = 0; i < memorySlice.Length; i++)
            {
                Console.Write($"{memorySlice.Span[i]} ");
            }
            Console.WriteLine();
        }

        private async Task WriteAsync(Memory<byte> memory)
        {
            await Task.Delay(100);
            
            for (int i = 0; i < memory.Length; i++)
            {
                memory.Span[i] = (byte)i;
            }
        }

        /// <summary>
        /// ArrayPool for buffer reuse
        /// </summary>
        public void ArrayPoolExample()
        {
            var pool = ArrayPool<byte>.Shared;
            
            // Rent buffer from pool
            byte[] buffer = pool.Rent(1024);
            
            try
            {
                // Use buffer
                Span<byte> span = buffer.AsSpan(0, 100);
                for (int i = 0; i < span.Length; i++)
                {
                    span[i] = (byte)(i % 256);
                }
                
                Console.WriteLine($"Used buffer of size {buffer.Length}");
            }
            finally
            {
                // Always return to pool
                pool.Return(buffer);
            }
        }

        /// <summary>
        /// MemoryPool<T> for Memory<T> reuse
        /// </summary>
        public async Task MemoryPoolExample()
        {
            using var memoryOwner = MemoryPool<byte>.Shared.Rent(1024);
            
            Memory<byte> memory = memoryOwner.Memory.Slice(0, 100);
            
            await Task.Run(() =>
            {
                for (int i = 0; i < memory.Length; i++)
                {
                    memory.Span[i] = (byte)(i * 2);
                }
            });
            
            Console.WriteLine($"Processed {memory.Length} bytes from pool");
        }

        /// <summary>
        /// High-performance string concatenation
        /// </summary>
        public string HighPerformanceStringConcatenation(int count)
        {
            // Use ArrayPool to avoid allocations
            var pool = ArrayPool<char>.Shared;
            char[] buffer = pool.Rent(count * 10);
            
            try
            {
                Span<char> span = buffer.AsSpan();
                int position = 0;
                
                for (int i = 0; i < count; i++)
                {
                    ReadOnlySpan<char> text = $"Item{i}".AsSpan();
                    text.CopyTo(span.Slice(position));
                    position += text.Length;
                    
                    if (i < count - 1)
                    {
                        span[position++] = ',';
                    }
                }
                
                return new string(span.Slice(0, position));
            }
            finally
            {
                pool.Return(buffer);
            }
        }

        /// <summary>
        /// Binary data processing with Span<T>
        /// </summary>
        public void BinaryDataProcessingExample()
        {
            Span<byte> buffer = stackalloc byte[4];
            
            // Write int as bytes (little-endian)
            int value = 0x12345678;
            BitConverter.TryWriteBytes(buffer, value);
            
            Console.WriteLine("Bytes:");
            foreach (var b in buffer)
            {
                Console.Write($"0x{b:X2} ");
            }
            Console.WriteLine();
            
            // Read back
            int readValue = BitConverter.ToInt32(buffer);
            Console.WriteLine($"Read value: 0x{readValue:X}");
        }

        /// <summary>
        /// Comparing performance: string vs Span<char>
        /// </summary>
        public void PerformanceComparisonExample()
        {
            const int iterations = 10000;
            string text = "The quick brown fox jumps over the lazy dog";
            
            // String approach (many allocations)
            var sw1 = System.Diagnostics.Stopwatch.StartNew();
            for (int i = 0; i < iterations; i++)
            {
                var _ = text.Substring(4, 5); // Allocates new string
            }
            sw1.Stop();
            
            // Span approach (no allocations)
            var sw2 = System.Diagnostics.Stopwatch.StartNew();
            for (int i = 0; i < iterations; i++)
            {
                ReadOnlySpan<char> _ = text.AsSpan().Slice(4, 5);
            }
            sw2.Stop();
            
            Console.WriteLine($"String.Substring: {sw1.ElapsedMilliseconds}ms");
            Console.WriteLine($"Span.Slice: {sw2.ElapsedMilliseconds}ms");
            Console.WriteLine($"Speedup: {(double)sw1.ElapsedMilliseconds / sw2.ElapsedMilliseconds:F2}x");
        }

        /// <summary>
        /// Span-based API design
        /// </summary>
        public int ParseNumbers(ReadOnlySpan<char> input, Span<int> output)
        {
            int count = 0;
            int start = 0;
            
            for (int i = 0; i <= input.Length; i++)
            {
                if (i == input.Length || input[i] == ',')
                {
                    if (i > start)
                    {
                        var numberSpan = input.Slice(start, i - start);
                        if (int.TryParse(numberSpan, out int number))
                        {
                            output[count++] = number;
                        }
                    }
                    start = i + 1;
                }
            }
            
            return count;
        }

        /// <summary>
        /// Demonstrates running Span and Memory samples
        /// </summary>
        public static async Task RunSamplesAsync()
        {
            var sample = new SpanAndMemorySample();
            
            Console.WriteLine("=== Span and Memory Sample ===\n");
            
            // Basic Span
            Console.WriteLine("1. Basic Span<T>:");
            sample.BasicSpanExample();
            Console.WriteLine();
            
            // Slicing
            Console.WriteLine("2. Span slicing:");
            sample.SpanSlicingExample();
            Console.WriteLine();
            
            // ReadOnlySpan
            Console.WriteLine("3. ReadOnlySpan<T>:");
            sample.ReadOnlySpanExample();
            Console.WriteLine();
            
            // Stack allocation
            Console.WriteLine("4. Stack allocation with stackalloc:");
            sample.StackAllocExample();
            Console.WriteLine();
            
            // String parsing
            Console.WriteLine("5. String parsing without allocation:");
            sample.SpanStringParsingExample();
            Console.WriteLine();
            
            // Memory async
            Console.WriteLine("6. Memory<T> for async:");
            await sample.MemoryAsyncExample();
            Console.WriteLine();
            
            // ArrayPool
            Console.WriteLine("7. ArrayPool for buffer reuse:");
            sample.ArrayPoolExample();
            Console.WriteLine();
            
            // High-performance concatenation
            Console.WriteLine("8. High-performance string concatenation:");
            var result = sample.HighPerformanceStringConcatenation(5);
            Console.WriteLine($"   Result: {result}");
            Console.WriteLine();
            
            // Performance comparison
            Console.WriteLine("9. Performance comparison:");
            sample.PerformanceComparisonExample();
            Console.WriteLine();
            
            // Span-based API
            Console.WriteLine("10. Span-based API:");
            int[] numbersArray = new int[10];
            int count = sample.ParseNumbers("1,2,3,4,5".AsSpan(), numbersArray.AsSpan());
            Console.Write($"   Parsed {count} numbers: ");
            for (int i = 0; i < count; i++)
            {
                Console.Write($"{numbersArray[i]} ");
            }
            Console.WriteLine("\n");
        }
    }
}
