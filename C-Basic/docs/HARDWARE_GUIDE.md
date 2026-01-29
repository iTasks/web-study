# Hardware Platform Guide

This document provides detailed information on deploying the C-Basic framework on different hardware platforms.

## Raspberry Pi

### Supported Models
- Raspberry Pi 4 Model B (Recommended)
- Raspberry Pi 3 Model B/B+
- Raspberry Pi Zero W/2W
- Raspberry Pi 5

### GPIO Pin Mapping

**Raspberry Pi 4 (BCM2711)**

```
Pin Number | BCM GPIO | Function
-----------|----------|--------------------
3          | GPIO 2   | I2C SDA
5          | GPIO 3   | I2C SCL
8          | GPIO 14  | UART TX
10         | GPIO 15  | UART RX
11         | GPIO 17  | General Purpose
12         | GPIO 18  | PWM0
13         | GPIO 27  | General Purpose
15         | GPIO 22  | General Purpose
19         | GPIO 10  | SPI MOSI
21         | GPIO 9   | SPI MISO
23         | GPIO 11  | SPI SCLK
24         | GPIO 8   | SPI CE0
```

### Enable Interfaces

```bash
sudo raspi-config
# Select "Interfacing Options"
# Enable: I2C, SPI, Serial/UART as needed
```

### Required Libraries

```bash
# For GPIO access
sudo apt-get install libbcm2835-dev

# Alternative: WiringPi (deprecated but still works)
sudo apt-get install wiringpi

# For I2C tools
sudo apt-get install i2c-tools
```

### Compile and Run

```bash
cd C-Basic
make RASPBERRY_PI=1
sudo ./bin/solar_monitor  # Needs sudo for GPIO access
```

## Arduino

### Supported Boards
- Arduino Uno (ATmega328P)
- Arduino Mega 2560 (ATmega2560)
- Arduino Nano
- Arduino Pro Mini

### Pin Mapping

**Arduino Uno**

```
Pin | Function        | Alternative
----|-----------------|------------------
0   | RX (UART)      | Digital I/O
1   | TX (UART)      | Digital I/O
2   | Digital I/O    | Interrupt 0
3   | PWM            | Interrupt 1
5   | PWM            |
6   | PWM            |
9   | PWM            |
10  | PWM / SPI SS   |
11  | PWM / SPI MOSI |
12  | SPI MISO       |
13  | SPI SCK        | LED
A0  | Analog Input   |
A4  | I2C SDA        |
A5  | I2C SCL        |
```

### Toolchain Setup

```bash
# Install AVR toolchain
sudo apt-get install gcc-avr avr-libc avrdude

# Verify installation
avr-gcc --version
```

### Compile for Arduino

```bash
cd C-Basic
make ARDUINO=1

# Flash to Arduino
avrdude -c arduino -p atmega328p -P /dev/ttyUSB0 -b 115200 -U flash:w:bin/program.hex
```

### Memory Considerations

Arduino Uno has limited resources:
- Flash: 32KB
- RAM: 2KB
- EEPROM: 1KB

Optimize code by:
- Using `PROGMEM` for constant data
- Minimizing global variables
- Using efficient data types (uint8_t instead of int)

## Generic Linux

Works on any Linux system with GPIO support:
- BeagleBone Black
- NVIDIA Jetson Nano
- Orange Pi
- Banana Pi

### GPIO Access

Use sysfs GPIO interface:

```c
// Export GPIO
echo 17 > /sys/class/gpio/export

// Set direction
echo out > /sys/class/gpio/gpio17/direction

// Set value
echo 1 > /sys/class/gpio/gpio17/value
```

Or use libgpiod (modern approach):

```bash
sudo apt-get install libgpiod-dev
```

## Platform-Specific Features

### Raspberry Pi
- Hardware PWM on specific pins
- DMA-capable GPIO
- Built-in pull-up/down resistors
- 3.3V logic levels (⚠️ NOT 5V tolerant)

### Arduino
- True analog inputs (10-bit ADC)
- 5V logic levels
- Hardware interrupts on specific pins
- Watchdog timer

### Considerations

| Feature           | Raspberry Pi | Arduino | Generic Linux |
|-------------------|--------------|---------|---------------|
| GPIO Speed        | Medium       | Fast    | Varies        |
| PWM               | Hardware     | Timer   | Software      |
| ADC               | External     | Built-in| External      |
| Operating System  | Linux        | None    | Linux         |
| Real-time         | No           | Yes     | No            |
| Power             | ~2-3W        | ~50mW   | Varies        |

## Best Practices

1. **Level Shifting**: Use level shifters when interfacing 5V devices with 3.3V systems
2. **Current Limiting**: Add resistors to protect GPIO pins
3. **Pull Resistors**: Use pull-up/down resistors for reliable digital reads
4. **Debouncing**: Implement software debouncing for buttons/switches
5. **Power Supply**: Use adequate power supply for motors and high-current devices
6. **Isolation**: Use optocouplers for high-voltage/high-current circuits
