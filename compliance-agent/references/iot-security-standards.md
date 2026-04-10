# IoT Security Standards

## NIST IoT Cybersecurity Framework
Key areas:
- **Device identity:** unique, cryptographic identity per device
- **Device configuration:** ability to configure securely, disable unused services
- **Data protection:** encryption, integrity verification
- **Logical access:** authentication, authorization for device management
- **Software update:** secure, verified OTA update capability
- **Cybersecurity awareness:** logging, monitoring, anomaly detection

## ETSI EN 303 645
Consumer IoT security standard (14 provisions):
1. No universal default passwords
2. Implement vulnerability disclosure policy
3. Keep software updated
4. Securely store sensitive security parameters
5. Communicate securely (encrypted)
6. Minimize exposed attack surfaces
7. Ensure software integrity (verified updates)
8. Ensure personal data is secure
9. Make systems resilient to outages
10. Examine telemetry data (monitor for anomalies)
11. Easy for users to delete personal data
12. Easy installation and maintenance
13. Validate input data
14. Document security properties

## Device Identity Requirements
- Each device: unique cryptographic identity (X.509 certificate or equivalent)
- No shared secrets across fleet
- Identity bound to hardware (TPM or secure element preferred)
- Revocation mechanism (CRL or OCSP)

## Secure Boot
- Bootloader verifies firmware signature before execution
- Chain of trust: ROM → bootloader → firmware → application
- Bootloader is immutable (cannot be updated OTA)
- Anti-rollback: prevent downgrading to vulnerable firmware version

## OTA Update Security
- Firmware signed by authorized build system
- Device verifies signature before applying
- Encrypted in transit (TLS) and optionally at rest
- Atomic updates with rollback capability
- Update server authenticated (device verifies server identity)

## Vulnerability Disclosure
- Public security contact (security@company.com)
- Disclosure policy published on website
- Acknowledgment within 5 business days
- Fix timeline: critical (7 days), high (30 days), medium (90 days)
- Coordinate disclosure with reporter
