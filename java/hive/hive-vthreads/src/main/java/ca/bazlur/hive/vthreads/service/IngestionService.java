package ca.bazlur.hive.vthreads.service;

import ca.bazlur.hive.vthreads.model.ProcessingResult;
import ca.bazlur.hive.vthreads.model.TemperatureReading;
import ca.bazlur.hive.vthreads.model.WeatherData;
import ca.bazlur.hive.vthreads.repository.ReadingRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.concurrent.StructuredTaskScope;

/**
 * Ingestion Service demonstrating virtual threads simplicity.
 *
 * <p>This service orchestrates: 1. Persisting readings to database 2. Broadcasting to SSE
 * subscribers 3. Fetching outdoor weather (with retry) 4. Computing temperature delta
 *
 * <p>Compare with reactive version: - StructuredTaskScope for parallel ops (vs Mono.zip()) - Simple
 * method calls (vs flatMap chains) - Direct returns (vs map transformations) - try-catch (vs
 * onErrorResume)
 *
 * <p>The logic is identical but the code is immediately readable.
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

  public IngestionService(
      ReadingRepository repository,
      SseBroadcaster broadcaster,
      WeatherService weatherService,
      AlertService alertService,
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
   * <p>Virtual threads simplicity: 1. rateLimiter.checkLimit() - simple rate limiting (throws if
   * exceeded) 2. StructuredTaskScope.open() creates a scope for parallel tasks 3. scope.fork()
   * launches each task in its own virtual thread 4. scope.join() waits for all tasks to complete 5.
   * Direct get() retrieves results 6. Simple method call for alert checking
   *
   * <p>This is just as concurrent as the reactive version but far more readable.
   */
  public ProcessingResult process(TemperatureReading reading) {
    try {
      rateLimiter.checkLimit(
          reading
              .sensorId()); // Rate limit check - simple method call that throws if limit exceeded

      try (var scope = StructuredTaskScope.open()) { // Launch parallel operations
        var broadcastTask =
            scope.fork(
                () -> {
                  broadcaster.broadcast(reading);
                  return reading;
                });
        var weatherTask = scope.fork(() -> weatherService.fetchEnrichedWeather(DEFAULT_LOCATION));

        scope.join(); // Wait for parallel tasks to complete

        TemperatureReading savedReading = broadcastTask.get();
        WeatherData weather = weatherTask.get();
        repository.save(savedReading, weather);
        double delta = calculateDelta(savedReading.temperature(), weather);

        ProcessingResult result = new ProcessingResult(savedReading, weather, delta);

        log.info(
            "Processed reading: sensor={}, indoor={}°C, outdoor={}°C, delta={}°C",
            result.reading().sensorId(),
            result.reading().temperature(),
            result.weather().available() ? result.weather().temperature() : "N/A",
            String.format("%.1f", result.deltaFromOutdoor()));

        return alertService.checkAndAlert(result); // Check thresholds and trigger alerts if needed
      }
    } catch (InterruptedException | StructuredTaskScope.FailedException e) {
      if (e instanceof InterruptedException) {
        Thread.currentThread().interrupt();
      }
      log.error("Failed to process reading for sensor {}", reading.sensorId(), e);
      return ProcessingResult.failed(reading, e);
    }
  }

  private double calculateDelta(double indoorTemp, WeatherData weather) {
    if (!weather.available()) {
      return 0.0;
    }
    return Math.round((indoorTemp - weather.temperature()) * 10.0) / 10.0;
  }
}
