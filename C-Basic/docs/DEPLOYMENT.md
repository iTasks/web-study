# Deployment Guide

This guide covers deploying C-Basic applications to production environments.

## Development Workflow

1. **Develop on Linux PC** - Write and test code
2. **Cross-compile** - Build for target platform
3. **Test on target** - Deploy and verify
4. **Automate** - Set up systemd services
5. **Monitor** - Implement logging and telemetry

## Cross-Compilation

### For Raspberry Pi (from x86_64 Linux)

```bash
# Install cross-compiler
sudo apt-get install gcc-arm-linux-gnueabihf

# Cross-compile
arm-linux-gnueabihf-gcc -o program program.c \
    -I./include \
    -lm -lpthread

# Copy to Raspberry Pi
scp program pi@raspberrypi.local:~/
```

### For Arduino

```bash
# Compile
avr-gcc -mmcu=atmega328p -DF_CPU=16000000UL \
    -Os -o program.elf program.c
    
# Create hex file
avr-objcopy -O ihex -R .eeprom program.elf program.hex

# Flash
avrdude -c arduino -p atmega328p \
    -P /dev/ttyUSB0 -b 115200 \
    -U flash:w:program.hex
```

## Systemd Service Setup

Create a systemd service for automatic startup on Raspberry Pi/Linux.

### Service File

Create `/etc/systemd/system/solar-monitor.service`:

```ini
[Unit]
Description=Solar Power Monitoring System
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/home/pi/C-Basic
ExecStart=/home/pi/C-Basic/bin/solar_monitor
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### Enable and Start

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service (start on boot)
sudo systemctl enable solar-monitor.service

# Start service now
sudo systemctl start solar-monitor.service

# Check status
sudo systemctl status solar-monitor.service

# View logs
sudo journalctl -u solar-monitor.service -f
```

## Production Hardening

### 1. Error Handling

Add comprehensive error handling:

```c
int result = sensor_init();
if (result != 0) {
    syslog(LOG_ERR, "Failed to initialize sensor: %d", result);
    // Implement retry logic or fail gracefully
    return -1;
}
```

### 2. Logging

Use syslog for production logging:

```c
#include <syslog.h>

openlog("solar-monitor", LOG_PID | LOG_CONS, LOG_USER);
syslog(LOG_INFO, "Solar monitor started");
syslog(LOG_WARNING, "Low voltage detected: %.2fV", voltage);
closelog();
```

### 3. Watchdog

Implement watchdog to recover from crashes:

```c
#include <systemd/sd-daemon.h>

while (running) {
    // Do work
    process_data();
    
    // Notify systemd watchdog
    sd_notify(0, "WATCHDOG=1");
    
    sleep(1);
}
```

Update service file:

```ini
[Service]
WatchdogSec=30
```

### 4. Resource Limits

Prevent resource exhaustion:

```ini
[Service]
MemoryLimit=100M
CPUQuota=50%
```

### 5. Security

Run with minimal privileges:

```bash
# Create dedicated user
sudo useradd -r -s /bin/false solarmon

# Set file permissions
sudo chown -R solarmon:solarmon /home/pi/C-Basic
```

Update service:

```ini
[Service]
User=solarmon
Group=solarmon
```

## Data Persistence

### CSV Logging

Implement log rotation:

```bash
# Install logrotate config
sudo nano /etc/logrotate.d/solar-monitor
```

```
/home/pi/C-Basic/logs/*.csv {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0644 solarmon solarmon
}
```

### Database Integration

For large-scale deployments, use SQLite or InfluxDB:

```c
#include <sqlite3.h>

sqlite3 *db;
sqlite3_open("/var/lib/solar/data.db", &db);

char *sql = "INSERT INTO readings (timestamp, voltage, current, power) "
            "VALUES (?, ?, ?, ?)";
sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
sqlite3_bind_int(stmt, 1, timestamp);
sqlite3_bind_double(stmt, 2, voltage);
// ... etc
sqlite3_step(stmt);
```

## Remote Monitoring

### MQTT Integration

Publish data to MQTT broker:

```c
#include <mosquitto.h>

struct mosquitto *mosq = mosquitto_new(NULL, true, NULL);
mosquitto_connect(mosq, "mqtt.example.com", 1883, 60);

char payload[256];
snprintf(payload, sizeof(payload), 
         "{\"voltage\":%.2f,\"current\":%.2f,\"power\":%.2f}",
         voltage, current, power);
         
mosquitto_publish(mosq, NULL, "solar/readings", 
                 strlen(payload), payload, 0, false);
```

### Web Interface

Create a simple web server:

```c
#include <microhttpd.h>

// Serve current readings as JSON
int answer_request(void *cls, struct MHD_Connection *connection,
                  const char *url, const char *method) {
    char json[512];
    snprintf(json, sizeof(json),
            "{\"voltage\":%.2f,\"current\":%.2f,\"power\":%.2f}",
            current_voltage, current_current, current_power);
            
    struct MHD_Response *response = 
        MHD_create_response_from_buffer(strlen(json), json,
                                       MHD_RESPMEM_MUST_COPY);
    int ret = MHD_queue_response(connection, MHD_HTTP_OK, response);
    MHD_destroy_response(response);
    return ret;
}
```

## Performance Optimization

### 1. Minimize System Calls

Batch operations when possible:

```c
// Bad: Multiple reads
for (int i = 0; i < 100; i++) {
    read_sensor();
}

// Good: Batch read
read_sensor_batch(readings, 100);
```

### 2. Use Efficient Data Structures

```c
// Use fixed-size arrays instead of dynamic allocation
#define MAX_READINGS 1000
reading_t readings[MAX_READINGS];

// Use ring buffer for continuous data
typedef struct {
    reading_t data[MAX_READINGS];
    int head;
    int tail;
} ring_buffer_t;
```

### 3. CPU Affinity

Pin critical tasks to specific cores:

```c
#include <sched.h>

cpu_set_t cpuset;
CPU_ZERO(&cpuset);
CPU_SET(2, &cpuset);  // Use core 2
pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);
```

## Monitoring and Maintenance

### Health Checks

Implement health check endpoint:

```c
int check_health(void) {
    if (sensor_last_read_age() > 60) {
        return -1;  // Sensor stale
    }
    if (battery_voltage < 10.0f) {
        return -1;  // Low battery
    }
    return 0;  // OK
}
```

### Metrics Collection

Export metrics for Prometheus:

```
# HELP solar_voltage_volts Current solar panel voltage
# TYPE solar_voltage_volts gauge
solar_voltage_volts 18.5

# HELP solar_power_watts Current solar panel power output
# TYPE solar_power_watts gauge
solar_power_watts 92.5
```

### Automated Testing

Set up continuous integration:

```bash
#!/bin/bash
# test.sh

make clean
make all

# Run unit tests
./tests/test_hal
./tests/test_energy

# Integration tests
timeout 10 ./bin/solar_monitor &
sleep 5
kill %1

echo "Tests passed"
```

## Backup and Recovery

### Configuration Backup

```bash
# Backup config files
tar -czf config-backup.tar.gz /etc/systemd/system/solar-*.service

# Restore
tar -xzf config-backup.tar.gz -C /
```

### Data Backup

```bash
# Daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d)
rsync -av /home/pi/C-Basic/logs/ /backup/logs-$DATE/
```

## Troubleshooting

### Common Issues

**GPIO Permission Denied**
```bash
sudo usermod -a -G gpio $USER
# Or run with sudo
```

**I2C Device Not Found**
```bash
# List I2C devices
i2cdetect -y 1

# Enable I2C
sudo raspi-config
```

**High CPU Usage**
```bash
# Check process
top -p $(pgrep solar_monitor)

# Profile with perf
perf record -g ./bin/solar_monitor
perf report
```

### Debug Build

```bash
# Compile with debug symbols
make CFLAGS="-g -O0 -Wall -Wextra"

# Run with gdb
gdb ./bin/solar_monitor
```

## Update Strategy

### Rolling Updates

1. Deploy new version to `/opt/app-new`
2. Test with separate service
3. Switch symlink: `ln -sf /opt/app-new /opt/app`
4. Restart service
5. Monitor for issues
6. Rollback if needed: `ln -sf /opt/app-old /opt/app`

### Over-The-Air Updates

For remote devices:

```bash
# On server
scp new_binary pi@device.local:/tmp/
ssh pi@device.local 'sudo systemctl stop solar-monitor && \
                      sudo mv /tmp/new_binary /usr/local/bin/solar_monitor && \
                      sudo systemctl start solar-monitor'
```
