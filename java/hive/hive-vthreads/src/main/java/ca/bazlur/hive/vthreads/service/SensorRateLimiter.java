package ca.bazlur.hive.vthreads.service;

import ca.bazlur.hive.vthreads.exception.RateLimitExceededException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedDeque;
import java.util.concurrent.ConcurrentMap;

/**
 * Simple sliding window rate limiter per sensor.
 *
 * Compare with reactive version which requires:
 * - Resilience4j RateLimiter dependency
 * - RateLimiterConfig builder
 * - Mono.fromCallable() wrapping
 * - flatMap for error handling
 *
 * This hand-rolled implementation is ~40 lines and immediately readable.
 * Uses a simple sliding window with ConcurrentLinkedDeque.
 *
 * Configure via properties:
 * - hive.rate-limit.enabled=false (disable for benchmarks)
 * - hive.rate-limit.requests-per-minute=60 (default)
 */
@Service
public class SensorRateLimiter {
    private static final Logger log = LoggerFactory.getLogger(SensorRateLimiter.class);
    private static final long WINDOW_MS = 60_000;

    private final ConcurrentMap<String, ConcurrentLinkedDeque<Long>> windows = new ConcurrentHashMap<>();

    @Value("${hive.rate-limit.enabled:true}")
    private boolean enabled;

    @Value("${hive.rate-limit.requests-per-minute:60}")
    private int requestsPerMinute;

    /**
     * Check if a request from a sensor is allowed.
     * Simple, blocking implementation - perfect for virtual threads.
     */
    public void checkLimit(String sensorId) {
        if (!enabled) {
            return; // Rate limiting disabled
        }

        ConcurrentLinkedDeque<Long> window = windows.computeIfAbsent(
                sensorId, _ -> new ConcurrentLinkedDeque<>());

        long now = Instant.now().toEpochMilli();
        long cutoff = now - WINDOW_MS;

        // Remove expired entries
        while (!window.isEmpty() && window.peekFirst() < cutoff) {
            window.pollFirst();
        }

        // Check if we're over the limit
        if (window.size() >= requestsPerMinute) {
            log.warn("Rate limit exceeded for sensor: {}", sensorId);
            throw new RateLimitExceededException(sensorId);
        }

        // Record this request
        window.addLast(now);
    }
}
