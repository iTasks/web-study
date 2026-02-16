package ca.bazlur.hive.reactive.repository;

import ca.bazlur.hive.reactive.model.HourlyStat;
import ca.bazlur.hive.reactive.model.SensorAggregate;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;

@Repository
public class AggregationRepository {
    private final DatabaseClient databaseClient;

    public AggregationRepository(DatabaseClient databaseClient) {
        this.databaseClient = databaseClient;
    }

    public Mono<SensorAggregate> calculateRollingAggregate(String sensorId, int windowMinutes) {
        return databaseClient.sql("""
                        SELECT sensor_id,
                               AVG(temperature) as avg_temp,
                               MIN(temperature) as min_temp,
                               MAX(temperature) as max_temp,
                               COUNT(*) as reading_count
                        FROM readings
                        WHERE sensor_id = :sensorId
                          AND reading_time > NOW() - INTERVAL '%d minutes'
                        GROUP BY sensor_id
                        """.formatted(windowMinutes))
                .bind("sensorId", sensorId)
                .map((row, metadata) -> new SensorAggregate(
                        row.get("sensor_id", String.class),
                        row.get("avg_temp", Double.class),
                        row.get("min_temp", Double.class),
                        row.get("max_temp", Double.class),
                        row.get("reading_count", Long.class).intValue(),
                        Instant.now()
                ))
                .one()
                .switchIfEmpty(Mono.just(SensorAggregate.empty(sensorId)));
    }

    public Flux<SensorAggregate> calculateAllRollingAggregates(int windowMinutes) {
        return databaseClient.sql("""
                        SELECT sensor_id,
                               AVG(temperature) as avg_temp,
                               MIN(temperature) as min_temp,
                               MAX(temperature) as max_temp,
                               COUNT(*) as reading_count
                        FROM readings
                        WHERE reading_time > NOW() - INTERVAL '%d minutes'
                        GROUP BY sensor_id
                        """.formatted(windowMinutes))
                .map((row, metadata) -> new SensorAggregate(
                        row.get("sensor_id", String.class),
                        row.get("avg_temp", Double.class),
                        row.get("min_temp", Double.class),
                        row.get("max_temp", Double.class),
                        row.get("reading_count", Long.class).intValue(),
                        Instant.now()
                ))
                .all();
    }

    public Mono<Void> saveHourlyStat(HourlyStat stat) {
        return databaseClient.sql("""
                        INSERT INTO hourly_stats (sensor_id, hour_start, avg_temp, min_temp, max_temp, reading_count)
                        VALUES (:sensorId, :hourStart, :avgTemp, :minTemp, :maxTemp, :readingCount)
                        ON CONFLICT (sensor_id, hour_start) DO UPDATE SET
                            avg_temp = :avgTemp,
                            min_temp = :minTemp,
                            max_temp = :maxTemp,
                            reading_count = :readingCount
                        """)
                .bind("sensorId", stat.sensorId())
                .bind("hourStart", stat.hourStart())
                .bind("avgTemp", stat.avgTemp())
                .bind("minTemp", stat.minTemp())
                .bind("maxTemp", stat.maxTemp())
                .bind("readingCount", stat.readingCount())
                .then();
    }

    public Flux<HourlyStat> findHourlyStats(String sensorId, int hours) {
        return databaseClient.sql("""
                        SELECT id, sensor_id, hour_start, avg_temp, min_temp, max_temp, reading_count
                        FROM hourly_stats
                        WHERE sensor_id = :sensorId
                          AND hour_start > NOW() - INTERVAL '%d hours'
                        ORDER BY hour_start DESC
                        """.formatted(hours))
                .bind("sensorId", sensorId)
                .map((row, metadata) -> new HourlyStat(
                        row.get("id", Long.class),
                        row.get("sensor_id", String.class),
                        row.get("hour_start", Instant.class),
                        row.get("avg_temp", Double.class),
                        row.get("min_temp", Double.class),
                        row.get("max_temp", Double.class),
                        row.get("reading_count", Integer.class)
                ))
                .all();
    }
}
