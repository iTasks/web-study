# Linux Basics Examples

This directory contains practical examples to help you learn Linux fundamentals through hands-on practice.

## Available Examples

### 1. File Operations (`01-file-operations.sh`)
Demonstrates basic file and directory operations:
- Creating and managing directories
- File copying, moving, and renaming
- Organizing files into subdirectories
- Counting files and directories

**Usage:**
```bash
chmod +x 01-file-operations.sh
./01-file-operations.sh
```

### 2. Text Processing (`02-text-processing.sh`)
Shows how to process and analyze text files using:
- `grep` for searching patterns
- `sed` for text replacement
- `awk` for column-based processing
- Pipes for combining commands
- Real-world log file analysis

**Usage:**
```bash
chmod +x 02-text-processing.sh
./02-text-processing.sh
```

### 3. System Information (`03-system-info.sh`)
Comprehensive system information script that displays:
- Basic system information (hostname, user, uptime)
- Operating system details
- CPU and memory information
- Disk usage
- Network interfaces
- Top processes by CPU and memory

**Usage:**
```bash
chmod +x 03-system-info.sh
./03-system-info.sh
```

### 4. Automated Backup (`04-backup-script.sh`)
Production-ready backup script with features:
- Timestamp-based backups
- Compression using tar.gz
- Retention policy (keeps only recent backups)
- Logging
- Error handling
- Color-coded output

**Usage:**
```bash
chmod +x 04-backup-script.sh
# Default usage (backs up ~/documents to ~/backups)
./04-backup-script.sh

# Custom source and destination
./04-backup-script.sh /path/to/source /path/to/backup
```

## Learning Path

1. Start with `01-file-operations.sh` to understand basic file management
2. Move to `02-text-processing.sh` to learn text manipulation tools
3. Explore `03-system-info.sh` to understand system monitoring
4. Practice with `04-backup-script.sh` to see a real-world automation example

## Tips

- Always make scripts executable: `chmod +x script.sh`
- Read through each script before running to understand what it does
- Modify the scripts to experiment and learn
- Use these as templates for your own automation tasks

## Additional Practice

Try modifying these scripts to:
- Add more functionality
- Handle edge cases
- Improve error handling
- Add user interaction
- Create your own automation scripts
