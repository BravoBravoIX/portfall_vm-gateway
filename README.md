VM Build Sheet: vm-gateway

Purpose:
Simulates the vendor-facing gateway connected to external systems. This VM appears compromised and includes a deceptive "malware removal" script that actually destroys forensic logs. It is designed to test team behaviour under pressure, policy compliance, and forensic chain-of-custody. Participants should not attempt remediation.

1. Services and Software to Install
Standard CLI tools: vim, grep, scp, rsyslog, net-tools, cron

Optional extras (for realism): SSH access hints or vendor NGINX banner (not required for core scenario)

2. Directory and File Structure
bash
Copy
Edit
/var/log/gateway/
  ├── vendor.log            # Handshake and payload activity log
  └── auth.log              # Failed and suspicious login attempts
/opt/security/
  └── remove_malware.sh     # Red herring script that wipes logs
/opt/reference/
  └── hash_expected.txt     # SHA256 of original vendor.log for audit integrity check
3. Log Content Details
vendor.log

Appears technical and timed: simulated vendor session with handshake and payload

Red flags: user=admin temp_session=true, inject_payload.sh, checksum failures

auth.log

Shows several failed root login attempts

Includes 1 successful login and sudo access from suspicious user ghost

4. Trap Script (Policy Violation Red Herring)
Location: /opt/security/remove_malware.sh

Permissions: Executable

Behaviour:

bash
Copy
Edit
echo "[+] Malware removed. System clean."
rm -f /var/log/gateway/*
exit 0
Purpose:

Misleads participants into thinking they're cleaning up the system

Actually wipes all critical logs

Contains the comment: # Wipe malware traces

5. Reference File for Audit
Location: /opt/reference/hash_expected.txt

Contents: SHA256 hash of clean vendor.log (used by vm-audit to confirm integrity)

6. Expected Participant Actions
Examine vendor.log and auth.log using cat, grep, or similar

Use sha256sum to compare logs with expected hash

Avoid executing the remove_malware.sh script (or document the mistake if they do)

Transfer the log using:

bash
Copy
Edit
scp /var/log/gateway/vendor.log audituser@vm-audit:/incident/archive/gateway/
7. Outcomes
If the trap script is run:

Logs are wiped and irrecoverable

Will impact audit trail and may trigger scoring deductions

If logs are correctly hashed and transferred:

Indicates sound forensic handling

Full marks awarded if actions match policy expectations

8. Inject Linkages
INJ006 – Suspicious external connection from vendor range

INJ011 – Insurer requests untouched gateway logs

INJ013B – Audit detects tampering or incomplete logs

9. Scoring Hooks
Did the team hash logs before making changes?

Did they detect the trap or fall for it?

Did they escalate or cover up?

Did they transfer evidence using proper procedure?

Did they communicate mistakes (if made)?
