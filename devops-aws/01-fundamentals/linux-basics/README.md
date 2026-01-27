# Linux Basics

[← Back to Level 1: Fundamentals](../README.md) | [DevOps & AWS](../../README.md) | [Main README](../../../README.md)

## Introduction

Linux is the backbone of modern DevOps and cloud computing. Understanding Linux is essential for managing servers, containers, and cloud infrastructure. This module will teach you the fundamental commands and concepts you need to be productive in a Linux environment.

## Learning Objectives

By the end of this module, you will be able to:
- Navigate the Linux file system confidently
- Perform file and directory operations
- Understand and manage file permissions
- Process and manipulate text efficiently
- Manage running processes
- Write basic shell scripts for automation

## Prerequisites

- A Linux environment (Ubuntu recommended, or WSL2 for Windows users)
- Terminal access
- Basic computer literacy

## Setup

### Option 1: Ubuntu on Windows (WSL2)
```bash
# Windows 11/10
# Open PowerShell as Administrator
wsl --install
# Restart your computer
# Open Ubuntu from Start menu
```

### Option 2: Ubuntu Virtual Machine
- Download VirtualBox: https://www.virtualbox.org/
- Download Ubuntu ISO: https://ubuntu.com/download/desktop
- Create a new VM with at least 2GB RAM and 20GB storage

### Option 3: Native Linux
- Install Ubuntu or your preferred Linux distribution

## Module Content

### 1. Linux File System Structure

Understanding the Linux directory hierarchy:

```
/                    # Root directory
├── bin/            # Essential command binaries
├── boot/           # Boot loader files
├── dev/            # Device files
├── etc/            # Configuration files
├── home/           # User home directories
├── lib/            # Shared libraries
├── opt/            # Optional software
├── root/           # Root user's home directory
├── tmp/            # Temporary files
├── usr/            # User programs
└── var/            # Variable data (logs, databases)
```

**Practice Exercise**:
```bash
# Explore the file system
cd /
ls -la
cd /home
pwd
cd ~
ls -la
```

---

### 2. Essential Commands

#### Navigation Commands

```bash
# Print working directory
pwd

# List files and directories
ls                  # Basic listing
ls -l              # Long format (detailed)
ls -la             # Include hidden files
ls -lh             # Human-readable sizes
ls -ltr            # Sort by time, reverse

# Change directory
cd /path/to/dir    # Absolute path
cd ../             # Parent directory
cd ~               # Home directory
cd -               # Previous directory

# Command history
history            # Show command history
!123               # Execute command 123 from history
!!                 # Execute last command
```

**Practice Exercise**:
```bash
# Navigate your file system
cd ~
pwd
ls -la
cd /var/log
ls -ltr
cd -
pwd
```

#### File Operations

```bash
# Create files
touch file.txt                # Create empty file
echo "Hello" > file.txt       # Create with content
echo "World" >> file.txt      # Append to file

# Copy files
cp source.txt dest.txt        # Copy file
cp -r dir1 dir2               # Copy directory recursively
cp -v file1.txt file2.txt     # Verbose output

# Move/Rename files
mv oldname.txt newname.txt    # Rename
mv file.txt /path/to/dest/    # Move
mv -i file.txt dest.txt       # Interactive (prompt before overwrite)

# Delete files
rm file.txt                   # Remove file
rm -r directory/              # Remove directory recursively
rm -rf directory/             # Force remove (dangerous!)
rm -i file.txt                # Interactive (prompt before delete)

# Create directories
mkdir newdir                  # Create directory
mkdir -p path/to/dir          # Create parent directories
mkdir -p {dir1,dir2,dir3}     # Create multiple directories
```

**Hands-On Lab 1**: File Management
```bash
# Create a project structure
mkdir -p ~/devops-practice/{scripts,logs,configs}
cd ~/devops-practice

# Create some files
echo "#!/bin/bash" > scripts/hello.sh
echo "echo 'Hello DevOps!'" >> scripts/hello.sh
touch logs/app.log
echo "port=8080" > configs/app.conf

# Practice copying and moving
cp scripts/hello.sh scripts/hello-backup.sh
mv scripts/hello-backup.sh scripts/backup/hello.sh

# List everything
ls -lR
```

---

### 3. Viewing and Editing Files

```bash
# View file contents
cat file.txt                  # Display entire file
cat file1.txt file2.txt       # Concatenate files
less file.txt                 # Page through file (q to quit)
more file.txt                 # Page through file
head file.txt                 # First 10 lines
head -n 20 file.txt           # First 20 lines
tail file.txt                 # Last 10 lines
tail -f /var/log/syslog       # Follow file (real-time)

# Text editors
nano file.txt                 # Simple editor (Ctrl+X to exit)
vim file.txt                  # Powerful editor (ESC :wq to save and quit)
```

**Practice Exercise**:
```bash
# Create a log file and monitor it
echo "App started" > app.log
tail -f app.log &
# In another terminal
echo "User logged in" >> app.log
echo "Request processed" >> app.log
```

---

### 4. File Permissions

Linux uses a permission system for files and directories:

```
-rwxr-xr--
 │││││││││
 ││││││││└─ Other: read
 │││││││└── Other: write (not set)
 ││││││└─── Other: execute (not set)
 │││││└──── Group: read
 ││││└───── Group: write (not set)
 │││└────── Group: execute
 ││└─────── Owner: read
 │└──────── Owner: write
 └───────── Owner: execute
```

**Permission Commands**:
```bash
# View permissions
ls -l file.txt

# Change permissions (numeric)
chmod 755 script.sh           # rwxr-xr-x
chmod 644 file.txt            # rw-r--r--
chmod 600 secret.txt          # rw-------

# Change permissions (symbolic)
chmod +x script.sh            # Add execute
chmod -w file.txt             # Remove write
chmod u+x,g+r script.sh       # User execute, group read

# Change owner
chown user:group file.txt     # Change owner and group
chown -R user:group dir/      # Recursive

# Change group
chgrp groupname file.txt
```

**Hands-On Lab 2**: Permissions
```bash
# Create a script
cat > hello.sh << 'EOF'
#!/bin/bash
echo "Hello from script!"
EOF

# Try to run it
./hello.sh                    # Permission denied

# Make it executable
chmod +x hello.sh
ls -l hello.sh
./hello.sh                    # Now it works!

# Secure a file
echo "secret data" > secret.txt
chmod 600 secret.txt
ls -l secret.txt
```

---

### 5. Text Processing

```bash
# Search in files
grep "pattern" file.txt       # Search for pattern
grep -r "pattern" dir/        # Recursive search
grep -i "pattern" file.txt    # Case-insensitive
grep -n "pattern" file.txt    # Show line numbers
grep -v "pattern" file.txt    # Invert match (exclude)

# Stream editor (sed)
sed 's/old/new/' file.txt     # Replace first occurrence
sed 's/old/new/g' file.txt    # Replace all occurrences
sed -i 's/old/new/g' file.txt # In-place edit

# AWK for text processing
awk '{print $1}' file.txt     # Print first column
awk -F: '{print $1}' /etc/passwd  # Custom delimiter

# Word count
wc file.txt                   # Lines, words, bytes
wc -l file.txt                # Count lines
wc -w file.txt                # Count words

# Sort and unique
sort file.txt                 # Sort lines
sort -r file.txt              # Reverse sort
sort -n file.txt              # Numeric sort
uniq file.txt                 # Remove duplicates (needs sorted input)
sort file.txt | uniq -c       # Count occurrences
```

**Hands-On Lab 3**: Log Analysis
```bash
# Create a sample log file
cat > access.log << 'EOF'
192.168.1.1 - GET /home 200
192.168.1.2 - POST /login 200
192.168.1.1 - GET /about 200
192.168.1.3 - GET /home 404
192.168.1.2 - GET /contact 200
192.168.1.1 - POST /api 500
EOF

# Find all errors (non-200 status)
grep -v " 200$" access.log

# Count requests per IP
awk '{print $1}' access.log | sort | uniq -c

# Find all POST requests
grep "POST" access.log

# Count total requests
wc -l access.log
```

---

### 6. Process Management

```bash
# View processes
ps                            # Current shell processes
ps aux                        # All processes (detailed)
ps aux | grep nginx           # Find specific process

# Real-time process monitoring
top                           # Interactive process viewer (q to quit)
htop                          # Better top (needs installation)

# Process control
command &                     # Run in background
jobs                          # List background jobs
fg %1                         # Bring job 1 to foreground
bg %1                         # Resume job 1 in background

# Kill processes
kill PID                      # Terminate process
kill -9 PID                   # Force kill
killall process_name          # Kill all by name
pkill pattern                 # Kill by pattern

# Process priority
nice -n 10 command            # Run with lower priority
renice -n 5 -p PID            # Change priority
```

**Practice Exercise**:
```bash
# Start a background process
sleep 100 &
jobs
ps aux | grep sleep

# Kill it
pkill sleep
jobs
```

---

### 7. Input/Output Redirection and Pipes

```bash
# Output redirection
command > file.txt            # Redirect stdout (overwrite)
command >> file.txt           # Redirect stdout (append)
command 2> error.log          # Redirect stderr
command &> all.log            # Redirect both stdout and stderr
command 2>&1                  # Redirect stderr to stdout

# Input redirection
command < input.txt           # Read from file

# Pipes (chain commands)
ls -l | grep ".txt"           # Find text files
cat file.txt | grep "error" | wc -l  # Count error lines
ps aux | grep python | awk '{print $2}'  # Get PIDs

# Tee (output to file and stdout)
command | tee output.txt      # Save and display
command | tee -a output.txt   # Append mode
```

**Hands-On Lab 4**: Pipes and Redirection
```bash
# Find largest files
du -h /var/log | sort -h | tail -10

# Monitor system in real-time
dmesg | tail -f

# Create a pipeline
cat /var/log/syslog | grep "error" | awk '{print $1, $2, $3}' | sort | uniq
```

---

### 8. Basic Shell Scripting

```bash
#!/bin/bash
# This is a comment

# Variables
NAME="DevOps"
echo "Hello, $NAME"

# User input
read -p "Enter your name: " USERNAME
echo "Welcome, $USERNAME!"

# Conditionals
if [ -f file.txt ]; then
    echo "File exists"
else
    echo "File not found"
fi

# Loops
for i in {1..5}; do
    echo "Iteration $i"
done

for file in *.txt; do
    echo "Processing $file"
done

# While loop
COUNT=1
while [ $COUNT -le 5 ]; do
    echo "Count: $COUNT"
    ((COUNT++))
done

# Functions
greet() {
    echo "Hello, $1!"
}
greet "World"

# Command substitution
CURRENT_DATE=$(date +%Y-%m-%d)
echo "Today is $CURRENT_DATE"

# Exit codes
if [ $? -eq 0 ]; then
    echo "Success"
else
    echo "Failed"
fi
```

**Hands-On Lab 5**: Create a Backup Script
```bash
#!/bin/bash
# backup.sh - Simple backup script

# Configuration
SOURCE_DIR="$HOME/documents"
BACKUP_DIR="$HOME/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_$DATE.tar.gz"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Create backup
echo "Creating backup of $SOURCE_DIR..."
tar -czf "$BACKUP_DIR/$BACKUP_FILE" "$SOURCE_DIR" 2>/dev/null

# Check if successful
if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_FILE"
    ls -lh "$BACKUP_DIR/$BACKUP_FILE"
else
    echo "Backup failed!"
    exit 1
fi

# Keep only last 5 backups
cd "$BACKUP_DIR"
ls -t backup_*.tar.gz | tail -n +6 | xargs -r rm
echo "Old backups cleaned up"
```

---

## Practice Projects

### Project 1: System Information Script
Create a script that displays:
- Current user
- Hostname
- OS version
- CPU information
- Memory usage
- Disk usage
- Running processes

### Project 2: Log Analyzer
Create a script that:
- Reads a log file
- Counts errors, warnings, and info messages
- Shows top IP addresses
- Generates a summary report

### Project 3: File Organizer
Create a script that:
- Scans a directory
- Organizes files by extension into subdirectories
- Generates a report of changes made

## Assessment

Test your knowledge with these challenges:

1. **Navigation**: Navigate to `/var/log`, list the 10 largest files
2. **Permissions**: Create a script that only you can read, write, and execute
3. **Text Processing**: Find all unique IP addresses in a log file
4. **Pipes**: Create a one-liner that shows running processes sorted by memory usage
5. **Scripting**: Write a script that backs up a directory daily

## Additional Resources

- [Linux Command Line Cheat Sheet](https://cheatography.com/davechild/cheat-sheets/linux-command-line/)
- [Bash Scripting Tutorial](https://linuxconfig.org/bash-scripting-tutorial-for-beginners)
- [The Linux Documentation Project](https://tldp.org/)
- [ExplainShell](https://explainshell.com/) - Explains shell commands

## Next Steps

Once you're comfortable with Linux basics, move on to:
- [Git and GitHub](../git-github/) - Version control fundamentals

---

**Remember**: The best way to learn Linux is by using it daily. Practice these commands regularly, break things in a safe environment, and don't be afraid to explore!
