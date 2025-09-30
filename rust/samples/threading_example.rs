use std::sync::{Arc, Mutex, mpsc};
use std::thread;
use std::time::{Duration, Instant};
use std::collections::HashMap;

/// Demonstrate various threading patterns in Rust
pub fn main() {
    println!("=== Rust Threading Examples ===\n");
    
    // Example 1: Basic threading
    basic_threading_example();
    
    // Example 2: Shared state with Mutex
    shared_state_example();
    
    // Example 3: Message passing with channels
    message_passing_example();
    
    // Example 4: Producer-Consumer pattern
    producer_consumer_example();
    
    // Example 5: Thread pool simulation
    thread_pool_example();
    
    // Example 6: Parallel processing
    parallel_processing_example();
}

/// Example 1: Basic threading
fn basic_threading_example() {
    println!("1. Basic Threading:");
    
    let start = Instant::now();
    
    // Create multiple threads
    let handles: Vec<_> = (0..4).map(|i| {
        thread::spawn(move || {
            println!("  Thread {} starting work", i);
            
            // Simulate some work
            thread::sleep(Duration::from_millis(100 * (i + 1)));
            
            println!("  Thread {} finished work", i);
            i * i  // Return value
        })
    }).collect();
    
    // Wait for all threads to complete and collect results
    let results: Vec<_> = handles.into_iter()
        .map(|handle| handle.join().unwrap())
        .collect();
    
    let duration = start.elapsed();
    println!("  Results: {:?}", results);
    println!("  Completed in {:?}\n", duration);
}

/// Example 2: Shared state with Mutex
fn shared_state_example() {
    println!("2. Shared State with Mutex:");
    
    let counter = Arc::new(Mutex::new(0));
    let num_threads = 10;
    let increments_per_thread = 1000;
    
    let handles: Vec<_> = (0..num_threads).map(|i| {
        let counter = Arc::clone(&counter);
        thread::spawn(move || {
            for _ in 0..increments_per_thread {
                let mut num = counter.lock().unwrap();
                *num += 1;
            }
            println!("  Thread {} completed {} increments", i, increments_per_thread);
        })
    }).collect();
    
    // Wait for all threads
    for handle in handles {
        handle.join().unwrap();
    }
    
    let final_count = *counter.lock().unwrap();
    let expected = num_threads * increments_per_thread;
    println!("  Final counter value: {} (expected: {})", final_count, expected);
    println!("  Success: {}\n", final_count == expected);
}

/// Example 3: Message passing with channels
fn message_passing_example() {
    println!("3. Message Passing with Channels:");
    
    let (tx, rx) = mpsc::channel();
    let num_senders = 5;
    
    // Create multiple sender threads
    for i in 0..num_senders {
        let tx = tx.clone();
        thread::spawn(move || {
            for j in 0..3 {
                let message = format!("Message {}-{} from thread {}", i, j, i);
                tx.send(message).unwrap();
                thread::sleep(Duration::from_millis(50));
            }
            println!("  Sender thread {} finished", i);
        });
    }
    
    // Drop the original sender to close the channel when all senders are done
    drop(tx);
    
    // Receive messages
    let mut message_count = 0;
    while let Ok(message) = rx.recv() {
        println!("  Received: {}", message);
        message_count += 1;
    }
    
    println!("  Total messages received: {}\n", message_count);
}

/// Example 4: Producer-Consumer pattern
fn producer_consumer_example() {
    println!("4. Producer-Consumer Pattern:");
    
    let (tx, rx) = mpsc::channel();
    let buffer_size = 10;
    let num_items = 20;
    
    // Producer thread
    let producer = thread::spawn(move || {
        for i in 0..num_items {
            let item = format!("Item-{}", i);
            tx.send(item.clone()).unwrap();
            println!("  Produced: {}", item);
            thread::sleep(Duration::from_millis(100));
        }
        println!("  Producer finished");
    });
    
    // Consumer thread
    let consumer = thread::spawn(move || {
        let mut consumed_count = 0;
        
        while let Ok(item) = rx.recv() {
            println!("  Consumed: {}", item);
            consumed_count += 1;
            
            // Simulate processing time
            thread::sleep(Duration::from_millis(150));
            
            if consumed_count >= num_items {
                break;
            }
        }
        println!("  Consumer finished - processed {} items", consumed_count);
        consumed_count
    });
    
    // Wait for both threads
    producer.join().unwrap();
    let consumed = consumer.join().unwrap();
    println!("  Total items processed: {}\n", consumed);
}

/// Example 5: Thread pool simulation
fn thread_pool_example() {
    println!("5. Thread Pool Simulation:");
    
    let (job_tx, job_rx) = mpsc::channel::<Box<dyn FnOnce() + Send + 'static>>();
    let job_rx = Arc::new(Mutex::new(job_rx));
    let pool_size = 4;
    
    // Create worker threads
    let workers: Vec<_> = (0..pool_size).map(|id| {
        let job_rx = Arc::clone(&job_rx);
        thread::spawn(move || {
            println!("  Worker {} started", id);
            
            loop {
                let job = {
                    let rx = job_rx.lock().unwrap();
                    rx.recv()
                };
                
                match job {
                    Ok(job) => {
                        println!("  Worker {} executing job", id);
                        job();
                    }
                    Err(_) => {
                        println!("  Worker {} shutting down", id);
                        break;
                    }
                }
            }
        })
    }).collect();
    
    // Submit jobs to the pool
    for i in 0..10 {
        let job = Box::new(move || {
            println!("    Executing job {}", i);
            thread::sleep(Duration::from_millis(200));
            println!("    Job {} completed", i);
        });
        
        job_tx.send(job).unwrap();
    }
    
    // Close the job channel
    drop(job_tx);
    
    // Wait for all workers to finish
    for worker in workers {
        worker.join().unwrap();
    }
    
    println!("  Thread pool finished all jobs\n");
}

/// Example 6: Parallel processing
fn parallel_processing_example() {
    println!("6. Parallel Processing:");
    
    let data: Vec<i32> = (1..=1000).collect();
    let chunk_size = data.len() / 4;
    
    // Sequential processing
    let start = Instant::now();
    let sequential_sum: i32 = data.iter().map(|&x| expensive_computation(x)).sum();
    let sequential_time = start.elapsed();
    
    // Parallel processing
    let start = Instant::now();
    
    let chunks: Vec<_> = data.chunks(chunk_size).map(|chunk| chunk.to_vec()).collect();
    let handles: Vec<_> = chunks.into_iter().enumerate().map(|(i, chunk)| {
        thread::spawn(move || {
            println!("  Thread {} processing {} items", i, chunk.len());
            let sum: i32 = chunk.iter().map(|&x| expensive_computation(x)).sum();
            println!("  Thread {} finished with partial sum: {}", i, sum);
            sum
        })
    }).collect();
    
    let parallel_sum: i32 = handles.into_iter()
        .map(|handle| handle.join().unwrap())
        .sum();
    
    let parallel_time = start.elapsed();
    
    println!("  Sequential sum: {} (took {:?})", sequential_sum, sequential_time);
    println!("  Parallel sum: {} (took {:?})", parallel_sum, parallel_time);
    println!("  Results match: {}", sequential_sum == parallel_sum);
    
    if parallel_time < sequential_time {
        let speedup = sequential_time.as_secs_f64() / parallel_time.as_secs_f64();
        println!("  Speedup: {:.2}x", speedup);
    }
    
    println!();
}

/// Simulate an expensive computation
fn expensive_computation(x: i32) -> i32 {
    // Simulate CPU-intensive work
    let mut result = x;
    for _ in 0..1000 {
        result = (result * 17) % 1000003;
    }
    result
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_expensive_computation() {
        let result = expensive_computation(42);
        assert!(result >= 0);
        assert!(result < 1000003);
    }
    
    #[test]
    fn test_threading_safety() {
        let counter = Arc::new(Mutex::new(0));
        let handles: Vec<_> = (0..10).map(|_| {
            let counter = Arc::clone(&counter);
            thread::spawn(move || {
                for _ in 0..100 {
                    let mut num = counter.lock().unwrap();
                    *num += 1;
                }
            })
        }).collect();
        
        for handle in handles {
            handle.join().unwrap();
        }
        
        assert_eq!(*counter.lock().unwrap(), 1000);
    }
}