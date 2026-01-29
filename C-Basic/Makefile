# Makefile for C-Basic Production-Ready Project
# Supports OS, Hardware (RPi, Arduino), Renewable Energy, Robotics, Aerospace

CC = gcc
CFLAGS = -Wall -Wextra -O2 -I./include
LDFLAGS = -lm -lpthread

# Directories
SRC_DIR = src
INC_DIR = include
EXAMPLES_DIR = examples
BUILD_DIR = build
BIN_DIR = bin

# Source files
CORE_SOURCES = $(wildcard $(SRC_DIR)/*.c)
CORE_OBJECTS = $(CORE_SOURCES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

# Example programs
EXAMPLES = $(BIN_DIR)/solar_monitor \
           $(BIN_DIR)/wind_monitor \
           $(BIN_DIR)/robot_control \
           $(BIN_DIR)/drone_flight \
           $(BIN_DIR)/rc_aircraft

# Platform-specific settings
ifdef RASPBERRY_PI
    CFLAGS += -DRASPBERRY_PI
    LDFLAGS += -lbcm2835 -lwiringPi
endif

ifdef ARDUINO
    CC = avr-gcc
    CFLAGS = -mmcu=atmega328p -DF_CPU=16000000UL -I./include
    LDFLAGS = 
endif

# Targets
.PHONY: all clean examples install test docs

all: $(CORE_OBJECTS) examples

# Create directories
$(BUILD_DIR) $(BIN_DIR):
	mkdir -p $@

# Compile core library
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Build examples
examples: $(EXAMPLES)

$(BIN_DIR)/solar_monitor: $(EXAMPLES_DIR)/solar_monitor.c $(CORE_OBJECTS) | $(BIN_DIR)
	$(CC) $(CFLAGS) $< $(CORE_OBJECTS) $(LDFLAGS) -o $@

$(BIN_DIR)/wind_monitor: $(EXAMPLES_DIR)/wind_monitor.c $(CORE_OBJECTS) | $(BIN_DIR)
	$(CC) $(CFLAGS) $< $(CORE_OBJECTS) $(LDFLAGS) -o $@

$(BIN_DIR)/robot_control: $(EXAMPLES_DIR)/robot_control.c $(CORE_OBJECTS) | $(BIN_DIR)
	$(CC) $(CFLAGS) $< $(CORE_OBJECTS) $(LDFLAGS) -o $@

$(BIN_DIR)/drone_flight: $(EXAMPLES_DIR)/drone_flight.c $(CORE_OBJECTS) | $(BIN_DIR)
	$(CC) $(CFLAGS) $< $(CORE_OBJECTS) $(LDFLAGS) -o $@

$(BIN_DIR)/rc_aircraft: $(EXAMPLES_DIR)/rc_aircraft.c $(CORE_OBJECTS) | $(BIN_DIR)
	$(CC) $(CFLAGS) $< $(CORE_OBJECTS) $(LDFLAGS) -o $@

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)
	rm -f *.log *.csv

# Install to system (requires sudo)
install: all
	install -d /usr/local/include/c-basic
	install -m 644 $(INC_DIR)/*.h /usr/local/include/c-basic/
	install -d /usr/local/lib
	install -m 755 $(BIN_DIR)/* /usr/local/bin/

# Run tests (if test framework exists)
test:
	@echo "Running tests..."
	# Add test commands here

# Generate documentation (requires doxygen)
docs:
	doxygen Doxyfile

# Help target
help:
	@echo "Available targets:"
	@echo "  all          - Build all core modules and examples"
	@echo "  examples     - Build example programs"
	@echo "  clean        - Remove build artifacts"
	@echo "  install      - Install to system (requires sudo)"
	@echo "  test         - Run tests"
	@echo "  docs         - Generate documentation"
	@echo ""
	@echo "Platform-specific builds:"
	@echo "  make RASPBERRY_PI=1  - Build for Raspberry Pi"
	@echo "  make ARDUINO=1       - Build for Arduino"
