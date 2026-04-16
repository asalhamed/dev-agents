# OTA Plan

**Producer:** firmware-ota-agent
**Consumer(s):** tech-lead, reviewer, compliance-agent, observability-agent,
  security-agent, iot-dev

## Purpose

The operational plan for a firmware rollout. Defines the fleet classification, the
metadata model, the cohort sequence, the health gates, and the rollback procedure for a
specific firmware release or class of releases.

## Required Fields

- **Release identity** — `FirmwareBundle` identifier and version; applicable `DeviceClass`
  set
- **Fleet classification** — cohort table keyed by hardware rev, current version, region,
  site, customer tier
- **Metadata model** — TUF / Uptane / SUIT; role key thresholds; delegation structure
- **Signing summary** — who signed, with which keys, with what attestations
- **Stages** — ordered stages (e.g., internal → canary → early → broad → full) with
  target percentage and observation window per stage
- **Health gates** — per stage, the SLIs/SLOs that gate advancement
- **Auto-halt criteria** — explicit numeric thresholds and responsible runbook
- **Rollback plan** — mechanism (anti-rollback counter, signed downgrade manifest, slot
  flip) and drill status
- **Attestation requirement** — which device classes must present a valid
  `AttestationQuote` before targeting
- **Observability hooks** — links to the dashboards and alerts
  (`observability-agent` owns SLOs)
- **Known risks and mitigations**
- **Compliance notes** — applicable IEC 62443 / NIST SP 800-193 / ETSI 303 645 controls
  (when in scope)
- **Supply-chain evidence** — link to `supply-chain-review.md` or SLSA provenance

## Validation Checklist

- [ ] Every cohort has a name, criteria, and size
- [ ] Every stage has an observation window AND a health gate
- [ ] Auto-halt thresholds are numeric, not qualitative
- [ ] Rollback is tested against every `DeviceClass` in scope
- [ ] Attestation requirements are explicit per `DeviceClass`
- [ ] Observability dashboards exist and are linked
- [ ] Runbook exists for "revoke a bad bundle we already signed"
- [ ] Bundle signing is evidenced by an attestation from `supply-chain-security-agent`
- [ ] When IEC 62443 is in scope, the plan maps to relevant FR × SL-T cells

## See also

- `firmware-ota-agent/SKILL.md`
- `firmware-ota-agent/references/staged-rollout.md`
- `threat-model.md` — OTA-specific threat categories
- `supply-chain-review.md` — provenance of the signed bundle
- `../glossary.md` — `FirmwareBundle`, `Cohort`, `AttestationQuote`
