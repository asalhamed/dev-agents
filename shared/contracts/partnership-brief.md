# Partnership Brief

**Producer:** partnerships-agent
**Consumer(s):** product-owner, legal

## Required Fields

- **Partner name/type** — company, category (hardware vendor, SI, channel, technology)
- **Partnership model** — OEM, white-label, referral, technology integration, channel/reseller
- **Value exchange** — what each party gives and gets
- **Technical integration requirements** — APIs, SDKs, protocols, certification effort
- **Exclusivity terms** — if any, scope and duration
- **Success metrics** — how we measure partnership value
- **Risks** — what could go wrong, mitigation plan

## Validation Checklist

- [ ] Value to both parties defined (not one-sided)
- [ ] Technical requirements defined before legal engagement
- [ ] Conflict-of-interest assessed (does this partner compete with existing partners?)
- [ ] Success metrics defined (revenue, leads, integrations, certifications)

## Example (valid)

```markdown
## PARTNERSHIP BRIEF: Axis Communications — Technology Integration

**Partner:** Axis Communications (camera manufacturer)
**Model:** Technology integration — certified compatible partner program

### Value Exchange
- **We get:** "Axis Certified" badge, co-marketing, access to Axis dealer network
- **They get:** monitoring platform that works out-of-box with Axis cameras, case studies

### Technical Integration
- VAPIX API integration for camera discovery and configuration
- ONVIF Profile S/T compliance for streaming
- Test against 5 camera models (M-series, P-series)
- Effort: ~3 weeks engineering, ~2 weeks QA

### Exclusivity
None. Non-exclusive technology partnership. We maintain compatibility with all ONVIF cameras.

### Success Metrics
- 10 joint leads from Axis dealer network in 6 months
- Axis cameras as recommended hardware in our docs
- 2 joint case studies published

### Risks
- Axis prioritizes their own VMS → mitigate by targeting use cases outside their core (IoT + video)
- Certification process takes 3+ months → start early, dedicate QA resources
```
