use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

// ---------------------------------------------------------------------------
// CircuitBreaker
// ---------------------------------------------------------------------------

#[derive(Debug, Clone, PartialEq)]
pub enum CircuitState {
    Closed,
    Open,
    HalfOpen,
}

struct CircuitBreakerState {
    state: CircuitState,
    failure_count: u32,
    last_failure: Option<Instant>,
}

#[derive(Clone)]
pub struct CircuitBreaker {
    name: String,
    failure_threshold: u32,
    recovery_timeout: Duration,
    inner: Arc<Mutex<CircuitBreakerState>>,
}

impl CircuitBreaker {
    pub fn new(name: &str) -> Self {
        CircuitBreaker {
            name: name.to_string(),
            // Open the circuit after 5 consecutive failures.
            failure_threshold: 5,
            // Allow a probe request after 30 s in the Open state.
            recovery_timeout: Duration::from_secs(30),
            inner: Arc::new(Mutex::new(CircuitBreakerState {
                state: CircuitState::Closed,
                failure_count: 0,
                last_failure: None,
            })),
        }
    }

    /// Executes `f`. Returns `None` when the circuit is Open or `f` panics;
    /// returns `Some(result)` on success.
    pub fn call<F, T>(&self, f: F) -> Option<T>
    where
        F: FnOnce() -> T,
    {
        // Check / transition state
        {
            let mut s = self.inner.lock().unwrap();
            match s.state {
                CircuitState::Open => {
                    let should_probe = s
                        .last_failure
                        .map(|t| t.elapsed() >= self.recovery_timeout)
                        .unwrap_or(false);
                    if should_probe {
                        s.state = CircuitState::HalfOpen;
                    } else {
                        return None;
                    }
                }
                CircuitState::Closed | CircuitState::HalfOpen => {}
            }
        }

        // Execute (catch panics so we can update failure count)
        let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(f));

        match result {
            Ok(value) => {
                let mut s = self.inner.lock().unwrap();
                s.failure_count = 0;
                s.state = CircuitState::Closed;
                Some(value)
            }
            Err(_) => {
                let mut s = self.inner.lock().unwrap();
                s.failure_count += 1;
                s.last_failure = Some(Instant::now());
                if s.failure_count >= self.failure_threshold {
                    s.state = CircuitState::Open;
                    eprintln!("Circuit breaker '{}' opened", self.name);
                }
                None
            }
        }
    }

    pub fn get_state(&self) -> CircuitState {
        self.inner.lock().unwrap().state.clone()
    }
}

// ---------------------------------------------------------------------------
// ConcurrencyLimiter
// ---------------------------------------------------------------------------

#[derive(Clone)]
pub struct ConcurrencyLimiter {
    semaphore: Arc<tokio::sync::Semaphore>,
    pub max_concurrent: usize,
}

impl ConcurrencyLimiter {
    pub fn new(max_concurrent: usize) -> Self {
        ConcurrencyLimiter {
            semaphore: Arc::new(tokio::sync::Semaphore::new(max_concurrent)),
            max_concurrent,
        }
    }

    /// Acquires a permit. Drops when the returned value is dropped.
    pub async fn acquire(&self) -> tokio::sync::OwnedSemaphorePermit {
        Arc::clone(&self.semaphore)
            .acquire_owned()
            .await
            .expect("semaphore closed")
    }
}
