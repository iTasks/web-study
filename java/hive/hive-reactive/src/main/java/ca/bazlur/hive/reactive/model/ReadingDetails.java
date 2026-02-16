package ca.bazlur.hive.reactive.model;

import java.time.Instant;

public record ReadingDetails(
        String sensorId,
        double temperature,
        Instant timestamp,
        double outdoorTemperature,
        double humidity,
        double windSpeed,
        String weatherLocation,
        Instant weatherFetchedAt,
        boolean weatherAvailable
) {
}
