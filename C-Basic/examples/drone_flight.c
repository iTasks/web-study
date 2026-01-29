/**
 * Drone Flight Controller Example
 * 
 * Demonstrates a quadcopter flight control system with
 * stabilization, altitude hold, and GPS navigation.
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
    printf("=== Quadcopter Flight Controller ===\n\n");
    
    signal(SIGINT, signal_handler);
    
    // Initialize systems
    hal_init(PLATFORM_RPI);
    aerospace_init(VEHICLE_MULTIROTOR);
    
    // Initialize flight controller
    flight_control_init();
    telemetry_init();
    
    // Initialize sensors
    barometer_init(1, 0x77);      // I2C barometer
    gps_init(0, 9600);            // GPS on UART0
    magnetometer_init(1, 0x1E);   // I2C magnetometer
    
    // Initialize RC receiver
    rc_init();
    
    // Initialize control mixer
    control_mixer_init(VEHICLE_MULTIROTOR);
    
    // Initialize safety features
    safety_init();
    safety_geofence_set(37.7749f, -122.4194f, 100.0f); // 100m radius
    
    // Initialize autopilot
    autopilot_init();
    
    printf("Flight controller initialized.\n");
    printf("Waiting for RC connection...\n");
    
    // Wait for RC connection
    while (!rc_is_connected() && running) {
        hal_delay_ms(100);
    }
    
    if (!running) goto cleanup;
    
    printf("RC connected!\n");
    printf("Set throttle to minimum and toggle arm switch to arm.\n");
    
    // Main flight control loop
    uint32_t last_update = hal_millis();
    
    while (running) {
        uint32_t now = hal_millis();
        float dt = (now - last_update) / 1000.0f;
        last_update = now;
        
        // Read telemetry
        telemetry_t telem;
        telemetry_update(&telem);
        
        // Read GPS
        gps_read(&telem.latitude, &telem.longitude, &telem.altitude,
                &telem.ground_speed, &telem.gps_fix);
        
        // Read barometer
        float pressure, temperature;
        barometer_read(&pressure, &temperature);
        telem.altitude = barometer_calculate_altitude(pressure);
        telem.temperature = temperature;
        telem.pressure = pressure;
        
        // Read RC input
        rc_input_t rc;
        rc_read(&rc);
        
        // Check for arming command (channel 4 switch)
        if (rc.channel[4] > 500 && !flight_control_is_armed()) {
            if (flight_control_arm() == 0) {
                printf("ARMED - Be careful!\n");
            }
        } else if (rc.channel[4] < -500 && flight_control_is_armed()) {
            flight_control_disarm();
            printf("DISARMED\n");
        }
        
        // Safety checks
        if (safety_check(&telem) != 0) {
            printf("SAFETY VIOLATION - Initiating RTL\n");
            autopilot_return_to_launch();
        }
        
        // Compute motor outputs
        motor_outputs_t motors;
        control_mixer_update(&rc, &telem, NULL, &motors);
        
        // Apply motor commands (only if armed)
        if (flight_control_is_armed()) {
            // In real system, output to ESCs via PWM
            // For now, just log
            if (now % 1000 < 50) { // Print once per second
                printf("Motors: [%4u, %4u, %4u, %4u] Alt: %.2fm GPS: %d sats\n",
                       motors.motor[0], motors.motor[1],
                       motors.motor[2], motors.motor[3],
                       telem.altitude, telem.satellite_count);
            }
        }
        
        // Send telemetry
        telemetry_send(&telem);
        
        // Log telemetry
        if (flight_control_is_armed()) {
            telemetry_log(&telem, "flight_log.csv");
        }
        
        // Run at 100Hz
        hal_delay_ms(10);
    }
    
cleanup:
    // Emergency disarm and stop motors
    flight_control_disarm();
    
    printf("\nFlight controller stopped.\n");
    
    // Cleanup
    aerospace_deinit();
    hal_deinit();
    
    return 0;
}
