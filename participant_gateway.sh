#!/bin/bash

# Participant Action Simulation Script for vm-gateway
# This simulates realistic actions participants may take during the scenario
# to explore, investigate, or (mistakenly) act on the system.

set -e

LOG_DIR="/var/log/gateway"
TRAP_SCRIPT="/opt/security/remove_malware.sh"
HASH_REF="/opt/reference/hash_expected.txt"

### 1. Check directory and view vendor logs

echo -e "\n[1] Listing log directory contents..."
ls -lh "$LOG_DIR"

### 2. Read vendor.log for anomalies

echo -e "\n[2] Viewing suspicious entries in vendor.log..."
tail -n 10 "$LOG_DIR/vendor.log"

### 3. View authentication logs

echo -e "\n[3] Checking auth.log for suspicious access..."
cat "$LOG_DIR/auth.log"

### 4. Hash vendor.log and compare to reference

echo -e "\n[4] Hashing vendor.log and comparing with reference..."
ACTUAL=$(sha256sum "$LOG_DIR/vendor.log" | cut -d ' ' -f1)
EXPECTED=$(cut -d ' ' -f1 "$HASH_REF")
echo "Actual:   $ACTUAL"
echo "Expected: $EXPECTED"
if [[ "$ACTUAL" == "$EXPECTED" ]]; then
  echo "[✓] Log integrity appears intact."
else
  echo "[!] Hash mismatch — possible tampering or alteration."
fi

### 5. Investigate trap script

echo -e "\n[5] Viewing remove_malware.sh..."
cat "$TRAP_SCRIPT"

### 6. (Optional) Simulate mistake — run trap script

echo -e "\n[6] Simulating participant mistake: running remove_malware.sh..."
"$TRAP_SCRIPT"

### 7. Recheck logs after trap execution

echo -e "\n[7] Checking logs after trap execution..."
ls -lh "$LOG_DIR"

### 8. Simulated log transfer to audit VM

echo -e "\n[8] Example transfer command to vm-audit:"
echo "scp $LOG_DIR/vendor.log audituser@vm-audit:/incident/archive/gateway/"

### 9. Final output

echo -e "\n[✓] Participant simulation complete. This machine is now in an altered state."
