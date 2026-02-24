use std::collections::{HashMap, VecDeque};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

use sha2::{Digest, Sha256};

use crate::models::QueryResponse;

/// Cache TTL: entries older than this are considered stale and evicted on next access.
const TTL: Duration = Duration::from_secs(300);
/// Maximum number of entries retained in the LRU cache before eviction of the LRU entry.
const MAX_SIZE: usize = 10_000;

// ---------------------------------------------------------------------------
// Internal LRU implementation
// ---------------------------------------------------------------------------

struct CacheEntry {
    response: QueryResponse,
    inserted_at: Instant,
}

struct LruInner {
    entries: HashMap<String, CacheEntry>,
    order: VecDeque<String>, // front = most-recently-used
    max_size: usize,
}

impl LruInner {
    fn new(max_size: usize) -> Self {
        LruInner {
            entries: HashMap::new(),
            order: VecDeque::new(),
            max_size,
        }
    }

    fn get(&mut self, key: &str) -> Option<QueryResponse> {
        // Remove if TTL expired
        if let Some(entry) = self.entries.get(key) {
            if entry.inserted_at.elapsed() > TTL {
                self.entries.remove(key);
                self.order.retain(|k| k != key);
                return None;
            }
        }
        if let Some(entry) = self.entries.get(key) {
            let response = entry.response.clone();
            // Promote to front (most-recently-used)
            self.order.retain(|k| k != key);
            self.order.push_front(key.to_string());
            return Some(response);
        }
        None
    }

    fn set(&mut self, key: String, response: QueryResponse) {
        if self.entries.contains_key(&key) {
            self.order.retain(|k| k != &key);
        } else if self.entries.len() >= self.max_size {
            // Evict least-recently-used (back of the deque)
            if let Some(lru_key) = self.order.pop_back() {
                self.entries.remove(&lru_key);
            }
        }
        self.entries.insert(
            key.clone(),
            CacheEntry {
                response,
                inserted_at: Instant::now(),
            },
        );
        self.order.push_front(key);
    }
}

// ---------------------------------------------------------------------------
// Public QueryCache
// ---------------------------------------------------------------------------

#[derive(Clone)]
pub struct QueryCache {
    inner: Arc<Mutex<LruInner>>,
}

impl QueryCache {
    pub fn new() -> Self {
        QueryCache {
            inner: Arc::new(Mutex::new(LruInner::new(MAX_SIZE))),
        }
    }

    fn make_key(business_id: &str, query: &str) -> String {
        let mut hasher = Sha256::new();
        hasher.update(format!("{}:{}", business_id, query).as_bytes());
        format!("{:x}", hasher.finalize())
    }

    pub fn get(&self, business_id: &str, query: &str) -> Option<QueryResponse> {
        let key = Self::make_key(business_id, query);
        self.inner.lock().unwrap().get(&key)
    }

    pub fn set(&self, business_id: &str, query: &str, response: QueryResponse) {
        let key = Self::make_key(business_id, query);
        self.inner.lock().unwrap().set(key, response);
    }
}
