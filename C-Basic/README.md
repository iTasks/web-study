# C-Basic: Production-Ready Embedded Systems Framework

A comprehensive C framework for production-ready embedded systems projects targeting:
- **Operating Systems & Hardware**: Raspberry Pi, Arduino, generic Linux, microcontrollers
- **Renewable Energy**: Solar panels, wind turbines, thermal generators with MPPT and battery management
- **Robotics**: Motor control, servos, sensors, navigation, path planning
- **Aerospace**: Drones, RC aircraft, rockets with flight control and telemetry

## Features

### Hardware Abstraction Layer (HAL)
- Unified GPIO, PWM, ADC interface across platforms
- I2C, SPI, UART communication
- Timer and delay functions
- Platform detection and initialization

### Energy Management System
- **Solar Power**: Voltage/current monitoring, MPPT (Maximum Power Point Tracking), efficiency calculation
- **Wind Energy**: RPM monitoring, power coefficient calculation, blade control
- **Thermal Energy**: Temperature-based power generation, efficiency optimization
- **Battery Management**: State of charge estimation, runtime prediction, charging control

### Robotics Framework
- **Motor Control**: DC motors, stepper motors, servos, brushless motors with encoder feedback
- **Sensors**: Ultrasonic, IR, LIDAR, IMU (accelerometer, gyroscope, magnetometer)
- **Navigation**: Dead reckoning, pose estimation, waypoint navigation
- **Path Planning**: Multi-waypoint support, obstacle avoidance

### Aerospace Control System
- **Flight Modes**: Manual, Stabilize, Altitude Hold, Position Hold, Auto, Return-to-Launch
- **Telemetry**: Real-time data logging and transmission
- **Safety Features**: Geofencing, battery monitoring, altitude limits
- **Auto-pilot**: Target altitude/position control, autonomous navigation
- **Sensor Fusion**: GPS, barometer, magnetometer, IMU integration

## Directory Structure

```
C-Basic/
├── include/          # Header files
│   ├── hal.h         # Hardware abstraction layer
│   ├── energy.h      # Renewable energy systems
│   ├── robotics.h    # Robotics control framework
│   └── aerospace.h   # Aerospace/flight control
├── src/              # Implementation files
│   ├── hal.c
│   ├── energy.c
│   ├── robotics.c
│   └── aerospace.c
├── examples/         # Example applications
│   ├── solar_monitor.c
│   ├── wind_monitor.c
│   ├── robot_control.c
│   ├── drone_flight.c
│   └── rc_aircraft.c
├── hardware/         # Platform-specific implementations
│   ├── rpi/          # Raspberry Pi
│   └── arduino/      # Arduino
├── energy/           # Energy system configurations
│   ├── solar/
│   ├── wind/
│   └── thermal/
├── robotics/         # Robotics configurations
├── aerospace/        # Aerospace configurations
│   ├── rocket/
│   └── rc_aircraft/
├── tests/            # Unit tests
├── docs/             # Documentation
├── Makefile          # Build system
└── README.md         # This file
```

## Quick Start

### Prerequisites

**For Linux/Raspberry Pi:**
```bash
sudo apt-get install build-essential gcc make
# Optional: for Raspberry Pi GPIO
sudo apt-get install libbcm2835-dev wiringpi
```

**For Arduino:**
```bash
sudo apt-get install gcc-avr avr-libc avrdude
```

### Building

**Build all examples:**
```bash
make all
```

**Build for Raspberry Pi:**
```bash
make RASPBERRY_PI=1
```

**Build for Arduino:**
```bash
make ARDUINO=1
```

**Clean build artifacts:**
```bash
make clean
```

### Running Examples

**Solar Power Monitor:**
```bash
./bin/solar_monitor
```

**Wind Turbine Monitor:**
```bash
./bin/wind_monitor
```

**Autonomous Robot:**
```bash
./bin/robot_control
```

**Quadcopter Flight Controller:**
```bash
./bin/drone_flight
```

**RC Aircraft Controller:**
```bash
./bin/rc_aircraft
```

## Hardware Setup Examples

### Solar Power Monitoring System

**Components:**
- Solar panel (12V-18V, 5A)
- Voltage divider (for ADC input)
- Current sensor (ACS712 or similar)
- Raspberry Pi or Arduino

**Connections:**
```
Solar Panel + → Voltage Divider → ADC Channel 0
Solar Panel + → Current Sensor → ADC Channel 1
Solar Panel - → GND
```

### Wind Turbine System

**Components:**
- Wind turbine generator
- Hall effect sensor for RPM
- Voltage and current sensors
- Charge controller

**Connections:**
```
Turbine Output → Voltage Sensor → ADC
Turbine Output → Current Sensor → ADC
RPM Sensor → GPIO (interrupt capable)
```

### Autonomous Robot

**Components:**
- 2x DC motors with encoders
- H-bridge motor driver (L298N)
- 3x Ultrasonic sensors (HC-SR04)
- IMU (MPU6050 or BNO055)
- Raspberry Pi or compatible

**Connections:**
```
Motors → H-Bridge → GPIO (PWM + Direction pins)
Encoders → GPIO (interrupt pins)
Ultrasonic → GPIO (Trigger + Echo pins)
IMU → I2C Bus
```

### Quadcopter/Drone

**Components:**
- Flight controller (Raspberry Pi or dedicated)
- 4x Brushless motors + ESCs
- IMU (MPU6050/9250)
- GPS module
- Barometer (BMP280/MS5611)
- RC receiver
- LiPo battery + voltage monitor

**Connections:**
```
ESCs → PWM outputs
RC Receiver → PPM/SBUS input
IMU → I2C
GPS → UART
Barometer → I2C
Battery Monitor → ADC
```

## API Documentation

### Hardware Abstraction Layer

```c
// Initialize HAL for specific platform
hal_init(PLATFORM_RASPBERRY_PI);

// GPIO control
hal_gpio_set_mode(pin, GPIO_MODE_OUTPUT);
hal_gpio_write(pin, GPIO_HIGH);
state = hal_gpio_read(pin);

// PWM control
hal_gpio_pwm_set_duty_cycle(pin, 128); // 50% duty cycle

// ADC reading
voltage = hal_adc_read_voltage(channel, 5.0f);
```

### Energy Systems

```c
// Solar panel configuration
solar_config_t config = {
    .voltage_pin = 0,
    .current_pin = 1,
    .max_voltage = 22.0f,
    .max_current = 5.0f,
    .vref = 5.0f
};
solar_init(&config);

// Read solar data
energy_reading_t reading;
solar_read(&reading);
printf("Power: %.2fW\n", reading.power);
```

### Robotics

```c
// Initialize motor
motor_config_t motor = {
    .type = MOTOR_TYPE_DC,
    .pwm_pin = 12,
    .dir_pin1 = 23,
    .dir_pin2 = 24
};
motor_init(0, &motor);

// Control motor
motor_set_speed(0, 200); // Forward at speed 200
motor_stop(0);
motor_brake(0);
```

### Aerospace

```c
// Initialize flight controller
aerospace_init(VEHICLE_MULTIROTOR);
flight_control_init();

// Arm and set mode
flight_control_arm();
flight_control_set_mode(FLIGHT_MODE_STABILIZE);

// Read telemetry
telemetry_t telem;
telemetry_update(&telem);
printf("Altitude: %.2fm\n", telem.altitude);
```

## Production Deployment

### Raspberry Pi

1. **Cross-compile** for ARM:
```bash
arm-linux-gnueabihf-gcc -o program program.c
```

2. **Enable hardware interfaces**:
```bash
sudo raspi-config
# Enable I2C, SPI, UART as needed
```

3. **Run as systemd service** for auto-start

### Arduino

1. **Compile for AVR**:
```bash
avr-gcc -mmcu=atmega328p -DF_CPU=16000000UL -o program.elf program.c
avr-objcopy -O ihex program.elf program.hex
```

2. **Flash to Arduino**:
```bash
avrdude -c arduino -p atmega328p -P /dev/ttyUSB0 -b 115200 -U flash:w:program.hex
```

## Safety Considerations

⚠️ **IMPORTANT SAFETY NOTES:**

### Energy Systems
- Always use proper fuses and circuit breakers
- Implement reverse polarity protection
- Monitor for overcharge/overdischarge conditions
- Use appropriate gauge wiring for current loads

### Robotics
- Implement emergency stop mechanisms
- Test in controlled environments first
- Add collision detection and avoidance
- Ensure mechanical fail-safes

### Aerospace
- Follow local regulations (FAA in US, EASA in EU, etc.)
- Never fly beyond visual line of sight without authorization
- Implement geofencing for safety
- Always test thoroughly in simulation first
- Use redundant safety systems
- Maintain proper battery safety protocols

## License

This project is provided as-is for educational and development purposes.

## Contributing

Contributions are welcome! Please ensure:
- Code follows existing style
- Functions are documented
- Safety considerations are addressed
- Tests are included for new features

## Support

For issues, questions, or contributions, please refer to the main repository.
