# Aerospace Configuration Examples

Example configurations for drones, RC aircraft, and rockets.

## Quadcopter (X Configuration)

**Components:**
- 4x Brushless motors (1000-1500KV)
- 4x ESCs (30A+)
- Flight controller (RPi or dedicated)
- IMU (MPU9250 or similar)
- GPS module
- Barometer (BMP280)
- RC receiver
- LiPo battery (3S or 4S)

**Motor Mixing:**

```c
// Quadcopter X configuration
//     Front
//   1     0
//     X
//   2     3
//     Rear

void quad_x_mixer(int16_t throttle, int16_t roll, 
                   int16_t pitch, int16_t yaw,
                   motor_outputs_t* motors) {
    motors->motor[0] = throttle + pitch - roll - yaw;  // Front Right
    motors->motor[1] = throttle + pitch + roll + yaw;  // Front Left
    motors->motor[2] = throttle - pitch + roll - yaw;  // Rear Left
    motors->motor[3] = throttle - pitch - roll + yaw;  // Rear Right
    
    // Clamp to valid range
    for (int i = 0; i < 4; i++) {
        if (motors->motor[i] < 0) motors->motor[i] = 0;
        if (motors->motor[i] > 1000) motors->motor[i] = 1000;
    }
    
    motors->motor_count = 4;
}
```

**PID Tuning:**

```c
typedef struct {
    float p, i, d;
} pid_gains_t;

// Typical starting values for quadcopter
pid_gains_t roll_pid = {.p = 4.5, .i = 0.05, .d = 0.3};
pid_gains_t pitch_pid = {.p = 4.5, .i = 0.05, .d = 0.3};
pid_gains_t yaw_pid = {.p = 4.0, .i = 0.02, .d = 0.0};

// Altitude PID
pid_gains_t altitude_pid = {.p = 3.0, .i = 0.5, .d = 1.0};
```

## Hexacopter (Y6 Configuration)

**Motor Configuration:**

```c
void hexa_y6_mixer(int16_t throttle, int16_t roll,
                   int16_t pitch, int16_t yaw,
                   motor_outputs_t* motors) {
    // Y6 has motors stacked (top/bottom) at 3 arms
    float cos30 = 0.866f;
    float sin30 = 0.5f;
    
    // Front motors (top/bottom)
    motors->motor[0] = throttle + pitch - yaw;           // Front top
    motors->motor[1] = throttle + pitch + yaw;           // Front bottom
    
    // Right rear motors
    motors->motor[2] = throttle - pitch*sin30 - roll*cos30 - yaw;  // Top
    motors->motor[3] = throttle - pitch*sin30 - roll*cos30 + yaw;  // Bottom
    
    // Left rear motors
    motors->motor[4] = throttle - pitch*sin30 + roll*cos30 - yaw;  // Top
    motors->motor[5] = throttle - pitch*sin30 + roll*cos30 + yaw;  // Bottom
    
    motors->motor_count = 6;
}
```

## Fixed-Wing Aircraft

**Control Surfaces:**

```c
typedef struct {
    int16_t aileron;    // Roll control
    int16_t elevator;   // Pitch control
    int16_t rudder;     // Yaw control
    uint16_t throttle;  // Engine power
    int16_t flaps;      // Optional
} aircraft_controls_t;

void aircraft_stabilize(telemetry_t* telem, 
                       rc_input_t* rc,
                       aircraft_controls_t* controls) {
    // Target angles from RC
    float target_roll = rc->channel[0] * 45.0f / 1000.0f;   // ±45°
    float target_pitch = rc->channel[1] * 30.0f / 1000.0f;  // ±30°
    
    // PID control for roll
    float roll_error = target_roll - telem->roll;
    controls->aileron = (int16_t)(roll_error * 20.0f);
    
    // PID control for pitch
    float pitch_error = target_pitch - telem->pitch;
    controls->elevator = (int16_t)(pitch_error * 20.0f);
    
    // Yaw damping
    controls->rudder = (int16_t)(-telem->yaw * 10.0f);
    
    // Throttle pass-through
    controls->throttle = rc->channel[2];
    
    // Clamp values
    if (controls->aileron > 1000) controls->aileron = 1000;
    if (controls->aileron < -1000) controls->aileron = -1000;
    // ... similar for other controls
}
```

## Model Rocket Flight Computer

**Components:**
- Barometer (high precision)
- IMU
- GPS (optional)
- Pyro channels for parachute deployment
- Data logger

**Flight Phases:**

```c
typedef enum {
    PHASE_PAD,          // On launch pad
    PHASE_BOOST,        // Motor burning
    PHASE_COAST,        // Coasting to apogee
    PHASE_APOGEE,       // At maximum altitude
    PHASE_DROGUE,       // Drogue chute deployed
    PHASE_MAIN,         // Main chute deployed
    PHASE_LANDED        // On ground
} rocket_phase_t;

rocket_phase_t detect_flight_phase(telemetry_t* telem) {
    static rocket_phase_t phase = PHASE_PAD;
    static float apogee_altitude = 0.0f;
    
    switch (phase) {
        case PHASE_PAD:
            if (telem->accel_z > 20.0f) {  // 2G acceleration
                phase = PHASE_BOOST;
                printf("LIFTOFF!\n");
            }
            break;
            
        case PHASE_BOOST:
            if (telem->accel_z < 5.0f) {   // Low acceleration
                phase = PHASE_COAST;
            }
            break;
            
        case PHASE_COAST:
            if (telem->vertical_speed < 0.0f) {
                phase = PHASE_APOGEE;
                apogee_altitude = telem->altitude;
                printf("Apogee: %.1fm\n", apogee_altitude);
            }
            break;
            
        case PHASE_APOGEE:
            // Deploy drogue at apogee
            deploy_drogue_chute();
            phase = PHASE_DROGUE;
            break;
            
        case PHASE_DROGUE:
            if (telem->altitude < 300.0f) {  // 300m AGL
                deploy_main_chute();
                phase = PHASE_MAIN;
            }
            break;
            
        case PHASE_MAIN:
            if (telem->vertical_speed > -1.0f &&
                telem->altitude < 10.0f) {
                phase = PHASE_LANDED;
                printf("Landed safely.\n");
            }
            break;
            
        case PHASE_LANDED:
            // Do nothing
            break;
    }
    
    return phase;
}
```

**Parachute Deployment:**

```c
#define DROGUE_CHANNEL 1
#define MAIN_CHANNEL 2

void deploy_drogue_chute(void) {
    printf("Deploying drogue chute!\n");
    hal_gpio_write(DROGUE_CHANNEL, GPIO_HIGH);
    hal_delay_ms(500);  // Fire pyro for 500ms
    hal_gpio_write(DROGUE_CHANNEL, GPIO_LOW);
}

void deploy_main_chute(void) {
    printf("Deploying main chute!\n");
    hal_gpio_write(MAIN_CHANNEL, GPIO_HIGH);
    hal_delay_ms(500);
    hal_gpio_write(MAIN_CHANNEL, GPIO_LOW);
}
```

## Failsafe Systems

**Battery Failsafe:**

```c
void check_battery_failsafe(telemetry_t* telem) {
    const float WARN_VOLTAGE = 11.1f;   // 3.7V per cell (3S)
    const float CRIT_VOLTAGE = 10.5f;   // 3.5V per cell
    
    if (telem->battery_voltage < CRIT_VOLTAGE) {
        printf("CRITICAL BATTERY - EMERGENCY LAND\n");
        flight_control_set_mode(FLIGHT_MODE_LAND);
        return;
    }
    
    if (telem->battery_voltage < WARN_VOLTAGE) {
        printf("LOW BATTERY - RTL\n");
        flight_control_set_mode(FLIGHT_MODE_RTL);
    }
}
```

**GPS Failsafe:**

```c
void check_gps_failsafe(telemetry_t* telem) {
    static uint32_t last_gps_time = 0;
    
    if (telem->gps_fix >= 2) {
        last_gps_time = hal_millis();
    } else {
        uint32_t gps_lost_time = hal_millis() - last_gps_time;
        
        if (gps_lost_time > 5000) {  // 5 seconds
            printf("GPS LOST - SWITCHING TO STABILIZE\n");
            flight_control_set_mode(FLIGHT_MODE_STABILIZE);
        }
    }
}
```

**RC Failsafe:**

```c
void check_rc_failsafe(rc_input_t* rc) {
    if (rc->failsafe) {
        printf("RC FAILSAFE - RTL\n");
        autopilot_return_to_launch();
    }
}
```

## Pre-Flight Checklist

```c
bool preflight_check(void) {
    bool pass = true;
    
    // Battery check
    telemetry_t telem;
    telemetry_update(&telem);
    if (telem.battery_voltage < 11.4f) {
        printf("FAIL: Battery voltage low: %.2fV\n", 
               telem.battery_voltage);
        pass = false;
    }
    
    // GPS check
    if (telem.gps_fix < 2) {
        printf("FAIL: No GPS fix\n");
        pass = false;
    }
    
    if (telem.satellite_count < 6) {
        printf("WARN: Low satellite count: %d\n", 
               telem.satellite_count);
    }
    
    // IMU check
    imu_data_t imu;
    imu_read(&imu);
    if (fabs(imu.accel_x) > 2.0f || fabs(imu.accel_y) > 2.0f) {
        printf("FAIL: IMU not level\n");
        pass = false;
    }
    
    // RC check
    if (!rc_is_connected()) {
        printf("FAIL: RC not connected\n");
        pass = false;
    }
    
    // Geofence check
    if (!safety_is_in_geofence(telem.latitude, telem.longitude)) {
        printf("FAIL: Outside geofence\n");
        pass = false;
    }
    
    return pass;
}
```

## Black Box Logging

```c
void blackbox_log(const telemetry_t* telem, 
                  const rc_input_t* rc,
                  const motor_outputs_t* motors) {
    FILE* f = fopen("blackbox.bin", "ab");
    if (!f) return;
    
    // Write timestamp
    fwrite(&telem->timestamp, sizeof(uint32_t), 1, f);
    
    // Write telemetry
    fwrite(telem, sizeof(telemetry_t), 1, f);
    
    // Write RC inputs
    fwrite(rc, sizeof(rc_input_t), 1, f);
    
    // Write motor outputs
    fwrite(motors, sizeof(motor_outputs_t), 1, f);
    
    fclose(f);
}
```
