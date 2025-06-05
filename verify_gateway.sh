#!/bin/bash

# Gateway Setup Verification Script
# Checks all expected files, traps, logs, and hash are correctly configured

set -e

PASS=0
FAIL=0

echo "[Gateway VM Setup Verification]"

check_file() {
  local file=$1
  local description=$2
  if [ -f "$file" ]; then
    echo "[✓] $description ($file)"
    ((PASS++))
  else
    echo "[✗] MISSING: $description ($file)"
    ((FAIL++))
  fi
}

check_file /opt/security/remove_malware.sh "Trap script present"
check_file /var/log/gateway/vendor.log "Vendor log present"
check_file /var/log/gateway/auth.log "Auth log present"
check_file /opt/reference/hash_expected.txt "Reference hash file present"
check_file /opt/setup_gateway_complete.flag "Setup flag file"

# Check that the trap script is executable
if [ -x /opt/security/remove_malware.sh ]; then
  echo "[✓] Trap script is executable"
  ((PASS++))
else
  echo "[✗] Trap script is NOT executable"
  ((FAIL++))
fi

# Check that the hash in the reference file matches the actual vendor log
EXPECTED=$(cut -d ' ' -f1 /opt/reference/hash_expected.txt)
ACTUAL=$(sha256sum /var/log/gateway/vendor.log | cut -d ' ' -f1)
if [ "$EXPECTED" == "$ACTUAL" ]; then
  echo "[✓] vendor.log hash matches reference"
  ((PASS++))
else
  echo "[✗] vendor.log hash does NOT match reference"
  ((FAIL++))
fi

# Summary

echo -e "\n[Summary]"
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [ $FAIL -eq 0 ]; then
  echo "[✓] All gateway VM setup checks passed."
  exit 0
else
  echo "[!] Gateway VM setup verification failed."
  exit 1
fi
