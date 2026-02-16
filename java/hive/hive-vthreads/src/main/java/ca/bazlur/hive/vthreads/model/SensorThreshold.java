package ca.bazlur.hive.vthreads.model;

public record SensorThreshold(
        Long id,
        String sensorId,
        double minTemp,
        double maxTemp,
        double maxOutdoorDelta
) {
    public static SensorThreshold defaults(String sensorId) {
        return new SensorThreshold(null, sensorId, 15.0, 30.0, 10.0);
    }

    public static SensorThreshold defaultThreshold(String sensorId) {
        return defaults(sensorId);
    }
}
