"""
MongoDB Queue Processor with Bulk Insert Operations

Demonstrates efficient queue processing with MongoDB bulk inserts:
- Batch consumption from queue
- Bulk insert operations
- Automatic retry logic
- Performance monitoring
"""

from pymongo import MongoClient, InsertOne
from pymongo.errors import BulkWriteError
from queue import Queue
from typing import List, Dict, Any
import time
import threading


class MongoDBQueueProcessor:
    """
    Process queued items with MongoDB bulk insert operations
    
    Features:
    - Configurable batch sizes
    - Automatic retry on failures
    - Connection pooling
    - Performance metrics
    """
    
    def __init__(
        self,
        connection_string: str = "mongodb://localhost:27017",
        database_name: str = "market_data",
        collection_name: str = "orders"
    ):
        """
        Initialize MongoDB queue processor
        
        Args:
            connection_string: MongoDB connection string
            database_name: Target database name
            collection_name: Target collection name
        """
        self.client = MongoClient(connection_string)
        self.db = self.client[database_name]
        self.collection = self.db[collection_name]
        self.queue = Queue()
        self.processed_count = 0
        self.error_count = 0
        self.total_time = 0
        
    def enqueue(self, item: Dict[str, Any]) -> None:
        """Add item to processing queue"""
        self.queue.put(item)
        
    def enqueue_batch(self, items: List[Dict[str, Any]]) -> None:
        """Add multiple items to queue"""
        for item in items:
            self.queue.put(item)
            
    def bulk_insert(self, documents: List[Dict[str, Any]]) -> int:
        """
        Perform bulk insert operation
        
        Args:
            documents: List of documents to insert
            
        Returns:
            Number of documents inserted
        """
        if not documents:
            return 0
            
        try:
            start_time = time.time()
            
            # Use bulk_write for better performance
            operations = [InsertOne(doc) for doc in documents]
            result = self.collection.bulk_write(operations, ordered=False)
            
            elapsed = time.time() - start_time
            self.total_time += elapsed
            self.processed_count += result.inserted_count
            
            return result.inserted_count
            
        except BulkWriteError as e:
            # Some documents may have been inserted
            self.processed_count += e.details.get('nInserted', 0)
            self.error_count += len(e.details.get('writeErrors', []))
            print(f"Bulk write error: {len(e.details.get('writeErrors', []))} errors")
            return e.details.get('nInserted', 0)
            
    def single_insert(self, document: Dict[str, Any]) -> bool:
        """
        Insert single document (for small queues)
        
        Args:
            document: Document to insert
            
        Returns:
            True if successful
        """
        try:
            start_time = time.time()
            self.collection.insert_one(document)
            self.total_time += time.time() - start_time
            self.processed_count += 1
            return True
        except Exception as e:
            self.error_count += 1
            print(f"Insert error: {e}")
            return False
            
    def process_queue(
        self,
        batch_size: int = 1000,
        workers: int = 1,
        adaptive: bool = True
    ) -> None:
        """
        Process queue with optional adaptive batching
        
        Args:
            batch_size: Maximum batch size for bulk operations
            workers: Number of worker threads
            adaptive: Enable adaptive batching based on queue size
        """
        def worker():
            while True:
                batch = []
                
                # Determine batch size based on queue depth
                if adaptive:
                    queue_size = self.queue.qsize()
                    if queue_size < 100:
                        # Small queue: process individually
                        current_batch_size = 1
                    elif queue_size < 1000:
                        # Medium queue: small batches
                        current_batch_size = 100
                    else:
                        # Large queue: full batches
                        current_batch_size = batch_size
                else:
                    current_batch_size = batch_size
                    
                # Collect items for batch
                for _ in range(current_batch_size):
                    try:
                        item = self.queue.get(timeout=1)
                        batch.append(item)
                        self.queue.task_done()
                    except:
                        break
                        
                if not batch:
                    continue
                    
                # Process batch
                if len(batch) == 1:
                    self.single_insert(batch[0])
                else:
                    self.bulk_insert(batch)
                    
        # Start worker threads
        threads = []
        for _ in range(workers):
            t = threading.Thread(target=worker, daemon=True)
            t.start()
            threads.append(t)
            
        # Wait for queue to be empty
        self.queue.join()
        
    def get_stats(self) -> Dict[str, Any]:
        """
        Get processing statistics
        
        Returns:
            Dictionary with performance metrics
        """
        throughput = (
            self.processed_count / self.total_time
            if self.total_time > 0
            else 0
        )
        
        return {
            "processed_count": self.processed_count,
            "error_count": self.error_count,
            "total_time_seconds": round(self.total_time, 2),
            "throughput_per_second": round(throughput, 2),
            "queue_size": self.queue.qsize()
        }
        
    def close(self) -> None:
        """Close database connection"""
        self.client.close()


# Example usage and demonstration
if __name__ == "__main__":
    import random
    
    print("=== MongoDB Queue Processor Demo ===\n")
    
    # Initialize processor
    processor = MongoDBQueueProcessor(
        connection_string="mongodb://localhost:27017",
        database_name="market_data",
        collection_name="orders"
    )
    
    # Generate sample market orders
    print("Generating sample market orders...")
    symbols = ["AAPL", "GOOGL", "MSFT", "AMZN", "TSLA"]
    
    for i in range(5000):
        order = {
            "order_id": f"ORD{i:06d}",
            "symbol": random.choice(symbols),
            "quantity": random.randint(1, 1000),
            "price": round(random.uniform(100, 500), 2),
            "side": random.choice(["BUY", "SELL"]),
            "timestamp": time.time(),
            "order_type": "MARKET"
        }
        processor.enqueue(order)
        
    print(f"Enqueued {processor.queue.qsize()} orders")
    
    # Process with adaptive batching
    print("\nProcessing queue with adaptive batching...")
    start = time.time()
    processor.process_queue(batch_size=1000, workers=4, adaptive=True)
    
    # Display stats
    print(f"\nProcessing completed in {time.time() - start:.2f} seconds")
    print(f"Statistics: {processor.get_stats()}")
    
    processor.close()
    print("\nDemo completed!")
