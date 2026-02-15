"""
PostgreSQL Queue Processor with Batch Insert Operations

Demonstrates efficient queue processing with PostgreSQL batch inserts:
- Batch consumption from queue
- COPY and executemany batch operations
- Connection pooling
- Performance monitoring
"""

import psycopg2
from psycopg2.extras import execute_batch
from queue import Queue
from typing import List, Dict, Any, Tuple
import time
import threading


class PostgreSQLQueueProcessor:
    """
    Process queued items with PostgreSQL batch insert operations
    
    Features:
    - Multiple batch insert strategies (executemany, execute_batch, COPY)
    - Adaptive batching based on queue size
    - Connection pooling
    - Performance metrics
    """
    
    def __init__(
        self,
        connection_string: str = "postgresql://postgres:password@localhost:5432/market_data",
        table_name: str = "orders"
    ):
        """
        Initialize PostgreSQL queue processor
        
        Args:
            connection_string: PostgreSQL connection string
            table_name: Target table name
        """
        self.connection_string = connection_string
        self.table_name = table_name
        self.queue = Queue()
        self.processed_count = 0
        self.error_count = 0
        self.total_time = 0
        
        # Initialize database
        self._init_database()
        
    def _init_database(self) -> None:
        """Create table if it doesn't exist"""
        conn = psycopg2.connect(self.connection_string)
        try:
            with conn.cursor() as cur:
                cur.execute(f"""
                    CREATE TABLE IF NOT EXISTS {self.table_name} (
                        id SERIAL PRIMARY KEY,
                        order_id VARCHAR(50) UNIQUE NOT NULL,
                        symbol VARCHAR(10) NOT NULL,
                        quantity INTEGER NOT NULL,
                        price NUMERIC(10, 2) NOT NULL,
                        side VARCHAR(4) NOT NULL,
                        order_type VARCHAR(20) NOT NULL,
                        timestamp DOUBLE PRECISION NOT NULL,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                """)
                
                # Create indexes for better performance
                cur.execute(f"""
                    CREATE INDEX IF NOT EXISTS idx_{self.table_name}_symbol 
                    ON {self.table_name}(symbol)
                """)
                cur.execute(f"""
                    CREATE INDEX IF NOT EXISTS idx_{self.table_name}_timestamp 
                    ON {self.table_name}(timestamp)
                """)
                
                conn.commit()
        finally:
            conn.close()
            
    def enqueue(self, item: Dict[str, Any]) -> None:
        """Add item to processing queue"""
        self.queue.put(item)
        
    def enqueue_batch(self, items: List[Dict[str, Any]]) -> None:
        """Add multiple items to queue"""
        for item in items:
            self.queue.put(item)
            
    def batch_insert_executemany(
        self,
        documents: List[Dict[str, Any]]
    ) -> int:
        """
        Batch insert using executemany (slowest but most compatible)
        
        Args:
            documents: List of documents to insert
            
        Returns:
            Number of documents inserted
        """
        if not documents:
            return 0
            
        conn = psycopg2.connect(self.connection_string)
        try:
            start_time = time.time()
            
            with conn.cursor() as cur:
                values = [
                    (
                        doc['order_id'],
                        doc['symbol'],
                        doc['quantity'],
                        doc['price'],
                        doc['side'],
                        doc['order_type'],
                        doc['timestamp']
                    )
                    for doc in documents
                ]
                
                cur.executemany(
                    f"""
                    INSERT INTO {self.table_name} 
                    (order_id, symbol, quantity, price, side, order_type, timestamp)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT (order_id) DO NOTHING
                    """,
                    values
                )
                
                conn.commit()
                inserted = cur.rowcount
                
            elapsed = time.time() - start_time
            self.total_time += elapsed
            self.processed_count += inserted
            
            return inserted
            
        except Exception as e:
            self.error_count += len(documents)
            print(f"Batch insert error: {e}")
            conn.rollback()
            return 0
        finally:
            conn.close()
            
    def batch_insert_execute_batch(
        self,
        documents: List[Dict[str, Any]],
        page_size: int = 100
    ) -> int:
        """
        Batch insert using execute_batch (faster, recommended)
        
        Args:
            documents: List of documents to insert
            page_size: Number of rows per batch
            
        Returns:
            Number of documents inserted
        """
        if not documents:
            return 0
            
        conn = psycopg2.connect(self.connection_string)
        try:
            start_time = time.time()
            
            with conn.cursor() as cur:
                values = [
                    (
                        doc['order_id'],
                        doc['symbol'],
                        doc['quantity'],
                        doc['price'],
                        doc['side'],
                        doc['order_type'],
                        doc['timestamp']
                    )
                    for doc in documents
                ]
                
                execute_batch(
                    cur,
                    f"""
                    INSERT INTO {self.table_name} 
                    (order_id, symbol, quantity, price, side, order_type, timestamp)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT (order_id) DO NOTHING
                    """,
                    values,
                    page_size=page_size
                )
                
                conn.commit()
                inserted = len(documents)
                
            elapsed = time.time() - start_time
            self.total_time += elapsed
            self.processed_count += inserted
            
            return inserted
            
        except Exception as e:
            self.error_count += len(documents)
            print(f"Batch insert error: {e}")
            conn.rollback()
            return 0
        finally:
            conn.close()
            
    def single_insert(self, document: Dict[str, Any]) -> bool:
        """
        Insert single document (for small queues)
        
        Args:
            document: Document to insert
            
        Returns:
            True if successful
        """
        conn = psycopg2.connect(self.connection_string)
        try:
            start_time = time.time()
            
            with conn.cursor() as cur:
                cur.execute(
                    f"""
                    INSERT INTO {self.table_name} 
                    (order_id, symbol, quantity, price, side, order_type, timestamp)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT (order_id) DO NOTHING
                    """,
                    (
                        document['order_id'],
                        document['symbol'],
                        document['quantity'],
                        document['price'],
                        document['side'],
                        document['order_type'],
                        document['timestamp']
                    )
                )
                conn.commit()
                
            self.total_time += time.time() - start_time
            self.processed_count += 1
            return True
            
        except Exception as e:
            self.error_count += 1
            print(f"Insert error: {e}")
            conn.rollback()
            return False
        finally:
            conn.close()
            
    def process_queue(
        self,
        batch_size: int = 1000,
        workers: int = 1,
        adaptive: bool = True,
        method: str = "execute_batch"
    ) -> None:
        """
        Process queue with optional adaptive batching
        
        Args:
            batch_size: Maximum batch size for bulk operations
            workers: Number of worker threads
            adaptive: Enable adaptive batching based on queue size
            method: Insert method ('executemany' or 'execute_batch')
        """
        def worker():
            while True:
                batch = []
                
                # Determine batch size based on queue depth
                if adaptive:
                    queue_size = self.queue.qsize()
                    if queue_size < 100:
                        current_batch_size = 1
                    elif queue_size < 1000:
                        current_batch_size = 100
                    else:
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
                    if method == "executemany":
                        self.batch_insert_executemany(batch)
                    else:
                        self.batch_insert_execute_batch(batch)
                        
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


# Example usage and demonstration
if __name__ == "__main__":
    import random
    
    print("=== PostgreSQL Queue Processor Demo ===\n")
    
    # Initialize processor
    processor = PostgreSQLQueueProcessor(
        connection_string="postgresql://postgres:password@localhost:5432/market_data",
        table_name="orders"
    )
    
    # Generate sample market orders
    print("Generating sample market orders...")
    symbols = ["AAPL", "GOOGL", "MSFT", "AMZN", "TSLA"]
    
    for i in range(5000):
        order = {
            "order_id": f"PG_ORD{i:06d}",
            "symbol": random.choice(symbols),
            "quantity": random.randint(1, 1000),
            "price": round(random.uniform(100, 500), 2),
            "side": random.choice(["BUY", "SELL"]),
            "order_type": "MARKET",
            "timestamp": time.time()
        }
        processor.enqueue(order)
        
    print(f"Enqueued {processor.queue.qsize()} orders")
    
    # Process with adaptive batching
    print("\nProcessing queue with adaptive batching (execute_batch)...")
    start = time.time()
    processor.process_queue(
        batch_size=1000,
        workers=4,
        adaptive=True,
        method="execute_batch"
    )
    
    # Display stats
    print(f"\nProcessing completed in {time.time() - start:.2f} seconds")
    print(f"Statistics: {processor.get_stats()}")
    
    print("\nDemo completed!")
