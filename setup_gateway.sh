#!/bin/bash

SETUP_FLAG="/opt/setup_gateway_complete.flag"

function install_packages() {
  echo "[+] Installing required packages..."
  apt-get update -qq
  apt-get install -y vim grep scp rsyslog net-tools cron
}

function create_directories() {
  echo "[+] Creating required directories..."
  mkdir -p /opt/security
  mkdir -p /opt/reference
  mkdir -p /var/log/gateway
}

function create_logs() {
  echo "[+] Creating sample vendor log with anomalies..."
  cat > /var/log/gateway/vendor.log <<EOF
2025-06-04T08:00:00Z Handshake initiated with 203.0.113.45
2025-06-04T08:01:00Z AUTH user=admin temp_session=true
2025-06-04T08:01:15Z Data channel open
2025-06-04T08:01:40Z Suspicious command sent: ./inject_payload.sh
2025-06-04T08:02:10Z Connection dropped unexpectedly
2025-06-04T08:05:00Z Checksum failed for data packet 22
EOF

  echo "[+] Creating auth log with intrusion hints..."
  cat > /var/log/gateway/auth.log <<EOF
2025-06-04T07:55:32Z Failed password for root from 203.0.113.100 port 45218 ssh2
2025-06-04T07:56:10Z Failed password for unknown user from 203.0.113.99 port 44800 ssh2
2025-06-04T07:57:22Z Accepted password for ghost from 203.0.113.99 port 44842 ssh2
2025-06-04T07:57:25Z ghost : TTY=pts/0 : sudo session opened
EOF

  echo "[+] Creating reference hash for audit comparison..."
  sha256sum /var/log/gateway/vendor.log > /opt/reference/hash_expected.txt
}

function create_trap_script() {
  echo "[+] Deploying trap script..."
  cat > /opt/security/remove_malware.sh <<EOF
#!/bin/bash
echo "[+] Malware removed. System clean."
# Wipe malware traces
rm -f /var/log/gateway/*
exit 0
EOF
  chmod +x /opt/security/remove_malware.sh
}

function mark_complete() {
  echo "[+] Marking setup complete."
  touch "$SETUP_FLAG"
}

function reset_vm() {
  echo "[!] Resetting vm-gateway to pre-scenario state..."
  rm -f /opt/security/remove_malware.sh
  rm -f /var/log/gateway/vendor.log
  rm -f /var/log/gateway/auth.log
  rm -f /opt/reference/hash_expected.txt
  rm -f "$SETUP_FLAG"
  echo "[+] Reset complete."
  exit 0
}

if [[ "$1" == "-reset" ]]; then
  reset_vm
fi

if [ -f "$SETUP_FLAG" ]; then
  echo "[!] Setup already completed. Use -reset to reset."
  exit 1
fi

install_packages
create_directories
create_logs
create_trap_script
mark_complete

echo "[✓] vm-gateway setup complete. Ready for scenario."
