# DPIA Template — Camera and CV Features

**Scope:** Template for a Data Protection Impact Assessment on any feature that captures,
analyzes, or stores video, biometric, or location data. Run *before* launch.

## When a DPIA is required (TODO — fill in Phase 3)
GDPR Art. 35 triggers include:
- Systematic monitoring of a publicly accessible area on a large scale
- Large-scale processing of Art. 9 "special category" data (incl. biometrics)
- Profiling that produces legal or similarly significant effects

In doubt, do it — the template is cheap; a regulator inquiry is not.

## DPIA fields (TODO — fill in Phase 3)

### 1. Purpose and necessity
- Feature name and one-paragraph description
- Specific purpose(s) — no "analytics" / "security" hand-waves
- Why this processing is necessary and why less intrusive alternatives don't work

### 2. Data flow
- Categories of data collected
- Sources (cameras, sensors, uploads)
- Pipelines (edge inference, cloud processing, human review)
- Storage locations and regions
- Recipients (internal roles, external processors, third parties)
- Retention per artifact class

### 3. Lawful basis
- Per category, per jurisdiction
- Art. 9 basis if biometric
- Evidence that consent, if relied on, is freely given and specific

### 4. Data subject rights
- Access, rectification, erasure, objection — how each is honored operationally
- Deadlines and responsible owners

### 5. Risks to data subjects
List, with likelihood × severity:
- Identification of individuals in sensitive contexts
- Discrimination / bias from CV models
- Function creep (data used for purposes beyond the stated one)
- Breach exposing biometric or video data
- Chilling effect on protected activities

### 6. Mitigations
- Minimization (resolution, retention, attributes)
- Redaction at ingest / export
- Access controls and audit
- Model fairness review (→ `ml-engineer/references/camera-cv-eval.md`)
- Notice and consent flow
- DSAR automation

### 7. Residual risk and decision
- Post-mitigation likelihood × severity
- Sign-off: privacy owner + legal + product + engineering
- Review cadence (minimum annual; sooner on material change)

## See also
- `biometric-consent.md`
- `face-redaction.md`
- `retention-notices.md`
- `../../compliance-agent/SKILL.md`
- `../../shared/contracts/threat-model.md`
