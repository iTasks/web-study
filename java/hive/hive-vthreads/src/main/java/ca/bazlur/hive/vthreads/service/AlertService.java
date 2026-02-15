package ca.bazlur.hive.vthreads.service;

import ca.bazlur.hive.vthreads.model.*;
import ca.bazlur.hive.vthreads.repository.AlertRepository;
import ca.bazlur.hive.vthreads.repository.ThresholdRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;

/**
 * Alert Service demonstrating virtual threads simplicity.
 *
 * Compare with reactive version:
 * - Simple if-else (vs flatMap chains with filter)
 * - Direct method calls (vs Mono.when and flatMap)
 * - Plain return statements (vs switchIfEmpty)
 *
 * The logic is identical but the code is immediately readable.
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
     * Virtual threads simplicity:
     * 1. Get threshold (simple method call)
     * 2. Check conditions (simple if-else)
     * 3. Save alert if needed (simple method call)
     * 4. Broadcast alert (simple method call)
     * 5. Return result
     *
     * This is just as functional but far more readable than the reactive version.
     */
    public ProcessingResult checkAndAlert(ProcessingResult result) {
        SensorThreshold threshold = thresholdRepository.findBySensorId(result.reading().sensorId());
        Alert alert = checkThreshold(result, threshold);

        if (alert != null) {
            Alert savedAlert = alertRepository.save(alert);
            alertBroadcaster.broadcast(savedAlert);

            log.warn("ALERT triggered: type={}, sensor={}, value={}, threshold={}",
                    savedAlert.alertType(),
                    savedAlert.sensorId(),
                    savedAlert.actualValue(),
                    savedAlert.thresholdValue());

            return result.withAlert(savedAlert);
        }

        return result;
    }

    private Alert checkThreshold(ProcessingResult result, SensorThreshold threshold) {
        TemperatureReading reading = result.reading();
        WeatherData weather = result.weather();
        double temp = reading.temperature();
        double delta = result.deltaFromOutdoor();

        // Check for HIGH_TEMP
        if (temp > threshold.maxTemp()) {
            return new Alert(
                    reading.sensorId(),
                    AlertType.HIGH_TEMP,
                    temp,
                    threshold.maxTemp(),
                    weather.available() ? weather.temperature() : null,
                    Instant.now()
            );
        }

        // Check for LOW_TEMP
        if (temp < threshold.minTemp()) {
            return new Alert(
                    reading.sensorId(),
                    AlertType.LOW_TEMP,
                    temp,
                    threshold.minTemp(),
                    weather.available() ? weather.temperature() : null,
                    Instant.now()
            );
        }

        // Check for ABNORMAL_DELTA (if weather is available)
        if (weather.available() && Math.abs(delta) > threshold.maxOutdoorDelta()) {
            return new Alert(
                    reading.sensorId(),
                    AlertType.ABNORMAL_DELTA,
                    delta,
                    threshold.maxOutdoorDelta(),
                    weather.temperature(),
                    Instant.now()
            );
        }

        return null;
    }

    public List<Alert> getRecentAlerts(int limit) {
        return alertRepository.findRecent(limit);
    }

    public List<Alert> getUnacknowledgedAlerts() {
        return alertRepository.findUnacknowledged();
    }

    public void acknowledgeAlert(Long id) {
        alertRepository.acknowledge(id);
    }
}
