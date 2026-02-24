# Robotics Configuration Examples

[← Back to C-Basic](../README.md) | [Main README](../../README.md)

Example configurations for various robotic platforms.

## Differential Drive Robot

**Components:**
- 2x DC motors with encoders
- Motor driver (L298N or similar)
- Ultrasonic sensors (3x)
- IMU (MPU6050)
- Raspberry Pi

**Motor Configuration:**

```c
// Left motor
motor_config_t left_motor = {
    .type = MOTOR_TYPE_DC,
    .pwm_pin = 12,
    .dir_pin1 = 23,
    .dir_pin2 = 24,
    .encoder_pin_a = 5,
    .encoder_pin_b = 6,
    .max_speed = 255
};

// Right motor
motor_config_t right_motor = {
    .type = MOTOR_TYPE_DC,
    .pwm_pin = 13,
    .dir_pin1 = 27,
    .dir_pin2 = 22,
    .encoder_pin_a = 17,
    .encoder_pin_b = 18,
    .max_speed = 255
};
```

**Basic Movement:**

```c
// Forward
motor_set_speed(MOTOR_LEFT, 200);
motor_set_speed(MOTOR_RIGHT, 200);

// Turn right (pivot)
motor_set_speed(MOTOR_LEFT, 200);
motor_set_speed(MOTOR_RIGHT, -200);

// Turn left (gentle arc)
motor_set_speed(MOTOR_LEFT, 150);
motor_set_speed(MOTOR_RIGHT, 200);

// Stop
motor_stop(MOTOR_LEFT);
motor_stop(MOTOR_RIGHT);

// Brake
motor_brake(MOTOR_LEFT);
motor_brake(MOTOR_RIGHT);
```

## Line Following Robot

**Additional Components:**
- 5x IR sensors (line detection)
- Threshold tuning

**Sensor Reading:**

```c
typedef struct {
    uint8_t sensors[5];  // Left to Right
    int8_t position;     // -2 to +2 (left to right)
} line_position_t;

line_position_t read_line_sensors(void) {
    line_position_t pos;
    
    // Read digital sensors
    for (int i = 0; i < 5; i++) {
        pos.sensors[i] = hal_gpio_read(LINE_SENSOR_PINS[i]);
    }
    
    // Calculate position
    int weighted_sum = 0;
    int count = 0;
    
    for (int i = 0; i < 5; i++) {
        if (pos.sensors[i]) {
            weighted_sum += (i - 2);  // -2, -1, 0, 1, 2
            count++;
        }
    }
    
    pos.position = (count > 0) ? (weighted_sum / count) : 0;
    
    return pos;
}
```

**PID Control:**

```c
typedef struct {
    float kp;  // Proportional gain
    float ki;  // Integral gain
    float kd;  // Derivative gain
    float integral;
    float last_error;
} pid_controller_t;

float pid_compute(pid_controller_t* pid, float error, float dt) {
    pid->integral += error * dt;
    float derivative = (error - pid->last_error) / dt;
    
    float output = pid->kp * error + 
                   pid->ki * pid->integral + 
                   pid->kd * derivative;
    
    pid->last_error = error;
    
    return output;
}

// Use for line following
pid_controller_t line_pid = {
    .kp = 50.0f,
    .ki = 0.1f,
    .kd = 10.0f
};

void line_following_control(void) {
    line_position_t pos = read_line_sensors();
    float error = pos.position;
    
    float correction = pid_compute(&line_pid, error, 0.1f);
    
    int base_speed = 150;
    motor_set_speed(MOTOR_LEFT, base_speed + correction);
    motor_set_speed(MOTOR_RIGHT, base_speed - correction);
}
```

## Robotic Arm

**Components:**
- 4-6 servo motors
- Gripper servo
- Joystick or remote control

**Servo Configuration:**

```c
servo_config_t servos[6] = {
    // Base rotation
    {.pin = 12, .min_pulse_us = 600, .max_pulse_us = 2400, 
     .min_angle = 0, .max_angle = 180},
    
    // Shoulder
    {.pin = 13, .min_pulse_us = 600, .max_pulse_us = 2400,
     .min_angle = 0, .max_angle = 180},
    
    // Elbow
    {.pin = 14, .min_pulse_us = 600, .max_pulse_us = 2400,
     .min_angle = 0, .max_angle = 180},
    
    // Wrist pitch
    {.pin = 15, .min_pulse_us = 600, .max_pulse_us = 2400,
     .min_angle = 0, .max_angle = 180},
    
    // Wrist roll
    {.pin = 16, .min_pulse_us = 600, .max_pulse_us = 2400,
     .min_angle = 0, .max_angle = 180},
    
    // Gripper
    {.pin = 17, .min_pulse_us = 600, .max_pulse_us = 2400,
     .min_angle = 0, .max_angle = 90}
};
```

**Inverse Kinematics (Simple 2-DOF):**

```c
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

typedef struct {
    float x, y;  // Target position
} point_t;

void arm_inverse_kinematics_2dof(point_t target, 
                                  float l1, float l2,
                                  float* theta1, float* theta2) {
    // l1, l2 are link lengths
    float r = sqrtf(target.x * target.x + target.y * target.y);
    
    // Elbow angle (using cosine rule)
    float cos_theta2 = (r*r - l1*l1 - l2*l2) / (2*l1*l2);
    *theta2 = acosf(cos_theta2);
    
    // Shoulder angle
    float alpha = atan2f(target.y, target.x);
    float beta = atan2f(l2 * sinf(*theta2), l1 + l2 * cosf(*theta2));
    *theta1 = alpha - beta;
    
    // Convert to degrees
    *theta1 = *theta1 * 180.0f / M_PI;
    *theta2 = *theta2 * 180.0f / M_PI;
}
```

## Hexapod Walker

**Components:**
- 18 servo motors (3 per leg × 6 legs)
- Controller (Arduino Mega or RPi)

**Gait Patterns:**

```c
typedef enum {
    GAIT_TRIPOD,      // Fast, stable (3 legs at a time)
    GAIT_WAVE,        // Slow, very stable (1 leg at a time)
    GAIT_RIPPLE       // Medium speed and stability
} gait_type_t;

void hexapod_tripod_gait(void) {
    // Tripod 1: legs 1, 3, 5
    // Tripod 2: legs 2, 4, 6
    
    // Phase 1: Lift and move tripod 1 forward
    hexapod_lift_legs(1, 3, 5);
    hexapod_move_legs_forward(1, 3, 5);
    hexapod_lower_legs(1, 3, 5);
    
    // Phase 2: Lift and move tripod 2 forward
    hexapod_lift_legs(2, 4, 6);
    hexapod_move_legs_forward(2, 4, 6);
    hexapod_lower_legs(2, 4, 6);
}
```

## Obstacle Avoidance

**Simple reactive behavior:**

```c
void obstacle_avoidance(void) {
    float front = distance_sensor_read(SENSOR_FRONT);
    float left = distance_sensor_read(SENSOR_LEFT);
    float right = distance_sensor_read(SENSOR_RIGHT);
    
    const float SAFE_DISTANCE = 30.0f;  // cm
    
    if (front < SAFE_DISTANCE) {
        // Obstacle ahead
        motor_stop(MOTOR_LEFT);
        motor_stop(MOTOR_RIGHT);
        
        // Turn away from closer obstacle
        if (left < right) {
            // Turn right
            motor_set_speed(MOTOR_LEFT, 200);
            motor_set_speed(MOTOR_RIGHT, -200);
        } else {
            // Turn left
            motor_set_speed(MOTOR_LEFT, -200);
            motor_set_speed(MOTOR_RIGHT, 200);
        }
        
        hal_delay_ms(500);
    } else {
        // Path clear, move forward
        motor_set_speed(MOTOR_LEFT, 200);
        motor_set_speed(MOTOR_RIGHT, 200);
    }
}
```

## SLAM (Simultaneous Localization and Mapping)

Basic dead reckoning:

```c
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

typedef struct {
    float x, y;      // Position (meters)
    float theta;     // Heading (radians)
} robot_pose_t;

void update_odometry(robot_pose_t* pose, 
                     float left_distance, 
                     float right_distance,
                     float wheel_base) {
    float distance = (left_distance + right_distance) / 2.0f;
    float delta_theta = (right_distance - left_distance) / wheel_base;
    
    // Update position
    pose->x += distance * cosf(pose->theta);
    pose->y += distance * sinf(pose->theta);
    pose->theta += delta_theta;
    
    // Normalize angle
    while (pose->theta > M_PI) pose->theta -= 2*M_PI;
    while (pose->theta < -M_PI) pose->theta += 2*M_PI;
}
```

## Battery Management

```c
void robot_battery_monitor(void) {
    battery_status_t bat;
    battery_read_status(&bat);
    
    if (bat.state_of_charge < 20.0f) {
        printf("WARNING: Low battery! %.1f%% remaining\n", 
               bat.state_of_charge);
        
        // Reduce speed to conserve power
        motor_set_speed(MOTOR_LEFT, 100);
        motor_set_speed(MOTOR_RIGHT, 100);
    }
    
    if (bat.state_of_charge < 10.0f) {
        printf("CRITICAL: Battery critical! Returning home.\n");
        robot_return_to_home();
    }
}
```

## Remote Control

**Bluetooth/WiFi control:**

```c
typedef struct {
    int8_t forward;   // -100 to 100
    int8_t turn;      // -100 to 100
    bool turbo;
} remote_command_t;

void robot_remote_control(remote_command_t* cmd) {
    int speed_mult = cmd->turbo ? 255 : 150;
    
    int left_speed = cmd->forward + cmd->turn;
    int right_speed = cmd->forward - cmd->turn;
    
    // Scale and clamp
    left_speed = (left_speed * speed_mult) / 100;
    right_speed = (right_speed * speed_mult) / 100;
    
    if (left_speed > 255) left_speed = 255;
    if (left_speed < -255) left_speed = -255;
    if (right_speed > 255) right_speed = 255;
    if (right_speed < -255) right_speed = -255;
    
    motor_set_speed(MOTOR_LEFT, left_speed);
    motor_set_speed(MOTOR_RIGHT, right_speed);
}
```
