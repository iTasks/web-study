package ca.bazlur.hive.reactive.model;

import java.time.Instant;

public record WeatherData(
        double temperature,
        double humidity,
        double windSpeed,
        String location,
        Instant fetchedAt,
        boolean available
) {
    public WeatherData(double temperature, double humidity, double windSpeed, String location, Instant fetchedAt) {
        this(temperature, humidity, windSpeed, location, fetchedAt, true);
    }

    public static WeatherData unavailable() {
        return new WeatherData(0.0, 0.0, 0.0, "unknown", Instant.now(), false);
    }

    public static WeatherData unavailable(String location) {
        return new WeatherData(0.0, 0.0, 0.0, location, Instant.now(), false);
    }
}
