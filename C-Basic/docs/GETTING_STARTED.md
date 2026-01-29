# Getting Started with C-Basic

This guide will help you get started with the C-Basic framework for embedded systems.

## Installation

### Linux / Raspberry Pi

```bash
# Clone the repository
git clone https://github.com/iTasks/web-study.git
cd web-study/C-Basic

# Install build tools
sudo apt-get update
sudo apt-get install build-essential gcc make

# Build the framework
make all

# Test an example
./bin/solar_monitor
```

### Arduino

```bash
# Install AVR toolchain
sudo apt-get install gcc-avr avr-libc avrdude

# Build for Arduino
cd C-Basic
make ARDUINO=1

# Flash to device
avrdude -c arduino -p atmega328p -P /dev/ttyUSB0 -b 115200 -U flash:w:bin/program.hex
```

## Your First Project

### Simple GPIO Blink (LED)

Create a new file `my_blink.c`:

```c
#include "hal.h"
#include <stdio.h>

#define LED_PIN 18

int main(void) {
    // Initialize HAL
    hal_init(PLATFORM_RPI);
    
    // Set LED pin as output
    hal_gpio_set_mode(LED_PIN, GPIO_MODE_OUTPUT);
    
    printf("Blinking LED on GPIO %d\n", LED_PIN);
    
    // Blink loop
    for (int i = 0; i < 10; i++) {
        hal_gpio_write(LED_PIN, GPIO_HIGH);
        printf("LED ON\n");
        hal_delay_ms(500);
        
        hal_gpio_write(LED_PIN, GPIO_LOW);
        printf("LED OFF\n");
        hal_delay_ms(500);
    }
    
    hal_deinit();
    return 0;
}
```

Compile and run:

```bash
gcc -I./include my_blink.c src/hal.c -o my_blink -lm
sudo ./my_blink
```

### Reading a Sensor (Temperature)

```c
#include "hal.h"
#include <stdio.h>

#define TEMP_SENSOR_PIN 0  // ADC channel 0

int main(void) {
    hal_init(PLATFORM_RPI);
    hal_adc_init(TEMP_SENSOR_PIN);
    
    printf("Reading temperature sensor...\n");
    
    for (int i = 0; i < 10; i++) {
        // Read voltage from sensor
        float voltage = hal_adc_read_voltage(TEMP_SENSOR_PIN, 3.3f);
        
        // Convert to temperature (example: LM35 sensor)
        // LM35: 10mV per degree Celsius
        float temperature = voltage * 100.0f;
        
        printf("Temperature: %.1f°C\n", temperature);
        hal_delay_ms(1000);
    }
    
    hal_deinit();
    return 0;
}
```

### Controlling a Motor

```c
#include "hal.h"
#include "robotics.h"
#include <stdio.h>

int main(void) {
    hal_init(PLATFORM_RPI);
    robotics_init();
    
    // Configure motor
    motor_config_t motor = {
        .type = MOTOR_TYPE_DC,
        .pwm_pin = 12,
        .dir_pin1 = 23,
        .dir_pin2 = 24,
        .max_speed = 255
    };
    
    motor_init(0, &motor);
    
    printf("Testing motor...\n");
    
    // Forward
    printf("Forward...\n");
    motor_set_speed(0, 200);
    hal_delay_ms(2000);
    
    // Stop
    printf("Stop...\n");
    motor_stop(0);
    hal_delay_ms(1000);
    
    // Reverse
    printf("Reverse...\n");
    motor_set_speed(0, -200);
    hal_delay_ms(2000);
    
    // Stop
    motor_stop(0);
    
    robotics_deinit();
    hal_deinit();
    return 0;
}
```

## Project Structure

When creating a new project:

```
my_project/
├── main.c              # Your main program
├── config.h            # Configuration constants
├── Makefile            # Build configuration
└── README.md           # Project documentation
```

Example Makefile:

```makefile
CC = gcc
CFLAGS = -Wall -Wextra -O2 -I../include
LDFLAGS = -lm -lpthread

CBASIC_SRC = ../src/hal.c ../src/energy.c ../src/robotics.c ../src/aerospace.c

all: my_project

my_project: main.c $(CBASIC_SRC)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

clean:
	rm -f my_project
```

## Common Patterns

### Error Handling

```c
int result = sensor_init();
if (result != 0) {
    fprintf(stderr, "Error initializing sensor: %d\n", result);
    return 1;
}
```

### Graceful Shutdown

```c
#include <signal.h>

volatile int running = 1;

void signal_handler(int signum) {
    (void)signum;
    running = 0;
}

int main(void) {
    signal(SIGINT, signal_handler);
    
    hal_init(PLATFORM_RPI);
    
    while (running) {
        // Main loop
        do_work();
        hal_delay_ms(100);
    }
    
    // Cleanup
    hal_deinit();
    printf("Exited cleanly\n");
    return 0;
}
```

### Data Logging

```c
FILE* log_file = fopen("data.csv", "w");
fprintf(log_file, "timestamp,value\n");

while (running) {
    uint32_t timestamp = hal_millis();
    float value = read_sensor();
    
    fprintf(log_file, "%u,%.2f\n", timestamp, value);
    fflush(log_file);  // Ensure data is written
    
    hal_delay_ms(1000);
}

fclose(log_file);
```

## Debugging Tips

### Enable Verbose Output

```c
#define DEBUG 1

#ifdef DEBUG
    #define DEBUG_PRINT(fmt, ...) printf(fmt, ##__VA_ARGS__)
#else
    #define DEBUG_PRINT(fmt, ...)
#endif

// Usage
DEBUG_PRINT("Sensor value: %.2f\n", value);
```

### Use GDB

```bash
# Compile with debug symbols
gcc -g -O0 -I./include main.c src/hal.c -o main

# Run with GDB
gdb ./main

# Inside GDB:
(gdb) break main
(gdb) run
(gdb) next
(gdb) print variable_name
```

### Check GPIO Permissions

```bash
# List GPIO devices
ls -l /sys/class/gpio/

# Add user to gpio group
sudo usermod -a -G gpio $USER

# Check groups
groups
```

## Best Practices

1. **Initialize before use**: Always call `*_init()` functions before using a module
2. **Clean up**: Call `*_deinit()` functions when done
3. **Check return values**: Most functions return 0 on success, -1 on error
4. **Use const for config**: Mark configuration structs as const
5. **Limit scope**: Use static for internal functions
6. **Document your code**: Add comments for complex logic

## Performance Optimization

### Minimize System Calls

```c
// Bad: Multiple calls
for (int i = 0; i < 100; i++) {
    read_sensor();
}

// Good: Batch if possible
read_sensor_batch(buffer, 100);
```

### Use Appropriate Data Types

```c
// Use smallest type that fits the data
uint8_t pin_number;        // 0-255
int16_t motor_speed;       // -255 to 255
float sensor_reading;      // Floating point needed
```

### Avoid Dynamic Memory

```c
// Bad for embedded systems
int* array = malloc(100 * sizeof(int));

// Good: Use stack allocation
int array[100];
```

## Troubleshooting

### "Permission denied" when accessing GPIO

```bash
sudo ./program
# or
sudo usermod -a -G gpio $USER
```

### "Cannot find -lm"

```bash
# Install math library (usually installed by default)
sudo apt-get install libc6-dev
```

### "I2C/SPI device not found"

```bash
# Enable in raspi-config
sudo raspi-config
# Select "Interfacing Options" -> Enable I2C/SPI

# Check if enabled
ls /dev/i2c* /dev/spi*
```

### Program hangs

- Check for infinite loops
- Add debug prints to find where it hangs
- Check sensor connections
- Verify power supply is adequate

## Next Steps

1. Explore the examples in `examples/` directory
2. Read the detailed documentation in `docs/`
3. Check hardware-specific guides in `hardware/`
4. Review application examples in `energy/`, `robotics/`, `aerospace/`
5. Join the community and share your projects!

## Resources

- [Main README](../README.md) - Complete feature list
- [Hardware Guide](HARDWARE_GUIDE.md) - Platform-specific details
- [Deployment Guide](DEPLOYMENT.md) - Production deployment
- [Example Projects](../examples/) - Working code examples

## Getting Help

If you run into issues:

1. Check the documentation
2. Look at the example code
3. Search for similar issues
4. Ask the community
5. Report bugs with detailed information

Happy coding! 🚀
