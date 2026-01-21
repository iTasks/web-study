#!/bin/bash
# Example 3: System Information Script
# Displays comprehensive system information

echo "╔════════════════════════════════════════════════╗"
echo "║        SYSTEM INFORMATION REPORT               ║"
echo "╚════════════════════════════════════════════════╝"

# Basic Information
echo -e "\n📋 BASIC INFORMATION"
echo "─────────────────────────────────────────────────"
echo "Hostname: $(hostname)"
echo "Current User: $(whoami)"
echo "Date & Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"

# Operating System
echo -e "\n💻 OPERATING SYSTEM"
echo "─────────────────────────────────────────────────"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "OS: $NAME $VERSION"
else
    echo "OS: $(uname -s) $(uname -r)"
fi
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"

# CPU Information
echo -e "\n🔧 CPU INFORMATION"
echo "─────────────────────────────────────────────────"
if [ -f /proc/cpuinfo ]; then
    CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
    CPU_CORES=$(grep -c "processor" /proc/cpuinfo)
    echo "CPU Model: $CPU_MODEL"
    echo "CPU Cores: $CPU_CORES"
else
    echo "CPU info not available"
fi

# Memory Information
echo -e "\n💾 MEMORY INFORMATION"
echo "─────────────────────────────────────────────────"
if command -v free &> /dev/null; then
    free -h
else
    echo "Memory info not available"
fi

# Disk Usage
echo -e "\n💿 DISK USAGE"
echo "─────────────────────────────────────────────────"
df -h | grep -E '^/dev/|Filesystem'

# Network Interfaces
echo -e "\n🌐 NETWORK INTERFACES"
echo "─────────────────────────────────────────────────"
if command -v ip &> /dev/null; then
    ip -br addr
elif command -v ifconfig &> /dev/null; then
    ifconfig | grep -E "^[a-z]|inet "
else
    echo "Network info not available"
fi

# Running Processes (top 5 by CPU)
echo -e "\n⚙️  TOP 5 PROCESSES BY CPU"
echo "─────────────────────────────────────────────────"
ps aux --sort=-%cpu | head -6

# Running Processes (top 5 by Memory)
echo -e "\n⚙️  TOP 5 PROCESSES BY MEMORY"
echo "─────────────────────────────────────────────────"
ps aux --sort=-%mem | head -6

# Load Average
echo -e "\n📊 LOAD AVERAGE"
echo "─────────────────────────────────────────────────"
uptime

echo -e "\n╔════════════════════════════════════════════════╗"
echo "║           END OF REPORT                        ║"
echo "╚════════════════════════════════════════════════╝"
