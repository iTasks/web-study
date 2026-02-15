"""
Market Order Processor - Large-Scale Stock Exchange (SE) Order Processing

Demonstrates processing of high-volume market orders with:
- Dual database persistence (MongoDB + PostgreSQL)
- Intelligent cache management
- Adaptive batching based on order volume
- Performance optimization for throughput
- Realistic market order simulation
"""

from typing import Dict, List, Any, Optional
import time
import random
from datetime import datetime
from cache_manager import MarketDataCache

# Import database processors
try:
    from mongodb_queue_processor import MongoDBQueueProcessor
    MONGODB_AVAILABLE = True
except:
    MONGODB_AVAILABLE = False

try:
    from postgresql_queue_processor import PostgreSQLQueueProcessor
    POSTGRESQL_AVAILABLE = True
except:
    POSTGRESQL_AVAILABLE = False


class MarketOrderProcessor:
    """
    High-performance market order processor for Stock Exchange (SE) scenarios
    
    Features:
    - Dual database persistence (MongoDB for documents, PostgreSQL for relational)
    - Intelligent caching with LRU eviction
    - Adaptive batching based on order volume
    - Real-time throughput monitoring
    - Simulated market order generation
    """
    
    def __init__(
        self,
        mongodb_uri: Optional[str] = "mongodb://localhost:27017",
        postgresql_uri: Optional[str] = "postgresql://postgres:password@localhost:5432/market_data",
        cache_size: int = 10000,
        enable_cache: bool = True
    ):
        """
        Initialize market order processor
        
        Args:
            mongodb_uri: MongoDB connection string
            postgresql_uri: PostgreSQL connection string
            cache_size: Maximum cache size
            enable_cache: Enable caching
        """
        # Initialize database processors
        self.mongodb_processor = None
        self.postgresql_processor = None
        
        if MONGODB_AVAILABLE and mongodb_uri:
            self.mongodb_processor = MongoDBQueueProcessor(
                connection_string=mongodb_uri,
                database_name="market_data",
                collection_name="market_orders"
            )
            
        if POSTGRESQL_AVAILABLE and postgresql_uri:
            self.postgresql_processor = PostgreSQLQueueProcessor(
                connection_string=postgresql_uri,
                table_name="market_orders"
            )
            
        # Initialize cache
        self.cache = MarketDataCache(max_size=cache_size) if enable_cache else None
        self.enable_cache = enable_cache
        
        # Performance metrics
        self.total_orders_processed = 0
        self.start_time = None
        
    def generate_market_order(self, order_id: int, symbol: str) -> Dict[str, Any]:
        """
        Generate realistic market order
        
        Args:
            order_id: Unique order ID
            symbol: Stock symbol
            
        Returns:
            Market order dictionary
        """
        order = {
            "order_id": f"MKT{order_id:010d}",
            "symbol": symbol,
            "quantity": random.randint(100, 10000),
            "price": round(random.uniform(50, 1000), 2),
            "side": random.choice(["BUY", "SELL"]),
            "order_type": "MARKET",
            "timestamp": time.time(),
            "trader_id": f"TRADER{random.randint(1, 1000):04d}",
            "account_id": f"ACC{random.randint(1, 500):06d}",
            "exchange": random.choice(["NYSE", "NASDAQ", "LSE"]),
            "status": "PENDING"
        }
        
        return order
        
    def cache_order(self, order: Dict[str, Any]) -> None:
        """Cache order data"""
        if self.enable_cache and self.cache:
            self.cache.set_order(order["order_id"], order)
            self.cache.set_symbol_price(order["symbol"], order["price"])
            
    def get_cached_order(self, order_id: str) -> Optional[Dict[str, Any]]:
        """Retrieve order from cache"""
        if self.enable_cache and self.cache:
            return self.cache.get_order(order_id)
        return None
        
    def process_order_batch(
        self,
        orders: List[Dict[str, Any]],
        use_mongodb: bool = True,
        use_postgresql: bool = True
    ) -> None:
        """
        Process batch of orders
        
        Args:
            orders: List of orders to process
            use_mongodb: Store in MongoDB
            use_postgresql: Store in PostgreSQL
        """
        # Cache orders
        for order in orders:
            self.cache_order(order)
            
        # Enqueue to databases
        if use_mongodb and self.mongodb_processor:
            self.mongodb_processor.enqueue_batch(orders)
            
        if use_postgresql and self.postgresql_processor:
            self.postgresql_processor.enqueue_batch(orders)
            
        self.total_orders_processed += len(orders)
        
    def simulate_market_orders(
        self,
        num_orders: int = 100000,
        workers: int = 8,
        use_cache: bool = True,
        symbols: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """
        Simulate high-volume market order processing
        
        Args:
            num_orders: Number of orders to generate
            workers: Number of worker threads
            use_cache: Enable caching
            symbols: List of stock symbols (default: major tech stocks)
            
        Returns:
            Performance statistics
        """
        if symbols is None:
            symbols = [
                "AAPL", "GOOGL", "MSFT", "AMZN", "TSLA",
                "META", "NVDA", "AMD", "NFLX", "INTC"
            ]
            
        print(f"\n=== Market Order Simulation ===")
        print(f"Orders to process: {num_orders:,}")
        print(f"Worker threads: {workers}")
        print(f"Cache enabled: {use_cache}")
        print(f"Symbols: {len(symbols)}")
        print(f"Databases: MongoDB={MONGODB_AVAILABLE}, PostgreSQL={POSTGRESQL_AVAILABLE}")
        
        self.start_time = time.time()
        self.enable_cache = use_cache
        
        # Generate and process orders in batches
        batch_size = 1000
        total_batches = (num_orders + batch_size - 1) // batch_size
        
        print(f"\nGenerating and processing {total_batches} batches...")
        
        for batch_num in range(total_batches):
            batch_orders = []
            batch_start = batch_num * batch_size
            batch_end = min(batch_start + batch_size, num_orders)
            
            # Generate batch
            for i in range(batch_start, batch_end):
                symbol = random.choice(symbols)
                order = self.generate_market_order(i, symbol)
                batch_orders.append(order)
                
            # Process batch
            self.process_order_batch(batch_orders)
            
            # Progress update
            if (batch_num + 1) % 10 == 0:
                progress = ((batch_num + 1) / total_batches) * 100
                print(f"  Progress: {progress:.1f}% ({batch_end:,} orders)")
                
        # Process queues
        print("\nProcessing database queues...")
        
        if self.mongodb_processor:
            self.mongodb_processor.process_queue(
                batch_size=1000,
                workers=workers // 2 if workers > 1 else 1,
                adaptive=True
            )
            
        if self.postgresql_processor:
            self.postgresql_processor.process_queue(
                batch_size=1000,
                workers=workers // 2 if workers > 1 else 1,
                adaptive=True
            )
            
        elapsed = time.time() - self.start_time
        
        # Collect statistics
        stats = {
            "total_orders": num_orders,
            "processed_orders": self.total_orders_processed,
            "elapsed_seconds": round(elapsed, 2),
            "throughput_per_second": round(num_orders / elapsed, 2),
            "workers": workers,
            "cache_enabled": use_cache,
            "cache_stats": self.cache.get_stats() if self.cache else None,
            "mongodb_stats": self.mongodb_processor.get_stats() if self.mongodb_processor else None,
            "postgresql_stats": self.postgresql_processor.get_stats() if self.postgresql_processor else None
        }
        
        return stats
        
    def print_performance_report(self, stats: Dict[str, Any]) -> None:
        """Print detailed performance report"""
        print("\n" + "=" * 60)
        print("PERFORMANCE REPORT")
        print("=" * 60)
        
        print(f"\nOrder Processing:")
        print(f"  Total Orders: {stats['total_orders']:,}")
        print(f"  Processed: {stats['processed_orders']:,}")
        print(f"  Duration: {stats['elapsed_seconds']} seconds")
        print(f"  Throughput: {stats['throughput_per_second']:,.0f} orders/sec")
        
        if stats['cache_stats']:
            print(f"\nCache Performance:")
            cs = stats['cache_stats']
            print(f"  Size: {cs['size']:,} / {cs['max_size']:,}")
            print(f"  Hits: {cs['hits']:,}")
            print(f"  Misses: {cs['misses']:,}")
            print(f"  Hit Rate: {cs['hit_rate']}")
            
        if stats['mongodb_stats']:
            print(f"\nMongoDB Performance:")
            ms = stats['mongodb_stats']
            print(f"  Processed: {ms['processed_count']:,}")
            print(f"  Errors: {ms['error_count']}")
            print(f"  Time: {ms['total_time_seconds']}s")
            print(f"  Throughput: {ms['throughput_per_second']:,.0f} ops/sec")
            
        if stats['postgresql_stats']:
            print(f"\nPostgreSQL Performance:")
            ps = stats['postgresql_stats']
            print(f"  Processed: {ps['processed_count']:,}")
            print(f"  Errors: {ps['error_count']}")
            print(f"  Time: {ps['total_time_seconds']}s")
            print(f"  Throughput: {ps['throughput_per_second']:,.0f} ops/sec")
            
        print("\n" + "=" * 60)


# Example usage and demonstration
if __name__ == "__main__":
    print("=== Stock Exchange Market Order Processing Demo ===")
    
    # Initialize processor
    processor = MarketOrderProcessor(
        mongodb_uri="mongodb://localhost:27017" if MONGODB_AVAILABLE else None,
        postgresql_uri="postgresql://postgres:password@localhost:5432/market_data" if POSTGRESQL_AVAILABLE else None,
        cache_size=10000,
        enable_cache=True
    )
    
    # Simulate large-scale market order processing
    stats = processor.simulate_market_orders(
        num_orders=50000,
        workers=8,
        use_cache=True
    )
    
    # Print performance report
    processor.print_performance_report(stats)
    
    print("\nDemo completed!")
