package ca.bazlur.hive.vthreads.model;

import java.time.Instant;

public record BuildingStatus(
        int sensorCount,
        double minTemperature,
        double maxTemperature,
        double avgTemperature,
        Instant updatedAt
) {
}
