"""
Adaptive Batch Processor

Intelligently adjusts batch sizes based on:
- Queue depth/size
- System resources (CPU, memory)
- Database performance
- Historical throughput
"""

from typing import Dict, Any, List, Callable, Optional
from queue import Queue
import time
import psutil
import threading


class AdaptiveBatchProcessor:
    """
    Adaptive batching strategy that optimizes batch size based on:
    - Queue size (more items = larger batches)
    - System resources (CPU/memory usage)
    - Processing performance (throughput)
    - Error rates
    
    This ensures optimal resource utilization and throughput.
    """
    
    def __init__(
        self,
        min_batch_size: int = 1,
        max_batch_size: int = 5000,
        target_cpu_percent: float = 80.0,
        target_memory_percent: float = 75.0
    ):
        """
        Initialize adaptive batch processor
        
        Args:
            min_batch_size: Minimum batch size
            max_batch_size: Maximum batch size
            target_cpu_percent: Target CPU utilization (%)
            target_memory_percent: Target memory utilization (%)
        """
        self.min_batch_size = min_batch_size
        self.max_batch_size = max_batch_size
        self.target_cpu_percent = target_cpu_percent
        self.target_memory_percent = target_memory_percent
        
        # Current batch size (starts at minimum)
        self.current_batch_size = min_batch_size
        
        # Performance metrics
        self.recent_throughput = []
        self.recent_batch_sizes = []
        self.max_history = 10
        
    def calculate_batch_size(self, queue_size: int) -> int:
        """
        Calculate optimal batch size based on queue size and system resources
        
        Args:
            queue_size: Current queue depth
            
        Returns:
            Optimal batch size
        """
        # Get system metrics
        cpu_percent = psutil.cpu_percent(interval=0.1)
        memory_percent = psutil.virtual_memory().percent
        
        # Base calculation on queue size
        if queue_size < 100:
            base_size = self.min_batch_size
        elif queue_size < 1000:
            base_size = 100
        elif queue_size < 10000:
            base_size = 500
        else:
            base_size = 1000
            
        # Adjust based on CPU usage
        if cpu_percent > self.target_cpu_percent:
            # CPU overloaded, reduce batch size
            cpu_factor = 0.7
        elif cpu_percent < self.target_cpu_percent * 0.5:
            # CPU underutilized, increase batch size
            cpu_factor = 1.3
        else:
            cpu_factor = 1.0
            
        # Adjust based on memory usage
        if memory_percent > self.target_memory_percent:
            # Memory pressure, reduce batch size
            memory_factor = 0.7
        elif memory_percent < self.target_memory_percent * 0.5:
            # Memory available, increase batch size
            memory_factor = 1.2
        else:
            memory_factor = 1.0
            
        # Calculate final batch size
        batch_size = int(base_size * cpu_factor * memory_factor)
        
        # Ensure within bounds
        batch_size = max(self.min_batch_size, min(batch_size, self.max_batch_size))
        
        # Store for history
        self.current_batch_size = batch_size
        self.recent_batch_sizes.append(batch_size)
        if len(self.recent_batch_sizes) > self.max_history:
            self.recent_batch_sizes.pop(0)
            
        return batch_size
        
    def record_throughput(self, items_processed: int, elapsed_seconds: float) -> None:
        """
        Record processing throughput for adaptive learning
        
        Args:
            items_processed: Number of items processed
            elapsed_seconds: Time taken
        """
        if elapsed_seconds > 0:
            throughput = items_processed / elapsed_seconds
            self.recent_throughput.append(throughput)
            
            if len(self.recent_throughput) > self.max_history:
                self.recent_throughput.pop(0)
                
    def get_average_throughput(self) -> float:
        """Get average throughput from recent history"""
        if not self.recent_throughput:
            return 0.0
        return sum(self.recent_throughput) / len(self.recent_throughput)
        
    def get_statistics(self) -> Dict[str, Any]:
        """Get processor statistics"""
        cpu_percent = psutil.cpu_percent(interval=0.1)
        memory = psutil.virtual_memory()
        
        return {
            "current_batch_size": self.current_batch_size,
            "min_batch_size": self.min_batch_size,
            "max_batch_size": self.max_batch_size,
            "avg_batch_size": (
                sum(self.recent_batch_sizes) / len(self.recent_batch_sizes)
                if self.recent_batch_sizes else 0
            ),
            "avg_throughput": self.get_average_throughput(),
            "cpu_percent": cpu_percent,
            "memory_percent": memory.percent,
            "memory_available_mb": memory.available / (1024 * 1024)
        }


class AdaptiveQueueProcessor:
    """
    Queue processor with adaptive batching and resource management
    """
    
    def __init__(
        self,
        process_batch_func: Callable[[List[Any]], None],
        min_batch_size: int = 1,
        max_batch_size: int = 5000,
        num_workers: int = 4
    ):
        """
        Initialize adaptive queue processor
        
        Args:
            process_batch_func: Function to process batches
            min_batch_size: Minimum batch size
            max_batch_size: Maximum batch size
            num_workers: Number of worker threads
        """
        self.process_batch_func = process_batch_func
        self.num_workers = num_workers
        self.queue = Queue()
        
        self.adaptive_processor = AdaptiveBatchProcessor(
            min_batch_size=min_batch_size,
            max_batch_size=max_batch_size
        )
        
        self.running = False
        self.workers = []
        self.total_processed = 0
        
    def enqueue(self, item: Any) -> None:
        """Add item to queue"""
        self.queue.put(item)
        
    def enqueue_batch(self, items: List[Any]) -> None:
        """Add multiple items to queue"""
        for item in items:
            self.queue.put(item)
            
    def _worker(self) -> None:
        """Worker thread that processes batches"""
        while self.running or not self.queue.empty():
            # Get current queue size
            queue_size = self.queue.qsize()
            
            if queue_size == 0:
                time.sleep(0.1)
                continue
                
            # Calculate optimal batch size
            batch_size = self.adaptive_processor.calculate_batch_size(queue_size)
            
            # Collect batch
            batch = []
            for _ in range(batch_size):
                try:
                    item = self.queue.get_nowait()
                    batch.append(item)
                except:
                    break
                    
            if not batch:
                continue
                
            # Process batch and measure performance
            start_time = time.time()
            try:
                self.process_batch_func(batch)
                self.total_processed += len(batch)
            except Exception as e:
                print(f"Error processing batch: {e}")
            finally:
                elapsed = time.time() - start_time
                self.adaptive_processor.record_throughput(len(batch), elapsed)
                
                # Mark items as done
                for _ in batch:
                    self.queue.task_done()
                    
    def start(self) -> None:
        """Start worker threads"""
        self.running = True
        
        for i in range(self.num_workers):
            worker = threading.Thread(
                target=self._worker,
                name=f"AdaptiveWorker-{i}",
                daemon=True
            )
            worker.start()
            self.workers.append(worker)
            
        print(f"Started {self.num_workers} adaptive workers")
        
    def wait_completion(self) -> None:
        """Wait for queue to be empty"""
        self.queue.join()
        
    def stop(self) -> None:
        """Stop all workers"""
        self.running = False
        for worker in self.workers:
            worker.join(timeout=5)
            
    def get_statistics(self) -> Dict[str, Any]:
        """Get combined statistics"""
        stats = self.adaptive_processor.get_statistics()
        stats.update({
            "queue_size": self.queue.qsize(),
            "total_processed": self.total_processed,
            "workers": self.num_workers
        })
        return stats


# Example usage and demonstration
if __name__ == "__main__":
    import random
    
    print("=== Adaptive Batch Processor Demo ===\n")
    
    # Simulated batch processor
    def process_batch(batch: List[Dict[str, Any]]) -> None:
        """Simulate processing a batch"""
        time.sleep(0.01 * len(batch) / 100)  # Simulate work
        print(f"  Processed batch of {len(batch)} items")
        
    # Create adaptive processor
    processor = AdaptiveQueueProcessor(
        process_batch_func=process_batch,
        min_batch_size=1,
        max_batch_size=1000,
        num_workers=4
    )
    
    # Generate sample data
    print("Generating sample orders...")
    symbols = ["AAPL", "GOOGL", "MSFT", "AMZN", "TSLA"]
    
    for i in range(10000):
        order = {
            "order_id": f"ADAPTIVE_ORD{i:06d}",
            "symbol": random.choice(symbols),
            "quantity": random.randint(1, 1000),
            "price": round(random.uniform(100, 500), 2)
        }
        processor.enqueue(order)
        
    print(f"Enqueued {processor.queue.qsize()} orders\n")
    
    # Start processing
    print("Starting adaptive processing...")
    processor.start()
    
    # Monitor progress
    while processor.queue.qsize() > 0:
        stats = processor.get_statistics()
        print(f"\nQueue: {stats['queue_size']:,} | "
              f"Batch: {stats['current_batch_size']} | "
              f"CPU: {stats['cpu_percent']:.1f}% | "
              f"Mem: {stats['memory_percent']:.1f}% | "
              f"Throughput: {stats['avg_throughput']:.0f} items/sec")
        time.sleep(2)
        
    # Wait for completion
    processor.wait_completion()
    processor.stop()
    
    # Final statistics
    print("\n=== Final Statistics ===")
    final_stats = processor.get_statistics()
    for key, value in final_stats.items():
        if isinstance(value, float):
            print(f"{key}: {value:.2f}")
        else:
            print(f"{key}: {value}")
            
    print("\nDemo completed!")
