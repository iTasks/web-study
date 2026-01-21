#!/bin/bash
# Example 2: Text Processing
# Demonstrates grep, sed, awk, and other text tools

echo "=== Text Processing Demo ==="

# Create a sample log file
cat > sample.log << 'EOF'
2024-01-15 10:23:45 INFO User john logged in from 192.168.1.100
2024-01-15 10:24:12 ERROR Failed to connect to database
2024-01-15 10:24:15 INFO User jane logged in from 192.168.1.101
2024-01-15 10:25:30 WARNING High memory usage detected
2024-01-15 10:26:45 ERROR Connection timeout
2024-01-15 10:27:10 INFO User john logged out
2024-01-15 10:28:22 INFO User bob logged in from 192.168.1.102
2024-01-15 10:29:15 ERROR Database query failed
2024-01-15 10:30:45 INFO User jane logged out
2024-01-15 10:31:20 WARNING Disk space low
EOF

echo "Created sample.log with 10 entries"

# Example 1: Find all ERROR lines
echo -e "\n=== All ERROR entries ==="
grep "ERROR" sample.log

# Example 2: Count errors
echo -e "\n=== Error count ==="
grep -c "ERROR" sample.log

# Example 3: Case-insensitive search
echo -e "\n=== Search for 'user' (case-insensitive) ==="
grep -i "user" sample.log

# Example 4: Extract IP addresses
echo -e "\n=== Extract all IP addresses ==="
grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' sample.log

# Example 5: AWK - print specific columns
echo -e "\n=== Time and log level (columns 2 and 3) ==="
awk '{print $2, $3}' sample.log

# Example 6: AWK - filter by condition
echo -e "\n=== Only ERROR and WARNING messages ==="
awk '$3 == "ERROR" || $3 == "WARNING"' sample.log

# Example 7: SED - replace text
echo -e "\n=== Replace ERROR with CRITICAL ==="
sed 's/ERROR/CRITICAL/g' sample.log

# Example 8: Count unique users
echo -e "\n=== Unique users ==="
grep "User" sample.log | awk '{print $4}' | sort | uniq

# Example 9: Count events by type
echo -e "\n=== Events by type ==="
awk '{print $3}' sample.log | sort | uniq -c

# Example 10: Complex pipeline
echo -e "\n=== IPs with login attempts ==="
grep "logged in" sample.log | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort | uniq -c

echo -e "\n=== Demo complete! ==="
