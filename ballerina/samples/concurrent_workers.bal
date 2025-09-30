import ballerina/io;
import ballerina/random;

// Demonstrate Ballerina's worker-based concurrency
public function main() {
    io:println("=== Ballerina Concurrent Workers Demo ===\n");
    
    // Example 1: Basic worker communication
    basicWorkerExample();
    
    // Example 2: Worker coordination with multiple workers
    workerCoordinationExample();
    
    // Example 3: Producer-Consumer pattern
    producerConsumerExample();
    
    // Example 4: Parallel processing
    parallelProcessingExample();
}

// Basic worker communication example
function basicWorkerExample() {
    io:println("1. Basic Worker Communication:");
    
    // Create a worker that sends messages
    worker sender {
        string[] messages = ["Hello", "from", "worker", "sender"];
        
        foreach string msg in messages {
            msg -> receiver;
            io:println("Sender: Sent '" + msg + "'");
            runtime:sleep(0.5);
        }
        
        "DONE" -> receiver;
    }
    
    // Create a worker that receives messages
    worker receiver {
        string receivedMessage = "";
        
        while receivedMessage != "DONE" {
            receivedMessage = <- sender;
            if receivedMessage != "DONE" {
                io:println("Receiver: Got '" + receivedMessage + "'");
            }
        }
        
        io:println("Receiver: Communication complete\n");
    }
    
    // Wait for workers to complete
    wait {sender, receiver};
}

// Worker coordination with multiple workers
function workerCoordinationExample() {
    io:println("2. Worker Coordination:");
    
    int[] numbers = [1, 2, 3, 4, 5];
    int sum = 0;
    int product = 1;
    
    // Worker to calculate sum
    worker sumCalculator {
        int localSum = 0;
        foreach int num in numbers {
            localSum += num;
            runtime:sleep(0.1);
        }
        localSum -> coordinator;
    }
    
    // Worker to calculate product
    worker productCalculator {
        int localProduct = 1;
        foreach int num in numbers {
            localProduct *= num;
            runtime:sleep(0.1);
        }
        localProduct -> coordinator;
    }
    
    // Coordinator worker
    worker coordinator {
        sum = <- sumCalculator;
        product = <- productCalculator;
        
        io:println("Sum: " + sum.toString());
        io:println("Product: " + product.toString());
        io:println("Average: " + (sum / numbers.length()).toString() + "\n");
    }
    
    wait {sumCalculator, productCalculator, coordinator};
}

// Producer-Consumer pattern
function producerConsumerExample() {
    io:println("3. Producer-Consumer Pattern:");
    
    int maxItems = 10;
    int producedCount = 0;
    int consumedCount = 0;
    
    // Producer worker
    worker producer {
        while producedCount < maxItems {
            int item = producedCount + 1;
            item -> consumer;
            producedCount += 1;
            io:println("Producer: Created item " + item.toString());
            runtime:sleep(random:createDecimal() * 0.5);
        }
        
        // Send termination signal
        -1 -> consumer;
    }
    
    // Consumer worker
    worker consumer {
        int item = 0;
        
        while item != -1 {
            item = <- producer;
            if item != -1 {
                consumedCount += 1;
                io:println("Consumer: Processed item " + item.toString());
                runtime:sleep(random:createDecimal() * 0.3);
            }
        }
        
        io:println("Consumer: Finished processing " + consumedCount.toString() + " items\n");
    }
    
    wait {producer, consumer};
}

// Parallel processing example
function parallelProcessingExample() {
    io:println("4. Parallel Processing:");
    
    int[] data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    int[] results = [];
    
    // Split data into chunks for parallel processing
    int chunkSize = 3;
    int[][] chunks = splitIntoChunks(data, chunkSize);
    
    // Worker 1: Process first chunk
    worker worker1 {
        int[] chunk1Results = [];
        if chunks.length() > 0 {
            chunk1Results = processChunk(chunks[0], "Worker1");
        }
        chunk1Results -> aggregator;
    }
    
    // Worker 2: Process second chunk
    worker worker2 {
        int[] chunk2Results = [];
        if chunks.length() > 1 {
            chunk2Results = processChunk(chunks[1], "Worker2");
        }
        chunk2Results -> aggregator;
    }
    
    // Worker 3: Process third chunk
    worker worker3 {
        int[] chunk3Results = [];
        if chunks.length() > 2 {
            chunk3Results = processChunk(chunks[2], "Worker3");
        }
        chunk3Results -> aggregator;
    }
    
    // Aggregator worker
    worker aggregator {
        int totalWorkers = 3;
        int completedWorkers = 0;
        
        while completedWorkers < totalWorkers {
            int[] chunkResult = <- {worker1, worker2, worker3};
            results = mergeArrays(results, chunkResult);
            completedWorkers += 1;
        }
        
        io:println("Final results: " + results.toString());
        io:println("Total processed items: " + results.length().toString());
    }
    
    wait {worker1, worker2, worker3, aggregator};
}

// Helper function to split array into chunks
function splitIntoChunks(int[] data, int chunkSize) returns int[][] {
    int[][] chunks = [];
    int i = 0;
    
    while i < data.length() {
        int[] chunk = [];
        int j = 0;
        
        while j < chunkSize && (i + j) < data.length() {
            chunk.push(data[i + j]);
            j += 1;
        }
        
        chunks.push(chunk);
        i += chunkSize;
    }
    
    return chunks;
}

// Helper function to process a chunk of data
function processChunk(int[] chunk, string workerName) returns int[] {
    int[] processed = [];
    
    foreach int item in chunk {
        // Simulate processing (square the number)
        int result = item * item;
        processed.push(result);
        io:println(workerName + ": Processed " + item.toString() + " -> " + result.toString());
        runtime:sleep(0.2);
    }
    
    return processed;
}

// Helper function to merge two arrays
function mergeArrays(int[] arr1, int[] arr2) returns int[] {
    int[] merged = [...arr1];
    
    foreach int item in arr2 {
        merged.push(item);
    }
    
    return merged;
}