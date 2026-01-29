#ifndef AEROSPACE_H
#define AEROSPACE_H

#include <stdint.h>
#include <stdbool.h>

/**
 * Aerospace Control System
 * Supports rockets, RC aircraft, drones, and flight control
 */

// Vehicle types
typedef enum {
    VEHICLE_ROCKET = 0,
    VEHICLE_RC_AIRCRAFT,
    VEHICLE_MULTIROTOR,
    VEHICLE_FIXED_WING
} vehicle_type_t;

// Flight modes
typedef enum {
    FLIGHT_MODE_MANUAL = 0,
    FLIGHT_MODE_STABILIZE,
    FLIGHT_MODE_ALTITUDE_HOLD,
    FLIGHT_MODE_POSITION_HOLD,
    FLIGHT_MODE_AUTO,
    FLIGHT_MODE_RTL  // Return to Launch
} flight_mode_t;

// Flight state
typedef enum {
    FLIGHT_STATE_IDLE = 0,
    FLIGHT_STATE_ARMED,
    FLIGHT_STATE_TAKEOFF,
    FLIGHT_STATE_FLYING,
    FLIGHT_STATE_LANDING,
    FLIGHT_STATE_LANDED,
    FLIGHT_STATE_ERROR
} flight_state_t;

// Telemetry data
typedef struct {
    // Position and orientation
    float latitude, longitude;  // GPS coordinates
    float altitude;             // meters above sea level
    float roll, pitch, yaw;     // degrees
    
    // Velocity
    float velocity_x, velocity_y, velocity_z; // m/s
    float ground_speed;         // m/s
    float vertical_speed;       // m/s
    
    // Acceleration
    float accel_x, accel_y, accel_z; // m/s^2
    
    // Environmental
    float temperature;          // Celsius
    float pressure;             // Pascal
    float battery_voltage;      // Volts
    float battery_current;      // Amperes
    
    // Status
    flight_state_t state;
    flight_mode_t mode;
    uint8_t gps_fix;           // 0=no fix, 1=2D, 2=3D
    uint8_t satellite_count;
    
    uint32_t timestamp;
} telemetry_t;

// Control surfaces (for aircraft)
typedef struct {
    int16_t aileron;           // -1000 to 1000
    int16_t elevator;          // -1000 to 1000
    int16_t rudder;            // -1000 to 1000
    uint16_t throttle;         // 0 to 1000
} control_surfaces_t;

// Motor outputs (for multirotor)
typedef struct {
    uint16_t motor[8];         // 0 to 1000 for up to 8 motors
    uint8_t motor_count;
} motor_outputs_t;

// RC receiver input
typedef struct {
    int16_t channel[16];       // -1000 to 1000 for each channel
    uint8_t channel_count;
    bool failsafe;
} rc_input_t;

// Aerospace system initialization
int aerospace_init(vehicle_type_t vehicle_type);
int aerospace_deinit(void);

// Flight control
int flight_control_init(void);
int flight_control_set_mode(flight_mode_t mode);
flight_mode_t flight_control_get_mode(void);
int flight_control_arm(void);
int flight_control_disarm(void);
bool flight_control_is_armed(void);

// Telemetry
int telemetry_init(void);
int telemetry_update(telemetry_t* telem);
int telemetry_send(const telemetry_t* telem);
int telemetry_log(const telemetry_t* telem, const char* filename);

// RC receiver
int rc_init(void);
int rc_read(rc_input_t* input);
bool rc_is_connected(void);

// Control mixing (converts pilot commands to motor/servo outputs)
int control_mixer_init(vehicle_type_t type);
int control_mixer_update(const rc_input_t* rc, const telemetry_t* telem,
                         control_surfaces_t* surfaces, motor_outputs_t* motors);

// Sensors
int barometer_init(uint8_t i2c_bus, uint8_t addr);
int barometer_read(float* pressure, float* temperature);
float barometer_calculate_altitude(float pressure);

int gps_init(uint8_t uart_port, uint32_t baudrate);
int gps_read(float* lat, float* lon, float* alt, float* speed, uint8_t* fix);

int magnetometer_init(uint8_t i2c_bus, uint8_t addr);
int magnetometer_read(float* mag_x, float* mag_y, float* mag_z);
float magnetometer_calculate_heading(float mag_x, float mag_y, float roll, float pitch);

// Safety features
int safety_init(void);
int safety_check(const telemetry_t* telem);
int safety_geofence_set(float center_lat, float center_lon, float radius_m);
bool safety_is_in_geofence(float lat, float lon);
int safety_battery_low_trigger(float voltage_threshold);

// Auto-pilot
int autopilot_init(void);
int autopilot_set_target_altitude(float altitude_m);
int autopilot_set_target_position(float lat, float lon, float alt);
int autopilot_set_target_velocity(float vx, float vy);
int autopilot_return_to_launch(void);

#endif // AEROSPACE_H
