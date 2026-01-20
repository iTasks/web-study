# Zig

## Purpose

This directory contains Zig programming language study materials and sample applications. Zig is a general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software. It aims to be a better C, offering modern language features while maintaining simplicity and performance.

## Contents

### Pure Language Samples
- `samples/`: Core Zig language examples and applications
  - Basic syntax and language fundamentals
  - Memory management and allocators
  - Compile-time programming (comptime)
  - Error handling patterns
  - C interoperability examples
  - Testing framework usage
  - Advanced features and patterns

### Embedded Systems
- `embedded/`: Bare-metal embedded programming examples
  - Minimal OS for microcontrollers
  - RP2040 (Raspberry Pi Pico) implementation
  - Arduino compatibility layer
  - Real-time drone flight controller
  - Hardware abstraction layers (GPIO, PWM, I2C)
  - Safety-critical embedded systems

## Setup Instructions

### Prerequisites
- Zig 0.11.0 or higher
- A text editor or IDE with Zig support (VS Code with Zig extension recommended)

### Installation
1. **Install Zig**
   ```bash
   # Download from official website
   # Visit https://ziglang.org/download/ for latest version
   
   # On Linux (x86_64)
   wget https://ziglang.org/download/0.11.0/zig-linux-x86_64-0.11.0.tar.xz
   tar -xf zig-linux-x86_64-0.11.0.tar.xz
   sudo mv zig-linux-x86_64-0.11.0 /opt/zig
   export PATH=$PATH:/opt/zig
   
   # On macOS with Homebrew
   brew install zig
   
   # On Windows, download and extract to desired location
   # Add to PATH environment variable
   
   # Verify installation
   zig version
   ```

2. **Set up Development Environment**
   ```bash
   # Add to your shell profile (.bashrc, .zshrc, etc.)
   export PATH=$PATH:/opt/zig  # Adjust path as needed
   
   # For VS Code users, install the Zig extension
   code --install-extension ziglang.vscode-zig
   ```

### Building and Running

#### For samples directory:
```bash
cd zig/samples

# Run a specific example
zig run hello.zig

# Build an executable
zig build-exe hello.zig
./hello

# Run with optimizations
zig run -O ReleaseFast hello.zig
```

## Usage

### Running Sample Applications
```bash
# Basic examples
cd zig/samples
zig run hello.zig
zig run variables.zig
zig run functions.zig

# Advanced examples
zig run comptime.zig
zig run memory_management.zig
zig run interop.zig

# Run tests
zig test testing.zig
```

### Building Embedded Projects
```bash
# Build drone controller for RP2040
cd zig/embedded
zig build-exe -target thumb-freestanding-eabi -mcpu cortex_m0plus \
  -O ReleaseSafe drone/drone_controller.zig

# Build Arduino-style drone
zig build-exe -target thumb-freestanding-eabi -mcpu cortex_m0plus \
  -O ReleaseSafe arduino/arduino_drone.zig

# See embedded/README.md for detailed instructions
```

### Building Projects
```bash
# Create optimized executable
zig build-exe -O ReleaseFast your_program.zig

# Cross-compile for different targets
zig build-exe -target x86_64-windows your_program.zig
zig build-exe -target aarch64-linux your_program.zig
```

## Project Structure

```
zig/
├── README.md                    # This file
├── samples/                     # Pure Zig language examples
│   ├── hello.zig               # Hello world and basic syntax
│   ├── variables.zig           # Variables, constants, and types
│   ├── functions.zig           # Function definitions and usage
│   ├── control_flow.zig        # Conditionals, loops, and control flow
│   ├── error_handling.zig      # Error unions and error handling
│   ├── structs_enums.zig       # Structs, enums, and custom types
│   ├── comptime.zig            # Compile-time programming
│   ├── memory_management.zig   # Allocators and memory handling
│   ├── interop.zig             # C interoperability
│   └── testing.zig             # Testing framework and examples
└── embedded/                    # Embedded systems and bare-metal programming
    ├── README.md               # Embedded systems guide
    ├── BUILD.md                # Build instructions and scripts
    ├── rp2040/                 # RP2040 (Raspberry Pi Pico) implementation
    │   ├── minimal_os.zig      # Minimal OS with scheduler
    │   ├── pwm.zig             # PWM driver for servos/ESC
    │   └── i2c.zig             # I2C driver for sensors
    ├── arduino/                # Arduino compatibility layer
    │   ├── arduino_compat.zig  # Arduino-style API wrapper
    │   └── arduino_drone.zig   # Arduino-style drone controller
    └── drone/                  # Fixed-wing drone flight controller
        └── drone_controller.zig # Complete drone control system
```

## Key Learning Topics

- **Core Zig Concepts**: Values vs pointers, optional types, error unions
- **Memory Management**: Manual memory management, allocators, RAII patterns
- **Compile-time Programming**: Comptime evaluation, generic programming
- **Safety**: Runtime safety checks, undefined behavior detection
- **Performance**: Zero-cost abstractions, explicit control over memory
- **Interoperability**: Seamless C integration, calling C libraries
- **Cross-compilation**: Build for any supported target from any platform
- **Testing**: Built-in testing framework and documentation tests
- **Embedded Systems**: Bare-metal programming, hardware control, real-time systems
- **Drone Control**: Flight controllers, sensor fusion, PID control algorithms

## Contribution Guidelines

1. **Code Style**: Use `zig fmt` for consistent formatting
2. **Documentation**: Include comprehensive comments explaining concepts
3. **Testing**: Write tests using Zig's built-in testing framework
4. **Examples**: Provide clear, runnable examples with expected output
5. **Error Handling**: Demonstrate proper error handling patterns

### Adding New Samples
1. Place pure Zig examples in the `samples/` directory
2. Follow the established naming convention (lowercase with underscores)
3. Update this README with new content descriptions
4. Include comprehensive comments explaining the code
5. Test all examples to ensure they compile and run correctly

### Code Quality Standards
- Use meaningful variable and function names
- Follow Zig naming conventions (camelCase for functions, snake_case for variables)
- Handle errors explicitly using error unions
- Write clean, readable code with comprehensive comments
- Use `zig fmt` to maintain consistent formatting
- Include usage examples and expected output

## Resources and References

### Official Documentation
- [Zig Language Reference](https://ziglang.org/documentation/master/) - Comprehensive language specification
- [Zig Standard Library](https://ziglang.org/documentation/master/std/) - Standard library documentation
- [Zig Learn](https://ziglearn.org/) - Community-driven learning resource

### Community Resources
- [Zig Official Website](https://ziglang.org/) - Main website with downloads and news
- [Zig GitHub Repository](https://github.com/ziglang/zig) - Source code and issue tracking
- [Zig Community Discord](https://discord.gg/gxsFFjE) - Real-time community support
- [r/Zig Subreddit](https://www.reddit.com/r/Zig/) - Reddit community discussions

### Learning Materials
- [Zig Guide](https://zig.guide/) - Comprehensive learning guide
- [Ziglings](https://github.com/ratfactor/ziglings) - Interactive exercises
- [Zig by Example](https://zig-by-example.com/) - Code examples and explanations
- [Zig News](https://zig.news/) - Community blog and articles

### Tools and IDE Support
- [VS Code Zig Extension](https://marketplace.visualstudio.com/items?itemName=ziglang.vscode-zig) - Official VS Code support
- [Sublime Text Zig Package](https://github.com/ziglang/sublime-zig-language) - Sublime Text syntax highlighting
- [Vim Zig Plugin](https://github.com/ziglang/zig.vim) - Vim/Neovim support
- [Emacs Zig Mode](https://github.com/ziglang/zig-mode) - Emacs integration

### Books and Advanced Resources
- [Zig in Depth](https://zig.guide/getting-started/installation) - Advanced concepts and patterns
- [Systems Programming with Zig](https://zig.guide/language-basics/) - Systems-level programming
- [Game Development with Zig](https://github.com/hexops/mach) - Game engine and graphics programming