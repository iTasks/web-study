/**
 * Solar Power Monitoring System Example
 * 
 * Demonstrates monitoring solar panel voltage, current, power output,
 * and implementing Maximum Power Point Tracking (MPPT).
 */

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include "hal.h"
#include "energy.h"

static volatile int running = 1;

void signal_handler(int signum) {
    (void)signum;
    running = 0;
}

int main(int argc, char** argv) {
    printf("=== Solar Power Monitor ===\n\n");
    
    // Setup signal handler for graceful shutdown
    signal(SIGINT, signal_handler);
    
    // Initialize HAL
    hal_init(PLATFORM_GENERIC_LINUX);
    
    // Initialize energy system
    energy_init();
    
    // Configure solar panel
    solar_config_t solar_config = {
        .voltage_pin = 0,        // ADC channel 0 for voltage
        .current_pin = 1,        // ADC channel 1 for current
        .max_voltage = 22.0f,    // 22V max (18V panel)
        .max_current = 5.0f,     // 5A max
        .vref = 5.0f             // 5V ADC reference
    };
    
    if (solar_init(&solar_config) != 0) {
        fprintf(stderr, "Failed to initialize solar system\n");
        return 1;
    }
    
    // Start data logging
    energy_start_logging("solar_data.csv");
    
    printf("Monitoring solar panel...\n");
    printf("Press Ctrl+C to stop\n\n");
    printf("Time(s)\tVoltage(V)\tCurrent(A)\tPower(W)\tMPPT(V)\tEfficiency(%%)\n");
    printf("-----------------------------------------------------------------------\n");
    
    uint32_t start_time = hal_millis();
    float total_energy_wh = 0.0f;
    uint32_t last_log_time = 0;
    
    while (running) {
        energy_reading_t reading;
        
        // Read solar panel data
        if (solar_read(&reading) == 0) {
            uint32_t current_time = (hal_millis() - start_time) / 1000;
            
            // Calculate MPPT voltage
            float mppt_voltage = solar_get_mppt_voltage();
            
            // Accumulate energy (simplified)
            if (last_log_time > 0) {
                float dt_hours = (current_time - last_log_time) / 3600.0f;
                total_energy_wh += reading.power * dt_hours;
            }
            last_log_time = current_time;
            
            // Display readings every second
            printf("%5u\t%7.2f\t%7.2f\t%7.2f\t%7.2f\t%7.2f\n",
                   current_time,
                   reading.voltage,
                   reading.current,
                   reading.power,
                   mppt_voltage,
                   reading.efficiency);
            
            // Log to file
            FILE* log = fopen("solar_data.csv", "a");
            if (log) {
                fprintf(log, "%u,%.2f,%.2f,%.2f,%.2f,%.2f\n",
                        current_time, reading.voltage, reading.current,
                        reading.power, mppt_voltage, reading.efficiency);
                fclose(log);
            }
        }
        
        // Update every second
        hal_delay_ms(1000);
    }
    
    printf("\n=== Summary ===\n");
    printf("Total energy generated: %.2f Wh\n", total_energy_wh);
    
    // Cleanup
    energy_stop_logging();
    energy_deinit();
    hal_deinit();
    
    printf("Solar monitor stopped.\n");
    return 0;
}
