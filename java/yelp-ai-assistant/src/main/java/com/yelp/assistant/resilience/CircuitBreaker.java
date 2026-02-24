package com.yelp.assistant.resilience;

import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.atomic.AtomicReference;

@Component
public class CircuitBreaker {

    public enum State { CLOSED, OPEN, HALF_OPEN }

    private final int failureThreshold;
    private final long recoveryTimeoutSeconds;

    private final AtomicReference<State> state = new AtomicReference<>(State.CLOSED);
    private final AtomicInteger failureCount = new AtomicInteger(0);
    private final AtomicLong lastFailureEpoch = new AtomicLong(0);

    public CircuitBreaker() {
        this(5, 30);
    }

    public CircuitBreaker(int failureThreshold, long recoveryTimeoutSeconds) {
        this.failureThreshold = failureThreshold;
        this.recoveryTimeoutSeconds = recoveryTimeoutSeconds;
    }

    public boolean isOpen() {
        if (state.get() == State.OPEN) {
            if (Instant.now().getEpochSecond() - lastFailureEpoch.get() >= recoveryTimeoutSeconds) {
                state.compareAndSet(State.OPEN, State.HALF_OPEN);
                return false;
            }
            return true;
        }
        return false;
    }

    public void recordSuccess() {
        failureCount.set(0);
        state.set(State.CLOSED);
    }

    public void recordFailure() {
        lastFailureEpoch.set(Instant.now().getEpochSecond());
        if (failureCount.incrementAndGet() >= failureThreshold) {
            state.set(State.OPEN);
        }
    }

    public String stateName() {
        return state.get().name().toLowerCase();
    }
}
