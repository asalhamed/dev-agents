# Privacy Review

**Producer:** privacy-agent
**Consumer(s):** tech-lead, reviewer, compliance-agent, legal, product-owner,
  edge-media-agent, data-engineer

## Purpose

The operational privacy dossier for a feature that touches video, audio, biometric, or
location data. Written *before* launch. Makes purpose, consent, retention, and redaction
concrete enough that an operator can execute and an auditor can inspect.

## Required Fields

- **Feature identity** — Feature ID (F-NNN), one-paragraph summary
- **Data classification table** — per captured stream / derived artifact:
  category, identifiability, sensitivity (biometric vs. otherwise personal vs.
  non-personal), source
- **Purpose statements** — plain-language purpose per stream / artifact; single paragraph
  each; no "analytics" / "security" hand-waves
- **Lawful basis** — per jurisdiction in scope; Art. 9 basis for any biometric
  processing
- **Consent plan** — notice surfaces (signage, in-app, published), consent-capture flow,
  `ConsentRecord` schema fields, revocation mechanism
- **Retention schedule** — `RetentionWindow` per artifact class; storage tier progression;
  deletion triggers; evidence emitted on deletion
- **DSAR flow** — identity proofing, scoping, delivery, erasure; operator runbook link;
  jurisdictional deadline commitment
- **Redaction approach** — `RedactionPolicy` per artifact class; where in the pipeline
  redaction is applied; QA sampling cadence
- **DPIA summary** — if required (GDPR Art. 35 or equivalent trigger); residual risk
  decision and sign-off roster
- **Cross-jurisdictional deltas** — explicit differences across EU/UK, US states, APAC, etc.
- **Operator runbook links** — `privacy-agent/references/*`
- **Dependencies** — link to `threat-model.md` consent-bypass analysis, `streaming-spec.md`
  privacy fields, `schema-registry.md` privacy review for any schema with biometric/PII

## Validation Checklist

- [ ] Every captured stream has a written purpose a non-lawyer can understand
- [ ] Every biometric processing path has an identified lawful basis and
  `ConsentRecord` schema
- [ ] Retention is enforced by automation; `RetentionWindow` is per artifact class
- [ ] DSAR flow is documented AND end-to-end tested against the jurisdictional deadline
- [ ] Redaction is applied at the earliest feasible point
- [ ] DPIA performed (or explicitly justified as not required) for any new biometric or
  public-space feature
- [ ] Cross-jurisdictional deltas explicit when the feature ships to more than one region
- [ ] Consent-bypass analysis in the threat-model contract is present and complete
- [ ] Operator runbook exists for the three highest-frequency privacy requests

## See also

- `privacy-agent/SKILL.md`
- `threat-model.md` — privacy-specific threat categories
- `streaming-spec.md` — privacy fields on the video path
- `schema-registry.md` — schema-level PII / biometric review
- `compliance-audit.md` — framework-level audit evidence
- `../glossary.md` — `Purpose`, `ConsentRecord`, `RetentionWindow`, `DSAR`,
  `RedactionPolicy`
