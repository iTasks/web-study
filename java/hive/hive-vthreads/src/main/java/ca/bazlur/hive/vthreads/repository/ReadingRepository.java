package ca.bazlur.hive.vthreads.repository;

import ca.bazlur.hive.vthreads.model.ReadingDetails;
import ca.bazlur.hive.vthreads.model.TemperatureReading;
import ca.bazlur.hive.vthreads.model.WeatherData;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;

@Repository
public class ReadingRepository {
    private final JdbcTemplate jdbcTemplate;
    private final boolean demoDbError;

    public ReadingRepository(
            JdbcTemplate jdbcTemplate,
            @Value("${hive.demo.db-error:false}") boolean demoDbError
    ) {
        this.jdbcTemplate = jdbcTemplate;
        this.demoDbError = demoDbError;
    }

    public void save(TemperatureReading reading, WeatherData weather) {
        String insertSql = demoDbError
                ? """
                        INSERT INTO readings (
                            sensor_id,
                            temperature,
                            reading_time_broken,
                            outdoor_temperature,
                            humidity,
                            wind_speed,
                            weather_location,
                            weather_fetched_at,
                            weather_available
                        )
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """
                : """
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
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """;
        jdbcTemplate.update(insertSql,
                reading.sensorId(),
                reading.temperature(),
                Timestamp.from(reading.timestamp()),
                weather.temperature(),
                weather.humidity(),
                weather.windSpeed(),
                weather.location(),
                Timestamp.from(weather.fetchedAt()),
                weather.available());
    }

    public ReadingDetails latest(String sensorId) {
        List<ReadingDetails> result = jdbcTemplate.query("""
                        SELECT sensor_id, temperature, reading_time,
                               outdoor_temperature, humidity, wind_speed,
                               weather_location, weather_fetched_at, weather_available
                        FROM readings
                        WHERE sensor_id = ?
                        ORDER BY reading_time DESC
                        LIMIT 1
                        """,
                readingDetailsRowMapper(),
                sensorId);
        return result.isEmpty() ? null : result.getFirst();
    }

    public List<ReadingDetails> history(String sensorId) {
        if (sensorId == null || sensorId.isBlank()) {
            return jdbcTemplate.query("""
                            SELECT sensor_id, temperature, reading_time,
                                   outdoor_temperature, humidity, wind_speed,
                                   weather_location, weather_fetched_at, weather_available
                            FROM readings
                            ORDER BY reading_time DESC
                            """,
                    readingDetailsRowMapper());
        }
        return jdbcTemplate.query("""
                        SELECT sensor_id, temperature, reading_time,
                               outdoor_temperature, humidity, wind_speed,
                               weather_location, weather_fetched_at, weather_available
                        FROM readings
                        WHERE sensor_id = ?
                        ORDER BY reading_time DESC
                        """,
                readingDetailsRowMapper(),
                sensorId);
    }

    public List<TemperatureReading> latestTemperatures() {
        return jdbcTemplate.query("""
                        SELECT DISTINCT ON (sensor_id) sensor_id, temperature, reading_time
                        FROM readings
                        ORDER BY sensor_id, reading_time DESC
                        """,
                readingRowMapper());
    }

    private RowMapper<TemperatureReading> readingRowMapper() {
        return (rs, rowNum) -> new TemperatureReading(
                rs.getString("sensor_id"),
                rs.getDouble("temperature"),
                rs.getTimestamp("reading_time").toInstant()
        );
    }

    private RowMapper<ReadingDetails> readingDetailsRowMapper() {
        return (rs, rowNum) -> new ReadingDetails(
                rs.getString("sensor_id"),
                rs.getDouble("temperature"),
                rs.getTimestamp("reading_time").toInstant(),
                rs.getDouble("outdoor_temperature"),
                rs.getDouble("humidity"),
                rs.getDouble("wind_speed"),
                rs.getString("weather_location"),
                rs.getTimestamp("weather_fetched_at") != null
                        ? rs.getTimestamp("weather_fetched_at").toInstant()
                        : null,
                rs.getBoolean("weather_available")
        );
    }
}
