# Arduino Specific Implementation

[← Back to C-Basic](../../README.md) | [Main README](../../../README.md)

This directory contains Arduino-specific code and examples.

## Supported Boards

- Arduino Uno (ATmega328P)
- Arduino Mega 2560 (ATmega2560)
- Arduino Nano
- Arduino Pro Mini

## Installation

```bash
# Install AVR toolchain
sudo apt-get install gcc-avr avr-libc avrdude
```

## Memory Constraints

Arduino Uno has limited memory:
- Flash: 32KB (program storage)
- SRAM: 2KB (variables)
- EEPROM: 1KB (persistent storage)

Optimization tips:
- Use `const` and `PROGMEM` for constants
- Minimize global variables
- Use smaller data types (uint8_t vs int)
- Disable unused features

## Building

```bash
cd C-Basic
make ARDUINO=1
```

## Flashing

```bash
# Find Arduino port
ls /dev/ttyUSB* /dev/ttyACM*

# Flash to Arduino
avrdude -c arduino -p atmega328p -P /dev/ttyUSB0 -b 115200 -U flash:w:bin/program.hex
```

## Pin Mapping

```
Arduino Pin | ATmega Pin | Function
------------|------------|------------------
0           | PD0        | RX (UART)
1           | PD1        | TX (UART)
2-7         | PD2-PD7    | Digital I/O
8-13        | PB0-PB5    | Digital I/O
3,5,6,9,10,11| Timer PWM | PWM Output
A0-A5       | PC0-PC5    | Analog Input
A4          | PC4        | I2C SDA
A5          | PC5        | I2C SCL
```

## Common Issues

**Sketch too large:**
- Reduce code size
- Remove unused libraries
- Use optimization flags

**Out of memory:**
- Use F() macro for strings
- Store data in PROGMEM
- Reduce buffer sizes
