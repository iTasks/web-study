#!/bin/bash
# Network Diagnostics Script
# Tests network connectivity and DNS resolution

echo "════════════════════════════════════════════════"
echo "     NETWORK DIAGNOSTICS TOOL"
echo "════════════════════════════════════════════════"

# Function to test connectivity
test_connectivity() {
    local host=$1
    local description=$2
    
    echo -e "\n▶ Testing: $description ($host)"
    
    if ping -c 3 -W 2 "$host" > /dev/null 2>&1; then
        echo "  ✓ Connectivity: OK"
    else
        echo "  ✗ Connectivity: FAILED"
    fi
}

# Function to test DNS
test_dns() {
    local domain=$1
    
    echo -e "\n▶ DNS Resolution: $domain"
    
    if nslookup "$domain" > /dev/null 2>&1; then
        echo "  ✓ DNS: OK"
        nslookup "$domain" | grep -A 1 "Name:" | tail -1
    else
        echo "  ✗ DNS: FAILED"
    fi
}

# Function to test HTTP/HTTPS
test_http() {
    local url=$1
    local description=$2
    
    echo -e "\n▶ Testing: $description ($url)"
    
    response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url")
    
    if [ "$response" -eq 200 ]; then
        echo "  ✓ HTTP Status: $response (OK)"
    else
        echo "  ⚠ HTTP Status: $response"
    fi
}

# Function to show network interfaces
show_interfaces() {
    echo -e "\n▶ Network Interfaces"
    if command -v ip &> /dev/null; then
        ip -br addr
    elif command -v ifconfig &> /dev/null; then
        ifconfig | grep -E "^[a-z]|inet "
    fi
}

# Function to show routing table
show_routes() {
    echo -e "\n▶ Default Route"
    if command -v ip &> /dev/null; then
        ip route | grep default
    elif command -v route &> /dev/null; then
        route -n | grep "^0.0.0.0"
    fi
}

# Function to check open ports
check_ports() {
    echo -e "\n▶ Common Open Ports"
    if command -v netstat &> /dev/null; then
        netstat -tuln | grep LISTEN | head -5
    elif command -v ss &> /dev/null; then
        ss -tuln | grep LISTEN | head -5
    fi
}

# Run diagnostics
echo -e "\n═══ NETWORK INTERFACES ═══"
show_interfaces

echo -e "\n═══ ROUTING ═══"
show_routes

echo -e "\n═══ CONNECTIVITY TESTS ═══"
test_connectivity "8.8.8.8" "Google DNS"
test_connectivity "1.1.1.1" "Cloudflare DNS"

echo -e "\n═══ DNS TESTS ═══"
test_dns "google.com"
test_dns "github.com"
test_dns "aws.amazon.com"

echo -e "\n═══ HTTP/HTTPS TESTS ═══"
test_http "https://www.google.com" "Google"
test_http "https://github.com" "GitHub"
test_http "https://aws.amazon.com" "AWS"

echo -e "\n═══ LISTENING PORTS ═══"
check_ports

echo -e "\n════════════════════════════════════════════════"
echo "     DIAGNOSTICS COMPLETE"
echo "════════════════════════════════════════════════"
