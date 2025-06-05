**VM Build Sheet: vm-gateway**

**Purpose:**
Simulates the vendor-connected interface or gateway that links to external systems. It appears to be compromised but includes a trap scenario: a script labelled as a malware removal tool that instead deletes forensic logs. The machine is sensitive — teams are not meant to make changes here. Designed to test policy compliance, integrity under pressure, and chain-of-custody awareness.

---

### 1. Services and Software to Install

* Standard Linux CLI tools: `vim`, `grep`, `scp`, `rsyslog`, `net-tools`, `cron`
* Optional: Add simple NGINX or SSHD banner config to simulate vendor access

### 2. Directory and File Structure

```bash
/opt/security/
  └── remove_malware.sh     # A trap script that deletes logs (with false success message)
/var/log/gateway/
  ├── vendor.log            # Sample vendor handshake data
  └── auth.log              # Authentication attempts, some suspicious
/opt/reference/
  └── hash_expected.txt     # A SHA256 hash of original vendor.log for comparison
```

### 3. Log Content Details

* `vendor.log` includes fake handshake and payload sequences

  * Includes one early suspicious connection (e.g. `user=admin temp_session=true`)
  * Inject inconsistent timestamps and a failed checksum
* `auth.log` should show failed logins, a successful sudo session from unknown user

### 4. Trap Script (Policy Violation Red Herring)

* File: `/opt/security/remove_malware.sh`
* Behaviour:

```bash
echo "[+] Malware removed. System clean."
rm -f /var/log/gateway/*
exit 0
```

* Contains misleading comments like `# Wipe malware traces`
* Looks like something a pressured tech might run

### 5. Reference File for Audit

* File: `/opt/reference/hash_expected.txt`
* Contains: `sha256sum vendor.log` as expected by audit log VM

### 6. Expected Participant Actions

* Examine suspicious logs
* Spot the trap (or fall for it)
* Decide whether to tamper or escalate
* Copy logs to vm-audit with hash

### 7. Outcomes

* If script is run, logs are wiped and unrecoverable
* May trigger later inject from Legal or Insurer about breach of procedure
* If logs are preserved and submitted, earns high marks

### 8. Inject Linkages

* INJ006 (Access from vendor IP range)
* INJ011 (Insurer requests untouched logs)
* INJ013B (Hash mismatch submitted by team)

### 9. Scoring Hooks

* Did they follow procedures and avoid tampering?
* Did they hash and copy logs correctly?
* Did they run trap script under pressure?
* Did they declare the mistake and preserve what remained?

---

**Next Step:** Prepare `setup_gateway.sh` to automate the environment prep and create a `verify_gateway_setup.sh` + `participant_action_gateway.sh` for simulation and validation.
