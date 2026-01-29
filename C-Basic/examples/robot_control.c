/**
 * Robot Control Example
 * 
 * Demonstrates a simple autonomous robot using motors, sensors,
 * and navigation algorithms.
 */

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include "hal.h"
#include "robotics.h"

static volatile int running = 1;

void signal_handler(int signum) {
    (void)signum;
    running = 0;
}

int main(void) {
    printf("=== Autonomous Robot Control ===\n\n");
    
    signal(SIGINT, signal_handler);
    
    // Initialize systems
    hal_init(PLATFORM_RPI);
    robotics_init();
    
    // Configure left motor (DC motor with H-bridge)
    motor_config_t left_motor = {
        .type = MOTOR_TYPE_DC,
        .pwm_pin = 12,
        .dir_pin1 = 23,
        .dir_pin2 = 24,
        .encoder_pin_a = 5,
        .encoder_pin_b = 6,
        .max_speed = 255
    };
    
    // Configure right motor
    motor_config_t right_motor = {
        .type = MOTOR_TYPE_DC,
        .pwm_pin = 13,
        .dir_pin1 = 27,
        .dir_pin2 = 22,
        .encoder_pin_a = 17,
        .encoder_pin_b = 18,
        .max_speed = 255
    };
    
    motor_init(0, &left_motor);
    motor_init(1, &right_motor);
    
    // Initialize distance sensors
    distance_sensor_init(0, SENSOR_ULTRASONIC, 16, 20); // Front
    distance_sensor_init(1, SENSOR_ULTRASONIC, 19, 26); // Left
    distance_sensor_init(2, SENSOR_ULTRASONIC, 21, 25); // Right
    
    // Initialize IMU for orientation
    imu_init(1, 0x68); // I2C bus 1, MPU6050 address
    imu_calibrate();
    
    // Initialize navigation
    nav_init();
    
    // Set up waypoint path
    path_plan_init();
    path_add_waypoint(1.0f, 0.0f);   // 1 meter forward
    path_add_waypoint(1.0f, 1.0f);   // Turn right
    path_add_waypoint(0.0f, 1.0f);   // Move left
    path_add_waypoint(0.0f, 0.0f);   // Return home
    
    printf("Robot initialized. Starting autonomous navigation...\n");
    printf("Press Ctrl+C to stop\n\n");
    
    uint32_t last_update = hal_millis();
    
    while (running && !path_is_complete()) {
        uint32_t now = hal_millis();
        float dt = (now - last_update) / 1000.0f;
        last_update = now;
        
        // Read sensors
        float front_dist = distance_sensor_read(0);
        float left_dist = distance_sensor_read(1);
        float right_dist = distance_sensor_read(2);
        
        printf("Distances - Front: %.1fcm, Left: %.1fcm, Right: %.1fcm\n",
               front_dist, left_dist, right_dist);
        
        // Obstacle avoidance
        if (front_dist < 30.0f) {
            printf("Obstacle ahead! Turning...\n");
            motor_set_speed(0, -100);  // Left motor backward
            motor_set_speed(1, 100);   // Right motor forward
            hal_delay_ms(500);
            continue;
        }
        
        // Read IMU
        imu_data_t imu;
        imu_read(&imu);
        
        // Update navigation
        nav_update_position(&imu, dt);
        
        // Get current waypoint
        waypoint_t* waypoint = path_get_next_waypoint();
        if (waypoint) {
            printf("Navigating to waypoint: (%.2f, %.2f)\n", waypoint->x, waypoint->y);
        }
        
        // Compute motor control
        float left_speed, right_speed;
        nav_compute_control(&left_speed, &right_speed);
        
        // Apply motor commands
        motor_set_speed(0, (int16_t)(left_speed * 200));
        motor_set_speed(1, (int16_t)(right_speed * 200));
        
        hal_delay_ms(100);
    }
    
    // Stop motors
    motor_stop(0);
    motor_stop(1);
    
    printf("\nMission complete!\n");
    
    // Cleanup
    robotics_deinit();
    hal_deinit();
    
    return 0;
}
