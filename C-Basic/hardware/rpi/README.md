# Raspberry Pi Specific Implementation

[← Back to C-Basic](../../README.md) | [Main README](../../../README.md)

This directory contains Raspberry Pi-specific implementations using the BCM2835 library.

## Installation

```bash
# Download and install BCM2835 library
cd /tmp
wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.71.tar.gz
tar -xzf bcm2835-1.71.tar.gz
cd bcm2835-1.71
./configure
make
sudo make check
sudo make install
```

## GPIO Pin Mapping

Raspberry Pi uses BCM numbering (not physical pin numbers).

Common pins for projects:
- GPIO 2,3: I2C (SDA, SCL)
- GPIO 14,15: UART (TX, RX)
- GPIO 18: Hardware PWM
- GPIO 12,13,19: Additional PWM
- GPIO 10,9,11,8: SPI

## Building

```bash
cd C-Basic
make RASPBERRY_PI=1
```

## Running

GPIO access requires root privileges:

```bash
sudo ./bin/solar_monitor
```

Or add user to gpio group:

```bash
sudo usermod -a -G gpio $USER
# Log out and back in
```

## Notes

- All GPIO are 3.3V (NOT 5V tolerant)
- Maximum current per pin: 16mA
- Total GPIO current: 50mA
- Use level shifters for 5V devices
