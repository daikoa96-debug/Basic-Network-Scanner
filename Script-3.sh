#!/bin/bash
# Purpose: Check if important files are modified

# Script 3 - File Integrity Checker

echo "=== File Integrity Checker ==="
files=("/etc/passwd" "/etc/hosts" "/etc/shadow")
hashfile="hashes.txt"

Check() {
    
    for file in ${files[@]}; do
        if [ -f $file ]; then
            md5sum $file >> $hashfile
            echo "[+] hashed $file"
        fi
    done

}

Verify() {

    echo -e "\n Verifying Files..."
    md5sum -c $hashfile

}


if [ -f $hashfile ]; then
    echo "Creating bashline hashes..."
    Check
else
    Verify
fi