# Face & Plate Redaction — Operator Runbook

**Scope:** Step-by-step procedures a non-technical operator executes to honor a DSAR,
export redacted footage, or perform routine redaction review.

## Principles
- **Irreversible by default** — exports use a one-way blur or mosaic
- **Earliest feasible** — redact at ingest for always-on streams; at export for
  on-demand retrieval
- **Two-eyes** — DSAR redactions are reviewed by a second operator before release

## Tools (TODO — fill in Phase 3)
- In-app redaction console (link to internal tool)
- Batch redaction CLI (for bulk DSAR responses)
- QA sampling dashboard (link)

## Runbook: export a redacted clip for a DSAR (TODO — fill in Phase 3)
1. Verify DSAR ticket — subject identity proved per the documented flow
2. Scope: date/time range, camera IDs, event IDs
3. Retrieve source recordings (consult retention table for availability)
4. Run redaction pipeline: face + plate + voice (if audio)
5. Spot-review output at 3 random timestamps per clip
6. Second-operator review
7. Package: redacted clip + metadata (what was kept, what was removed, why)
8. Deliver via the DSAR portal; ticket closes on delivery
9. Log the DSAR outcome event

## Runbook: honor an erasure request (TODO — fill in Phase 3)
1. Verify identity and scope
2. Tag all matching artifacts for deletion
3. Delete across: primary storage, backups, read replicas, search indexes, derived
   embeddings, ML training caches
4. Emit a verifiable deletion event per artifact
5. Confirm to the requester within the jurisdictional deadline

## Runbook: redaction QA sampling (TODO — fill in Phase 3)
- Weekly: random sample of N redacted exports
- Check for missed faces / plates / reflections / mirror surfaces
- Check for over-redaction that destroys the context the subject needs

## Failure modes and escalation (TODO — fill in Phase 3)
- Face not detected (low light, occlusion, unusual angle) → escalate to manual redaction
- Redaction tool offline → pause exports, open incident
- Request scope ambiguous → loop in privacy-agent / legal

## See also
- `biometric-consent.md`
- `dpia-template.md`
- `../../compliance-agent/SKILL.md` — framework-level obligations
