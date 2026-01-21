# Zig Embedded Systems - Minimal OS for Drone Control

## Purpose

This directory contains Zig implementations for embedded systems, focusing on bare-metal programming for microcontrollers. The primary application is a minimal real-time operating system (RTOS) for small fixed-wing drone control using Arduino and RP2040 (Raspberry Pi Pico).

## Contents

### RP2040 (Raspberry Pi Pico) Implementation
- `rp2040/` - Bare-metal RP2040 implementation
  - Hardware abstraction layer (HAL)
  - GPIO, PWM, UART, SPI, I2C drivers
  - Real-time scheduler
  - Interrupt handling

### Arduino Compatibility
- `arduino/` - Arduino-compatible implementations
  - Arduino-style API wrappers
  - Cross-platform compatibility layer

### Drone Control System
- `drone/` - Fixed-wing drone control implementation
  - Flight controller core
  - Sensor fusion (IMU, GPS, Barometer)
  - PID controllers for stabilization
  - Motor and servo control
  - Safety and failsafe systems

## Hardware Requirements

### Raspberry Pi Pico (RP2040)
- **MCU**: Dual-core ARM Cortex-M0+ @ 133 MHz
- **RAM**: 264 KB SRAM
- **Flash**: 2 MB onboard flash
- **GPIO**: 26 multi-function GPIO pins
- **PWM**: 16 PWM channels
- **Interfaces**: 2x UART, 2x SPI, 2x I2C
- **Cost**: ~$4 USD

### Required Sensors for Drone
- **IMU**: MPU6050 or MPU9250 (gyroscope + accelerometer)
- **GPS**: NEO-6M or similar UART GPS module
- **Barometer**: BMP280 or MS5611 (altitude)
- **ESC**: Electronic Speed Controller for motor
- **Servos**: 2-4 servos for control surfaces (aileron, elevator, rudder)

### Pinout Configuration
```
RP2040 Pin Assignments:
- GPIO 0-1:   UART0 (GPS)
- GPIO 2-3:   I2C0 (IMU, Barometer)
- GPIO 4:     PWM (Motor ESC)
- GPIO 5-7:   PWM (Servos: Aileron, Elevator, Rudder)
- GPIO 8-9:   UART1 (Debug/Telemetry)
- GPIO 10:    Status LED
```

## Setup Instructions

### Prerequisites
- Zig 0.11.0 or higher
- ARM GCC toolchain (for cross-compilation)
- Picotool or OpenOCD (for flashing)
- USB cable for programming

### Installation

1. **Install Zig**
   ```bash
   # See main zig/README.md for Zig installation
   zig version  # Verify installation
   ```

2. **Install ARM Toolchain** (Optional - Zig can cross-compile)
   ```bash
   # Ubuntu/Debian
   sudo apt-get install gcc-arm-none-eabi
   
   # macOS
   brew install arm-none-eabi-gcc
   ```

3. **Install Picotool** (for RP2040)
   ```bash
   # Ubuntu/Debian
   sudo apt-get install libusb-1.0-0-dev
   git clone https://github.com/raspberrypi/picotool.git
   cd picotool
   mkdir build && cd build
   cmake ..
   make
   sudo make install
   ```

### Building

#### Build for RP2040
```bash
cd zig/embedded/rp2040

# Build the minimal OS
zig build-exe -target thumb-freestanding-eabi -mcpu cortex_m0plus \
  -O ReleaseSafe minimal_os.zig

# Build drone controller
zig build-exe -target thumb-freestanding-eabi -mcpu cortex_m0plus \
  -O ReleaseSafe ../drone/drone_controller.zig
```

#### Build for Arduino (AVR)
```bash
cd zig/embedded/arduino

# Build for Arduino Uno (ATmega328p)
zig build-exe -target avr-freestanding-none -mcpu atmega328p \
  -O ReleaseSafe arduino_drone.zig
```

### Flashing

#### Flash to RP2040 (Pico)
```bash
# Method 1: Using picotool
# Hold BOOTSEL button while connecting USB
picotool load -x firmware.elf

# Method 2: Drag and drop UF2 file
# Hold BOOTSEL, connect USB, copy .uf2 file to mounted drive
```

#### Flash to Arduino
```bash
# Using avrdude
avrdude -p atmega328p -c arduino -P /dev/ttyUSB0 -b 115200 -U flash:w:firmware.hex:i
```

## Architecture Overview

### Minimal OS Components

1. **Bootloader & Initialization**
   - System clock configuration
   - Memory initialization
   - Peripheral setup
   - Interrupt vector table

2. **Real-Time Scheduler**
   - Cooperative task scheduling
   - Priority-based execution
   - Time-slicing for fairness
   - Low latency interrupt handling

3. **Hardware Abstraction Layer (HAL)**
   - GPIO control
   - PWM generation
   - UART, SPI, I2C communication
   - ADC reading
   - Timer management

4. **Drone Control System**
   - Sensor data acquisition (1kHz)
   - Attitude estimation (complementary filter)
   - PID control loops (roll, pitch, yaw)
   - Motor/servo output generation
   - Safety monitoring and failsafe

### Control Loop Timing

```
Main Loop (1kHz / 1ms):
├─ Read sensors (IMU)           [0.1ms]
├─ Attitude estimation          [0.2ms]
├─ PID calculations             [0.3ms]
├─ Generate PWM outputs         [0.1ms]
└─ Safety checks                [0.1ms]

Background Tasks:
├─ GPS update (10Hz)
├─ Barometer read (50Hz)
├─ Telemetry transmission (5Hz)
└─ LED status updates (2Hz)
```

## Flight Control Algorithms

### Attitude Estimation
- **Complementary Filter**: Combines gyroscope and accelerometer
- **Update Rate**: 1000 Hz
- **Latency**: < 1ms

### PID Controllers
```
Roll Control:
- P gain: 1.5
- I gain: 0.1
- D gain: 0.05
- Output: Aileron servo position

Pitch Control:
- P gain: 1.2
- I gain: 0.08
- D gain: 0.04
- Output: Elevator servo position

Yaw Control:
- P gain: 2.0
- I gain: 0.15
- D gain: 0.1
- Output: Rudder servo position
```

### Safety Features
- **Watchdog Timer**: Resets system if main loop hangs
- **Failsafe Mode**: Level flight if RC signal lost
- **Brownout Detection**: Safe shutdown on low voltage
- **Geofencing**: GPS-based boundary enforcement
- **Max Angle Limits**: Prevent excessive bank/pitch

## Usage

### Basic Flight Controller
```bash
# Build and flash the basic flight controller
cd zig/embedded/drone
zig build-exe -target thumb-freestanding-eabi -mcpu cortex_m0plus \
  -O ReleaseSafe drone_controller.zig
picotool load -x drone_controller.elf

# Monitor via UART
screen /dev/ttyUSB0 115200
```

### Testing Individual Components
```bash
# Test PWM output
zig run -target thumb-freestanding-eabi ../rp2040/pwm_test.zig

# Test IMU reading
zig run -target thumb-freestanding-eabi ../rp2040/imu_test.zig

# Test GPS parsing
zig run -target thumb-freestanding-eabi ../rp2040/gps_test.zig
```

## Safety Warning

⚠️ **WARNING**: This is educational code for learning embedded systems programming.

- **DO NOT** use for actual flight without extensive testing
- **DO NOT** fly near people or property
- **ALWAYS** test in a safe, controlled environment
- **ENSURE** proper failsafe mechanisms are in place
- **FOLLOW** local regulations for UAV operation
- **UNDERSTAND** the risks of autonomous flight

## Key Learning Topics

- **Bare-Metal Programming**: Direct hardware control without OS
- **Real-Time Systems**: Deterministic timing and scheduling
- **Embedded Systems**: Resource-constrained programming
- **Control Theory**: PID controllers and feedback loops
- **Sensor Fusion**: Combining multiple sensor inputs
- **Hardware Interfaces**: GPIO, PWM, UART, I2C, SPI
- **Cross-Compilation**: Building for different architectures
- **Safety-Critical Systems**: Failsafe and error handling

## Resources

### RP2040 Documentation
- [RP2040 Datasheet](https://datasheets.raspberrypi.com/rp2040/rp2040-datasheet.pdf)
- [Pico C SDK](https://github.com/raspberrypi/pico-sdk)
- [Hardware Design](https://datasheets.raspberrypi.com/rp2040/hardware-design-with-rp2040.pdf)

### Drone Control Resources
- [ArduPilot Architecture](https://ardupilot.org/dev/docs/apmcopter-programming-basics.html)
- [PX4 Flight Stack](https://docs.px4.io/main/en/)
- [Betaflight](https://betaflight.com/) - For reference
- [DIY Drone Guide](https://www.instructables.com/DIY-Arduino-Flight-Controller/)

### Embedded Zig Resources
- [MicroZig](https://github.com/ZigEmbeddedGroup/microzig) - Embedded Zig framework
- [Zig Embedded Group](https://github.com/ZigEmbeddedGroup)
- [Zig Cross-Compilation](https://ziglang.org/learn/overview/#cross-compiling-is-a-first-class-use-case)

## Contributing

Contributions are welcome! Please ensure:
1. Code compiles for target platforms
2. Comments explain embedded-specific concepts
3. Safety considerations are documented
4. Hardware requirements are clearly stated
5. Testing procedures are included

## License

Educational use only. See repository license for details.
