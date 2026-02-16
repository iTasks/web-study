package ca.bazlur.hive.vthreads.service;

import ca.bazlur.hive.vthreads.exception.WeatherServiceException;
import ca.bazlur.hive.vthreads.model.WeatherData;
import io.github.resilience4j.circuitbreaker.CallNotPermittedException;
import io.github.resilience4j.circuitbreaker.CircuitBreaker;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Random;
import java.util.concurrent.StructuredTaskScope;

/**
 * Mock Weather Service demonstrating virtual threads simplicity.
 *
 * Compare this with the reactive version:
 * - Simple for-loop for retries (vs retryWhen(Retry.backoff()))
 * - Thread.sleep() for delays (vs Mono.delay())
 * - try-catch for errors (vs onErrorResume())
 * - Plain method calls (vs flatMap/map chains)
 * - StructuredTaskScope for parallel calls (vs Mono.zip())
 *
 * Both versions now use Resilience4j for circuit breaker:
 * - Reactive: transformDeferred(CircuitBreakerOperator.of(circuitBreaker))
 * - Virtual Threads: circuitBreaker.executeSupplier(() -> ...) - simple method call
 *
 * The logic is identical, but the virtual threads code is more readable.
 */
@Service
public class WeatherService {
    private static final Logger log = LoggerFactory.getLogger(WeatherService.class);
    private final Random random = new Random();
    private final CircuitBreaker circuitBreaker;

    public WeatherService(CircuitBreaker weatherCircuitBreaker) {
        this.circuitBreaker = weatherCircuitBreaker;
    }

    private static final double FAILURE_RATE = 0.15; // 15% failure rate
    private static final int MIN_DELAY_MS = 100;
    private static final int MAX_DELAY_MS = 500;
    private static final int MAX_RETRIES = 3;

    /**
     * Fetches outdoor temperature with retry logic and circuit breaker.
     * Simple, readable code that does exactly what the reactive version does.
     *
     * With Resilience4j, the circuit breaker is just a simple try-catch:
     * - circuitBreaker.executeSupplier() wraps the call
     * - CallNotPermittedException triggers the fallback
     *
     * Compare with reactive's transformDeferred(CircuitBreakerOperator.of()) chain.
     */
    public WeatherData fetchOutdoorTemperature(String location) {
        try {
            return circuitBreaker.executeSupplier(() -> fetchWithRetry(location));
        } catch (CallNotPermittedException e) {
            log.debug("Circuit breaker {} is OPEN, using fallback", circuitBreaker.getName());
            return WeatherData.unavailable(location);
        } catch (Exception e) {
            log.warn("Weather fetch failed: {}", e.getMessage());
            return WeatherData.unavailable(location);
        }
    }

    private WeatherData fetchWithRetry(String location) {
        WeatherServiceException lastException = null;

        for (int attempt = 1; attempt <= MAX_RETRIES; attempt++) {
            try {
                return simulateNetworkCall(location);
            } catch (WeatherServiceException e) {
                lastException = e;
                log.warn("Retrying weather fetch for {}, attempt {}, cause: {}",
                        location, attempt, e.getMessage());

                if (attempt < MAX_RETRIES) {
                    sleepWithBackoff(attempt);
                }
            }
        }

        throw lastException != null ? lastException :
                new WeatherServiceException("Max retries exceeded for " + location);
    }

    public CircuitBreaker.State getCircuitBreakerState() {
        return circuitBreaker.getState();
    }

    /**
     * Fetches weather with enriched data using StructuredTaskScope for parallel calls.
     * Compare with reactive Mono.zip() - this is just as concurrent but far more readable.
     */
    public WeatherData fetchEnrichedWeather(String location) {
        try (var scope = StructuredTaskScope.open()) {
            var tempTask = scope.fork(() -> fetchOutdoorTemperature(location));
            var humidityTask = scope.fork(() -> fetchHumidity(location));
            var windTask = scope.fork(() -> fetchWindSpeed(location));

            scope.join();

            WeatherData temp = tempTask.get();
            double humidity = humidityTask.get();
            double windSpeed = windTask.get();

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
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return WeatherData.unavailable(location);
        }
    }

    private double fetchHumidity(String location) {
        sleep(random.nextInt(100, 200));
        return random.nextDouble(30, 80);
    }

    private double fetchWindSpeed(String location) {
        sleep(random.nextInt(100, 200));
        return random.nextDouble(0, 50);
    }

    private WeatherData simulateNetworkCall(String location) {
        int delayMs = random.nextInt(MIN_DELAY_MS, MAX_DELAY_MS);
        sleep(delayMs);

        if (random.nextDouble() < FAILURE_RATE) {
            throw new WeatherServiceException("Simulated network failure for location: " + location);
        }

        double temperature = generateRealisticTemperature();
        return new WeatherData(temperature, 0.0, 0.0, location, Instant.now(), true);
    }

    private void sleepWithBackoff(int attempt) {
        // Exponential backoff: 200ms, 400ms, 800ms... with jitter
        long baseDelay = 200L * (1L << (attempt - 1));
        long jitter = random.nextLong(0, baseDelay / 2);
        sleep(baseDelay + jitter);
    }

    private void sleep(long millis) {
        try {
            Thread.sleep(millis);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private double generateRealisticTemperature() {
        return Math.round((random.nextDouble(10, 35)) * 10.0) / 10.0;
    }
}
