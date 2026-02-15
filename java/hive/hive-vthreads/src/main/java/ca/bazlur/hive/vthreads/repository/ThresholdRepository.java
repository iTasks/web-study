package ca.bazlur.hive.vthreads.repository;

import ca.bazlur.hive.vthreads.model.SensorThreshold;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class ThresholdRepository {
    private final JdbcTemplate jdbcTemplate;

    public ThresholdRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public SensorThreshold findBySensorId(String sensorId) {
        List<SensorThreshold> results = jdbcTemplate.query("""
                        SELECT id, sensor_id, min_temp, max_temp, max_outdoor_delta
                        FROM sensor_thresholds
                        WHERE sensor_id = ?
                        """,
                thresholdRowMapper(),
                sensorId);
        return results.isEmpty() ? SensorThreshold.defaultThreshold(sensorId) : results.getFirst();
    }

    public void save(SensorThreshold threshold) {
        jdbcTemplate.update("""
                        INSERT INTO sensor_thresholds (sensor_id, min_temp, max_temp, max_outdoor_delta)
                        VALUES (?, ?, ?, ?)
                        ON CONFLICT (sensor_id) DO UPDATE SET
                            min_temp = EXCLUDED.min_temp,
                            max_temp = EXCLUDED.max_temp,
                            max_outdoor_delta = EXCLUDED.max_outdoor_delta
                        """,
                threshold.sensorId(),
                threshold.minTemp(),
                threshold.maxTemp(),
                threshold.maxOutdoorDelta());
    }

    private RowMapper<SensorThreshold> thresholdRowMapper() {
        return (rs, rowNum) -> new SensorThreshold(
                rs.getLong("id"),
                rs.getString("sensor_id"),
                rs.getDouble("min_temp"),
                rs.getDouble("max_temp"),
                rs.getDouble("max_outdoor_delta")
        );
    }
}
