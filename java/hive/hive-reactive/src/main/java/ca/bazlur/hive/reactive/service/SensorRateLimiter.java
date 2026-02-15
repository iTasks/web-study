package ca.bazlur.hive.reactive.service;

import ca.bazlur.hive.reactive.exception.RateLimitExceededException;
import io.github.resilience4j.ratelimiter.RateLimiter;
import io.github.resilience4j.ratelimiter.RateLimiterConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

/**
 * Rate limiter per sensor using Resilience4j.
 *
 * Reactive complexity:
 * - RateLimiterRegistry for creating per-sensor rate limiters
 * - Mono.fromCallable() for wrapping blocking rate limit check
 * - Mono.error() for signaling rate limit exceeded
 * - ConcurrentHashMap for thread-safe limiter storage
 *
 * Compare with virtual threads version which uses a simple sliding window
 * with ConcurrentLinkedDeque (~30 lines of code).
 *
 * Configure via properties:
 * - hive.rate-limit.enabled=false (disable for benchmarks)
 * - hive.rate-limit.requests-per-minute=60 (default)
 */
@Service
public class SensorRateLimiter {
    private static final Logger log = LoggerFactory.getLogger(SensorRateLimiter.class);

    private final ConcurrentMap<String, RateLimiter> limiters = new ConcurrentHashMap<>();
    private RateLimiterConfig config;

    @Value("${hive.rate-limit.enabled:true}")
    private boolean enabled;

    @Value("${hive.rate-limit.requests-per-minute:60}")
    private int requestsPerMinute;

    private RateLimiterConfig getConfig() {
        if (config == null) {
            config = RateLimiterConfig.custom()
                    .limitRefreshPeriod(Duration.ofMinutes(1))
                    .limitForPeriod(requestsPerMinute)
                    .timeoutDuration(Duration.ZERO)
                    .build();
        }
        return config;
    }

    /**
     * Check if a request from a sensor is allowed.
     *
     * Reactive pattern: Returns Mono<Void> that completes if allowed,
     * or errors with RateLimitExceededException if rate limit exceeded.
     */
    public Mono<Void> checkLimit(String sensorId) {
        if (!enabled) {
            return Mono.empty(); // Rate limiting disabled
        }

        return Mono.fromCallable(() -> {
                    RateLimiter limiter = limiters.computeIfAbsent(sensorId, this::createLimiter);
                    return limiter.acquirePermission();
                })
                .flatMap(permitted -> {
                    if (permitted) {
                        return Mono.empty();
                    } else {
                        log.warn("Rate limit exceeded for sensor: {}", sensorId);
                        return Mono.error(new RateLimitExceededException(sensorId));
                    }
                });
    }

    private RateLimiter createLimiter(String sensorId) {
        return RateLimiter.of("sensor-" + sensorId, getConfig());
    }
}
