# Wind Turbine Configuration

[← Back to C-Basic](../../README.md) | [Main README](../../../README.md)

Example configurations for wind turbine monitoring and control systems.

## Small Vertical Axis Turbine (12V, 400W)

**Components:**
- Vertical axis wind turbine (VAWT)
- 3-phase permanent magnet generator
- Rectifier (3-phase AC to DC)
- Hall effect RPM sensor
- Voltage/current sensors
- Dump load controller

**Configuration:**

```c
wind_config_t config = {
    .rpm_pin = 2,            // Hall effect sensor
    .voltage_pin = 0,
    .current_pin = 1,
    .max_voltage = 14.0f,
    .max_current = 30.0f,
    .blade_count = 3
};
```

**Wiring:**

```
Turbine 3-Phase ─> Rectifier ─┬─> Charge Controller ─> Battery
                               │
                               ├─> Voltage Sensor ─> ADC0
                               │
                               └─> Current Sensor ─> ADC1

Hall Sensor ─> GPIO2 (with pull-up)
```

## Horizontal Axis Turbine (24V, 1000W)

**Components:**
- 3-blade horizontal axis turbine
- High-efficiency PMG (Permanent Magnet Generator)
- MPPT wind controller
- Yaw motor (auto-orient into wind)
- Brake system
- Anemometer

**Configuration:**

```c
wind_config_t config = {
    .rpm_pin = 2,
    .voltage_pin = 0,
    .current_pin = 1,
    .max_voltage = 28.0f,
    .max_current = 40.0f,
    .blade_count = 3
};
```

## RPM Measurement

Hall effect sensor produces one pulse per revolution:

```c
volatile uint32_t pulse_count = 0;
uint32_t last_count = 0;
uint32_t last_time = 0;

void hall_sensor_interrupt(void) {
    pulse_count++;
}

float wind_calculate_rpm(void) {
    uint32_t now = hal_millis();
    uint32_t dt = now - last_time;
    
    if (dt >= 1000) {  // Update every second
        uint32_t pulses = pulse_count - last_count;
        float rpm = (pulses * 60000.0f) / dt;
        
        last_count = pulse_count;
        last_time = now;
        
        return rpm;
    }
    return 0.0f;
}
```

## Power Curve

Theoretical power from wind:

```
P = 0.5 * ρ * A * v³ * Cp

Where:
P  = Power (Watts)
ρ  = Air density (1.225 kg/m³ at sea level)
A  = Swept area (m²)
v  = Wind speed (m/s)
Cp = Power coefficient (0.35-0.45 for good turbines)
```

Implementation:

```c
float wind_calculate_theoretical_power(float wind_speed_ms, float diameter_m) {
    const float AIR_DENSITY = 1.225f;  // kg/m³
    const float POWER_COEFF = 0.40f;   // Typical Cp
    const float PI = 3.14159265f;
    
    float area = PI * (diameter_m / 2.0f) * (diameter_m / 2.0f);
    float power = 0.5f * AIR_DENSITY * area * 
                  wind_speed_ms * wind_speed_ms * wind_speed_ms * 
                  POWER_COEFF;
    
    return power;
}
```

## Cut-in and Cut-out Speeds

**Cut-in speed:** Minimum wind speed to start generating
**Rated speed:** Wind speed at rated power output
**Cut-out speed:** Maximum safe wind speed

```c
typedef struct {
    float cut_in_speed;      // m/s (typically 3-4 m/s)
    float rated_speed;       // m/s (typically 12-14 m/s)
    float cut_out_speed;     // m/s (typically 25 m/s)
    float max_rpm;           // Maximum safe RPM
} wind_limits_t;

int wind_safety_control(float wind_speed, float rpm, 
                       const wind_limits_t* limits) {
    if (wind_speed > limits->cut_out_speed) {
        // Apply brake
        wind_apply_brake();
        return -1;
    }
    
    if (rpm > limits->max_rpm) {
        // Dump excess power to resistor
        wind_activate_dump_load();
        return -1;
    }
    
    if (wind_speed < limits->cut_in_speed) {
        // Not generating, maybe apply brake to reduce wear
        return 0;
    }
    
    return 1;  // Normal operation
}
```

## Furling System

Protection against high winds:

```c
// Servo-based tail furling
void wind_furl_turbine(float wind_speed) {
    const float FURL_START = 20.0f;  // m/s
    const float FURL_FULL = 25.0f;   // m/s
    
    if (wind_speed < FURL_START) {
        servo_set_angle(FURL_SERVO_ID, 0);  // Aligned
    } else if (wind_speed >= FURL_FULL) {
        servo_set_angle(FURL_SERVO_ID, 90); // Fully furled
    } else {
        // Partial furling
        float angle = 90.0f * (wind_speed - FURL_START) / 
                      (FURL_FULL - FURL_START);
        servo_set_angle(FURL_SERVO_ID, (int16_t)angle);
    }
}
```

## Brake System

Emergency brake for high wind or maintenance:

```c
// Electromagnetic brake
void wind_apply_brake(void) {
    hal_gpio_write(BRAKE_PIN, GPIO_HIGH);  // Engage brake
    hal_delay_ms(500);
    motor_stop(YAW_MOTOR_ID);  // Stop yaw motor
}

void wind_release_brake(void) {
    hal_gpio_write(BRAKE_PIN, GPIO_LOW);   // Release brake
}
```

## Yaw Control

Auto-orient turbine into wind:

```c
#include <math.h>

void wind_yaw_control(float wind_direction, float current_yaw) {
    const float TOLERANCE = 15.0f;  // degrees
    
    float error = wind_direction - current_yaw;
    
    // Normalize to -180 to 180
    while (error > 180.0f) error -= 360.0f;
    while (error < -180.0f) error += 360.0f;
    
    if (fabsf(error) > TOLERANCE) {
        int16_t speed = (int16_t)(error * 5.0f);  // Proportional control
        motor_set_speed(YAW_MOTOR_ID, speed);
    } else {
        motor_stop(YAW_MOTOR_ID);
    }
}
```

## Monitoring

Key metrics to monitor:

```c
typedef struct {
    float rpm;
    float wind_speed;
    float voltage;
    float current;
    float power;
    float energy_daily;    // kWh
    float yaw_angle;
    bool brake_engaged;
    uint32_t timestamp;
} wind_telemetry_t;
```

## Maintenance Alerts

```c
void wind_check_maintenance(wind_telemetry_t* telem) {
    static uint32_t operating_hours = 0;
    
    if (telem->rpm > 10.0f) {
        operating_hours++;
    }
    
    if (operating_hours > 2000) {  // Every ~2000 hours
        printf("MAINTENANCE: Lubricate bearings\n");
    }
    
    if (telem->vibration > 5.0f) {  // High vibration
        printf("WARNING: High vibration detected\n");
    }
}
```
