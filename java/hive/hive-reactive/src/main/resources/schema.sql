CREATE TABLE IF NOT EXISTS readings (
    id BIGSERIAL PRIMARY KEY,
    sensor_id TEXT NOT NULL,
    temperature DOUBLE PRECISION NOT NULL,
    reading_time TIMESTAMPTZ NOT NULL,
    outdoor_temperature DOUBLE PRECISION,
    humidity DOUBLE PRECISION,
    wind_speed DOUBLE PRECISION,
    weather_location TEXT,
    weather_fetched_at TIMESTAMPTZ,
    weather_available BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS readings_sensor_ts_idx
    ON readings (sensor_id, reading_time DESC);

-- Sensor Thresholds for alert configuration
CREATE TABLE IF NOT EXISTS sensor_thresholds (
    id BIGSERIAL PRIMARY KEY,
    sensor_id TEXT UNIQUE NOT NULL,
    min_temp DOUBLE PRECISION NOT NULL DEFAULT 15.0,
    max_temp DOUBLE PRECISION NOT NULL DEFAULT 30.0,
    max_outdoor_delta DOUBLE PRECISION NOT NULL DEFAULT 10.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Alerts triggered by threshold violations
CREATE TABLE IF NOT EXISTS alerts (
    id BIGSERIAL PRIMARY KEY,
    sensor_id TEXT NOT NULL,
    alert_type TEXT NOT NULL,
    actual_value DOUBLE PRECISION NOT NULL,
    threshold_value DOUBLE PRECISION NOT NULL,
    outdoor_temp DOUBLE PRECISION,
    triggered_at TIMESTAMPTZ NOT NULL,
    acknowledged BOOLEAN DEFAULT FALSE,
    acknowledged_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS alerts_sensor_time_idx
    ON alerts (sensor_id, triggered_at DESC);

CREATE INDEX IF NOT EXISTS alerts_unacknowledged_idx
    ON alerts (acknowledged, triggered_at DESC) WHERE NOT acknowledged;

-- Hourly aggregated statistics
CREATE TABLE IF NOT EXISTS hourly_stats (
    id BIGSERIAL PRIMARY KEY,
    sensor_id TEXT NOT NULL,
    hour_start TIMESTAMPTZ NOT NULL,
    avg_temp DOUBLE PRECISION NOT NULL,
    min_temp DOUBLE PRECISION NOT NULL,
    max_temp DOUBLE PRECISION NOT NULL,
    reading_count INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(sensor_id, hour_start)
);

CREATE INDEX IF NOT EXISTS hourly_stats_sensor_hour_idx
    ON hourly_stats (sensor_id, hour_start DESC);

-- Insert default thresholds for demo sensors
INSERT INTO sensor_thresholds (sensor_id, min_temp, max_temp, max_outdoor_delta)
VALUES
    ('t-1', 18.0, 28.0, 8.0),
    ('t-2', 16.0, 26.0, 10.0),
    ('t-3', 20.0, 30.0, 12.0),
    ('t-4', 15.0, 25.0, 8.0),
    ('t-5', 18.0, 28.0, 10.0),
    ('t-6', 17.0, 27.0, 9.0)
ON CONFLICT (sensor_id) DO NOTHING;
