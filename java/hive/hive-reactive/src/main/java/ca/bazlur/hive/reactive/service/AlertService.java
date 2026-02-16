package ca.bazlur.hive.reactive.service;

import ca.bazlur.hive.reactive.model.*;
import ca.bazlur.hive.reactive.repository.AlertRepository;
import ca.bazlur.hive.reactive.repository.ThresholdRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.Optional;

/**
 * Alert Service demonstrating reactive complexity.
 *
 * This service showcases nested reactive chains:
 * - flatMap() for dependent operations
 * - switchIfEmpty() for conditional defaults
 * - Mono.when() for parallel saves
 * - filter() with flatMap() for conditional processing
 *
 * Compare with virtual threads version which uses simple if-else statements.
 */
@Service
public class AlertService {
    private static final Logger log = LoggerFactory.getLogger(AlertService.class);

    private final ThresholdRepository thresholdRepository;
    private final AlertRepository alertRepository;
    private final AlertBroadcaster alertBroadcaster;

    public AlertService(ThresholdRepository thresholdRepository,
                        AlertRepository alertRepository,
                        AlertBroadcaster alertBroadcaster) {
        this.thresholdRepository = thresholdRepository;
        this.alertRepository = alertRepository;
        this.alertBroadcaster = alertBroadcaster;
    }

    /**
     * Check thresholds and potentially trigger an alert.
     *
     * Reactive complexity:
     * 1. flatMap to get threshold
     * 2. flatMap to check and potentially create alert
     * 3. flatMap to save alert if created
     * 4. flatMap to broadcast alert
     * 5. Mono.justOrEmpty() for Optional handling
     */
    public Mono<ProcessingResult> checkAndAlert(ProcessingResult result) {
        return thresholdRepository.findBySensorId(result.reading().sensorId())
                .flatMap(threshold -> checkThreshold(result, threshold))
                .flatMap(alert -> saveAndBroadcast(alert, result))
                .switchIfEmpty(Mono.just(result));
    }

    private Mono<Alert> checkThreshold(ProcessingResult result, SensorThreshold threshold) {
        TemperatureReading reading = result.reading();
        WeatherData weather = result.weather();
        double temp = reading.temperature();
        double delta = result.deltaFromOutdoor();

        // Check for HIGH_TEMP
        if (temp > threshold.maxTemp()) {
            return Mono.just(new Alert(
                    reading.sensorId(),
                    AlertType.HIGH_TEMP,
                    temp,
                    threshold.maxTemp(),
                    weather.available() ? weather.temperature() : null,
                    Instant.now()
            ));
        }

        // Check for LOW_TEMP
        if (temp < threshold.minTemp()) {
            return Mono.just(new Alert(
                    reading.sensorId(),
                    AlertType.LOW_TEMP,
                    temp,
                    threshold.minTemp(),
                    weather.available() ? weather.temperature() : null,
                    Instant.now()
            ));
        }

        // Check for ABNORMAL_DELTA (if weather is available)
        if (weather.available() && Math.abs(delta) > threshold.maxOutdoorDelta()) {
            return Mono.just(new Alert(
                    reading.sensorId(),
                    AlertType.ABNORMAL_DELTA,
                    delta,
                    threshold.maxOutdoorDelta(),
                    weather.temperature(),
                    Instant.now()
            ));
        }

        return Mono.empty();
    }

    private Mono<ProcessingResult> saveAndBroadcast(Alert alert, ProcessingResult result) {
        return alertRepository.save(alert)
                .flatMap(savedAlert -> alertBroadcaster.broadcast(savedAlert)
                        .thenReturn(savedAlert))
                .doOnNext(savedAlert -> log.warn(
                        "ALERT triggered: type={}, sensor={}, value={}, threshold={}",
                        savedAlert.alertType(),
                        savedAlert.sensorId(),
                        savedAlert.actualValue(),
                        savedAlert.thresholdValue()))
                .map(result::withAlert);
    }

    public Flux<Alert> getRecentAlerts(int limit) {
        return alertRepository.findRecent(limit);
    }

    public Flux<Alert> getUnacknowledgedAlerts() {
        return alertRepository.findUnacknowledged();
    }

    public Mono<Void> acknowledgeAlert(Long id) {
        return alertRepository.acknowledge(id);
    }
}
