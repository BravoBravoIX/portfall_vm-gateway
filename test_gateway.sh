#!/bin/bash

# Gateway Setup Verification Script
# Checks all expected files, services, traps, logs, and hashes

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

check_service_active() {
  local service=$1
  if systemctl is-active --quiet "$service"; then
    echo "[✓] Fake service '$service' is active"
    ((PASS++))
  else
    echo "[✗] Fake service '$service' is NOT active"
    ((FAIL++))
  fi
}

# Core checks
check_file /opt/security/remove_malware.sh "Trap script present"
check_file /var/log/gateway/vendor.log "Vendor log present"
check_file /var/log/gateway/auth.log "Auth log present"
check_file /opt/reference/hash_expected.txt "Reference hash file present"
check_file /opt/setup_gateway_complete.flag "Setup flag file"

# Executability
if [ -x /opt/security/remove_malware.sh ]; then
  echo "[✓] Trap script is executable"
  ((PASS++))
else
  echo "[✗] Trap script is NOT executable"
  ((FAIL++))
fi

# Fake service
check_service_active vendor-sync.service

# Hash match
EXPECTED=$(cut -d ' ' -f1 /opt/reference/hash_expected.txt)
ACTUAL=$(sha256sum /var/log/gateway/vendor.log | cut -d ' ' -f1)
if [ "$EXPECTED" == "$ACTUAL" ]; then
  echo "[✓] vendor.log hash matches reference"
  ((PASS++))
else
  echo "[✗] vendor.log hash does NOT match reference"
  echo "Expected: $EXPECTED"
  echo "Actual:   $ACTUAL"
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
