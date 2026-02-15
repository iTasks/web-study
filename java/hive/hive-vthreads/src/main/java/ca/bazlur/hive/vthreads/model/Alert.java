package ca.bazlur.hive.vthreads.model;

import java.time.Instant;

public record Alert(
        Long id,
        String sensorId,
        AlertType alertType,
        double actualValue,
        double thresholdValue,
        Double outdoorTemp,
        Instant triggeredAt,
        boolean acknowledged
) {
    public Alert(String sensorId, AlertType alertType, double actualValue,
                 double thresholdValue, Double outdoorTemp, Instant triggeredAt) {
        this(null, sensorId, alertType, actualValue, thresholdValue,
             outdoorTemp, triggeredAt, false);
    }

    public Alert withId(Long newId) {
        return new Alert(newId, sensorId, alertType, actualValue, thresholdValue,
                outdoorTemp, triggeredAt, acknowledged);
    }
}
