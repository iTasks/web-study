package ca.bazlur.hive.reactive.service;

import ca.bazlur.hive.reactive.exception.WeatherServiceException;
import ca.bazlur.hive.reactive.model.WeatherData;
import io.github.resilience4j.circuitbreaker.CircuitBreaker;
import io.github.resilience4j.reactor.circuitbreaker.operator.CircuitBreakerOperator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;
import reactor.util.retry.Retry;

import java.time.Duration;
import java.time.Instant;
import java.util.Random;

/**
 * Mock Weather Service demonstrating reactive complexity.
 *
 * This implementation showcases the operator complexity required in reactive programming:
 * - Mono.defer() for lazy evaluation
 * - Mono.delay() for simulating network latency
 * - retryWhen(Retry.backoff()) for exponential backoff
 * - timeout() for request timeouts
 * - onErrorResume() for fallback handling
 * - doOnNext/doOnError for logging side effects
 * - transformDeferred(CircuitBreakerOperator.of()) for circuit breaker
 *
 * Compare this with the virtual threads version which uses simple for-loops and Thread.sleep().
 */
@Service
public class WeatherService {
    private static final Logger log = LoggerFactory.getLogger(WeatherService.class);
    private final Random random = new Random();
    private final CircuitBreaker circuitBreaker;

    private static final double FAILURE_RATE = 0.15; // 15% failure rate
    private static final int MIN_DELAY_MS = 100;
    private static final int MAX_DELAY_MS = 500;
    private static final int MAX_RETRIES = 3;
    private static final Duration TIMEOUT = Duration.ofSeconds(2);

    public WeatherService(CircuitBreaker weatherCircuitBreaker) {
        this.circuitBreaker = weatherCircuitBreaker;
    }

    /**
     * Fetches outdoor temperature for a given location.
     *
     * The reactive chain complexity:
     * 1. Mono.defer() - defers execution until subscription
     * 2. Mono.delay() - simulates network latency (100-500ms)
     * 3. flatMap() - transforms after delay completes
     * 4. Mono.error() vs Mono.just() - conditional failure simulation
     * 5. retryWhen(Retry.backoff()) - exponential backoff with jitter
     * 6. timeout() - fails if operation takes too long
     * 7. transformDeferred(CircuitBreakerOperator.of()) - circuit breaker wrapper
     * 8. onErrorResume() - provides fallback value
     * 9. doOnNext/doOnError - side effects for logging
     */
    public Mono<WeatherData> fetchOutdoorTemperature(String location) {
        return Mono.defer(() -> simulateNetworkCall(location))
                .retryWhen(Retry.backoff(MAX_RETRIES, Duration.ofMillis(200))
                        .maxBackoff(Duration.ofSeconds(1))
                        .jitter(0.5)
                        .filter(ex -> ex instanceof WeatherServiceException)
                        .doBeforeRetry(signal -> log.warn(
                                "Retrying weather fetch for {}, attempt {}, cause: {}",
                                location, signal.totalRetries() + 1, signal.failure().getMessage())))
                .timeout(TIMEOUT)
                .transformDeferred(CircuitBreakerOperator.of(circuitBreaker))
                .doOnNext(data -> log.debug("Weather data fetched for {}: {}°C", location, data.temperature()))
                .doOnError(ex -> log.error("Failed to fetch weather for {}: {}", location, ex.getMessage()))
                .onErrorResume(ex -> {
                    log.warn("Using fallback weather data for {} due to: {}", location, ex.getMessage());
                    return Mono.just(WeatherData.unavailable(location));
                });
    }

    public CircuitBreaker.State getCircuitBreakerState() {
        return circuitBreaker.getState();
    }

    /**
     * Fetches weather with enriched data (demonstrates Mono.zip for parallel calls).
     * In a real scenario, this might fetch temperature, humidity, and wind speed in parallel.
     */
    public Mono<WeatherData> fetchEnrichedWeather(String location) {
        return Mono.zip(
                fetchOutdoorTemperature(location),
                fetchHumidity(location),
                fetchWindSpeed(location)
        ).map(tuple -> {
            WeatherData temp = tuple.getT1();
            double humidity = tuple.getT2();
            double windSpeed = tuple.getT3();
            // In a real app, you'd have fields for humidity and wind
            log.debug("Enriched weather: {}°C, {}% humidity, {} km/h wind",
                    temp.temperature(), humidity, windSpeed);
            return new WeatherData(
                    temp.temperature(),
                    humidity,
                    windSpeed,
                    temp.location(),
                    temp.fetchedAt(),
                    temp.available()
            );
        });
    }

    private Mono<Double> fetchHumidity(String location) {
        return Mono.defer(() -> Mono.delay(Duration.ofMillis(random.nextInt(100, 200)))
                .map(_ -> random.nextDouble(30, 80)));
    }

    private Mono<Double> fetchWindSpeed(String location) {
        return Mono.defer(() -> Mono.delay(Duration.ofMillis(random.nextInt(100, 200)))
                .map(_ -> random.nextDouble(0, 50)));
    }

    private Mono<WeatherData> simulateNetworkCall(String location) {
        int delayMs = random.nextInt(MIN_DELAY_MS, MAX_DELAY_MS);
        boolean shouldFail = random.nextDouble() < FAILURE_RATE;

        return Mono.delay(Duration.ofMillis(delayMs))
                .flatMap(_ -> {
                    if (shouldFail) {
                        return Mono.error(new WeatherServiceException(
                                "Simulated network failure for location: " + location));
                    }
                    double temperature = generateRealisticTemperature();
                    return Mono.just(new WeatherData(temperature, 0.0, 0.0, location, Instant.now(), true));
                });
    }

    private double generateRealisticTemperature() {
        // Generate temperature between 10°C and 35°C with some variation
        return Math.round((random.nextDouble(10, 35)) * 10.0) / 10.0;
    }
}
