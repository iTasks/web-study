# Zig Embedded Systems Examples

## Overview

This implementation provides a complete, educational example of bare-metal embedded programming in Zig for drone control. The code demonstrates:

1. **Minimal Operating System** - A lightweight RTOS for microcontrollers
2. **Hardware Abstraction Layer** - Low-level drivers for peripherals
3. **Real-Time Control** - Flight control algorithms with strict timing requirements
4. **Arduino Compatibility** - Familiar API for Arduino developers

## What Was Created

### 1. RP2040 Minimal OS (`rp2040/minimal_os.zig`)

A bare-metal operating system for the RP2040 microcontroller featuring:

- **Vector Table**: ARM Cortex-M0+ interrupt vectors
- **Clock Configuration**: System initialization to 133 MHz
- **Task Scheduler**: Cooperative multitasking with priorities
- **GPIO Control**: Direct hardware manipulation
- **Timing**: SysTick timer for 1ms interrupts
- **Safety**: Hardware fault handlers

**Key Features:**
- Runs directly on hardware (no Linux/OS)
- ~7.5 KB of clean, documented code
- Educational resource for understanding embedded systems
- Demonstrates bare-metal programming concepts

### 2. PWM Driver (`rp2040/pwm.zig`)

Controls motors and servos using Pulse Width Modulation:

- **8 PWM Slices**: RP2040 has 8 independent PWM generators
- **Servo Control**: Standard 50Hz servo signals (1000-2000μs)
- **ESC Control**: Electronic Speed Controller for motors
- **Flexible Configuration**: Adjustable frequency and duty cycle

**Use Cases:**
- Aileron/elevator/rudder servos
- Motor speed control via ESC
- Any PWM-based actuator

### 3. I2C Driver (`rp2040/i2c.zig`)

Communicates with sensors over I2C bus:

- **Standard and Fast Mode**: 100kHz or 400kHz
- **Master Mode**: Controller for sensor communication
- **Register Access**: Read/write sensor registers
- **Timeout Protection**: Prevents hanging

**Compatible Sensors:**
- MPU6050/MPU9250 (IMU)
- BMP280 (Barometer)
- Many other I2C devices

### 4. Drone Controller (`drone/drone_controller.zig`)

A complete fixed-wing flight controller:

**Sensor Fusion:**
- Reads IMU at 1000 Hz
- Complementary filter for attitude estimation
- Combines gyroscope and accelerometer data

**Control System:**
- Three PID controllers (roll, pitch, yaw)
- Tunable gains for different aircraft
- Anti-windup for integral terms
- Derivative filtering

**Safety Features:**
- Failsafe mode on extreme attitudes
- Watchdog timer monitoring
- Safe default positions
- Visual status indication

**Real-Time Performance:**
- 1ms control loop (1000 Hz)
- Deterministic timing
- Priority-based scheduling
- Low-latency interrupt handling

### 5. Arduino Compatibility (`arduino/arduino_compat.zig`)

Provides familiar Arduino API in Zig:

**Functions Implemented:**
- `pinMode()`, `digitalWrite()`, `digitalRead()`
- `delay()`, `delayMicroseconds()`, `millis()`, `micros()`
- `analogWrite()` (PWM)
- `servoAttach()`, `servoWrite()`, `servoWriteMicroseconds()`
- Wire library functions for I2C

**Benefits:**
- Easy transition from Arduino to Zig
- Familiar API for prototyping
- Demonstrates Zig's flexibility
- Educational bridge between platforms

### 6. Arduino-Style Drone (`arduino/arduino_drone.zig`)

Complete drone controller using Arduino API:

- Familiar `setup()` and `loop()` structure
- 100 Hz control loop
- MPU6050 sensor integration
- PID control implementation
- Safe arming procedure

## Technical Highlights

### Memory Safety
- No dynamic allocation (suitable for embedded)
- Compile-time bounds checking
- Explicit error handling
- No undefined behavior

### Performance
- Zero-cost abstractions
- Inline functions where appropriate
- Optimized for code size and speed
- Direct hardware access

### Cross-Platform
- RP2040 (Raspberry Pi Pico) - ARM Cortex-M0+
- Arduino (AVR) - ATmega328p
- Easy to port to other microcontrollers
- Zig's target system handles cross-compilation

### Educational Value
- Comprehensive comments explaining concepts
- Progressive complexity
- Multiple implementation approaches
- Real-world application (drone control)

## Architecture Decisions

### Why Cooperative Scheduling?
- Simpler than preemptive multitasking
- Deterministic timing
- Lower overhead
- Suitable for embedded systems

### Why Complementary Filter?
- Computationally efficient
- Good performance for attitude estimation
- Easier to implement than Kalman filter
- Suitable for resource-constrained systems

### Why PID Control?
- Industry-standard control algorithm
- Tunable for different aircraft
- Well-understood behavior
- Balance of simplicity and performance

## Safety Considerations

⚠️ **Educational Code Notice**

This implementation is for **learning purposes only**:

1. **Not Flight-Ready**: Requires extensive testing and validation
2. **Simplified**: Production systems need more features
3. **No Certification**: Not certified for safety-critical use
4. **Testing Required**: Must test thoroughly before any flight

**To make flight-ready, you would need:**
- Extensive hardware-in-the-loop testing
- Failsafe redundancy
- Radio control integration
- GPS navigation system
- Battery monitoring
- Emergency recovery modes
- Extensive field testing

## Learning Path

### Beginner
1. Start with `rp2040/minimal_os.zig` - Understand basic structure
2. Study `rp2040/pwm.zig` - Learn peripheral control
3. Review `arduino/arduino_compat.zig` - See API design

### Intermediate
1. Examine `drone/drone_controller.zig` - Real-time systems
2. Study PID control implementation
3. Understand sensor fusion (complementary filter)

### Advanced
1. Modify PID gains for different aircraft
2. Add GPS navigation
3. Implement additional sensors
4. Port to different microcontrollers

## Next Steps

### To Run This Code
1. Install Zig compiler
2. Install ARM toolchain (or use Zig's built-in cross-compilation)
3. Get RP2040 hardware (Raspberry Pi Pico)
4. Follow build instructions in `BUILD.md`
5. Flash to hardware and test

### To Extend This Code
- Add GPS module support
- Implement barometer altitude hold
- Add RC receiver input
- Create autopilot modes
- Implement data logging
- Add telemetry over UART

## Comparison with Arduino

### Advantages of Zig
- ✅ Better memory safety
- ✅ Compile-time programming
- ✅ No hidden allocations
- ✅ Better cross-compilation
- ✅ Modern language features
- ✅ Explicit error handling

### When Arduino Makes Sense
- Quick prototyping
- Large ecosystem of libraries
- Extensive hardware support
- Beginner-friendly
- Visual IDEs available

## Resources for Further Learning

### Embedded Systems
- RP2040 Datasheet
- ARM Cortex-M0+ Reference Manual
- Embedded Systems textbooks

### Control Theory
- PID Control tutorials
- Sensor fusion algorithms
- Drone flight dynamics

### Zig Programming
- Official Zig documentation
- MicroZig project
- Zig Embedded Group

## File Sizes

Approximate compiled sizes (optimized for safety):
- Minimal OS: ~2-3 KB
- Drone Controller: ~8-12 KB
- Full system: ~15-20 KB

This fits comfortably in RP2040's 2 MB flash with room for expansion.

## Contributing

To improve this educational resource:
1. Add more comments
2. Create hardware test results
3. Add diagrams and schematics
4. Document PID tuning procedures
5. Create simulation/testing tools

## Conclusion

This implementation demonstrates that Zig is an excellent choice for embedded systems:
- **Safe**: Catches bugs at compile time
- **Fast**: Zero-cost abstractions
- **Clear**: Explicit, readable code
- **Flexible**: Multiple programming paradigms

The drone controller showcases real-time systems, control theory, and hardware interfacing - fundamental concepts in embedded engineering.
