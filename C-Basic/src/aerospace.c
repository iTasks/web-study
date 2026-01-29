#include "aerospace.h"
#include "hal.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define PI 3.14159265358979323846
#define EARTH_RADIUS_M 6371000.0

static vehicle_type_t vehicle_type;
static flight_mode_t current_mode = FLIGHT_MODE_MANUAL;
static flight_state_t current_state = FLIGHT_STATE_IDLE;
static bool is_armed = false;
static telemetry_t telemetry;
static float geofence_lat = 0.0f;
static float geofence_lon = 0.0f;
static float geofence_radius = 0.0f;

int aerospace_init(vehicle_type_t type) {
    vehicle_type = type;
    memset(&telemetry, 0, sizeof(telemetry_t));
    printf("Aerospace system initialized for vehicle type: %d\n", type);
    return 0;
}

int aerospace_deinit(void) {
    flight_control_disarm();
    return 0;
}

// Flight control
int flight_control_init(void) {
    current_mode = FLIGHT_MODE_MANUAL;
    current_state = FLIGHT_STATE_IDLE;
    is_armed = false;
    return 0;
}

int flight_control_set_mode(flight_mode_t mode) {
    printf("Flight mode changed: %d -> %d\n", current_mode, mode);
    current_mode = mode;
    return 0;
}

flight_mode_t flight_control_get_mode(void) {
    return current_mode;
}

int flight_control_arm(void) {
    // Pre-arm checks
    if (telemetry.battery_voltage < 10.0f) {
        printf("Cannot arm: Battery voltage too low\n");
        return -1;
    }
    
    if (telemetry.gps_fix < 2) {
        printf("Warning: No GPS fix\n");
    }
    
    is_armed = true;
    current_state = FLIGHT_STATE_ARMED;
    printf("Vehicle ARMED\n");
    return 0;
}

int flight_control_disarm(void) {
    is_armed = false;
    current_state = FLIGHT_STATE_IDLE;
    printf("Vehicle DISARMED\n");
    return 0;
}

bool flight_control_is_armed(void) {
    return is_armed;
}

// Telemetry
int telemetry_init(void) {
    memset(&telemetry, 0, sizeof(telemetry_t));
    telemetry.state = FLIGHT_STATE_IDLE;
    telemetry.mode = FLIGHT_MODE_MANUAL;
    return 0;
}

int telemetry_update(telemetry_t* telem) {
    if (!telem) return -1;
    
    // Update sensors
    // GPS would update lat, lon, altitude, ground_speed
    // IMU would update roll, pitch, yaw, accel
    // Barometer would update altitude, pressure
    // Battery monitor would update voltage, current
    
    telem->state = current_state;
    telem->mode = current_mode;
    telem->timestamp = hal_millis();
    
    // Copy to global telemetry
    memcpy(&telemetry, telem, sizeof(telemetry_t));
    
    return 0;
}

int telemetry_send(const telemetry_t* telem) {
    // Send telemetry via radio (e.g., LoRa, 433MHz, 2.4GHz)
    // This would format and transmit telemetry packet
    return 0;
}

int telemetry_log(const telemetry_t* telem, const char* filename) {
    FILE* f = fopen(filename, "a");
    if (!f) return -1;
    
    fprintf(f, "%u,%.6f,%.6f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%d,%d,%d,%d\n",
            telem->timestamp,
            telem->latitude, telem->longitude, telem->altitude,
            telem->roll, telem->pitch, telem->yaw,
            telem->velocity_x, telem->velocity_y, telem->velocity_z,
            telem->state, telem->mode, telem->gps_fix, telem->satellite_count);
    
    fclose(f);
    return 0;
}

// RC receiver
int rc_init(void) {
    // Initialize RC receiver (PPM, SBUS, etc.)
    printf("RC receiver initialized\n");
    return 0;
}

int rc_read(rc_input_t* input) {
    if (!input) return -1;
    
    // Read RC channels
    // This would read from RC receiver hardware
    for (int i = 0; i < 8; i++) {
        input->channel[i] = 0; // Center position
    }
    input->channel_count = 8;
    input->failsafe = false;
    
    return 0;
}

bool rc_is_connected(void) {
    // Check if RC receiver has valid signal
    return true;
}

// Control mixing
int control_mixer_init(vehicle_type_t type) {
    printf("Control mixer initialized for vehicle type: %d\n", type);
    return 0;
}

int control_mixer_update(const rc_input_t* rc, const telemetry_t* telem,
                         control_surfaces_t* surfaces, motor_outputs_t* motors) {
    if (!rc || !telem) return -1;
    
    if (vehicle_type == VEHICLE_RC_AIRCRAFT || vehicle_type == VEHICLE_FIXED_WING) {
        // Mix RC inputs to control surfaces
        if (surfaces) {
            surfaces->aileron = rc->channel[0];   // Roll
            surfaces->elevator = rc->channel[1];  // Pitch
            surfaces->throttle = rc->channel[2];  // Throttle
            surfaces->rudder = rc->channel[3];    // Yaw
        }
    } else if (vehicle_type == VEHICLE_MULTIROTOR) {
        // Mix RC inputs to motors
        if (motors) {
            int16_t throttle = rc->channel[2];
            int16_t roll = rc->channel[0];
            int16_t pitch = rc->channel[1];
            int16_t yaw = rc->channel[3];
            
            // Quadcopter X configuration
            motors->motor[0] = throttle + pitch - roll - yaw; // Front Right
            motors->motor[1] = throttle + pitch + roll + yaw; // Front Left
            motors->motor[2] = throttle - pitch + roll - yaw; // Rear Left
            motors->motor[3] = throttle - pitch - roll + yaw; // Rear Right
            motors->motor_count = 4;
            
            // Clamp motor outputs
            for (int i = 0; i < motors->motor_count; i++) {
                if (motors->motor[i] < 0) motors->motor[i] = 0;
                if (motors->motor[i] > 1000) motors->motor[i] = 1000;
            }
        }
    }
    
    return 0;
}

// Sensors
int barometer_init(uint8_t i2c_bus, uint8_t addr) {
    hal_i2c_init(i2c_bus);
    printf("Barometer initialized on I2C bus %d, addr 0x%02X\n", i2c_bus, addr);
    return 0;
}

int barometer_read(float* pressure, float* temperature) {
    // Read from barometer (e.g., BMP280, MS5611)
    if (pressure) *pressure = 101325.0f; // Sea level pressure
    if (temperature) *temperature = 20.0f;
    return 0;
}

float barometer_calculate_altitude(float pressure) {
    // Barometric formula
    const float sea_level_pressure = 101325.0f;
    return 44330.0f * (1.0f - powf(pressure / sea_level_pressure, 0.1903f));
}

int gps_init(uint8_t uart_port, uint32_t baudrate) {
    hal_uart_init(uart_port, baudrate);
    printf("GPS initialized on UART %d at %u baud\n", uart_port, baudrate);
    return 0;
}

int gps_read(float* lat, float* lon, float* alt, float* speed, uint8_t* fix) {
    // Parse NMEA sentences from GPS
    // This would read from UART and parse GPS data
    if (lat) *lat = 0.0f;
    if (lon) *lon = 0.0f;
    if (alt) *alt = 0.0f;
    if (speed) *speed = 0.0f;
    if (fix) *fix = 0;
    return 0;
}

int magnetometer_init(uint8_t i2c_bus, uint8_t addr) {
    hal_i2c_init(i2c_bus);
    printf("Magnetometer initialized on I2C bus %d, addr 0x%02X\n", i2c_bus, addr);
    return 0;
}

int magnetometer_read(float* mag_x, float* mag_y, float* mag_z) {
    // Read from magnetometer (e.g., HMC5883L, QMC5883)
    if (mag_x) *mag_x = 0.0f;
    if (mag_y) *mag_y = 0.0f;
    if (mag_z) *mag_z = 0.0f;
    return 0;
}

float magnetometer_calculate_heading(float mag_x, float mag_y, float roll, float pitch) {
    // Tilt-compensated heading calculation
    float roll_rad = roll * PI / 180.0f;
    float pitch_rad = pitch * PI / 180.0f;
    
    float mag_x_comp = mag_x * cosf(pitch_rad) + mag_y * sinf(roll_rad) * sinf(pitch_rad);
    float mag_y_comp = mag_y * cosf(roll_rad) - mag_x * sinf(roll_rad) * sinf(pitch_rad);
    
    float heading = atan2f(mag_y_comp, mag_x_comp) * 180.0f / PI;
    if (heading < 0) heading += 360.0f;
    
    return heading;
}

// Safety features
int safety_init(void) {
    printf("Safety system initialized\n");
    return 0;
}

int safety_check(const telemetry_t* telem) {
    if (!telem) return -1;
    
    // Check battery voltage
    if (telem->battery_voltage < 10.5f) {
        printf("WARNING: Low battery voltage: %.2fV\n", telem->battery_voltage);
        return -1;
    }
    
    // Check geofence
    if (geofence_radius > 0) {
        if (!safety_is_in_geofence(telem->latitude, telem->longitude)) {
            printf("WARNING: Outside geofence!\n");
            return -1;
        }
    }
    
    // Check altitude limits
    if (telem->altitude > 120.0f) { // FAA limit for hobby aircraft
        printf("WARNING: Altitude limit exceeded: %.2fm\n", telem->altitude);
        return -1;
    }
    
    return 0;
}

int safety_geofence_set(float center_lat, float center_lon, float radius_m) {
    geofence_lat = center_lat;
    geofence_lon = center_lon;
    geofence_radius = radius_m;
    printf("Geofence set: %.6f, %.6f, radius %.0fm\n", center_lat, center_lon, radius_m);
    return 0;
}

bool safety_is_in_geofence(float lat, float lon) {
    if (geofence_radius <= 0) return true;
    
    // Haversine formula to calculate distance
    float dlat = (lat - geofence_lat) * PI / 180.0f;
    float dlon = (lon - geofence_lon) * PI / 180.0f;
    
    float a = sinf(dlat / 2.0f) * sinf(dlat / 2.0f) +
              cosf(geofence_lat * PI / 180.0f) * cosf(lat * PI / 180.0f) *
              sinf(dlon / 2.0f) * sinf(dlon / 2.0f);
    float c = 2.0f * atan2f(sqrtf(a), sqrtf(1.0f - a));
    float distance = EARTH_RADIUS_M * c;
    
    return (distance <= geofence_radius);
}

int safety_battery_low_trigger(float voltage_threshold) {
    // Set low battery warning threshold
    return 0;
}

// Auto-pilot
int autopilot_init(void) {
    printf("Autopilot initialized\n");
    return 0;
}

int autopilot_set_target_altitude(float altitude_m) {
    printf("Target altitude set: %.2fm\n", altitude_m);
    return 0;
}

int autopilot_set_target_position(float lat, float lon, float alt) {
    printf("Target position set: %.6f, %.6f, %.2fm\n", lat, lon, alt);
    return 0;
}

int autopilot_set_target_velocity(float vx, float vy) {
    printf("Target velocity set: %.2f, %.2f m/s\n", vx, vy);
    return 0;
}

int autopilot_return_to_launch(void) {
    printf("Return to launch activated\n");
    flight_control_set_mode(FLIGHT_MODE_RTL);
    return 0;
}
