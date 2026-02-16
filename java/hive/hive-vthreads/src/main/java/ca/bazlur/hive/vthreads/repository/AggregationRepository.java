package ca.bazlur.hive.vthreads.repository;

import ca.bazlur.hive.vthreads.model.HourlyStat;
import ca.bazlur.hive.vthreads.model.SensorAggregate;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;

@Repository
public class AggregationRepository {
    private final JdbcTemplate jdbcTemplate;

    public AggregationRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public SensorAggregate calculateRollingAggregate(String sensorId, int windowMinutes) {
        List<SensorAggregate> results = jdbcTemplate.query("""
                        SELECT sensor_id,
                               AVG(temperature) as avg_temp,
                               MIN(temperature) as min_temp,
                               MAX(temperature) as max_temp,
                               COUNT(*) as reading_count
                        FROM readings
                        WHERE sensor_id = ?
                          AND reading_time > NOW() - INTERVAL '%d minutes'
                        GROUP BY sensor_id
                        """.formatted(windowMinutes),
                aggregateRowMapper(),
                sensorId);
        return results.isEmpty() ? SensorAggregate.empty(sensorId) : results.getFirst();
    }

    public List<SensorAggregate> calculateAllRollingAggregates(int windowMinutes) {
        return jdbcTemplate.query("""
                        SELECT sensor_id,
                               AVG(temperature) as avg_temp,
                               MIN(temperature) as min_temp,
                               MAX(temperature) as max_temp,
                               COUNT(*) as reading_count
                        FROM readings
                        WHERE reading_time > NOW() - INTERVAL '%d minutes'
                        GROUP BY sensor_id
                        """.formatted(windowMinutes),
                aggregateRowMapper());
    }

    public void saveHourlyStat(HourlyStat stat) {
        jdbcTemplate.update("""
                        INSERT INTO hourly_stats (sensor_id, hour_start, avg_temp, min_temp, max_temp, reading_count)
                        VALUES (?, ?, ?, ?, ?, ?)
                        ON CONFLICT (sensor_id, hour_start) DO UPDATE SET
                            avg_temp = EXCLUDED.avg_temp,
                            min_temp = EXCLUDED.min_temp,
                            max_temp = EXCLUDED.max_temp,
                            reading_count = EXCLUDED.reading_count
                        """,
                stat.sensorId(),
                Timestamp.from(stat.hourStart()),
                stat.avgTemp(),
                stat.minTemp(),
                stat.maxTemp(),
                stat.readingCount());
    }

    public List<HourlyStat> findHourlyStats(String sensorId, int hours) {
        return jdbcTemplate.query("""
                        SELECT id, sensor_id, hour_start, avg_temp, min_temp, max_temp, reading_count
                        FROM hourly_stats
                        WHERE sensor_id = ?
                          AND hour_start > NOW() - INTERVAL '%d hours'
                        ORDER BY hour_start DESC
                        """.formatted(hours),
                hourlyStatRowMapper(),
                sensorId);
    }

    private RowMapper<SensorAggregate> aggregateRowMapper() {
        return (rs, rowNum) -> new SensorAggregate(
                rs.getString("sensor_id"),
                rs.getDouble("avg_temp"),
                rs.getDouble("min_temp"),
                rs.getDouble("max_temp"),
                rs.getInt("reading_count"),
                Instant.now()
        );
    }

    private RowMapper<HourlyStat> hourlyStatRowMapper() {
        return (rs, rowNum) -> new HourlyStat(
                rs.getLong("id"),
                rs.getString("sensor_id"),
                rs.getTimestamp("hour_start").toInstant(),
                rs.getDouble("avg_temp"),
                rs.getDouble("min_temp"),
                rs.getDouble("max_temp"),
                rs.getInt("reading_count")
        );
    }
}
