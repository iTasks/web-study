# Quick Start Guide - Zig Embedded Drone Controller

## Hardware Shopping List

### Essential Components (~$30-40)
- **Raspberry Pi Pico** (RP2040) - $4
  - Buy from: Adafruit, Sparkfun, Amazon
  
- **MPU6050 IMU Module** - $2-5
  - 6-axis gyroscope + accelerometer
  - I2C interface
  
- **Servo Motors** (3x) - $10-15
  - Standard 9g servos
  - For aileron, elevator, rudder
  
- **Brushless Motor ESC** - $10-15
  - 20A or 30A ESC
  - With BEC (5V output for servos)

### Optional but Recommended (~$20-30)
- **GPS Module** (NEO-6M) - $10
- **Barometer** (BMP280) - $3
- **Breadboard and jumper wires** - $10
- **Power supply** (5V 2A) - $7

### For Actual Drone (~$100-150 more)
- Fixed-wing foam aircraft frame
- Battery (LiPo 3S)
- Radio transmitter & receiver
- Propeller
- Various mounting hardware

## Wiring Diagram

### RP2040 to Components

```
Raspberry Pi Pico (RP2040)
┌─────────────────────────┐
│                         │
│  GPIO 2 (SDA) ──────────┼─→ MPU6050 SDA
│  GPIO 3 (SCL) ──────────┼─→ MPU6050 SCL
│                         │
│  GPIO 4 (PWM) ──────────┼─→ ESC Signal
│  GPIO 5 (PWM) ──────────┼─→ Aileron Servo
│  GPIO 6 (PWM) ──────────┼─→ Elevator Servo
│  GPIO 7 (PWM) ──────────┼─→ Rudder Servo
│                         │
│  GPIO 25 ───────────────┼─→ Status LED
│                         │
│  3V3 OUT ───────────────┼─→ MPU6050 VCC
│  GND ────────────────────┼─→ All GNDs
│                         │
└─────────────────────────┘

ESC Power (BEC 5V) ─→ Servo Power Rails
Battery ─→ ESC Power Input
```

### Pin Connections Table

| Component | RP2040 Pin | Notes |
|-----------|------------|-------|
| MPU6050 SDA | GPIO 2 | I2C Data |
| MPU6050 SCL | GPIO 3 | I2C Clock |
| MPU6050 VCC | 3.3V | Power |
| MPU6050 GND | GND | Ground |
| Aileron Servo | GPIO 5 | PWM Signal |
| Elevator Servo | GPIO 6 | PWM Signal |
| Rudder Servo | GPIO 7 | PWM Signal |
| Motor ESC | GPIO 4 | PWM Signal |
| Status LED | GPIO 25 | Built-in LED |

## Software Setup

### Step 1: Install Zig

**Linux:**
```bash
wget https://ziglang.org/download/0.11.0/zig-linux-x86_64-0.11.0.tar.xz
tar -xf zig-linux-x86_64-0.11.0.tar.xz
sudo mv zig-linux-x86_64-0.11.0 /opt/zig
export PATH=$PATH:/opt/zig
echo 'export PATH=$PATH:/opt/zig' >> ~/.bashrc
```

**macOS:**
```bash
brew install zig
```

**Windows:**
1. Download from https://ziglang.org/download/
2. Extract to C:\zig
3. Add C:\zig to PATH

Verify:
```bash
zig version
# Should show: 0.11.0 or higher
```

### Step 2: Install Picotool (for flashing)

**Linux:**
```bash
sudo apt-get install libusb-1.0-0-dev cmake
git clone https://github.com/raspberrypi/picotool.git
cd picotool
mkdir build && cd build
cmake ..
make
sudo make install
```

**macOS:**
```bash
brew install picotool
```

### Step 3: Clone and Build

```bash
# Navigate to project
cd web-study/zig/embedded

# Build the drone controller
zig build-exe \
  -target thumb-freestanding-eabi \
  -mcpu cortex_m0plus \
  -O ReleaseSafe \
  drone/drone_controller.zig

# You should see: drone_controller.o and drone_controller files
```

### Step 4: Flash to Pico

1. Hold BOOTSEL button on Raspberry Pi Pico
2. Connect USB cable to computer
3. Release BOOTSEL button
4. Pico appears as USB mass storage device

**Method 1 - Using picotool:**
```bash
picotool load -x drone_controller.elf
picotool reboot
```

**Method 2 - Drag and drop:**
```bash
# Convert to UF2 format (if you have elf2uf2)
elf2uf2 drone_controller.elf drone_controller.uf2

# Copy to Pico
cp drone_controller.uf2 /media/RPI-RP2/
```

## Testing

### Bench Test (No Flying!)

1. **Power up system** - LED should blink slowly
2. **Check servos** - Should center automatically
3. **Tilt board** - Servos should move to compensate
4. **Monitor status** - LED patterns indicate status

### LED Status Codes

- **Slow blink (1 Hz)**: Normal operation, disarmed
- **Steady on/off**: Armed and running
- **Fast blink**: Failsafe mode (problem detected)
- **Very fast blink**: Hard fault (critical error)

### Serial Monitor

Connect UART for debugging:
```bash
# Linux
screen /dev/ttyACM0 115200

# macOS  
screen /dev/tty.usbmodem* 115200

# Windows
Use PuTTY or similar
```

## Troubleshooting

### Build Errors

**"zig: command not found"**
- Solution: Add Zig to PATH

**"target 'thumb-freestanding-eabi' not found"**
- Solution: Update to Zig 0.11.0 or newer

**"undefined reference to..."**
- Solution: Check all imports are correct

### Hardware Issues

**LED doesn't blink**
- Check power connections
- Verify Pico has power (LED should be on)
- Try re-flashing firmware

**Servos don't move**
- Check servo power (5V from BEC)
- Verify PWM pin connections
- Check servo functionality separately

**IMU not responding**
- Verify I2C connections (SDA, SCL)
- Check 3.3V power to sensor
- Use I2C scanner to detect device

### Runtime Issues

**Servos jitter**
- May be normal during attitude correction
- Reduce PID gains if excessive
- Check for loose IMU mounting

**Failsafe activates immediately**
- IMU may be reading incorrectly
- Check sensor orientation
- Verify I2C communication

## Safe Testing Procedure

### Phase 1: Power and LED
1. Power up system
2. Verify LED blinks
3. No errors on serial monitor

### Phase 2: Sensor Reading
1. Monitor IMU output (if serial connected)
2. Tilt board, verify readings change
3. Check for reasonable values

### Phase 3: Servo Response
1. Manually tilt board
2. Servos should oppose motion (stabilization)
3. Roll right → aileron corrects left
4. Pitch up → elevator corrects down

### Phase 4: Controlled Movement (Optional)
1. Disable motor (set throttle = 0)
2. Secure aircraft to prevent movement
3. Add RC input integration
4. Test with minimal throttle

⚠️ **DO NOT** attempt free flight without:
- Extensive bench testing
- RC control integration
- Proper aircraft assembly
- Experience with RC aircraft
- Safe flying location

## Next Steps

### Immediate
1. ✅ Build and flash firmware
2. ✅ Verify LED blink
3. ✅ Test servo centering
4. ✅ Check IMU response

### Short Term
1. Add RC receiver input
2. Tune PID gains
3. Add GPS module
4. Test in simulation

### Long Term
1. Build or buy aircraft frame
2. Integrate all components
3. Extensive ground testing
4. First flight (experienced pilot recommended)

## Additional Resources

### Documentation
- See `README.md` for architecture details
- See `BUILD.md` for advanced build options
- See `OVERVIEW.md` for technical deep dive

### Community
- Zig Discord: Embedded channel
- RC Groups: Embedded flight controllers
- DIY Drones: ArduPilot community

### Safety
- FAA drone regulations (US)
- Local RC flying field rules
- LiPo battery safety guidelines
- Fixed-wing flying tutorials

## Help and Support

If you encounter issues:

1. Check this Quick Start guide
2. Review error messages carefully
3. Verify hardware connections
4. Check Zig version compatibility
5. Review code comments for hints

For educational purposes, this is a learning platform. For production use, consider established flight controller projects like ArduPilot or PX4.

## Success Checklist

- [ ] Zig installed and working
- [ ] Hardware connected per diagram
- [ ] Code compiled successfully
- [ ] Firmware flashed to Pico
- [ ] LED blinks indicating operation
- [ ] Servos center on power-up
- [ ] IMU responds to movement
- [ ] Servos provide stabilization
- [ ] Serial output shows status
- [ ] Safety features tested

**Ready for next level integration!** 🚀
