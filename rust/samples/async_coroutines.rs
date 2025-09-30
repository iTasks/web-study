use std::future::Future;
use std::pin::Pin;
use std::task::{Context, Poll};
use std::time::{Duration, Instant};
use tokio::time::{sleep, timeout};
use tokio::sync::{mpsc, oneshot};

/// Demonstrate async/await and coroutine patterns in Rust
#[tokio::main]
pub async fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("=== Rust Async/Coroutines Examples ===\n");
    
    // Example 1: Basic async functions
    basic_async_example().await;
    
    // Example 2: Concurrent execution
    concurrent_execution_example().await;
    
    // Example 3: Async channels
    async_channels_example().await;
    
    // Example 4: Custom Future implementation
    custom_future_example().await;
    
    // Example 5: Async generators (stream-like)
    async_generators_example().await;
    
    // Example 6: Error handling in async contexts
    async_error_handling_example().await;
    
    // Example 7: Timeouts and cancellation
    timeout_cancellation_example().await;
    
    Ok(())
}

/// Example 1: Basic async functions
async fn basic_async_example() {
    println!("1. Basic Async Functions:");
    
    async fn fetch_data(id: u32) -> String {
        // Simulate network delay
        sleep(Duration::from_millis(100)).await;
        format!("Data for ID: {}", id)
    }
    
    async fn process_data(data: String) -> String {
        // Simulate processing time
        sleep(Duration::from_millis(50)).await;
        format!("Processed: {}", data)
    }
    
    let start = Instant::now();
    
    // Sequential execution
    let data = fetch_data(1).await;
    let result = process_data(data).await;
    
    let duration = start.elapsed();
    println!("  Sequential result: {}", result);
    println!("  Time taken: {:?}\n", duration);
}

/// Example 2: Concurrent execution
async fn concurrent_execution_example() {
    println!("2. Concurrent Execution:");
    
    async fn fetch_user(id: u32) -> String {
        sleep(Duration::from_millis(100)).await;
        format!("User-{}", id)
    }
    
    async fn fetch_posts(user_id: u32) -> Vec<String> {
        sleep(Duration::from_millis(150)).await;
        vec![
            format!("Post 1 by User-{}", user_id),
            format!("Post 2 by User-{}", user_id),
        ]
    }
    
    async fn fetch_comments(user_id: u32) -> Vec<String> {
        sleep(Duration::from_millis(120)).await;
        vec![
            format!("Comment 1 by User-{}", user_id),
            format!("Comment 2 by User-{}", user_id),
        ]
    }
    
    let start = Instant::now();
    
    // Concurrent execution using join!
    let user_id = 42;
    let (user, posts, comments) = tokio::join!(
        fetch_user(user_id),
        fetch_posts(user_id),
        fetch_comments(user_id)
    );
    
    let duration = start.elapsed();
    println!("  User: {}", user);
    println!("  Posts: {:?}", posts);
    println!("  Comments: {:?}", comments);
    println!("  Concurrent time: {:?}", duration);
    
    // Compare with sequential execution
    let start = Instant::now();
    let user_seq = fetch_user(user_id).await;
    let posts_seq = fetch_posts(user_id).await;
    let comments_seq = fetch_comments(user_id).await;
    let sequential_duration = start.elapsed();
    
    println!("  Sequential time: {:?}", sequential_duration);
    println!("  Speedup: {:.2}x\n", sequential_duration.as_secs_f64() / duration.as_secs_f64());
}

/// Example 3: Async channels
async fn async_channels_example() {
    println!("3. Async Channels:");
    
    let (tx, mut rx) = mpsc::channel::<String>(32);
    
    // Producer task
    let producer = tokio::spawn(async move {
        for i in 0..5 {
            let message = format!("Message {}", i);
            tx.send(message.clone()).await.unwrap();
            println!("  Sent: {}", message);
            sleep(Duration::from_millis(100)).await;
        }
        println!("  Producer finished");
    });
    
    // Consumer task
    let consumer = tokio::spawn(async move {
        let mut messages = Vec::new();
        while let Some(message) = rx.recv().await {
            println!("  Received: {}", message);
            messages.push(message);
            sleep(Duration::from_millis(50)).await;
        }
        println!("  Consumer finished with {} messages", messages.len());
        messages
    });
    
    // Wait for both tasks
    let (_, messages) = tokio::join!(producer, consumer);
    let messages = messages.unwrap();
    println!("  Total messages processed: {}\n", messages.len());
}

/// Example 4: Custom Future implementation
async fn custom_future_example() {
    println!("4. Custom Future Implementation:");
    
    // Custom delay future
    struct DelayFuture {
        when: Instant,
    }
    
    impl DelayFuture {
        fn new(duration: Duration) -> Self {
            DelayFuture {
                when: Instant::now() + duration,
            }
        }
    }
    
    impl Future for DelayFuture {
        type Output = ();
        
        fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
            if Instant::now() >= self.when {
                println!("  Custom delay future completed!");
                Poll::Ready(())
            } else {
                // Wake up the task when the delay should be over
                let waker = cx.waker().clone();
                let when = self.when;
                tokio::spawn(async move {
                    tokio::time::sleep_until(when.into()).await;
                    waker.wake();
                });
                Poll::Pending
            }
        }
    }
    
    println!("  Starting custom delay future...");
    let start = Instant::now();
    DelayFuture::new(Duration::from_millis(200)).await;
    let duration = start.elapsed();
    println!("  Custom future took: {:?}\n", duration);
}

/// Example 5: Async generators (stream-like)
async fn async_generators_example() {
    println!("5. Async Generators (Stream-like):");
    
    // Async generator function using channels
    async fn number_generator(start: u32, count: u32) -> mpsc::Receiver<u32> {
        let (tx, rx) = mpsc::channel(10);
        
        tokio::spawn(async move {
            for i in start..start + count {
                if tx.send(i).await.is_err() {
                    break; // Receiver dropped
                }
                sleep(Duration::from_millis(50)).await;
            }
        });
        
        rx
    }
    
    // Async generator for Fibonacci sequence
    async fn fibonacci_generator(count: u32) -> mpsc::Receiver<u64> {
        let (tx, rx) = mpsc::channel(10);
        
        tokio::spawn(async move {
            let mut a = 0u64;
            let mut b = 1u64;
            
            for _ in 0..count {
                if tx.send(a).await.is_err() {
                    break;
                }
                let next = a + b;
                a = b;
                b = next;
                sleep(Duration::from_millis(30)).await;
            }
        });
        
        rx
    }
    
    // Consume number generator
    println!("  Number generator (5-9):");
    let mut numbers = number_generator(5, 5).await;
    while let Some(num) = numbers.recv().await {
        println!("    Generated number: {}", num);
    }
    
    // Consume Fibonacci generator
    println!("  Fibonacci generator (first 8):");
    let mut fibonacci = fibonacci_generator(8).await;
    while let Some(fib) = fibonacci.recv().await {
        println!("    Fibonacci: {}", fib);
    }
    
    println!();
}

/// Example 6: Error handling in async contexts
async fn async_error_handling_example() {
    println!("6. Async Error Handling:");
    
    #[derive(Debug)]
    enum MyError {
        NetworkError(String),
        ParseError(String),
        TimeoutError,
    }
    
    impl std::fmt::Display for MyError {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            match self {
                MyError::NetworkError(msg) => write!(f, "Network error: {}", msg),
                MyError::ParseError(msg) => write!(f, "Parse error: {}", msg),
                MyError::TimeoutError => write!(f, "Timeout error"),
            }
        }
    }
    
    impl std::error::Error for MyError {}
    
    async fn fallible_operation(id: u32) -> Result<String, MyError> {
        sleep(Duration::from_millis(100)).await;
        
        match id {
            1 => Ok(format!("Success for ID: {}", id)),
            2 => Err(MyError::NetworkError("Connection failed".to_string())),
            3 => Err(MyError::ParseError("Invalid JSON".to_string())),
            _ => Err(MyError::TimeoutError),
        }
    }
    
    // Test different error scenarios
    for id in 1..=4 {
        match fallible_operation(id).await {
            Ok(result) => println!("  ID {}: {}", id, result),
            Err(e) => println!("  ID {}: Error - {}", id, e),
        }
    }
    
    // Parallel error handling
    println!("  Testing parallel operations with errors:");
    let futures = (1..=4).map(|id| fallible_operation(id));
    let results = futures::future::join_all(futures).await;
    
    let successful = results.iter().filter(|r| r.is_ok()).count();
    let failed = results.len() - successful;
    println!("  Parallel results: {} successful, {} failed\n", successful, failed);
}

/// Example 7: Timeouts and cancellation
async fn timeout_cancellation_example() {
    println!("7. Timeouts and Cancellation:");
    
    async fn slow_operation(duration_ms: u64) -> String {
        sleep(Duration::from_millis(duration_ms)).await;
        format!("Completed after {}ms", duration_ms)
    }
    
    // Timeout example
    println!("  Testing timeouts:");
    
    let fast_result = timeout(Duration::from_millis(200), slow_operation(100)).await;
    match fast_result {
        Ok(result) => println!("    Fast operation: {}", result),
        Err(_) => println!("    Fast operation: Timed out"),
    }
    
    let slow_result = timeout(Duration::from_millis(200), slow_operation(300)).await;
    match slow_result {
        Ok(result) => println!("    Slow operation: {}", result),
        Err(_) => println!("    Slow operation: Timed out"),
    }
    
    // Cancellation with oneshot channels
    println!("  Testing cancellation:");
    
    let (cancel_tx, cancel_rx) = oneshot::channel::<()>();
    
    let cancellable_task = tokio::spawn(async move {
        tokio::select! {
            _ = sleep(Duration::from_millis(500)) => {
                println!("    Cancellable task completed normally");
                "Completed"
            }
            _ = cancel_rx => {
                println!("    Cancellable task was cancelled");
                "Cancelled"
            }
        }
    });
    
    // Cancel after 200ms
    tokio::spawn(async move {
        sleep(Duration::from_millis(200)).await;
        let _ = cancel_tx.send(());
    });
    
    let result = cancellable_task.await.unwrap();
    println!("    Final result: {}", result);
    
    // Select with multiple futures
    println!("  Racing multiple operations:");
    
    let race_result = tokio::select! {
        result = slow_operation(300) => format!("First: {}", result),
        result = slow_operation(200) => format!("Second: {}", result),
        result = slow_operation(250) => format!("Third: {}", result),
    };
    
    println!("    Race winner: {}\n", race_result);
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_basic_async() {
        async fn test_function() -> u32 {
            sleep(Duration::from_millis(10)).await;
            42
        }
        
        let result = test_function().await;
        assert_eq!(result, 42);
    }
    
    #[tokio::test]
    async fn test_concurrent_execution() {
        async fn task(id: u32, delay_ms: u64) -> u32 {
            sleep(Duration::from_millis(delay_ms)).await;
            id
        }
        
        let start = Instant::now();
        let (r1, r2, r3) = tokio::join!(
            task(1, 100),
            task(2, 100),
            task(3, 100)
        );
        let duration = start.elapsed();
        
        assert_eq!((r1, r2, r3), (1, 2, 3));
        assert!(duration < Duration::from_millis(200)); // Should be much faster than sequential
    }
    
    #[tokio::test]
    async fn test_timeout() {
        async fn slow_task() -> u32 {
            sleep(Duration::from_millis(200)).await;
            42
        }
        
        let result = timeout(Duration::from_millis(100), slow_task()).await;
        assert!(result.is_err()); // Should timeout
    }
}