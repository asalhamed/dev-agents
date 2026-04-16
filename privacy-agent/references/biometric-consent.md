# Biometric Consent

**Scope:** Lawful bases, consent flows, and consent-record schemas for face, voice, gait,
and other biometric processing performed by camera and IoT features.

## Why biometric is special (TODO — fill in Phase 3)
Under GDPR Art. 9, BIPA, and most emerging state laws, biometric data is a "special
category" that requires:
- A narrower set of lawful bases than ordinary personal data
- Higher transparency standards
- Stronger retention limits
- Often: prior *written* (not just click-through) consent

## GDPR Art. 9 (TODO — fill in Phase 3)
Processing of biometric data for uniquely identifying a natural person is prohibited
unless a specific Art. 9(2) exception applies. The relevant ones for camera/IoT:
- Explicit consent (Art. 9(2)(a))
- Substantial public interest with EU/Member State law backing (Art. 9(2)(g))
- Employment / social security law (Art. 9(2)(b)) — narrow, often misused

Each case must be documented per feature, per jurisdiction.

## BIPA (Illinois) (TODO — fill in Phase 3)
- Written, informed consent before collection
- Public retention schedule
- Deletion at the earlier of: purpose completion or 3 years since last interaction
- Private right of action; high statutory damages — treat as a red line

## Other state laws (TODO — fill in Phase 3)
- Texas CUBI, Washington HB 1493
- CCPA/CPRA biometric provisions
- Emerging: NY, MD, etc. — maintain a jurisdiction delta table

## Consent record schema (TODO — fill in Phase 3)
Every consent event persists:
- `subject_id` (pseudonymous where possible)
- `captured_at` (ISO-8601, with timezone)
- `purpose_id` (links to the declared purpose — see SKILL workflow step 2)
- `notice_version` (content hash of the notice presented)
- `lawful_basis` (enum per jurisdiction)
- `method` (in-app click-through, written form scan, operator-witnessed, etc.)
- `operator_id` (if operator-mediated)
- `expires_at` (derived from jurisdiction + purpose)
- `revoked_at` (null until revocation)

Store append-only. Link consent to every downstream artifact that relied on it.

## Revocation (TODO — fill in Phase 3)
- Revocation is free, immediate, and at least as easy as giving consent
- Revocation triggers: stop new processing, delete derived biometric data within the
  jurisdictional deadline, preserve minimal record of the revocation itself

## Employment / workplace (TODO — fill in Phase 3)
Consent in an employment relationship is often not freely given; Art. 6/9 consent is a
weak basis at work. Prefer an alternative lawful basis or a works-council agreement.
Document the legal analysis, not just the mechanism.

## See also
- `face-redaction.md`
- `dpia-template.md`
- `retention-notices.md`
- `../../shared/standards.md` *(Phase 3)*
