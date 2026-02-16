package ca.bazlur.hive.vthreads.model;

import java.time.Instant;

public record SensorAggregate(
        String sensorId,
        double avgTemp,
        double minTemp,
        double maxTemp,
        int readingCount,
        Instant calculatedAt
) {
    public static SensorAggregate empty(String sensorId) {
        return new SensorAggregate(sensorId, 0.0, 0.0, 0.0, 0, Instant.now());
    }
}
