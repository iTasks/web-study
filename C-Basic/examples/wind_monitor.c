/**
 * Wind Turbine Monitoring System Example
 * 
 * Monitors wind turbine RPM, voltage, current, and power output.
 */

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include "hal.h"
#include "energy.h"

static volatile int running = 1;

void signal_handler(int signum) {
    (void)signum;
    running = 0;
}

int main(void) {
    printf("=== Wind Turbine Monitor ===\n\n");
    
    signal(SIGINT, signal_handler);
    
    // Initialize HAL
    hal_init(PLATFORM_GENERIC_LINUX);
    energy_init();
    
    // Configure wind turbine
    wind_config_t wind_config = {
        .rpm_pin = 2,
        .voltage_pin = 0,
        .current_pin = 1,
        .max_voltage = 14.0f,
        .max_current = 10.0f,
        .blade_count = 3
    };
    
    if (wind_init(&wind_config) != 0) {
        fprintf(stderr, "Failed to initialize wind turbine\n");
        return 1;
    }
    
    printf("Monitoring wind turbine...\n");
    printf("Press Ctrl+C to stop\n\n");
    printf("Time(s)\tRPM\tVoltage(V)\tCurrent(A)\tPower(W)\n");
    printf("-----------------------------------------------------\n");
    
    uint32_t start_time = hal_millis();
    
    while (running) {
        energy_reading_t reading;
        
        if (wind_read(&reading) == 0) {
            uint32_t current_time = (hal_millis() - start_time) / 1000;
            float rpm = wind_get_rpm();
            
            printf("%5u\t%.0f\t%7.2f\t%7.2f\t%7.2f\n",
                   current_time,
                   rpm,
                   reading.voltage,
                   reading.current,
                   reading.power);
        }
        
        hal_delay_ms(1000);
    }
    
    // Cleanup
    energy_deinit();
    hal_deinit();
    
    printf("\nWind turbine monitor stopped.\n");
    return 0;
}
