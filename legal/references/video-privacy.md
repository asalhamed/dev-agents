# Video Privacy (GDPR Focus)

## Lawful Basis for Video Surveillance
1. **Legitimate interest** (most common for B2B): security, safety, operational monitoring
   - Requires: documented Legitimate Interest Assessment (LIA)
   - Balance test: our interest vs individual privacy rights
2. **Consent:** rarely practical for surveillance (can't get consent from everyone recorded)
3. **Legal obligation:** required by regulation (e.g., bank vault cameras)

## GDPR Requirements

### Data Minimization
- Only record areas where necessary (not break rooms, toilets)
- Lowest resolution sufficient for purpose
- Blur faces if identity not needed (analytics-only use case)

### Retention Periods
- Default: 30 days (sufficient for most security purposes)
- Extended: only with documented justification
- Incident footage: retain for investigation duration + legal hold
- Auto-delete: must be enforced technically, not just by policy

### Right to Erasure
- Video segments containing an individual must be deletable on request
- **Technical challenge:** video is continuous, not per-person
- Approaches: redaction (blur person), segment deletion, metadata-based search
- Document your approach and limitations

### DPIA (Data Protection Impact Assessment)
- **Required** for systematic monitoring of public areas
- Must assess: necessity, proportionality, risks, safeguards
- Must consult DPO (if appointed)
- Review annually or when processing changes

## Cross-Border Transfer
- Video of EU individuals cannot leave EU without adequate safeguards
- Options: EU-only cloud region, Standard Contractual Clauses, customer-controlled encryption
- Safest: deploy in customer's region, never transfer raw video

## Signage
- "CCTV in operation" signs at all monitored areas
- Include: who is recording, purpose, contact for data requests
- Visible before entering monitored area
