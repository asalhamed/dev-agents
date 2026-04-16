# Retention, Notices, and Signage

**Scope:** The operator-facing artifacts that make retention and notice visible to
data subjects and auditors — camera signage, in-app disclosures, published retention
schedules.

## Retention schedule (TODO — fill in Phase 3)
Per artifact class, document:
- Retention window (minimum and maximum)
- Storage tier progression (hot → warm → cold → deleted)
- Deletion trigger (purpose complete, TTL expiry, DSAR, revocation)
- Legal-hold override policy
- Evidence of deletion (typed event, audit trail)

Examples (tune to product):
- Live view buffer: seconds to minutes
- Motion-triggered recordings: 7–30 days
- Continuous recordings: 14 days default, configurable up to jurisdictional cap
- Face embeddings: deleted when source recording is deleted, or on revocation
- Exported DSAR clips: 30 days post-delivery

## Camera signage (TODO — fill in Phase 3)
Required elements (EU GDPR transparency, plus most common US state requirements):
- Camera pictogram
- Operator (controller) name
- Contact for privacy questions
- Summary of purpose
- Reference / link to full privacy notice
- Presence of biometric processing (if any)

Design: legible at approach distance, localized, weather-durable. Provide templates at
multiple sizes.

## In-app / on-device disclosure (TODO — fill in Phase 3)
- First-run: full privacy notice, biometric consent where applicable
- Feature activation: purpose-specific reminder when a privacy-sensitive feature is turned
  on (CV analytics, cloud recording, audio, etc.)
- Settings: persistent visibility of what's on, what's kept, and how to revoke

## Published privacy notice (TODO — fill in Phase 3)
- Hosted at a stable URL
- Versioned (content hash recorded in every consent event — see `biometric-consent.md`)
- Plain-language summary + layered detail
- Jurisdiction-specific supplements where required

## Annual review (TODO — fill in Phase 3)
- Verify signage is current against deployed features
- Verify disclosures match what the system actually does (walk a sample camera)
- Refresh notice if the data flow materially changed

## See also
- `biometric-consent.md`
- `dpia-template.md`
- `../../marketing/SKILL.md` — customer-facing copy tone
- `../../legal/SKILL.md` — regulator-facing text
