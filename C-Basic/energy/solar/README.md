# Solar Power System Configuration

Example configurations for solar power monitoring and control systems.

## Small Scale Solar (12V, 100W)

**Components:**
- 100W Solar Panel (18V, 5.5A)
- 12V 20Ah Lead-acid or LiPo battery
- Solar charge controller (PWM or MPPT)
- Voltage sensor (0-25V range)
- Current sensor (ACS712-30A)

**Configuration:**

```c
solar_config_t config = {
    .voltage_pin = 0,
    .current_pin = 1,
    .max_voltage = 22.0f,    // Open circuit voltage
    .max_current = 6.0f,     // Short circuit current
    .vref = 5.0f
};
```

**Wiring:**

```
Solar Panel (+) ─┬─> Charge Controller ─> Battery (+)
                 │
                 ├─> Voltage Divider ─> ADC0 (R1=68k, R2=10k)
                 │
                 └─> Current Sensor ─> ADC1

Solar Panel (-) ──> Battery (-)
```

## Medium Scale Solar (24V, 300W)

**Components:**
- 2x 150W Panels in Series (36V, 8.3A)
- 24V 50Ah Battery Bank
- MPPT Charge Controller
- INA219 I2C Power Monitor

**Configuration:**

```c
solar_config_t config = {
    .voltage_pin = 0,        // Or use I2C sensor
    .current_pin = 1,
    .max_voltage = 44.0f,    // 2x panels
    .max_current = 9.0f,
    .vref = 5.0f
};
```

## Off-Grid System (48V, 1kW+)

**Components:**
- 4x 250W Panels (2S2P = 72V, 14A)
- 48V Battery Bank (200Ah+)
- Grid-tie inverter
- Remote monitoring

**Features:**
- Grid sell-back capability
- Battery state-of-charge monitoring
- Load management
- Remote control via WiFi/4G

## MPPT Implementation

Maximum Power Point Tracking algorithm:

```c
float solar_mppt_perturb_observe(void) {
    static float voltage = 17.0f;
    static float last_power = 0.0f;
    static float step = 0.1f;
    
    energy_reading_t reading;
    solar_read(&reading);
    
    if (reading.power > last_power) {
        // Going in right direction
        voltage += step;
    } else {
        // Reverse direction
        step = -step;
        voltage += step;
    }
    
    last_power = reading.power;
    
    // Clamp voltage
    if (voltage < 14.0f) voltage = 14.0f;
    if (voltage > 18.0f) voltage = 18.0f;
    
    return voltage;
}
```

## Safety Features

**Essential protections:**
1. Over-voltage protection (disconnect at 15V for 12V system)
2. Under-voltage protection (disconnect at 10.5V)
3. Over-current protection (fuse/breaker)
4. Reverse polarity protection (diode or MOSFET)
5. Temperature monitoring (shut down if >60°C)

**Implementation:**

```c
int solar_safety_check(energy_reading_t* reading) {
    if (reading->voltage > 15.0f) {
        printf("DANGER: Over-voltage!\n");
        // Disconnect load
        return -1;
    }
    if (reading->voltage < 10.5f) {
        printf("WARNING: Under-voltage\n");
        // Reduce load
        return -1;
    }
    if (reading->current > 10.0f) {
        printf("DANGER: Over-current!\n");
        // Trip breaker
        return -1;
    }
    return 0;
}
```

## Data Logging

Log format (CSV):

```
timestamp,voltage,current,power,energy,efficiency,battery_soc
1643723456,17.5,4.2,73.5,0.0,67.0,85.2
1643723457,17.4,4.3,74.8,0.021,68.0,85.0
```

## Performance Optimization

**Typical efficiency:**
- Solar panel: 15-20%
- MPPT controller: 95-98%
- Battery: 85-90% (lead-acid), 95-98% (LiPo)
- Inverter: 90-95%
- System: 60-70% overall

**Improving efficiency:**
1. Clean panels regularly
2. Optimal tilt angle (latitude ± 15°)
3. Avoid shading
4. Use MPPT instead of PWM
5. Minimize cable resistance
6. Keep batteries cool
