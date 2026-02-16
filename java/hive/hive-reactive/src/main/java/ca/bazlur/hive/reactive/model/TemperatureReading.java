package ca.bazlur.hive.reactive.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;

public record TemperatureReading(
        @NotBlank String sensorId,
        @NotNull Double temperature,
        @NotNull Instant timestamp
) {
}
