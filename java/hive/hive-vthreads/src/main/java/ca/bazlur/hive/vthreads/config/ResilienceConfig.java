package ca.bazlur.hive.vthreads.config;

import io.github.resilience4j.circuitbreaker.CircuitBreaker;
import io.github.resilience4j.circuitbreaker.CircuitBreakerConfig;
import io.github.resilience4j.circuitbreaker.CircuitBreakerRegistry;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;

/**
 * Resilience4j configuration for virtual threads.
 *
 * Both reactive and virtual threads versions now use the same Resilience4j library.
 * The key difference is in how it's used:
 * - Reactive: transformDeferred(CircuitBreakerOperator.of(circuitBreaker))
 * - Virtual Threads: circuitBreaker.executeSupplier(() -> ...)
 *
 * The virtual threads version is more straightforward - just a method call wrapper.
 */
@Configuration
public class ResilienceConfig {

    @Bean
    public CircuitBreakerRegistry circuitBreakerRegistry() {
        CircuitBreakerConfig config = CircuitBreakerConfig.custom()
                .failureRateThreshold(50)
                .slowCallRateThreshold(50)
                .slowCallDurationThreshold(Duration.ofSeconds(2))
                .waitDurationInOpenState(Duration.ofSeconds(30))
                .permittedNumberOfCallsInHalfOpenState(5)
                .slidingWindowType(CircuitBreakerConfig.SlidingWindowType.COUNT_BASED)
                .slidingWindowSize(10)
                .minimumNumberOfCalls(5)
                .build();

        return CircuitBreakerRegistry.of(config);
    }

    @Bean
    public CircuitBreaker weatherCircuitBreaker(CircuitBreakerRegistry registry) {
        return registry.circuitBreaker("weatherService");
    }
}
