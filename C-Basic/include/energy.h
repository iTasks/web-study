#ifndef ENERGY_H
#define ENERGY_H

#include <stdint.h>
#include <stdbool.h>

/**
 * Renewable Energy Management System
 * Supports solar, wind, thermal energy monitoring and control
 */

// Energy source types
typedef enum {
    ENERGY_SOURCE_SOLAR = 0,
    ENERGY_SOURCE_WIND,
    ENERGY_SOURCE_THERMAL,
    ENERGY_SOURCE_HYBRID
} energy_source_t;

// Energy sensor data
typedef struct {
    float voltage;          // Volts
    float current;          // Amperes
    float power;            // Watts
    float energy;           // Watt-hours
    float efficiency;       // Percentage
    uint32_t timestamp;     // Unix timestamp
} energy_reading_t;

// Solar panel configuration
typedef struct {
    uint8_t voltage_pin;    // ADC pin for voltage
    uint8_t current_pin;    // ADC pin for current
    float max_voltage;      // Maximum panel voltage
    float max_current;      // Maximum panel current
    float vref;             // ADC reference voltage
} solar_config_t;

// Wind turbine configuration
typedef struct {
    uint8_t rpm_pin;        // Pin for RPM sensor
    uint8_t voltage_pin;    // ADC pin for voltage
    uint8_t current_pin;    // ADC pin for current
    float max_voltage;
    float max_current;
    uint8_t blade_count;    // Number of blades
} wind_config_t;

// Thermal/heat configuration
typedef struct {
    uint8_t temp_pin;       // Temperature sensor pin
    uint8_t voltage_pin;    // ADC pin for voltage
    uint8_t current_pin;    // ADC pin for current
    float max_voltage;
    float max_current;
    float temp_coefficient; // Temperature coefficient
} thermal_config_t;

// Energy system initialization
int energy_init(void);
int energy_deinit(void);

// Solar functions
int solar_init(const solar_config_t* config);
int solar_read(energy_reading_t* reading);
float solar_get_mppt_voltage(void); // Maximum Power Point Tracking

// Wind functions
int wind_init(const wind_config_t* config);
int wind_read(energy_reading_t* reading);
float wind_get_rpm(void);
float wind_calculate_power_coefficient(float wind_speed);

// Thermal functions
int thermal_init(const thermal_config_t* config);
int thermal_read(energy_reading_t* reading);
float thermal_get_temperature(void);
float thermal_get_efficiency(float temp_diff);

// Energy management
int energy_start_logging(const char* filename);
int energy_stop_logging(void);
int energy_get_total_production(float* total_wh);
int energy_get_average_power(float* avg_watts);

// Battery management
typedef struct {
    float voltage;
    float current;
    float state_of_charge; // Percentage
    float temperature;
    bool is_charging;
} battery_status_t;

int battery_init(uint8_t voltage_pin, uint8_t current_pin);
int battery_read_status(battery_status_t* status);
float battery_estimate_runtime(float load_watts);

#endif // ENERGY_H
