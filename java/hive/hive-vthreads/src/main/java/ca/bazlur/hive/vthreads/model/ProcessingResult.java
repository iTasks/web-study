package ca.bazlur.hive.vthreads.model;

import java.util.Optional;

public record ProcessingResult(
        TemperatureReading reading,
        WeatherData weather,
        double deltaFromOutdoor,
        Optional<Alert> triggeredAlert
) {
    public ProcessingResult(TemperatureReading reading, WeatherData weather, double deltaFromOutdoor) {
        this(reading, weather, deltaFromOutdoor, Optional.empty());
    }

    public static ProcessingResult failed(TemperatureReading reading, Throwable e) {
        return new ProcessingResult(reading, WeatherData.unavailable(), 0.0, Optional.empty());
    }

    public ProcessingResult withAlert(Alert alert) {
        return new ProcessingResult(reading, weather, deltaFromOutdoor, Optional.of(alert));
    }
}
