"""
Parallel Queue Workers with Multi-Threading

Demonstrates parallel processing with multiple worker threads:
- Thread pool management
- Work queue distribution
- Load balancing across workers
- Graceful shutdown
"""

from queue import Queue, Empty
from threading import Thread, Event
from typing import Callable, Any, Optional
import time


class ParallelQueueProcessor:
    """
    Manages multiple worker threads processing items from a shared queue
    
    Features:
    - Configurable worker count
    - Graceful shutdown
    - Error handling per worker
    - Performance monitoring
    """
    
    def __init__(
        self,
        num_workers: int = 4,
        queue_maxsize: int = 10000
    ):
        """
        Initialize parallel queue processor
        
        Args:
            num_workers: Number of worker threads
            queue_maxsize: Maximum queue size (0 = unlimited)
        """
        self.num_workers = num_workers
        self.queue = Queue(maxsize=queue_maxsize)
        self.workers = []
        self.stop_event = Event()
        self.processed_count = 0
        self.error_count = 0
        
    def enqueue(self, item: Any) -> None:
        """Add item to queue"""
        self.queue.put(item)
        
    def enqueue_batch(self, items: list) -> None:
        """Add multiple items to queue"""
        for item in items:
            self.queue.put(item)
            
    def start(self, process_func: Callable[[Any], None]) -> None:
        """
        Start worker threads
        
        Args:
            process_func: Function to process each queue item
        """
        def worker():
            while not self.stop_event.is_set():
                try:
                    # Get item from queue with timeout
                    item = self.queue.get(timeout=0.5)
                    
                    try:
                        # Process item
                        process_func(item)
                        self.processed_count += 1
                    except Exception as e:
                        print(f"Error processing item: {e}")
                        self.error_count += 1
                    finally:
                        self.queue.task_done()
                        
                except Empty:
                    # No items in queue, continue waiting
                    continue
                    
        # Create and start worker threads
        for i in range(self.num_workers):
            t = Thread(target=worker, name=f"Worker-{i}", daemon=True)
            t.start()
            self.workers.append(t)
            
        print(f"Started {self.num_workers} worker threads")
        
    def wait_completion(self, timeout: Optional[float] = None) -> bool:
        """
        Wait for queue to be empty
        
        Args:
            timeout: Maximum time to wait (None = wait forever)
            
        Returns:
            True if queue was emptied, False if timeout
        """
        try:
            self.queue.join()
            return True
        except Exception:
            return False
            
    def stop(self, wait: bool = True) -> None:
        """
        Stop all workers
        
        Args:
            wait: Wait for workers to finish
        """
        self.stop_event.set()
        
        if wait:
            for worker in self.workers:
                worker.join(timeout=5)
                
        print(f"Stopped {self.num_workers} workers")
        
    def get_stats(self) -> dict:
        """Get processing statistics"""
        return {
            "workers": self.num_workers,
            "queue_size": self.queue.qsize(),
            "processed": self.processed_count,
            "errors": self.error_count,
            "active_workers": sum(1 for w in self.workers if w.is_alive())
        }


class DatabaseWorkerPool:
    """
    Worker pool specifically for database operations
    Integrates with MongoDB or PostgreSQL processors
    """
    
    def __init__(
        self,
        db_type: str = "mongodb",
        num_workers: int = 4,
        batch_size: int = 100,
        **db_config
    ):
        """
        Initialize database worker pool
        
        Args:
            db_type: Database type ('mongodb' or 'postgresql')
            num_workers: Number of worker threads
            batch_size: Batch size for bulk operations
            **db_config: Database connection parameters
        """
        self.db_type = db_type
        self.num_workers = num_workers
        self.batch_size = batch_size
        self.db_config = db_config
        
        # Import appropriate processor
        if db_type == "mongodb":
            from mongodb_queue_processor import MongoDBQueueProcessor
            self.processor = MongoDBQueueProcessor(**db_config)
        elif db_type == "postgresql":
            from postgresql_queue_processor import PostgreSQLQueueProcessor
            self.processor = PostgreSQLQueueProcessor(**db_config)
        else:
            raise ValueError(f"Unsupported db_type: {db_type}")
            
        self.parallel_processor = ParallelQueueProcessor(num_workers=num_workers)
        
    def process_item(self, item: dict) -> None:
        """Process single item (enqueue to batch processor)"""
        self.processor.enqueue(item)
        
    def start(self, items: list) -> None:
        """
        Start processing items
        
        Args:
            items: List of items to process
        """
        # Enqueue all items
        self.parallel_processor.enqueue_batch(items)
        
        # Start workers
        self.parallel_processor.start(self.process_item)
        
        # Start database processor
        db_thread = Thread(
            target=self.processor.process_queue,
            kwargs={
                "batch_size": self.batch_size,
                "workers": 2,
                "adaptive": True
            },
            daemon=True
        )
        db_thread.start()
        
        # Wait for completion
        self.parallel_processor.wait_completion()
        self.processor.queue.join()
        
        # Stop workers
        self.parallel_processor.stop()
        
    def get_stats(self) -> dict:
        """Get combined statistics"""
        return {
            "parallel_stats": self.parallel_processor.get_stats(),
            "db_stats": self.processor.get_stats()
        }


# Example usage
if __name__ == "__main__":
    import random
    
    print("=== Parallel Queue Workers Demo ===\n")
    
    # Example 1: Basic parallel processing
    print("1. Basic Parallel Processing")
    
    def process_item(item):
        """Simple processing function"""
        time.sleep(0.01)  # Simulate work
        print(f"Processed: {item}")
        
    processor = ParallelQueueProcessor(num_workers=4)
    
    # Add items to queue
    for i in range(20):
        processor.enqueue(f"Item-{i}")
        
    # Start processing
    processor.start(process_item)
    processor.wait_completion()
    
    print(f"\nStats: {processor.get_stats()}")
    processor.stop()
    
    # Example 2: Database worker pool
    print("\n2. Database Worker Pool (MongoDB)")
    
    symbols = ["AAPL", "GOOGL", "MSFT", "AMZN", "TSLA"]
    orders = []
    
    for i in range(1000):
        order = {
            "order_id": f"PARALLEL_ORD{i:06d}",
            "symbol": random.choice(symbols),
            "quantity": random.randint(1, 1000),
            "price": round(random.uniform(100, 500), 2),
            "side": random.choice(["BUY", "SELL"]),
            "order_type": "MARKET",
            "timestamp": time.time()
        }
        orders.append(order)
        
    db_pool = DatabaseWorkerPool(
        db_type="mongodb",
        num_workers=4,
        batch_size=200,
        connection_string="mongodb://localhost:27017",
        database_name="market_data",
        collection_name="orders"
    )
    
    print(f"Processing {len(orders)} orders with {db_pool.num_workers} workers...")
    start = time.time()
    
    db_pool.start(orders)
    
    elapsed = time.time() - start
    print(f"\nCompleted in {elapsed:.2f} seconds")
    print(f"Statistics: {db_pool.get_stats()}")
    
    print("\nDemo completed!")
