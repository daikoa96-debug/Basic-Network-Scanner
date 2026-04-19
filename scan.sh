#!/bin/bash
# ─────────────────────────────────────────────
#  Simple Network Scanner — Pure Bash
#  Tools used: ping, nc (netcat), /dev/tcp
# ─────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ── 1. PING SWEEP ─────────────────────────────
# Scans all hosts in a /24 subnet (e.g. 192.168.1.0/24)
ping_sweep() {
    local subnet=$1   # e.g. 192.168.1
    echo -e "${CYAN}[*] Ping sweep on ${subnet}.0/24 ...${NC}"
    for i in $(seq 1 254); do
        ip="${subnet}.${i}"
        # -c1 = 1 packet, -W1 = 1 sec timeout, -q = quiet
        ping -c1 -W1 -q "$ip" &>/dev/null && \
            echo -e "  ${GREEN}[UP]${NC} $ip"
    done
    echo -e "${CYAN}[*] Ping sweep done.${NC}"
}

# ── 2. PORT SCAN (using /dev/tcp) ─────────────
# Pure bash — no extra tools needed
port_scan_bash() {
    local host=$1
    shift
    local ports=("$@")   # array of ports
    echo -e "${CYAN}[*] Port scan on $host ...${NC}"
    for port in "${ports[@]}"; do
        # Try to open a TCP connection; timeout after 1 sec
        (echo >/dev/tcp/"$host"/"$port") &>/dev/null 2>&1
        if [ $? -eq 0 ]; then
            svc=$(get_service_name "$port")
            echo -e "  ${GREEN}[OPEN]${NC}   $host:$port  ($svc)"
        else
            echo -e "  ${RED}[CLOSED]${NC} $host:$port"
        fi
    done
}

# ── 3. PORT SCAN (using netcat) ────────────────
# More reliable; requires nc to be installed
port_scan_nc() {
    local host=$1
    shift
    local ports=("$@")
    echo -e "${CYAN}[*] Netcat port scan on $host ...${NC}"
    for port in "${ports[@]}"; do
        # -z = zero-I/O mode (scan only), -w1 = 1 sec timeout
        nc -z -w1 "$host" "$port" &>/dev/null
        if [ $? -eq 0 ]; then
            svc=$(get_service_name "$port")
            echo -e "  ${GREEN}[OPEN]${NC}   $host:$port  ($svc)"
        else
            echo -e "  ${RED}[CLOSED]${NC} $host:$port"
        fi
    done
}

# ── 4. PORT RANGE SCAN ─────────────────────────
port_range_scan() {
    local host=$1
    local start=$2
    local end=$3
    echo -e "${CYAN}[*] Scanning $host ports $start–$end ...${NC}"
    for port in $(seq "$start" "$end"); do
        (echo >/dev/tcp/"$host"/"$port") &>/dev/null 2>&1
        if [ $? -eq 0 ]; then
            svc=$(get_service_name "$port")
            echo -e "  ${GREEN}[OPEN]${NC} $port ($svc)"
        fi
    done
    echo -e "${CYAN}[*] Range scan done.${NC}"
}

# ── 5. BANNER GRAB ─────────────────────────────
# Reads service banner from an open port
banner_grab() {
    local host=$1
    local port=$2
    echo -e "${CYAN}[*] Banner grab on $host:$port ...${NC}"
    # Send empty line, read response for 3 seconds
    timeout 3 bash -c "echo '' | nc -w3 $host $port 2>/dev/null" | head -5
}

# ── 6. OS DETECTION (TTL-based) ────────────────
# Rough OS guess from ping TTL value
detect_os() {
    local host=$1
    echo -e "${CYAN}[*] OS detection for $host (TTL-based) ...${NC}"
    ttl=$(ping -c1 -W1 "$host" 2>/dev/null | grep -oP 'ttl=\K[0-9]+')
    if [ -z "$ttl" ]; then
        echo -e "  ${RED}[!] Host unreachable${NC}"
        return
    fi
    echo -n "  TTL=$ttl → "
    if   [ "$ttl" -le 64  ]; then echo -e "${YELLOW}Linux/Unix/macOS${NC}"
    elif [ "$ttl" -le 128 ]; then echo -e "${YELLOW}Windows${NC}"
    else                           echo -e "${YELLOW}Network device / Router${NC}"
    fi
}

# ── HELPER: service name lookup ─────────────────
get_service_name() {
    case $1 in
        21) echo "FTP"        ;; 22) echo "SSH"         ;;
        23) echo "Telnet"     ;; 25) echo "SMTP"        ;;
        53) echo "DNS"        ;; 80) echo "HTTP"        ;;
       110) echo "POP3"       ;; 143) echo "IMAP"       ;;
       443) echo "HTTPS"      ;; 445) echo "SMB"        ;;
      3306) echo "MySQL"      ;; 5432) echo "PostgreSQL";;
      6379) echo "Redis"      ;; 8080) echo "HTTP-alt"  ;;
      8443) echo "HTTPS-alt"  ;; 27017) echo "MongoDB"  ;;
         *) echo "unknown"    ;;
    esac
}

# ══════════════════════════════════════════════
#  MAIN — Edit targets below and run
# ══════════════════════════════════════════════

TARGET_HOST="192.168.1.1"
TARGET_SUBNET="192.168.1"
COMMON_PORTS=(21 22 23 25 53 80 110 143 443 445 3306 5432 6379 8080 8443 27017)

echo -e "${YELLOW}╔══════════════════════════════════════╗"
echo -e "║     Simple Bash Network Scanner      ║"
echo -e "╚══════════════════════════════════════╝${NC}"
echo ""

# Uncomment the scan you want to run:

# 1. Ping sweep your subnet
# ping_sweep "$TARGET_SUBNET"

# 2. Scan common ports (pure bash /dev/tcp)
port_scan_bash "$TARGET_HOST" "${COMMON_PORTS[@]}"

# 3. Scan common ports (netcat — more reliable)
# port_scan_nc "$TARGET_HOST" "${COMMON_PORTS[@]}"

# 4. Scan a port range (e.g. 1–1024)
# port_range_scan "$TARGET_HOST" 1 1024

# 5. Grab banner from a specific port
# banner_grab "$TARGET_HOST" 80

# 6. Detect OS via TTL
# detect_os "$TARGET_HOST"