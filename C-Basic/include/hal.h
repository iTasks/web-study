#ifndef HAL_H
#define HAL_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

/**
 * Hardware Abstraction Layer (HAL)
 * Provides unified interface for different hardware platforms
 */

// Platform definitions
typedef enum {
    PLATFORM_UNKNOWN = 0,
    PLATFORM_RPI,
    PLATFORM_ARDUINO,
    PLATFORM_GENERIC_LINUX,
    PLATFORM_GENERIC_MCU
} platform_type_t;

// GPIO definitions
typedef enum {
    GPIO_MODE_INPUT = 0,
    GPIO_MODE_OUTPUT,
    GPIO_MODE_ALT,
    GPIO_MODE_PWM
} gpio_mode_t;

typedef enum {
    GPIO_PULL_NONE = 0,
    GPIO_PULL_UP,
    GPIO_PULL_DOWN
} gpio_pull_t;

typedef enum {
    GPIO_LOW = 0,
    GPIO_HIGH = 1
} gpio_state_t;

// Platform initialization
int hal_init(platform_type_t platform);
int hal_deinit(void);
platform_type_t hal_get_platform(void);

// GPIO functions
int hal_gpio_set_mode(uint8_t pin, gpio_mode_t mode);
int hal_gpio_set_pull(uint8_t pin, gpio_pull_t pull);
int hal_gpio_write(uint8_t pin, gpio_state_t state);
gpio_state_t hal_gpio_read(uint8_t pin);
int hal_gpio_pwm_set_duty_cycle(uint8_t pin, uint8_t duty_cycle);

// ADC functions
int hal_adc_init(uint8_t channel);
uint16_t hal_adc_read(uint8_t channel);
float hal_adc_read_voltage(uint8_t channel, float vref);

// I2C functions
int hal_i2c_init(uint8_t bus);
int hal_i2c_write(uint8_t bus, uint8_t addr, const uint8_t* data, size_t len);
int hal_i2c_read(uint8_t bus, uint8_t addr, uint8_t* data, size_t len);

// SPI functions
int hal_spi_init(uint8_t bus, uint32_t speed);
int hal_spi_transfer(uint8_t bus, const uint8_t* tx_data, uint8_t* rx_data, size_t len);

// UART functions
int hal_uart_init(uint8_t port, uint32_t baudrate);
int hal_uart_write(uint8_t port, const uint8_t* data, size_t len);
int hal_uart_read(uint8_t port, uint8_t* data, size_t len);

// Timer functions
int hal_delay_ms(uint32_t ms);
int hal_delay_us(uint32_t us);
uint32_t hal_millis(void);
uint32_t hal_micros(void);

#endif // HAL_H
