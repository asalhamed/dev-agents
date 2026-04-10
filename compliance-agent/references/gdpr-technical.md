# GDPR Technical Measures

## Encryption

### At Rest
- AES-256 encryption for all databases and object storage
- Transparent Data Encryption (TDE) for PostgreSQL/ClickHouse
- S3 server-side encryption (SSE-S3 or SSE-KMS)

### In Transit
- TLS 1.3 minimum for all connections
- mTLS for device-to-broker (MQTT)
- DTLS for WebRTC media streams
- No plaintext protocols in production

## Access Control & Audit Logs

```json
{
  "timestamp": "2025-01-15T10:30:00Z",
  "actor": "user:jane@company.com",
  "action": "view_video",
  "resource": "camera:site-a/cam-01",
  "ip": "203.0.113.42",
  "result": "allowed"
}
```

Log all: authentication events, data access, configuration changes, admin actions.
Retain audit logs for 2 years minimum. Tamper-evident logging.

## Data Retention Automation
- Define retention policy per data type (telemetry: 30 days, video: 30 days, alerts: 1 year)
- Automated deletion job runs daily
- Verify deletion (spot-check that expired data is actually gone)
- Document: what was deleted, when, by what process

## Right to Erasure (Video Challenge)
- Video is continuous — can't easily delete one person
- **Approach 1:** Delete entire time range requested (overinclusive but simple)
- **Approach 2:** AI-based face redaction (expensive, imperfect)
- **Approach 3:** Metadata-only deletion (remove association, keep anonymized video)
- Document limitations in privacy policy
- Response deadline: 30 days from request

## Breach Notification
- **72-hour requirement:** notify supervisory authority within 72 hours of discovery
- **Content:** nature of breach, categories of data, approximate number of individuals, consequences, measures taken
- **Notification to individuals:** required if high risk to rights and freedoms
- **Preparation:** pre-drafted notification templates, designated breach response team
