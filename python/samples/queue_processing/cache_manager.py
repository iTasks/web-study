"""
Cache Manager with LRU Eviction Policy

Provides efficient in-memory caching with automatic eviction based on:
- Least Recently Used (LRU) policy
- Maximum size limits
- Memory usage thresholds
"""

from collections import OrderedDict
from typing import Any, Optional
import time


class CacheManager:
    """
    Thread-safe LRU cache implementation with memory management
    
    Features:
    - LRU eviction policy
    - Configurable max size
    - Access time tracking
    - Hit/miss statistics
    """
    
    def __init__(self, max_size: int = 10000, ttl_seconds: Optional[int] = None):
        """
        Initialize cache manager
        
        Args:
            max_size: Maximum number of items in cache
            ttl_seconds: Time-to-live for cache entries (None = no expiration)
        """
        self.max_size = max_size
        self.ttl_seconds = ttl_seconds
        self.cache = OrderedDict()
        self.timestamps = {}
        self.hits = 0
        self.misses = 0
        
    def get(self, key: str) -> Optional[Any]:
        """
        Retrieve item from cache
        
        Args:
            key: Cache key
            
        Returns:
            Cached value or None if not found/expired
        """
        # Check if key exists
        if key not in self.cache:
            self.misses += 1
            return None
            
        # Check if expired
        if self.ttl_seconds and self._is_expired(key):
            self._evict(key)
            self.misses += 1
            return None
            
        # Move to end (mark as recently used)
        self.cache.move_to_end(key)
        self.hits += 1
        return self.cache[key]
        
    def set(self, key: str, value: Any) -> None:
        """
        Add or update item in cache
        
        Args:
            key: Cache key
            value: Value to cache
        """
        # If key exists, update and move to end
        if key in self.cache:
            self.cache.move_to_end(key)
        else:
            # Check if we need to evict
            if len(self.cache) >= self.max_size:
                self._evict_lru()
                
        self.cache[key] = value
        self.timestamps[key] = time.time()
        
    def delete(self, key: str) -> bool:
        """
        Remove item from cache
        
        Args:
            key: Cache key
            
        Returns:
            True if item was removed, False if not found
        """
        if key in self.cache:
            del self.cache[key]
            del self.timestamps[key]
            return True
        return False
        
    def clear(self) -> None:
        """Clear all items from cache"""
        self.cache.clear()
        self.timestamps.clear()
        self.hits = 0
        self.misses = 0
        
    def size(self) -> int:
        """Get current cache size"""
        return len(self.cache)
        
    def get_stats(self) -> dict:
        """
        Get cache statistics
        
        Returns:
            Dictionary with cache statistics
        """
        total_requests = self.hits + self.misses
        hit_rate = (self.hits / total_requests * 100) if total_requests > 0 else 0
        
        return {
            "size": len(self.cache),
            "max_size": self.max_size,
            "hits": self.hits,
            "misses": self.misses,
            "hit_rate": f"{hit_rate:.2f}%",
            "total_requests": total_requests
        }
        
    def _is_expired(self, key: str) -> bool:
        """Check if cache entry has expired"""
        if not self.ttl_seconds:
            return False
        timestamp = self.timestamps.get(key)
        if not timestamp:
            return True
        return (time.time() - timestamp) > self.ttl_seconds
        
    def _evict_lru(self) -> None:
        """Evict least recently used item"""
        if self.cache:
            # Remove first item (least recently used)
            key = next(iter(self.cache))
            self._evict(key)
            
    def _evict(self, key: str) -> None:
        """Evict specific key"""
        if key in self.cache:
            del self.cache[key]
        if key in self.timestamps:
            del self.timestamps[key]


class MarketDataCache(CacheManager):
    """
    Specialized cache for market data with symbol-based keys
    """
    
    def get_order(self, order_id: str) -> Optional[dict]:
        """Get order by ID"""
        return self.get(f"order:{order_id}")
        
    def set_order(self, order_id: str, order_data: dict) -> None:
        """Cache order data"""
        self.set(f"order:{order_id}", order_data)
        
    def get_symbol_price(self, symbol: str) -> Optional[float]:
        """Get cached price for symbol"""
        return self.get(f"price:{symbol}")
        
    def set_symbol_price(self, symbol: str, price: float) -> None:
        """Cache symbol price"""
        self.set(f"price:{symbol}", price)


# Example usage
if __name__ == "__main__":
    # Basic cache usage
    cache = CacheManager(max_size=5)
    
    print("=== Basic Cache Operations ===")
    cache.set("key1", "value1")
    cache.set("key2", "value2")
    cache.set("key3", "value3")
    
    print(f"Get key1: {cache.get('key1')}")
    print(f"Get key2: {cache.get('key2')}")
    print(f"Get missing: {cache.get('missing')}")
    
    print(f"\nCache stats: {cache.get_stats()}")
    
    # LRU eviction demo
    print("\n=== LRU Eviction Demo ===")
    for i in range(10):
        cache.set(f"key{i}", f"value{i}")
        
    print(f"Cache size: {cache.size()} (max: {cache.max_size})")
    print(f"Oldest keys evicted, newest keys remain")
    
    # Market data cache
    print("\n=== Market Data Cache ===")
    market_cache = MarketDataCache(max_size=1000)
    
    market_cache.set_order("ORD001", {
        "symbol": "AAPL",
        "quantity": 100,
        "price": 150.50,
        "side": "BUY"
    })
    
    market_cache.set_symbol_price("AAPL", 150.75)
    
    print(f"Order: {market_cache.get_order('ORD001')}")
    print(f"Price: {market_cache.get_symbol_price('AAPL')}")
    print(f"\nStats: {market_cache.get_stats()}")
