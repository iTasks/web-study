/**
 * RC Aircraft Flight Controller Example
 * 
 * Demonstrates fixed-wing aircraft control with stabilization
 * and autopilot features.
 */

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include "hal.h"
#include "aerospace.h"

static volatile int running = 1;

void signal_handler(int signum) {
    (void)signum;
    running = 0;
}

int main(void) {
    printf("=== RC Aircraft Flight Controller ===\n\n");
    
    signal(SIGINT, signal_handler);
    
    // Initialize systems
    hal_init(PLATFORM_RPI);
    aerospace_init(VEHICLE_FIXED_WING);
    
    // Initialize flight systems
    flight_control_init();
    telemetry_init();
    rc_init();
    control_mixer_init(VEHICLE_FIXED_WING);
    safety_init();
    autopilot_init();
    
    // Initialize sensors
    barometer_init(1, 0x77);
    gps_init(0, 9600);
    magnetometer_init(1, 0x1E);
    
    // Set safety parameters
    safety_geofence_set(37.7749f, -122.4194f, 500.0f); // 500m radius for aircraft
    safety_battery_low_trigger(11.1f); // 3S LiPo minimum
    
    printf("RC Aircraft controller initialized.\n");
    printf("Flight modes: Manual, Stabilize, Altitude Hold, Auto, RTL\n\n");
    
    // Main control loop
    uint32_t last_update = hal_millis();
    
    while (running) {
        uint32_t now = hal_millis();
        float dt = (now - last_update) / 1000.0f;
        last_update = now;
        
        // Update telemetry
        telemetry_t telem;
        telemetry_update(&telem);
        
        // Read sensors
        float pressure, temperature;
        barometer_read(&pressure, &temperature);
        telem.altitude = barometer_calculate_altitude(pressure);
        
        gps_read(&telem.latitude, &telem.longitude, &telem.altitude,
                &telem.ground_speed, &telem.gps_fix);
        
        float mag_x, mag_y, mag_z;
        magnetometer_read(&mag_x, &mag_y, &mag_z);
        float heading = magnetometer_calculate_heading(mag_x, mag_y, 
                                                       telem.roll, telem.pitch);
        telem.yaw = heading;
        
        // Read RC input
        rc_input_t rc;
        rc_read(&rc);
        
        // Check for failsafe
        if (rc.failsafe) {
            printf("RC FAILSAFE - Initiating RTL\n");
            autopilot_return_to_launch();
        }
        
        // Flight mode selection (channel 5)
        if (rc.channel[5] < -600) {
            flight_control_set_mode(FLIGHT_MODE_MANUAL);
        } else if (rc.channel[5] < -200) {
            flight_control_set_mode(FLIGHT_MODE_STABILIZE);
        } else if (rc.channel[5] < 200) {
            flight_control_set_mode(FLIGHT_MODE_ALTITUDE_HOLD);
        } else if (rc.channel[5] < 600) {
            flight_control_set_mode(FLIGHT_MODE_AUTO);
        } else {
            flight_control_set_mode(FLIGHT_MODE_RTL);
        }
        
        // Safety checks
        safety_check(&telem);
        
        // Mix controls to servos
        control_surfaces_t surfaces;
        control_mixer_update(&rc, &telem, &surfaces, NULL);
        
        // Apply servo commands
        // In real system, output to servos via PWM
        
        // Status display (once per second)
        if (now % 1000 < 50) {
            printf("Mode: %d | Alt: %.1fm | Speed: %.1fm/s | Heading: %.0f° | Battery: %.1fV\n",
                   flight_control_get_mode(),
                   telem.altitude,
                   telem.ground_speed,
                   telem.yaw,
                   telem.battery_voltage);
        }
        
        // Log telemetry
        telemetry_log(&telem, "aircraft_log.csv");
        
        // Send telemetry to ground station
        telemetry_send(&telem);
        
        // Run at 50Hz
        hal_delay_ms(20);
    }
    
    printf("\nAircraft controller stopped.\n");
    
    // Cleanup
    aerospace_deinit();
    hal_deinit();
    
    return 0;
}
