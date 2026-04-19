#!/bin/bash
# Purpose: Analyze auth logs for failed logins

# Script 2 - Log Analyzer

echo "=== Failed Log Analyzer ==="
log="/var/log/auth.log"

if [ ! -f $log ]; then
    echo "File Not Found!"
    exit 1
fi
echo -e "\n Top 5 Failed login IPs: \n"
grep "Failed password" $log | \
grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]" | \
sort | uniq -c | sort -rn | head -5

echo -e "\n Total Failed attempts:"
grep -c "Failed password" $log