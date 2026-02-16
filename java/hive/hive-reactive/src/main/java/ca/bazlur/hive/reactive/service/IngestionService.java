package ca.bazlur.hive.reactive.service;

import ca.bazlur.hive.reactive.model.ProcessingResult;
import ca.bazlur.hive.reactive.model.TemperatureReading;
import ca.bazlur.hive.reactive.model.WeatherData;
import ca.bazlur.hive.reactive.repository.ReadingRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

/**
 * Ingestion Service demonstrating reactive complexity.
 *
 * This service orchestrates:
 * 1. Persisting readings to database
 * 2. Broadcasting to SSE subscribers
 * 3. Fetching outdoor weather (with retry)
 * 4. Computing temperature delta
 *
 * The reactive chain complexity:
 * - Mono.zip() for parallel operations
 * - flatMap() for dependent operations
 * - map() for transformations
 * - doOnNext() for side effects
 * - onErrorResume() for error handling
 *
 * Compare with virtual threads version which uses StructuredTaskScope
 * and simple sequential/parallel code.
 */
@Service
public class IngestionService {
    private static final Logger log = LoggerFactory.getLogger(IngestionService.class);
    private static final String DEFAULT_LOCATION = "Toronto";

    private final ReadingRepository repository;
    private final SseBroadcaster broadcaster;
    private final WeatherService weatherService;
    private final AlertService alertService;
    private final SensorRateLimiter rateLimiter;

    public IngestionService(ReadingRepository repository, SseBroadcaster broadcaster,
                            WeatherService weatherService, AlertService alertService,
                            SensorRateLimiter rateLimiter) {
        this.repository = repository;
        this.broadcaster = broadcaster;
        this.weatherService = weatherService;
        this.alertService = alertService;
        this.rateLimiter = rateLimiter;
    }

    /**
     * Process a temperature reading with weather comparison and alert checking.
     *
     * Reactive complexity showcase:
     * 1. rateLimiter.checkLimit() - rate limiting check
     * 2. then() chains to main processing
     * 3. Mono.zip() orchestrates 3 parallel operations
     * 4. map() transforms the result into ProcessingResult
     * 5. flatMap() chains to alert checking
     * 6. doOnNext() logs the processing
     * 7. The chain is only executed when subscribed
     */
    public Mono<ProcessingResult> process(TemperatureReading reading) {
        return rateLimiter.checkLimit(reading.sensorId())
                .then(Mono.zip(
                        broadcaster.broadcast(reading).thenReturn(reading),// Operation 1: Broadcast to SSE subscribers
                        weatherService.fetchEnrichedWeather(DEFAULT_LOCATION)// Operation 2: Fetch enriched weather (with retry logic inside)
                ))
                .flatMap(tuple -> {
                    TemperatureReading savedReading = tuple.getT1();
                    WeatherData weather = tuple.getT2();
                    return repository.save(savedReading, weather)
                            .thenReturn(new ProcessingResult(savedReading, weather,
                                    calculateDelta(savedReading.temperature(), weather)));
                })
                .doOnNext(result -> log.info(
                        "Processed reading: sensor={}, indoor={}°C, outdoor={}°C, delta={}°C",
                        result.reading().sensorId(),
                        result.reading().temperature(),
                        result.weather().available() ? result.weather().temperature() : "N/A",
                        String.format("%.1f", result.deltaFromOutdoor())))
                .flatMap(alertService::checkAndAlert) // Check thresholds and trigger alerts if needed
                .onErrorResume(ex -> {
                    log.error("Failed to process reading for sensor {}", reading.sensorId(), ex);
                    return Mono.just(ProcessingResult.failed(reading, ex));
                });
    }

    private double calculateDelta(double indoorTemp, WeatherData weather) {
        if (!weather.available()) {
            return 0.0;
        }
        return Math.round((indoorTemp - weather.temperature()) * 10.0) / 10.0;
    }
}
