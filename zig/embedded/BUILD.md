# Build Scripts for Embedded Zig Projects

This directory contains helper scripts and build configurations for building embedded Zig projects.

## Building for RP2040 (Raspberry Pi Pico)

### Minimal OS
```bash
#!/bin/bash
# Build minimal OS for RP2040

cd "$(dirname "$0")/.."

zig build-exe \
  -target thumb-freestanding-eabi \
  -mcpu cortex_m0plus \
  -O ReleaseSafe \
  --name minimal_os \
  rp2040/minimal_os.zig

echo "Built: minimal_os"
```

### Drone Controller
```bash
#!/bin/bash
# Build drone controller for RP2040

cd "$(dirname "$0")/.."

zig build-exe \
  -target thumb-freestanding-eabi \
  -mcpu cortex_m0plus \
  -O ReleaseSafe \
  --name drone_controller \
  drone/drone_controller.zig

echo "Built: drone_controller"
```

### Arduino-style Drone
```bash
#!/bin/bash
# Build Arduino-style drone for RP2040

cd "$(dirname "$0")/.."

zig build-exe \
  -target thumb-freestanding-eabi \
  -mcpu cortex_m0plus \
  -O ReleaseSafe \
  --name arduino_drone \
  arduino/arduino_drone.zig

echo "Built: arduino_drone"
```

## Building for Arduino (AVR)

### Arduino Uno (ATmega328p)
```bash
#!/bin/bash
# Build for Arduino Uno

cd "$(dirname "$0")/.."

zig build-exe \
  -target avr-freestanding-none \
  -mcpu atmega328p \
  -O ReleaseSmall \
  --name arduino_drone_avr \
  arduino/arduino_drone.zig

echo "Built: arduino_drone_avr"
```

## Linker Script

For RP2040, you may need a linker script. Here's a minimal example:

**rp2040.ld**
```ld
/* Linker script for RP2040 */

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x10000000, LENGTH = 2048K
    RAM (rwx)   : ORIGIN = 0x20000000, LENGTH = 264K
}

ENTRY(reset_handler)

SECTIONS
{
    .vector_table : {
        KEEP(*(.vector_table))
    } > FLASH

    .text : {
        *(.text*)
        *(.rodata*)
    } > FLASH

    .data : {
        *(.data*)
    } > RAM AT > FLASH

    .bss : {
        *(.bss*)
        *(COMMON)
    } > RAM

    /DISCARD/ : {
        *(.ARM.exidx*)
    }
}
```

## Using Build Scripts

1. Make scripts executable:
```bash
chmod +x build_*.sh
```

2. Run build script:
```bash
./build_rp2040_drone.sh
```

3. Flash to device:
```bash
# For RP2040
picotool load -x drone_controller.elf

# For Arduino
avrdude -p atmega328p -c arduino -P /dev/ttyUSB0 -U flash:w:arduino_drone_avr.hex:i
```

## Optimization Levels

- **ReleaseSafe**: Optimized with safety checks (recommended for embedded)
- **ReleaseFast**: Maximum optimization, fewer safety checks
- **ReleaseSmall**: Optimize for code size (important for AVR)
- **Debug**: No optimization, full debug info

## Cross-Compilation Targets

Zig supports many embedded targets:

- `thumb-freestanding-eabi`: ARM Cortex-M (RP2040, STM32, etc.)
- `avr-freestanding-none`: AVR microcontrollers (Arduino)
- `riscv32-freestanding-none`: RISC-V 32-bit
- `mips-freestanding-none`: MIPS microcontrollers

## Tips

1. **Code Size**: Use `-O ReleaseSmall` for size-constrained devices
2. **Debugging**: Build with `-O Debug` for development
3. **Safety**: Use `-O ReleaseSafe` for production embedded systems
4. **Linker Script**: Use `-T linker.ld` to specify custom linker script
5. **Entry Point**: Use `--entry reset_handler` to set custom entry point
