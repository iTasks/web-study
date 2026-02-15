package ca.bazlur.hive.reactive.model;

import java.time.Instant;

public record BuildingStatus(
        int sensorCount,
        double minTemperature,
        double maxTemperature,
        double avgTemperature,
        Instant updatedAt
) {
}
