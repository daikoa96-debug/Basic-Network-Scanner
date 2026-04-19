#!/bin/bash
# Purpose: Scan open ports on machine

# Script 4 - Port Scanner

echo "=== Port Scanning ==="
read -p "Enter your target: " target

echo -e "\nScanning Ports...\n"
for port in {1..1024}; do
    (echo >/dev/tcp/$target/$port) > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "[+] Open Port: $port"
    fi
done

echo "\n Scanning Completed!"