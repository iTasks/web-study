package ca.bazlur.hive.reactive.repository;

import ca.bazlur.hive.reactive.model.ReadingDetails;
import ca.bazlur.hive.reactive.model.TemperatureReading;
import ca.bazlur.hive.reactive.model.WeatherData;
import io.r2dbc.spi.Row;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;

@Repository
public class ReadingRepository {

    private static final String READING_DETAILS_COLUMNS = """
            sensor_id, 
            temperature, 
            reading_time,
            outdoor_temperature, 
            humidity, wind_speed,
            weather_location, 
            weather_fetched_at, 
            weather_available
            """;

    private static final String INSERT_READING = """
        //language=SQL
        INSERT INTO readings (
            sensor_id,
            temperature,
            reading_time,
            outdoor_temperature,
            humidity,
            wind_speed,
            weather_location,
            weather_fetched_at,
            weather_available
        )
        VALUES (
            :sensorId,
            :temperature,
            :readingTime,
            :outdoorTemperature,
            :humidity,
            :windSpeed,
            :weatherLocation,
            :weatherFetchedAt,
            :weatherAvailable
        )
        """;

    private final DatabaseClient databaseClient;
    private final boolean demoDbError;

    public ReadingRepository(
            DatabaseClient databaseClient,
            @Value("${hive.demo.db-error:false}") boolean demoDbError
    ) {
        this.databaseClient = databaseClient;
        this.demoDbError = demoDbError;
    }

    public Mono<Void> save(TemperatureReading reading, WeatherData weather) {
        String insertSql = demoDbError
                ? INSERT_READING.replace("reading_time", "reading_time_broken")
                : INSERT_READING;
        return databaseClient.sql(insertSql)
            .bind("sensorId", reading.sensorId())
            .bind("temperature", reading.temperature())
            .bind("readingTime", reading.timestamp())
            .bind("outdoorTemperature", weather.temperature())
            .bind("humidity", weather.humidity())
            .bind("windSpeed", weather.windSpeed())
            .bind("weatherLocation", weather.location())
            .bind("weatherFetchedAt", weather.fetchedAt())
            .bind("weatherAvailable", weather.available())
            .fetch()
            .rowsUpdated()
            .then();
    }

    public Mono<ReadingDetails> latest(String sensorId) {
        if (sensorId == null || sensorId.isBlank()) {
            return Mono.error(new IllegalArgumentException("sensorId must not be blank"));
        }

        return databaseClient.sql("""
                        SELECT %s
                        FROM readings
                        WHERE sensor_id = :sensorId
                        ORDER BY reading_time DESC
                        LIMIT 1
                        """.formatted(READING_DETAILS_COLUMNS))
            .bind("sensorId", sensorId)
            .map((row, _) -> toReadingDetails(row))
            .one();
    }

    public Flux<ReadingDetails> history(String sensorId) {
        var base = """
                SELECT %s
                FROM readings
                """.formatted(READING_DETAILS_COLUMNS);

        if (sensorId == null || sensorId.isBlank()) {
            return databaseClient.sql(base + "ORDER BY reading_time DESC")
                .map((row, _) -> toReadingDetails(row))
                .all();
        }

        return databaseClient.sql(base + """
                        WHERE sensor_id = :sensorId
                        ORDER BY reading_time DESC
                        """)
            .bind("sensorId", sensorId)
            .map((row, _) -> toReadingDetails(row))
            .all();
    }

    public Flux<TemperatureReading> latestTemperatures() {
        return databaseClient.sql("""
                        SELECT DISTINCT ON (sensor_id) sensor_id, temperature, reading_time
                        FROM readings
                        ORDER BY sensor_id, reading_time DESC
                        """)
            .map((row, _) -> new TemperatureReading(
                row.get("sensor_id", String.class),
                row.get("temperature", Double.class),
                row.get("reading_time", Instant.class)
            ))
            .all();
    }

    private static ReadingDetails toReadingDetails(Row row) {
        return new ReadingDetails(
            row.get("sensor_id", String.class),
            row.get("temperature", Double.class),
            row.get("reading_time", Instant.class),
            row.get("outdoor_temperature", Double.class),
            row.get("humidity", Double.class),
            row.get("wind_speed", Double.class),
            row.get("weather_location", String.class),
            row.get("weather_fetched_at", Instant.class),
            Boolean.TRUE.equals(row.get("weather_available", Boolean.class))
        );
    }
}
