package ca.bazlur.hive.reactive.repository;

import ca.bazlur.hive.reactive.model.SensorThreshold;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

@Repository
public class ThresholdRepository {
    private final DatabaseClient databaseClient;

    public ThresholdRepository(DatabaseClient databaseClient) {
        this.databaseClient = databaseClient;
    }

    public Mono<SensorThreshold> findBySensorId(String sensorId) {
        return databaseClient.sql("""
                        SELECT id, sensor_id, min_temp, max_temp, max_outdoor_delta
                        FROM sensor_thresholds
                        WHERE sensor_id = :sensorId
                        """)
                .bind("sensorId", sensorId)
                .map((row, metadata) -> new SensorThreshold(
                        row.get("id", Long.class),
                        row.get("sensor_id", String.class),
                        row.get("min_temp", Double.class),
                        row.get("max_temp", Double.class),
                        row.get("max_outdoor_delta", Double.class)
                ))
                .one()
                .switchIfEmpty(Mono.just(SensorThreshold.defaultThreshold(sensorId)));
    }

    public Mono<Void> save(SensorThreshold threshold) {
        return databaseClient.sql("""
                        INSERT INTO sensor_thresholds (sensor_id, min_temp, max_temp, max_outdoor_delta)
                        VALUES (:sensorId, :minTemp, :maxTemp, :maxOutdoorDelta)
                        ON CONFLICT (sensor_id) DO UPDATE SET
                            min_temp = :minTemp,
                            max_temp = :maxTemp,
                            max_outdoor_delta = :maxOutdoorDelta
                        """)
                .bind("sensorId", threshold.sensorId())
                .bind("minTemp", threshold.minTemp())
                .bind("maxTemp", threshold.maxTemp())
                .bind("maxOutdoorDelta", threshold.maxOutdoorDelta())
                .then();
    }
}
