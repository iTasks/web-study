# Networking Basics

## Introduction

Understanding networking is fundamental for DevOps engineers. Whether you're troubleshooting connectivity issues, configuring firewalls, or designing cloud architectures, networking knowledge is essential.

## Learning Objectives

- Understand networking protocols (TCP/IP, HTTP, DNS)
- Work with IP addresses and subnets
- Use networking tools for troubleshooting
- Understand ports and firewalls
- Debug common network issues

## TCP/IP Model

```
Application Layer    → HTTP, HTTPS, FTP, SSH, DNS
Transport Layer      → TCP, UDP
Internet Layer       → IP, ICMP
Network Access Layer → Ethernet, WiFi
```

## IP Addresses

### IPv4
- Format: `192.168.1.100` (32-bit, 4 octets)
- Classes: A, B, C (rarely used now)
- Private ranges:
  - `10.0.0.0/8` (10.0.0.0 - 10.255.255.255)
  - `172.16.0.0/12` (172.16.0.0 - 172.31.255.255)
  - `192.168.0.0/16` (192.168.0.0 - 192.168.255.255)

### CIDR Notation
- `192.168.1.0/24` means 192.168.1.0 - 192.168.1.255
- `/24` = 256 addresses (254 usable)
- `/16` = 65,536 addresses

## Common Protocols and Ports

| Protocol | Port | Purpose |
|----------|------|---------|
| HTTP | 80 | Web traffic |
| HTTPS | 443 | Secure web traffic |
| SSH | 22 | Secure shell |
| FTP | 21 | File transfer |
| SMTP | 25 | Email |
| DNS | 53 | Domain resolution |
| MySQL | 3306 | Database |
| PostgreSQL | 5432 | Database |
| Redis | 6379 | Cache |
| MongoDB | 27017 | Database |

## Essential Networking Commands

### Testing Connectivity

```bash
# Ping - test reachability
ping google.com
ping -c 4 8.8.8.8

# Traceroute - show network path
traceroute google.com
tracert google.com  # Windows

# Test specific port
telnet example.com 80
nc -zv example.com 80
```

### DNS Lookup

```bash
# Query DNS records
nslookup google.com
dig google.com
dig +short google.com
host google.com

# Lookup specific record types
dig google.com MX
dig google.com NS
dig google.com TXT
```

### Network Information

```bash
# Show network interfaces
ifconfig          # Linux/macOS (deprecated)
ip addr show      # Linux (modern)
ipconfig          # Windows

# Show routing table
route -n          # Linux
netstat -r        # macOS
route print       # Windows

# Show active connections
netstat -tuln     # All listening ports
netstat -an       # All connections
ss -tuln          # Modern alternative (Linux)

# Show processes using network
lsof -i :80       # What's using port 80
netstat -tulnp    # Ports with process info
```

### HTTP Requests

```bash
# Make HTTP requests
curl https://api.github.com
curl -I https://google.com          # Headers only
curl -X POST -d "data" url          # POST request
curl -H "Authorization: token" url  # With headers

# Alternative
wget https://example.com/file.zip
```

## Troubleshooting Workflow

```
1. Can you ping the destination?
   → ping 8.8.8.8
   
2. Is DNS working?
   → nslookup google.com
   
3. Can you reach the specific port?
   → telnet example.com 80
   → nc -zv example.com 80
   
4. Is the service listening?
   → netstat -tuln | grep :80
   
5. Is there a firewall blocking?
   → Check iptables (Linux)
   → Check security groups (AWS)
   
6. What's the network path?
   → traceroute example.com
```

## Practical Examples

### Example 1: Debug Web Server

```bash
# 1. Check if web server is running
sudo systemctl status nginx

# 2. Check if it's listening
sudo netstat -tuln | grep :80

# 3. Test locally
curl http://localhost

# 4. Test from outside
curl http://your-public-ip

# 5. Check firewall
sudo iptables -L
```

### Example 2: Test Database Connection

```bash
# Can you reach the database port?
nc -zv database-server 5432

# Test with actual connection
psql -h database-server -U user -d database
```

### Example 3: DNS Troubleshooting

```bash
# Check if DNS is resolving
dig example.com

# Try different DNS server
dig @8.8.8.8 example.com

# Check local DNS cache
cat /etc/resolv.conf
```

## Key Concepts for DevOps

### Localhost and Loopback
- `127.0.0.1` or `localhost` = your own machine
- `0.0.0.0` = all network interfaces

### Port Binding
```bash
# Application binds to interface:port
0.0.0.0:8080    # All interfaces, port 8080
127.0.0.1:8080  # Only localhost
192.168.1.10:8080  # Specific interface
```

### HTTP Status Codes
- `200` OK
- `301` Moved Permanently
- `400` Bad Request
- `401` Unauthorized
- `403` Forbidden
- `404` Not Found
- `500` Internal Server Error
- `502` Bad Gateway
- `503` Service Unavailable

## Practice Exercises

1. Find your IP address and default gateway
2. Ping Google's DNS (8.8.8.8) and measure latency
3. Lookup DNS records for github.com
4. Find which process is using port 80
5. Test if port 443 is open on google.com
6. Make an HTTP request and view headers
7. Trace the route to a remote server

## Additional Resources

- [TCP/IP Guide](http://www.tcpipguide.com/)
- [HTTP Status Codes](https://httpstatuses.com/)
- [Subnet Calculator](https://www.subnet-calculator.com/)

## Next Steps

- [Docker Introduction](../docker-intro/) - Containerization and networking

---

**Pro Tip**: Always use networking tools to verify before assuming infrastructure is working!
