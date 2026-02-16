package ca.bazlur.hive.reactive.repository;

import ca.bazlur.hive.reactive.model.Alert;
import ca.bazlur.hive.reactive.model.AlertType;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;

@Repository
public class AlertRepository {
    private final DatabaseClient databaseClient;

    public AlertRepository(DatabaseClient databaseClient) {
        this.databaseClient = databaseClient;
    }

    public Mono<Alert> save(Alert alert) {
        return databaseClient.sql("""
                        INSERT INTO alerts (sensor_id, alert_type, actual_value, threshold_value, outdoor_temp, triggered_at, acknowledged)
                        VALUES (:sensorId, :alertType, :actualValue, :thresholdValue, :outdoorTemp, :triggeredAt, :acknowledged)
                        RETURNING id
                        """)
                .bind("sensorId", alert.sensorId())
                .bind("alertType", alert.alertType().name())
                .bind("actualValue", alert.actualValue())
                .bind("thresholdValue", alert.thresholdValue())
                .bind("outdoorTemp", alert.outdoorTemp() != null ? alert.outdoorTemp() : 0.0)
                .bind("triggeredAt", alert.triggeredAt())
                .bind("acknowledged", alert.acknowledged())
                .map((row, metadata) -> alert.withId(row.get("id", Long.class)))
                .one();
    }

    public Flux<Alert> findRecent(int limit) {
        return databaseClient.sql("""
                        SELECT id, sensor_id, alert_type, actual_value, threshold_value, outdoor_temp, triggered_at, acknowledged
                        FROM alerts
                        ORDER BY triggered_at DESC
                        LIMIT :limit
                        """)
                .bind("limit", limit)
                .map((row, metadata) -> new Alert(
                        row.get("id", Long.class),
                        row.get("sensor_id", String.class),
                        AlertType.valueOf(row.get("alert_type", String.class)),
                        row.get("actual_value", Double.class),
                        row.get("threshold_value", Double.class),
                        row.get("outdoor_temp", Double.class),
                        row.get("triggered_at", Instant.class),
                        row.get("acknowledged", Boolean.class)
                ))
                .all();
    }

    public Flux<Alert> findUnacknowledged() {
        return databaseClient.sql("""
                        SELECT id, sensor_id, alert_type, actual_value, threshold_value, outdoor_temp, triggered_at, acknowledged
                        FROM alerts
                        WHERE acknowledged = false
                        ORDER BY triggered_at DESC
                        """)
                .map((row, metadata) -> new Alert(
                        row.get("id", Long.class),
                        row.get("sensor_id", String.class),
                        AlertType.valueOf(row.get("alert_type", String.class)),
                        row.get("actual_value", Double.class),
                        row.get("threshold_value", Double.class),
                        row.get("outdoor_temp", Double.class),
                        row.get("triggered_at", Instant.class),
                        row.get("acknowledged", Boolean.class)
                ))
                .all();
    }

    public Mono<Void> acknowledge(Long id) {
        return databaseClient.sql("""
                        UPDATE alerts SET acknowledged = true WHERE id = :id
                        """)
                .bind("id", id)
                .then();
    }
}
