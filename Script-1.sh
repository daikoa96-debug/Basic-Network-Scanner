#!/bin/bash

# Script 1 - Network Scanner

# Purpose: Scan your own network for active hosts
# Use only on YOUR OWN network!

echo "=== Network Scanner ==="
read -p "Enter network range (e.g 192.168.1): " network

echo -e "\nScanning $network.0/24...\n"

for i in {1..254}; do
  ip="$network.$i"
  ping -c 1 -W 1 $ip > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "[+] Host found: $ip"
  fi
done

echo -e "\nScan complete!"
