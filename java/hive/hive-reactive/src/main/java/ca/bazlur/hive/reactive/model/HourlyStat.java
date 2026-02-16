package ca.bazlur.hive.reactive.model;

import java.time.Instant;

public record HourlyStat(
        Long id,
        String sensorId,
        Instant hourStart,
        double avgTemp,
        double minTemp,
        double maxTemp,
        int readingCount
) {
    public HourlyStat(String sensorId, Instant hourStart, double avgTemp,
                      double minTemp, double maxTemp, int readingCount) {
        this(null, sensorId, hourStart, avgTemp, minTemp, maxTemp, readingCount);
    }
}
