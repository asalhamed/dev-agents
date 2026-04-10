# SOC2 Type II Control Mapping

## Security (CC6, CC7)

### CC6.1 — Logical Access Controls
- **Requirement:** restrict access to authorized users only
- **Implementation:**
  - SSO (SAML/OIDC) for all platform access
  - RBAC with principle of least privilege
  - MFA enforced for all admin accounts
  - API keys scoped to specific resources
- **Evidence:** IAM policy documents, access review logs, MFA enrollment report

### CC6.6 — Encryption
- **At rest:** AES-256 for all data stores (RDS, S3, ClickHouse)
- **In transit:** TLS 1.3 for all connections (MQTT, HTTPS, WebRTC)
- **Key management:** AWS KMS or customer-managed keys (BYOK)
- **Evidence:** encryption configuration screenshots, TLS scan results

### CC7.2 — Monitoring & Anomaly Detection
- **Requirement:** monitor for security events and anomalies
- **Implementation:**
  - Centralized logging (all services → ELK/Datadog)
  - Security event alerting (failed auth, privilege escalation, data access)
  - Intrusion detection on infrastructure
- **Evidence:** SIEM dashboard, alert rule definitions, sample alerts

## Availability (A1)

### A1.2 — Recovery & Incident Response
- **Requirement:** mechanisms to recover from incidents
- **Implementation:**
  - Documented incident response plan
  - Automated backups (daily, tested monthly)
  - Disaster recovery plan (RPO: 1 hour, RTO: 4 hours)
  - On-call rotation with escalation matrix
- **Evidence:** IR plan document, backup verification logs, DR test results

## Confidentiality (C1)

### C1.1 — Data Classification
- **Public:** marketing materials, documentation
- **Internal:** architecture diagrams, internal tools
- **Confidential:** customer data, telemetry, video
- **Restricted:** credentials, encryption keys, PII
- **Evidence:** data classification policy, handling procedures per class

## Processing Integrity (PI1)

### PI1.1 — Data Pipeline Accuracy
- **Requirement:** data is processed completely, accurately, timely
- **Implementation:**
  - Schema validation at ingestion
  - Idempotent processing (safe to replay)
  - Monitoring: data freshness, completeness metrics
  - Checksums for video segment integrity
- **Evidence:** schema validation rules, data quality dashboard, test results
