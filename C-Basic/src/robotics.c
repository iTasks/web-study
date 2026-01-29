#include "robotics.h"
#include "hal.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define MAX_MOTORS 8
#define MAX_SERVOS 16
#define MAX_WAYPOINTS 100

static motor_config_t motors[MAX_MOTORS];
static servo_config_t servos[MAX_SERVOS];
static imu_data_t current_imu;
static pose_t current_pose;
static waypoint_t waypoints[MAX_WAYPOINTS];
static int waypoint_count = 0;
static int current_waypoint = 0;

int robotics_init(void) {
    printf("Robotics system initialized\n");
    memset(motors, 0, sizeof(motors));
    memset(servos, 0, sizeof(servos));
    memset(&current_imu, 0, sizeof(current_imu));
    memset(&current_pose, 0, sizeof(current_pose));
    return 0;
}

int robotics_deinit(void) {
    // Stop all motors
    for (int i = 0; i < MAX_MOTORS; i++) {
        motor_stop(i);
    }
    return 0;
}

// Motor control
int motor_init(uint8_t motor_id, const motor_config_t* config) {
    if (motor_id >= MAX_MOTORS || !config) return -1;
    
    memcpy(&motors[motor_id], config, sizeof(motor_config_t));
    
    // Initialize GPIO pins
    hal_gpio_set_mode(config->pwm_pin, GPIO_MODE_PWM);
    hal_gpio_set_mode(config->dir_pin1, GPIO_MODE_OUTPUT);
    hal_gpio_set_mode(config->dir_pin2, GPIO_MODE_OUTPUT);
    
    if (config->encoder_pin_a > 0) {
        hal_gpio_set_mode(config->encoder_pin_a, GPIO_MODE_INPUT);
        hal_gpio_set_pull(config->encoder_pin_a, GPIO_PULL_UP);
    }
    if (config->encoder_pin_b > 0) {
        hal_gpio_set_mode(config->encoder_pin_b, GPIO_MODE_INPUT);
        hal_gpio_set_pull(config->encoder_pin_b, GPIO_PULL_UP);
    }
    
    printf("Motor %d initialized: type=%d, pwm_pin=%d\n", 
           motor_id, config->type, config->pwm_pin);
    return 0;
}

int motor_set_speed(uint8_t motor_id, int16_t speed) {
    if (motor_id >= MAX_MOTORS) return -1;
    
    motor_config_t* motor = &motors[motor_id];
    
    // Clamp speed to valid range
    if (speed > 255) speed = 255;
    if (speed < -255) speed = -255;
    
    // Set direction
    if (speed >= 0) {
        hal_gpio_write(motor->dir_pin1, GPIO_HIGH);
        hal_gpio_write(motor->dir_pin2, GPIO_LOW);
    } else {
        hal_gpio_write(motor->dir_pin1, GPIO_LOW);
        hal_gpio_write(motor->dir_pin2, GPIO_HIGH);
        speed = -speed;
    }
    
    // Set PWM duty cycle
    hal_gpio_pwm_set_duty_cycle(motor->pwm_pin, (uint8_t)speed);
    
    return 0;
}

int motor_stop(uint8_t motor_id) {
    return motor_set_speed(motor_id, 0);
}

int motor_brake(uint8_t motor_id) {
    if (motor_id >= MAX_MOTORS) return -1;
    
    motor_config_t* motor = &motors[motor_id];
    
    // Short both motor terminals
    hal_gpio_write(motor->dir_pin1, GPIO_HIGH);
    hal_gpio_write(motor->dir_pin2, GPIO_HIGH);
    hal_gpio_pwm_set_duty_cycle(motor->pwm_pin, 255);
    
    return 0;
}

int32_t motor_get_encoder_count(uint8_t motor_id) {
    // In real implementation, this would read encoder counter
    return 0;
}

int motor_reset_encoder(uint8_t motor_id) {
    return 0;
}

// Servo control
int servo_init(uint8_t servo_id, const servo_config_t* config) {
    if (servo_id >= MAX_SERVOS || !config) return -1;
    
    memcpy(&servos[servo_id], config, sizeof(servo_config_t));
    hal_gpio_set_mode(config->pin, GPIO_MODE_PWM);
    
    printf("Servo %d initialized: pin=%d, range=%d to %d degrees\n",
           servo_id, config->pin, config->min_angle, config->max_angle);
    return 0;
}

int servo_set_angle(uint8_t servo_id, int16_t angle) {
    if (servo_id >= MAX_SERVOS) return -1;
    
    servo_config_t* servo = &servos[servo_id];
    
    // Clamp angle
    if (angle < servo->min_angle) angle = servo->min_angle;
    if (angle > servo->max_angle) angle = servo->max_angle;
    
    // Map angle to pulse width
    int16_t angle_range = servo->max_angle - servo->min_angle;
    uint16_t pulse_range = servo->max_pulse_us - servo->min_pulse_us;
    uint16_t pulse_us = servo->min_pulse_us + 
                        ((angle - servo->min_angle) * pulse_range / angle_range);
    
    return servo_set_pulse_width(servo_id, pulse_us);
}

int servo_set_pulse_width(uint8_t servo_id, uint16_t pulse_us) {
    if (servo_id >= MAX_SERVOS) return -1;
    
    // Convert pulse width to PWM duty cycle
    // Standard servo frequency is 50Hz (20ms period)
    uint8_t duty = (pulse_us * 255) / 20000;
    hal_gpio_pwm_set_duty_cycle(servos[servo_id].pin, duty);
    
    return 0;
}

// Distance sensors
int distance_sensor_init(uint8_t sensor_id, distance_sensor_type_t type, 
                        uint8_t trig_pin, uint8_t echo_pin) {
    if (type == SENSOR_ULTRASONIC) {
        hal_gpio_set_mode(trig_pin, GPIO_MODE_OUTPUT);
        hal_gpio_set_mode(echo_pin, GPIO_MODE_INPUT);
    }
    return 0;
}

float distance_sensor_read(uint8_t sensor_id) {
    // Ultrasonic sensor reading (HC-SR04)
    // This is a simplified version
    
    // Send 10us trigger pulse
    // hal_gpio_write(trig_pin, GPIO_HIGH);
    // hal_delay_us(10);
    // hal_gpio_write(trig_pin, GPIO_LOW);
    
    // Measure echo pulse duration
    // In real implementation, measure time between rising and falling edge
    uint32_t pulse_duration_us = 1000; // Placeholder
    
    // Calculate distance: speed of sound is 343 m/s
    // distance = (pulse_duration * 0.0343) / 2
    return (pulse_duration_us * 0.0343f) / 2.0f;
}

// IMU
int imu_init(uint8_t i2c_bus, uint8_t i2c_addr) {
    hal_i2c_init(i2c_bus);
    // Initialize IMU (e.g., MPU6050, BNO055)
    printf("IMU initialized on I2C bus %d, addr 0x%02X\n", i2c_bus, i2c_addr);
    return 0;
}

int imu_read(imu_data_t* data) {
    if (!data) return -1;
    
    // Read from IMU via I2C
    // This would read accelerometer, gyroscope, magnetometer
    // For now, use placeholder values
    data->accel_x = 0.0f;
    data->accel_y = 0.0f;
    data->accel_z = 9.81f;
    data->gyro_x = 0.0f;
    data->gyro_y = 0.0f;
    data->gyro_z = 0.0f;
    data->mag_x = 0.0f;
    data->mag_y = 0.0f;
    data->mag_z = 0.0f;
    data->roll = 0.0f;
    data->pitch = 0.0f;
    data->yaw = 0.0f;
    data->timestamp = hal_millis();
    
    return 0;
}

int imu_calibrate(void) {
    printf("Calibrating IMU... Please keep device stationary.\n");
    hal_delay_ms(2000);
    printf("IMU calibration complete.\n");
    return 0;
}

// Navigation
int nav_init(void) {
    memset(&current_pose, 0, sizeof(pose_t));
    return 0;
}

int nav_update_position(const imu_data_t* imu, float dt) {
    if (!imu) return -1;
    
    // Dead reckoning using IMU
    // This is simplified - real implementation would use Kalman filter
    current_pose.roll = imu->roll;
    current_pose.pitch = imu->pitch;
    current_pose.yaw = imu->yaw;
    
    // Integrate acceleration to get velocity
    current_pose.vx += imu->accel_x * dt;
    current_pose.vy += imu->accel_y * dt;
    current_pose.vz += imu->accel_z * dt;
    
    // Integrate velocity to get position
    current_pose.x += current_pose.vx * dt;
    current_pose.y += current_pose.vy * dt;
    current_pose.z += current_pose.vz * dt;
    
    return 0;
}

int nav_get_pose(pose_t* pose) {
    if (!pose) return -1;
    memcpy(pose, &current_pose, sizeof(pose_t));
    return 0;
}

int nav_set_target(float x, float y, float yaw) {
    // Set navigation target
    return 0;
}

int nav_compute_control(float* left_speed, float* right_speed) {
    // Compute differential drive control
    // This would implement a control algorithm (PID, etc.)
    *left_speed = 0.0f;
    *right_speed = 0.0f;
    return 0;
}

// Path planning
int path_plan_init(void) {
    waypoint_count = 0;
    current_waypoint = 0;
    return 0;
}

int path_add_waypoint(float x, float y) {
    if (waypoint_count >= MAX_WAYPOINTS) return -1;
    
    waypoints[waypoint_count].x = x;
    waypoints[waypoint_count].y = y;
    waypoint_count++;
    
    return 0;
}

int path_clear_waypoints(void) {
    waypoint_count = 0;
    current_waypoint = 0;
    return 0;
}

waypoint_t* path_get_next_waypoint(void) {
    if (current_waypoint >= waypoint_count) return NULL;
    return &waypoints[current_waypoint++];
}

bool path_is_complete(void) {
    return (current_waypoint >= waypoint_count);
}
