package ca.bazlur.hive.vthreads.repository;

import ca.bazlur.hive.vthreads.model.Alert;
import ca.bazlur.hive.vthreads.model.AlertType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.List;

@Repository
public class AlertRepository {
    private final JdbcTemplate jdbcTemplate;

    public AlertRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Alert save(Alert alert) {
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement("""
                            INSERT INTO alerts (sensor_id, alert_type, actual_value, threshold_value, outdoor_temp, triggered_at, acknowledged)
                            VALUES (?, ?, ?, ?, ?, ?, ?)
                            """,
                    new String[]{"id"});  // Only return the id column
            ps.setString(1, alert.sensorId());
            ps.setString(2, alert.alertType().name());
            ps.setDouble(3, alert.actualValue());
            ps.setDouble(4, alert.thresholdValue());
            ps.setDouble(5, alert.outdoorTemp() != null ? alert.outdoorTemp() : 0.0);
            ps.setTimestamp(6, Timestamp.from(alert.triggeredAt()));
            ps.setBoolean(7, alert.acknowledged());
            return ps;
        }, keyHolder);

        Number key = keyHolder.getKey();
        return key != null ? alert.withId(key.longValue()) : alert;
    }

    public List<Alert> findRecent(int limit) {
        return jdbcTemplate.query("""
                        SELECT id, sensor_id, alert_type, actual_value, threshold_value, outdoor_temp, triggered_at, acknowledged
                        FROM alerts
                        ORDER BY triggered_at DESC
                        LIMIT ?
                        """,
                alertRowMapper(),
                limit);
    }

    public List<Alert> findUnacknowledged() {
        return jdbcTemplate.query("""
                        SELECT id, sensor_id, alert_type, actual_value, threshold_value, outdoor_temp, triggered_at, acknowledged
                        FROM alerts
                        WHERE acknowledged = false
                        ORDER BY triggered_at DESC
                        """,
                alertRowMapper());
    }

    public void acknowledge(Long id) {
        jdbcTemplate.update("UPDATE alerts SET acknowledged = true WHERE id = ?", id);
    }

    private RowMapper<Alert> alertRowMapper() {
        return (rs, rowNum) -> new Alert(
                rs.getLong("id"),
                rs.getString("sensor_id"),
                AlertType.valueOf(rs.getString("alert_type")),
                rs.getDouble("actual_value"),
                rs.getDouble("threshold_value"),
                rs.getDouble("outdoor_temp"),
                rs.getTimestamp("triggered_at").toInstant(),
                rs.getBoolean("acknowledged")
        );
    }
}
