#ifndef ROBOTICS_H
#define ROBOTICS_H

#include <stdint.h>
#include <stdbool.h>

/**
 * Robotics Control Framework
 * Supports motors, servos, sensors, and robot navigation
 */

// Motor types
typedef enum {
    MOTOR_TYPE_DC = 0,
    MOTOR_TYPE_STEPPER,
    MOTOR_TYPE_SERVO,
    MOTOR_TYPE_BRUSHLESS
} motor_type_t;

// Motor configuration
typedef struct {
    motor_type_t type;
    uint8_t pwm_pin;        // PWM control pin
    uint8_t dir_pin1;       // Direction pin 1
    uint8_t dir_pin2;       // Direction pin 2 (for H-bridge)
    uint8_t encoder_pin_a;  // Encoder A (optional)
    uint8_t encoder_pin_b;  // Encoder B (optional)
    uint16_t max_speed;     // Maximum speed (0-255 for PWM)
} motor_config_t;

// Servo configuration
typedef struct {
    uint8_t pin;
    uint16_t min_pulse_us;  // Minimum pulse width (microseconds)
    uint16_t max_pulse_us;  // Maximum pulse width
    int16_t min_angle;      // Minimum angle (degrees)
    int16_t max_angle;      // Maximum angle
} servo_config_t;

// Distance sensor types
typedef enum {
    SENSOR_ULTRASONIC = 0,
    SENSOR_IR,
    SENSOR_LIDAR,
    SENSOR_TOF
} distance_sensor_type_t;

// IMU (Inertial Measurement Unit) data
typedef struct {
    float accel_x, accel_y, accel_z;    // m/s^2
    float gyro_x, gyro_y, gyro_z;       // rad/s
    float mag_x, mag_y, mag_z;          // uT
    float roll, pitch, yaw;             // degrees
    uint32_t timestamp;
} imu_data_t;

// Position and orientation
typedef struct {
    float x, y, z;          // Position (meters)
    float roll, pitch, yaw; // Orientation (degrees)
    float vx, vy, vz;       // Velocity (m/s)
} pose_t;

// Robotics initialization
int robotics_init(void);
int robotics_deinit(void);

// Motor control
int motor_init(uint8_t motor_id, const motor_config_t* config);
int motor_set_speed(uint8_t motor_id, int16_t speed); // -255 to 255
int motor_stop(uint8_t motor_id);
int motor_brake(uint8_t motor_id);
int32_t motor_get_encoder_count(uint8_t motor_id);
int motor_reset_encoder(uint8_t motor_id);

// Servo control
int servo_init(uint8_t servo_id, const servo_config_t* config);
int servo_set_angle(uint8_t servo_id, int16_t angle);
int servo_set_pulse_width(uint8_t servo_id, uint16_t pulse_us);

// Distance sensors
int distance_sensor_init(uint8_t sensor_id, distance_sensor_type_t type, uint8_t trig_pin, uint8_t echo_pin);
float distance_sensor_read(uint8_t sensor_id); // Returns distance in cm

// IMU
int imu_init(uint8_t i2c_bus, uint8_t i2c_addr);
int imu_read(imu_data_t* data);
int imu_calibrate(void);

// Navigation
int nav_init(void);
int nav_update_position(const imu_data_t* imu, float dt);
int nav_get_pose(pose_t* pose);
int nav_set_target(float x, float y, float yaw);
int nav_compute_control(float* left_speed, float* right_speed);

// Path planning
typedef struct {
    float x, y;
} waypoint_t;

int path_plan_init(void);
int path_add_waypoint(float x, float y);
int path_clear_waypoints(void);
waypoint_t* path_get_next_waypoint(void);
bool path_is_complete(void);

#endif // ROBOTICS_H
