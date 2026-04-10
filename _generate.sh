#!/bin/bash
set -e
cd /home/ahmed/.openclaw/workspace/dev-agents-review

###############################################################################
# PART 1: CONTRACT FILES
###############################################################################

cat > shared/contracts/device-spec.md << 'EOF'
# Device Specification

**Producer:** iot-dev
**Consumer(s):** qa-agent, reviewer

## Required Fields

- **Device type** — hardware model, form factor, intended environment
- **Firmware version** — semantic version, target platform (e.g., ESP32, STM32, nRF52)
- **Supported protocols** — MQTT, BLE, CoAP, HTTP, Modbus, etc.
- **Telemetry schema** — JSON/Protobuf schema with version, field names, types, units
- **Command schema** — inbound commands the device accepts (topic, payload, response)
- **OTA update mechanism** — update delivery, verification, rollback strategy
- **Power/connectivity requirements** — power source, sleep modes, expected uplink bandwidth
- **Security** — authentication method (X.509, PSK, token), encryption (TLS version), credential storage

## Validation Checklist

- [ ] MQTT topic hierarchy defined (follows `devices/{device_id}/telemetry` convention)
- [ ] Telemetry schema versioned (schema_version field in every message)
- [ ] OTA rollback mechanism documented (A/B partition or equivalent)
- [ ] No hardcoded credentials (certs or tokens loaded from secure storage)
- [ ] Power budget documented (active/sleep current, expected battery life if applicable)

## Example (valid)

```markdown
## DEVICE SPEC: TH-100 Temperature/Humidity Sensor

**Device type:** Indoor environmental sensor, DIN-rail mount
**Firmware version:** 1.2.0 (ESP32-S3)
**Protocols:** MQTT 3.1.1 over TLS 1.3

### Telemetry Schema (v2)
Topic: `devices/{device_id}/telemetry`
Interval: 30 seconds
```json
{
  "schema_version": 2,
  "device_id": "th100-a1b2c3",
  "timestamp": "2025-01-15T10:30:00Z",
  "temperature_c": 22.5,
  "humidity_pct": 45.2,
  "battery_v": 3.7
}
```

### Command Schema
Topic: `devices/{device_id}/commands`
- `set_interval` — `{"interval_s": 60}` → changes telemetry interval
- `reboot` — `{}` → triggers device reboot with status confirmation

### OTA
A/B partition. Download from `ota/{device_id}/firmware`. Ed25519 signature verification.
Watchdog triggers rollback if new firmware fails 3 consecutive boot attempts.

### Security
X.509 client certificate provisioned at manufacturing. TLS 1.3. No PSK fallback.
```
EOF

cat > shared/contracts/protocol-spec.md << 'EOF'
# Protocol Specification

**Producer:** iot-dev ↔ backend-dev (bidirectional)
**Consumer(s):** architect, tech-lead

## Required Fields

- **Protocol type** — MQTT / HTTP / WebSocket / CoAP / custom
- **Topic/endpoint definitions** — full topic hierarchy or endpoint list
- **Message schemas** — payload format with version, field types, examples
- **QoS/reliability guarantees** — delivery semantics (at-most-once, at-least-once, exactly-once)
- **Authentication mechanism** — how clients authenticate to the broker/server
- **Error handling** — malformed message behavior, rejection codes, retry guidance

## Validation Checklist

- [ ] All topics/endpoints documented with direction (device→cloud, cloud→device, bidirectional)
- [ ] Message schemas versioned (breaking changes require new topic/version)
- [ ] Auth mechanism specified (mutual TLS, token, API key)
- [ ] Error/rejection behavior defined (what happens with malformed or unauthorized messages)

## Example (valid)

```markdown
## PROTOCOL SPEC: Device Fleet MQTT

**Protocol:** MQTT 3.1.1 over TLS 1.3
**Broker:** EMQX cluster (mqtt.platform.internal:8883)
**Auth:** Mutual TLS (X.509 client certificates)

### Topic Hierarchy

| Topic | Direction | QoS | Purpose |
|-------|-----------|-----|---------|
| `devices/{id}/telemetry` | device→cloud | 1 | Sensor readings |
| `devices/{id}/status` | device→cloud | 1 (retained) | Online/offline/battery |
| `devices/{id}/commands` | cloud→device | 1 | Remote commands |
| `devices/{id}/commands/response` | device→cloud | 1 | Command acknowledgment |
| `devices/{id}/ota/notify` | cloud→device | 1 | New firmware available |
| `devices/{id}/ota/status` | device→cloud | 1 | OTA progress reporting |

### Last Will and Testament
Topic: `devices/{id}/status`
Payload: `{"status": "offline", "timestamp": "..."}`
QoS: 1, Retained: true

### Error Handling
- Malformed JSON: broker logs, message dropped (QoS 0 behavior)
- Unauthorized topic: connection terminated, event logged
- Schema version mismatch: consumer logs warning, processes best-effort
```
EOF

cat > shared/contracts/streaming-spec.md << 'EOF'
# Streaming Specification

**Producer:** video-streaming
**Consumer(s):** devops-agent, qa-agent, reviewer

## Required Fields

- **Input source** — RTSP URL format, camera type/model, resolution, framerate
- **Output protocols** — WebRTC, HLS, RTMP (with target use case for each)
- **Transcoding pipeline** — tools (GStreamer/FFmpeg), codec, profile, bitrate ladder
- **Recording strategy** — storage location, segment duration, retention policy
- **Latency target** — end-to-end camera-to-viewer latency requirement
- **Bandwidth requirements** — per-stream ingest and egress bandwidth budget
- **Error handling** — camera disconnect behavior, reconnect strategy, failover

## Validation Checklist

- [ ] Latency target defined and measurable (e.g., <1s for live, <10s for HLS)
- [ ] Recording retention policy specified (days, auto-delete, tiered storage)
- [ ] Camera disconnect/reconnect handled (automatic, with backoff)
- [ ] Bandwidth budget documented (per camera and aggregate)

## Example (valid)

```markdown
## STREAMING SPEC: Site Monitoring — Building A

**Input:** 8× Axis M3065-V cameras, RTSP (rtsp://{ip}:554/stream1), 1080p@15fps, H.264
**Live output:** WebRTC via Pion SFU — target <800ms latency
**Recording output:** HLS segments (6s) to S3 — 30-day retention

### Transcoding Pipeline
GStreamer: rtspsrc → h264parse → tee
  Branch 1: → webrtcbin (passthrough H.264, no re-encode)
  Branch 2: → hlssink2 (6s segments, 5-segment playlist)

### Bandwidth Budget
- Per camera ingest: 4 Mbps (1080p H.264 CBR)
- Site uplink for 8 cameras: 32 Mbps (dedicated VLAN)
- WebRTC egress per viewer: 4 Mbps

### Error Handling
- Camera disconnect: retry every 5s with exponential backoff (max 60s)
- WebRTC viewer disconnect: session cleanup after 30s timeout
- Recording gap: log gap event, resume recording on reconnect
```
EOF

cat > shared/contracts/model-spec.md << 'EOF'
# Model Specification

**Producer:** ml-engineer
**Consumer(s):** edge-agent, backend-dev

## Required Fields

- **Model name/version** — unique identifier and semantic version
- **Problem type** — classification, detection, segmentation, anomaly detection, regression
- **Input schema** — tensor shape, dtype, preprocessing steps (resize, normalize, etc.)
- **Output schema** — classes/values, confidence threshold, post-processing
- **Performance requirements** — accuracy/mAP, latency, false positive rate, false negative rate
- **Deployment targets** — cloud (GPU type), edge (hardware model, RAM/compute budget)
- **Model size** — file size, parameter count, quantization level
- **Dependencies** — runtime (ONNX, TFLite, TensorRT), library versions

## Validation Checklist

- [ ] Input/output schema explicitly typed (tensor shape, dtype, value ranges)
- [ ] False positive rate requirement defined (with acceptable threshold)
- [ ] Edge hardware compatibility confirmed (model fits in RAM, meets FPS target)
- [ ] Training data source documented (dataset, size, distribution, bias assessment)
- [ ] Drift detection plan included (what metrics to monitor, alert thresholds)

## Example (valid)

```markdown
## MODEL SPEC: person-detect-v3

**Problem type:** Object detection (person class only)
**Version:** 3.1.0
**Base architecture:** YOLOv8-nano

### Input
- Shape: [1, 3, 640, 640] (NCHW)
- Dtype: float32 (INT8 quantized for edge)
- Preprocessing: resize to 640×640, normalize [0,1], BGR→RGB

### Output
- Bounding boxes: [N, 4] (x1, y1, x2, y2 normalized)
- Confidence scores: [N, 1]
- Confidence threshold: 0.6 (tunable)
- NMS IoU threshold: 0.45

### Performance Requirements
- mAP@0.5: ≥ 0.82
- False positive rate: < 3% (on validation set)
- Inference latency: < 50ms on Jetson Nano, < 100ms on RPi4
- FPS: ≥ 15 on Jetson, ≥ 10 on RPi4

### Deployment
- Edge: ONNX (INT8) — 6.2 MB
- Cloud: ONNX (FP16) — 12.1 MB
- Runtime: ONNX Runtime 1.16+ with TensorRT EP (edge), CUDA EP (cloud)

### Drift Detection
Monitor: inference confidence distribution, detection count per hour
Alert: >20% shift in mean confidence over 7-day rolling window
```
EOF

cat > shared/contracts/gtm-strategy.md << 'EOF'
# Go-To-Market Strategy

**Producer:** growth-strategist
**Consumer(s):** product-owner, marketing, sales

## Required Fields

- **Target verticals** — prioritized list with rationale for ordering
- **ICP (Ideal Customer Profile)** — specific company characteristics, size, pain points
- **TAM/SAM/SOM estimates** — with sources and methodology
- **GTM motion** — product-led, sales-led, channel, or hybrid (with rationale)
- **Primary channels** — how we reach ICPs (content, events, outbound, partners)
- **90-day milestones** — specific, measurable goals for the first quarter
- **Success metrics** — how we measure GTM effectiveness (pipeline, conversion, CAC)

## Validation Checklist

- [ ] ICP is specific (not "any company that uses IoT")
- [ ] TAM/SAM/SOM sourced (analyst reports, census data, or bottom-up calc)
- [ ] GTM motion validated with sales/marketing (not just strategist opinion)
- [ ] 90-day plan is actionable (milestones have owners and are measurable)

## Example (valid)

```markdown
## GTM STRATEGY: Industrial Remote Monitoring — Oil & Gas Beachhead

### Target Verticals (prioritized)
1. **Oil & Gas** (beachhead) — pipeline monitoring, wellhead surveillance
2. Utilities — grid monitoring, water treatment
3. Manufacturing — equipment health monitoring

### ICP
Mid-size oil & gas operators (50-500 wells), US Permian Basin.
Pain: $2,000+ per field visit, 48h+ incident detection time.
Budget holder: VP Operations. Technical champion: SCADA engineer.
Company size: 200-2,000 employees, $50M-$500M revenue.

### TAM/SAM/SOM
- TAM: $4.2B (industrial remote monitoring, MarketsAndMarkets 2024)
- SAM: $380M (oil & gas, US, pipeline + wellhead)
- SOM: $3.8M (year 1 — 10 customers × $380K ACV)

### GTM Motion
Sales-led with technical content marketing for inbound.
Pilot-first: 30-day proof-of-value before procurement.

### 90-Day Milestones
1. Month 1: 5 qualified discovery calls booked
2. Month 2: 2 pilot deployments started
3. Month 3: 1 pilot converted to paid contract

### Success Metrics
- Pipeline: $2M qualified pipeline by day 90
- CAC: < $50K per customer (including pilot cost)
- Pilot→Paid conversion: > 50%
```
EOF

cat > shared/contracts/partnership-brief.md << 'EOF'
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
EOF

cat > shared/contracts/incident-report.md << 'EOF'
# Incident Report

**Producer:** incident-responder
**Consumer(s):** tech-lead, observability-agent

## Required Fields

- **Incident ID** — unique identifier (e.g., INC-2025-042)
- **Severity** — P1 / P2 / P3 (with definition reference)
- **Start/end time** — UTC timestamps for detection, mitigation, resolution
- **Impact** — customers affected (count/percentage), services affected, data loss (if any)
- **Timeline of events** — factual, timestamped sequence of events
- **Root cause** — actual underlying cause (not just symptoms)
- **Mitigation taken** — what was done to restore service
- **Action items** — each with owner, due date, and priority

## Validation Checklist

- [ ] Timeline is factual (not editorialized — "we noticed" not "someone failed to")
- [ ] Root cause identified (not just symptoms — "connection pool exhausted" not "service was slow")
- [ ] Action items have owners and due dates
- [ ] Blameless (no individual blamed — focus on systems, not people)
- [ ] Customers notified if P1/P2

## Example (valid)

```markdown
## INCIDENT REPORT: INC-2025-042

**Severity:** P2
**Duration:** 2025-03-15 14:22 UTC → 2025-03-15 15:07 UTC (45 min)
**Impact:** 12% of customers experienced degraded live video (frozen frames).
Zero data loss. Recording unaffected.

### Timeline
- 14:22 — Alert: WebRTC SFU error rate > 5% (PagerDuty)
- 14:25 — On-call engineer acknowledges, begins investigation
- 14:31 — Root cause identified: TURN server ran out of relay allocations
- 14:38 — Mitigation: scaled TURN server pool from 2 → 4 instances
- 14:52 — Error rate dropping, new connections succeeding
- 15:07 — All metrics nominal, incident resolved

### Root Cause
TURN server max-allocations was set to 500 (default). Customer growth pushed
concurrent relay connections to 480+ during peak hours. New connections failed
when allocation limit was hit.

### Action Items
1. Increase TURN allocation limit to 2000 and add monitoring — @devops — 2025-03-17
2. Add TURN allocation usage to capacity dashboard — @observability — 2025-03-19
3. Auto-scaling policy for TURN servers at 70% allocation — @devops — 2025-03-22
```
EOF

cat > shared/contracts/compliance-audit.md << 'EOF'
# Compliance Audit

**Producer:** compliance-agent
**Consumer(s):** legal, reviewer

## Required Fields

- **Framework** — SOC2 Type I/II, ISO 27001, GDPR, NIST, ETSI EN 303 645
- **Audit scope** — systems, services, and data flows in scope
- **Controls assessed** — specific control IDs and descriptions
- **Gaps found** — each with severity (critical/high/medium/low) and description
- **Remediation plan** — prioritized actions with owners and timelines
- **Evidence required** — what documentation/artifacts support each control

## Validation Checklist

- [ ] All in-scope systems assessed (no gaps in coverage)
- [ ] Every gap has severity rating and specific description
- [ ] Remediation items have owners and timelines
- [ ] Evidence collection plan included (what to gather, where it lives)

## Example (valid)

```markdown
## COMPLIANCE AUDIT: SOC2 Type II Gap Analysis

**Framework:** SOC2 Type II
**Scope:** Video monitoring platform (cloud + edge), customer data flows
**Date:** 2025-Q1

### Controls Assessed
- CC6.1 — Logical access controls
- CC6.6 — Encryption of data in transit
- CC7.2 — Monitoring for anomalies and security events
- A1.2 — Recovery mechanisms and incident response

### Gaps Found

| # | Control | Severity | Gap |
|---|---------|----------|-----|
| 1 | CC7.2 | High | No centralized security event logging — edge nodes log locally only |
| 2 | CC6.1 | Medium | Service-to-service auth uses shared API keys, not mTLS |
| 3 | A1.2 | Medium | Disaster recovery plan exists but untested in 12 months |

### Remediation Plan
1. **[High]** Centralize edge logs to SIEM — @devops — 2025-04-15
2. **[Medium]** Migrate service auth to mTLS — @backend-dev — 2025-05-01
3. **[Medium]** Schedule and execute DR test — @incident-responder — 2025-04-30

### Evidence Required
- CC6.1: Access control policy doc, IAM screenshots, audit log samples
- CC7.2: SIEM dashboard, alert rule definitions, sample alert
- A1.2: DR plan document, DR test report with findings
```
EOF

cat > shared/contracts/marketing-brief.md << 'EOF'
# Marketing Brief

**Producer:** marketing
**Consumer(s):** product-owner (for approval)

## Required Fields

- **Content type** — blog post, whitepaper, case study, webinar, video, social campaign
- **Target audience** — specific persona (role, industry, pain point)
- **Goal** — awareness, consideration, or conversion
- **Key messages** — 3 max, concise and differentiated
- **Call to action** — what we want the reader/viewer to do next
- **Success metric** — how we measure this content's impact
- **Distribution channels** — where and how it will be promoted
- **Timeline** — draft, review, publish dates

## Validation Checklist

- [ ] Audience is specific (not "anyone interested in IoT")
- [ ] Technical claims verified with engineering
- [ ] CTA is clear and measurable (not "learn more")
- [ ] Approved by product-owner before publication

## Example (valid)

```markdown
## MARKETING BRIEF: Blog — "How IoT Remote Monitoring Reduces Field Visit Costs"

**Content type:** Technical blog post (1,200-1,500 words)
**Target audience:** VP Operations at mid-size oil & gas companies (50-500 wells)
**Goal:** Consideration — move from awareness to evaluating our platform

### Key Messages
1. Remote monitoring eliminates 60-80% of routine field visits
2. Real-time alerts reduce incident response time from 48h to <1h
3. ROI is measurable within 90 days of deployment

### Call to Action
"Calculate your field visit savings" → leads to ROI calculator landing page

### Success Metric
- 500 organic visits in first 30 days
- 15 ROI calculator submissions (3% conversion)

### Distribution
- Company blog (SEO-optimized for "remote monitoring cost reduction")
- LinkedIn (organic + $500 promoted to ICP)
- Email to existing leads in oil & gas segment

### Timeline
- Draft: 2025-04-01 | Engineering review: 2025-04-03 | Publish: 2025-04-07
```
EOF

cat > shared/contracts/sales-proposal.md << 'EOF'
# Sales Proposal

**Producer:** sales
**Consumer(s):** legal (review), finance (pricing)

## Required Fields

- **Prospect name** — company and key contacts
- **Deal size** — estimated ACV and total contract value
- **Key pain points addressed** — specific problems this prospect has
- **Proposed solution** — what we're selling and how it maps to their needs
- **ROI calculation** — projected savings/gains using prospect's numbers where possible
- **Implementation timeline** — phases, durations, dependencies
- **SLA commitments** — uptime, support response times, data guarantees
- **Pricing** — approved by finance, with breakdown
- **Next steps** — concrete actions with dates

## Validation Checklist

- [ ] Addresses prospect's stated pain points (not generic value props)
- [ ] ROI uses customer's numbers where possible (not just industry averages)
- [ ] Timeline validated with tech-lead (we can actually deliver this)
- [ ] SLA approved by legal (we can actually commit to this)
- [ ] Pricing approved by finance (margins are acceptable)

## Example (valid)

```markdown
## SALES PROPOSAL: Acme Oil & Gas — Remote Wellhead Monitoring

**Prospect:** Acme Oil & Gas (120 wells, Permian Basin)
**Contact:** Jane Smith, VP Operations
**Deal size:** $360K ACV ($30K/mo for 120 devices + platform)

### Pain Points
1. $2,200 average cost per field visit (travel + labor)
2. 36-48h average time to detect wellhead anomalies
3. 2 safety incidents in past year from delayed detection

### Proposed Solution
- 120 IoT sensors (pressure, temperature, flow)
- Real-time dashboard + mobile app
- Automated alerting with 15-min detection SLA
- Video surveillance on 8 high-priority wells

### ROI
- Current field visit cost: $2,200 × 800 visits/year = $1.76M
- Projected reduction: 65% fewer visits → $1.14M savings
- Platform cost: $360K/year
- **Net savings: $784K/year (2.2x ROI)**

### Implementation: 8 weeks
- Week 1-2: Site survey, network setup
- Week 3-4: Sensor installation (30/week)
- Week 5-6: Platform configuration, integration
- Week 7-8: Training, go-live, monitoring

### Pricing
- Platform: $150/device/month (120 devices = $18K/mo)
- Video add-on: $500/camera/month (8 cameras = $4K/mo)
- Implementation: $30K one-time
- **Total Year 1: $294K + $30K setup = $324K**
```
EOF

cat > shared/contracts/customer-health.md << 'EOF'
# Customer Health Report

**Producer:** customer-success
**Consumer(s):** product-owner, data-analyst

## Required Fields

- **Customer name** — account identifier
- **Health score** — green / yellow / red (with scoring methodology reference)
- **Device uptime %** — fleet average and worst performers
- **Support ticket volume** — count, trend (increasing/stable/decreasing), avg resolution time
- **Adoption metrics** — features used, API call volume, active users
- **Renewal date** — contract end date and auto-renewal terms
- **Risks** — specific concerns with likelihood and impact
- **Expansion opportunities** — upsell/cross-sell potential with rationale

## Validation Checklist

- [ ] Health score based on objective metrics (not gut feeling)
- [ ] At-risk accounts flagged with specific risks (not just "seems unhappy")
- [ ] Feature requests documented and forwarded to product-owner
- [ ] Renewal timeline noted (flag if <90 days out)

## Example (valid)

```markdown
## CUSTOMER HEALTH: BuildCorp Industries — Q1 2025

**Health score:** 🟡 Yellow
**Devices:** 200 sensors, 12 cameras
**Renewal:** 2025-09-15 (auto-renew, 60-day cancellation notice)

### Device Uptime
- Fleet average: 97.2% (target: 99%)
- Worst: 3 sensors at Site B consistently dropping (WiFi coverage issue)

### Support
- Tickets this quarter: 14 (up from 8 last quarter)
- Avg resolution: 4.2h (SLA: 8h)
- Trend: increasing — driven by Site B connectivity issues

### Adoption
- Dashboard: 8 daily active users (up from 5)
- Mobile app: 3 users (low — training opportunity)
- API: 12K calls/day (stable)
- Unused features: anomaly detection, scheduled reports

### Risks
1. **Site B connectivity** — 3 devices chronically offline. Customer frustrated.
   Likelihood: high. Impact: may block expansion or trigger churn discussion.
2. **Low mobile adoption** — field teams not using mobile app.

### Expansion Opportunities
- Customer expanding to 2 new sites (Q3) — potential +80 devices
- Anomaly detection upsell — customer asked about predictive maintenance
```
EOF

cat > shared/contracts/hiring-plan.md << 'EOF'
# Hiring Plan

**Producer:** hr
**Consumer(s):** finance (budget approval)

## Required Fields

- **Role title** — specific job title
- **Level** — junior, mid, senior, staff, principal
- **Team/division** — which team this role belongs to
- **Start date target** — when we need this person
- **Compensation band** — base salary range, currency
- **Equity range** — option/RSU grant range
- **Headcount justification** — why this hire is needed now
- **Interview process outline** — stages, interviewers, timeline
- **Success criteria** — how we'll know this hire is working at 90 days

## Validation Checklist

- [ ] Compensation benchmarked to market (source: levels.fyi, Glassdoor, or recruiter data)
- [ ] Headcount approved by finance (budget allocated)
- [ ] Interview process defined before job posting goes live
- [ ] Success criteria defined (specific, not "fits in well")

## Example (valid)

```markdown
## HIRING PLAN: Senior Embedded Software Engineer

**Level:** Senior (L5)
**Team:** IoT / Device Engineering
**Start date target:** 2025-06-01
**Location:** Remote (US timezone overlap required)

### Compensation
- Base: $160K-$190K USD
- Equity: 0.05-0.08% ISO options (4-year vest, 1-year cliff)
- Signing bonus: $10K (for candidates with competing offers)

### Justification
Current team: 1 embedded engineer handling firmware for 3 device types.
Shipping IoT product requires dedicated firmware lead. Blocking on:
OTA update system, BLE provisioning, power optimization.

### Interview Process (3 weeks total)
1. Recruiter screen — 30min — culture fit, logistics
2. Technical screen — 60min — embedded systems questions, Rust/C
3. Take-home — 3h max — implement MQTT client with reconnect logic
4. System design — 60min — design OTA update pipeline
5. Team fit — 45min — with IoT team + tech-lead

### Success Criteria (90 days)
- Shipped OTA update system to staging
- Owned firmware for at least 1 device type end-to-end
- Contributed to device provisioning architecture
```
EOF

cat > shared/contracts/financial-report.md << 'EOF'
# Financial Report

**Producer:** finance
**Consumer(s):** growth-strategist, product-owner

## Required Fields

- **Reporting period** — month/quarter with start and end dates
- **MRR/ARR** — monthly and annualized recurring revenue
- **Burn rate** — monthly cash expenditure
- **Runway** — months of cash remaining at current burn
- **CAC** — customer acquisition cost (blended and by channel)
- **LTV** — lifetime value (with calculation methodology)
- **LTV/CAC ratio** — with benchmark comparison
- **Gross margin** — revenue minus COGS as percentage
- **Top cost drivers** — ranked by spend
- **90-day forecast** — projected MRR, burn, key assumptions
- **Key risks** — financial risks and scenarios

## Validation Checklist

- [ ] All assumptions documented (growth rate, churn rate, pricing)
- [ ] Sensitivity analysis included (best/base/worst case)
- [ ] Data sourced from actuals (not estimates where actuals are available)
- [ ] Risks explicitly listed with potential impact

## Example (valid)

```markdown
## FINANCIAL REPORT: March 2025

**Period:** 2025-03-01 → 2025-03-31
**MRR:** $42K | **ARR:** $504K

### Unit Economics
- Customers: 12 (net +2 this month)
- Average ACV: $42K
- CAC (blended): $8.5K | LTV: $126K | **LTV/CAC: 14.8x**
- Gross margin: 72% (COGS: cloud infra $8.2K, connectivity $3.6K)

### Burn & Runway
- Monthly burn: $85K (team: $62K, infra: $12K, other: $11K)
- Cash: $1.2M → **Runway: 14 months**

### Top Cost Drivers
1. Payroll: $62K (73%)
2. Cloud infrastructure: $12K (14%)
3. Connectivity (cellular): $3.6K (4%)

### Cost per Device
- 1,400 active devices → $0.56/device/month COGS
- Revenue/device: $2.50/device/month → **78% device-level margin**

### 90-Day Forecast
- MRR target: $58K (+38%) — based on 3 pipeline deals closing
- Burn increase: $92K (1 new hire)
- Assumption: 0% churn (no contracts up for renewal)

### Risks
- Pipeline deals slip → MRR flat at $42K → runway shrinks to 12 months
- Large customer (30% of MRR) renewal in Q3 — at-risk (Yellow health)
```
EOF

echo "✅ Part 1: 13 contracts created"

###############################################################################
# PART 2: REFERENCE FILES
###############################################################################

# Create directories
mkdir -p android-dev/references iot-dev/references video-streaming/references
mkdir -p edge-agent/references ml-engineer/references data-engineer/references
mkdir -p growth-strategist/references partnerships-agent/references
mkdir -p marketing/references sales/references customer-success/references
mkdir -p finance/references legal/references hr/references
mkdir -p incident-responder/references compliance-agent/references
mkdir -p analytics-engineer/references

cat > android-dev/references/kotlin-patterns.md << 'REFEOF'
# Kotlin + Android Patterns

## Coroutines

Use structured concurrency. Never use `GlobalScope`.

```kotlin
// ViewModel — survives configuration changes
class DeviceViewModel @Inject constructor(
    private val repo: DeviceRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<UiState>(UiState.Loading)
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            repo.getDevices()
                .catch { _uiState.value = UiState.Error(it.message) }
                .collect { _uiState.value = UiState.Success(it) }
        }
    }
}

// Fragment/Activity — lifecycle-aware
lifecycleScope.launch {
    repeatOnLifecycle(Lifecycle.State.STARTED) {
        viewModel.uiState.collect { state -> renderState(state) }
    }
}
```

## Sealed Classes for UI State

```kotlin
sealed interface UiState {
    data object Loading : UiState
    data class Success(val devices: List<Device>) : UiState
    data class Error(val message: String?) : UiState
}
```

## StateFlow vs SharedFlow

- **StateFlow**: always has a value, replays last value to new collectors. Use for UI state.
- **SharedFlow**: no initial value, configurable replay. Use for one-shot events (navigation, snackbar).

```kotlin
// One-shot events
private val _events = MutableSharedFlow<UiEvent>()
val events: SharedFlow<UiEvent> = _events.asSharedFlow()
```

## Jetpack Compose State Hoisting

```kotlin
// Stateless composable — receives state, emits events
@Composable
fun DeviceCard(
    device: Device,
    onTap: (DeviceId) -> Unit,
    modifier: Modifier = Modifier
) {
    Card(modifier = modifier.clickable { onTap(device.id) }) {
        Text(device.name)
        Text("${device.temperature}°C")
    }
}

// Stateful wrapper at screen level
@Composable
fun DeviceListScreen(viewModel: DeviceViewModel = hiltViewModel()) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    when (val s = state) {
        is UiState.Loading -> CircularProgressIndicator()
        is UiState.Success -> LazyColumn { items(s.devices) { DeviceCard(it, viewModel::onDeviceTap) } }
        is UiState.Error -> ErrorMessage(s.message)
    }
}
```

## Hilt Dependency Injection

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
    @Provides @Singleton
    fun provideRetrofit(): Retrofit = Retrofit.Builder()
        .baseUrl(BuildConfig.API_URL)
        .addConverterFactory(MoshiConverterFactory.create())
        .build()

    @Provides @Singleton
    fun provideDeviceApi(retrofit: Retrofit): DeviceApi =
        retrofit.create(DeviceApi::class.java)
}

@HiltViewModel
class DeviceViewModel @Inject constructor(
    private val repo: DeviceRepository
) : ViewModel()
```
REFEOF

cat > android-dev/references/android-architecture.md << 'REFEOF'
# Android Architecture — MVVM + Clean Architecture

## Layer Separation

```
UI Layer (Compose/Fragment)
  ↓ observes StateFlow
ViewModel Layer
  ↓ calls
UseCase Layer (optional, for complex logic)
  ↓ calls
Repository Layer (single source of truth)
  ↓ coordinates
DataSource Layer (Room, Retrofit, MQTT)
```

## Offline-First with Room + Remote Sync

```kotlin
// Repository — Room is source of truth, network refreshes it
class DeviceRepository @Inject constructor(
    private val local: DeviceDao,
    private val remote: DeviceApi
) {
    fun getDevices(): Flow<List<Device>> = local.observeAll()

    suspend fun refresh(): Result<Unit> = runCatching {
        val devices = remote.fetchDevices()
        local.upsertAll(devices.map { it.toEntity() })
    }
}

// Room DAO
@Dao
interface DeviceDao {
    @Query("SELECT * FROM devices ORDER BY name")
    fun observeAll(): Flow<List<DeviceEntity>>

    @Upsert
    suspend fun upsertAll(devices: List<DeviceEntity>)
}
```

## WorkManager for Background Sync

```kotlin
class SyncWorker @AssistedInject constructor(
    @Assisted context: Context,
    @Assisted params: WorkerParameters,
    private val repo: DeviceRepository
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        return when (repo.refresh()) {
            is kotlin.Result.Success -> Result.success()
            is kotlin.Result.Failure -> if (runAttemptCount < 3) Result.retry() else Result.failure()
        }
    }
}

// Schedule periodic sync
val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(15, TimeUnit.MINUTES)
    .setConstraints(Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build())
    .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 30, TimeUnit.SECONDS)
    .build()
WorkManager.getInstance(context).enqueueUniquePeriodicWork("sync", KEEP, syncRequest)
```

## Error Handling Across Layers

```kotlin
// Domain result type
sealed interface DomainResult<out T> {
    data class Ok<T>(val data: T) : DomainResult<T>
    data class Err(val error: DomainError) : DomainResult<Nothing>
}

sealed interface DomainError {
    data object NetworkUnavailable : DomainError
    data object Unauthorized : DomainError
    data class ServerError(val code: Int, val message: String) : DomainError
    data class Unknown(val throwable: Throwable) : DomainError
}

// Repository maps exceptions to domain errors
suspend fun refresh(): DomainResult<Unit> = try {
    val devices = remote.fetchDevices()
    local.upsertAll(devices)
    DomainResult.Ok(Unit)
} catch (e: UnknownHostException) { DomainResult.Err(DomainError.NetworkUnavailable) }
  catch (e: HttpException) { DomainResult.Err(DomainError.ServerError(e.code(), e.message())) }
  catch (e: Exception) { DomainResult.Err(DomainError.Unknown(e)) }
```

## Key Rules

- **ViewModel never imports Android framework** (except `SavedStateHandle`)
- **Repository is the single source of truth** — UI reads from Room, not network
- **Room flows are reactive** — insert/update automatically triggers UI refresh
- **WorkManager, not AlarmManager** — for deferrable background work
- **No business logic in Compose** — Composables are pure rendering functions
REFEOF

cat > android-dev/references/camera-integration.md << 'REFEOF'
# Camera Integration — CameraX + ExoPlayer

## CameraX for Device Camera

```kotlin
// Preview + capture in Compose
@Composable
fun CameraPreview(modifier: Modifier = Modifier) {
    val lifecycleOwner = LocalLifecycleOwner.current
    AndroidView(
        factory = { ctx ->
            PreviewView(ctx).apply {
                val cameraProviderFuture = ProcessCameraProvider.getInstance(ctx)
                cameraProviderFuture.addListener({
                    val cameraProvider = cameraProviderFuture.get()
                    val preview = Preview.Builder().build().also {
                        it.setSurfaceProvider(surfaceProvider)
                    }
                    cameraProvider.bindToLifecycle(
                        lifecycleOwner, CameraSelector.DEFAULT_BACK_CAMERA, preview
                    )
                }, ContextCompat.getMainExecutor(ctx))
            }
        },
        modifier = modifier
    )
}
```

## ExoPlayer for IP Camera Streams (HLS/RTSP)

```kotlin
@Composable
fun LiveFeed(rtspUrl: String, modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val player = remember {
        ExoPlayer.Builder(context).build().apply {
            setMediaItem(MediaItem.fromUri(rtspUrl))
            playWhenReady = true
            prepare()
        }
    }
    DisposableEffect(Unit) { onDispose { player.release() } }
    AndroidView(factory = { PlayerView(it).apply { this.player = player } }, modifier = modifier)
}
```

## RTSP with Reconnection

```kotlin
class StreamManager(private val context: Context) {
    private var player: ExoPlayer? = null
    private var retryCount = 0
    private val maxRetry = 10

    private val playerListener = object : Player.Listener {
        override fun onPlayerError(error: PlaybackException) {
            if (retryCount < maxRetry) {
                val delay = minOf(1000L * (1 shl retryCount), 60_000L) // exponential backoff, max 60s
                retryCount++
                handler.postDelayed({ reconnect() }, delay)
            }
        }
        override fun onIsPlayingChanged(isPlaying: Boolean) {
            if (isPlaying) retryCount = 0 // reset on success
        }
    }

    fun connect(url: String) {
        player = ExoPlayer.Builder(context)
            .setLoadControl(DefaultLoadControl.Builder()
                .setBufferDurationsMs(500, 2000, 500, 500) // low-latency
                .build())
            .build().apply {
                addListener(playerListener)
                setMediaItem(MediaItem.fromUri(url))
                prepare(); playWhenReady = true
            }
    }
}
```

## Camera Permissions

```kotlin
val cameraPermission = rememberLauncherForActivityResult(
    ActivityResultContracts.RequestPermission()
) { granted -> if (granted) showCamera() else showRationale() }

// Check before using
if (ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) == GRANTED) {
    showCamera()
} else {
    cameraPermission.launch(Manifest.permission.CAMERA)
}
```

## Background Streaming (Foreground Service)

```kotlin
class StreamingService : Service() {
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Live Stream Active")
            .setSmallIcon(R.drawable.ic_videocam)
            .build()
        startForeground(NOTIFICATION_ID, notification)
        // Initialize ExoPlayer here for background playback
        return START_STICKY
    }
}
```

## Key Rules

- **CameraX** for device camera (not deprecated Camera2 API directly)
- **ExoPlayer** for IP camera streams (RTSP, HLS) — not raw `MediaPlayer`
- **Low-latency buffer** settings for live feeds (500ms buffer, not default 15s)
- **Foreground service required** for background streaming (Android 12+)
- **Handle permissions gracefully** — explain why camera access is needed
REFEOF

cat > iot-dev/references/mqtt-patterns.md << 'REFEOF'
# MQTT Patterns for Device Fleets

## Topic Hierarchy Design

Use hierarchical topics. Never flat.

```
{org}/{site}/{device_type}/{device_id}/{channel}

Example:
acme/site-a/th100/dev-001/telemetry
acme/site-a/th100/dev-001/status
acme/site-a/th100/dev-001/commands
acme/site-a/th100/dev-001/commands/response
acme/site-a/th100/dev-001/ota/notify
acme/site-a/th100/dev-001/ota/status
```

### Naming Conventions
- Lowercase, hyphens (not underscores or camelCase)
- No leading slash (`acme/...` not `/acme/...`)
- No spaces or special characters
- Device ID in topic (not just in payload)

## QoS Levels

| QoS | Name | Use When |
|-----|------|----------|
| 0 | At most once | High-frequency telemetry where occasional loss is acceptable |
| 1 | At least once | Commands, status updates, alerts — must arrive (idempotent consumers) |
| 2 | Exactly once | Billing events, one-time provisioning — rarely needed, expensive |

**Default to QoS 1.** QoS 0 only for telemetry >1Hz where loss is tolerable. QoS 2 almost never.

## Retained Messages

Use retained for state that new subscribers need immediately:
- Device status (online/offline/battery level)
- Current configuration
- Last known location

**Never retain** telemetry streams or commands.

## Last Will and Testament (LWT)

```
Topic: {org}/{site}/{type}/{id}/status
Payload: {"status": "offline", "timestamp": "..."}
QoS: 1
Retain: true
```

On clean disconnect, publish `{"status": "offline", "reason": "shutdown"}` explicitly.
LWT fires only on ungraceful disconnect.

## Reconnect with Exponential Backoff

```
Attempt 1: wait 1s
Attempt 2: wait 2s
Attempt 3: wait 4s
...
Attempt N: wait min(2^N, 60s) + random jitter (0-1s)
```

Add jitter to prevent thundering herd when broker restarts and all devices reconnect simultaneously.

## Wildcard Subscriptions

```
# Single level: + matches one level
acme/site-a/+/+/telemetry    → all devices at site-a telemetry

# Multi level: # matches all remaining levels
acme/site-a/#                 → everything at site-a

# Backend subscribes to:
acme/+/+/+/telemetry          → all telemetry across all sites
```

**Never subscribe to `#`** (all topics) in production. Always scope to what you need.

## Message Format

```json
{
  "schema_version": 2,
  "device_id": "th100-a1b2c3",
  "timestamp": "2025-01-15T10:30:00Z",
  "payload": { "temperature_c": 22.5, "humidity_pct": 45.2 }
}
```

Always include `schema_version` and `timestamp` (ISO 8601 UTC).
REFEOF

cat > iot-dev/references/device-provisioning.md << 'REFEOF'
# Device Provisioning & Identity

## Certificate-Based Authentication (X.509)

Each device gets a unique X.509 client certificate. No shared secrets across a fleet.

```
Root CA (offline, air-gapped)
  └── Intermediate CA (per environment: staging, production)
       └── Device Certificate (per device, CN = device_id)
```

### Certificate Contents
- **CN (Common Name):** device ID (`th100-a1b2c3`)
- **SAN (Subject Alternative Name):** device ID, organization
- **Validity:** 2 years (with rotation before expiry)
- **Key size:** EC P-256 (smaller, faster than RSA on embedded)

## Device Identity Lifecycle

```
Manufacturing → Provisioning → Deployment → Active → Rotation → Retirement
```

1. **Manufacturing:** Generate key pair on device. CSR sent to provisioning service.
2. **Provisioning:** CA signs certificate. Device receives cert + intermediate CA.
3. **Deployment:** Device connects to MQTT broker using mTLS. Broker validates cert chain.
4. **Active:** Normal operation. Certificate monitored for expiry.
5. **Rotation:** 30 days before expiry, device requests new certificate via provisioning API.
6. **Retirement:** Certificate revoked via CRL or OCSP. Device decommissioned.

## Zero-Touch Provisioning

```
Device boots → connects to provisioning endpoint (bootstrap cert) →
  sends CSR + hardware attestation →
  receives production certificate + MQTT config →
  connects to production broker
```

Bootstrap certificate: short-lived (24h), limited permissions (can only reach provisioning API).

## Credential Rotation

```
1. Device generates new key pair
2. Device sends CSR to provisioning service (authenticated with current cert)
3. Service validates identity, signs new cert
4. Device receives new cert, tests connection
5. If successful: stores new cert, deletes old
6. If failed: keeps old cert, retries next cycle
```

## Fleet Management

- **Device registry:** central database mapping device_id → cert fingerprint, site, type, firmware version
- **Grouping:** by site, device type, firmware version (for targeted OTA)
- **Health monitoring:** track last-seen timestamp, cert expiry date, firmware version

## Security Rules

- Private keys never leave the device (generate on-device, not in cloud)
- No shared secrets or API keys across devices
- Certificate pinning for broker connection
- Revocation list checked by broker on every connection
REFEOF

cat > iot-dev/references/embedded-rust.md << 'REFEOF'
# Embedded Rust Patterns

## no_std Environment

```rust
#![no_std]
#![no_main]

use cortex_m_rt::entry;
use panic_halt as _; // halt on panic (no unwinding in embedded)

#[entry]
fn main() -> ! {
    let peripherals = pac::Peripherals::take().unwrap();
    // setup...
    loop {
        // main loop
    }
}
```

## Embassy Async Framework

```rust
use embassy_executor::Spawner;
use embassy_time::{Duration, Timer};

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    let p = embassy_stm32::init(Default::default());
    spawner.spawn(telemetry_task(p.ADC1)).unwrap();
    spawner.spawn(mqtt_task(p.USART1)).unwrap();
}

#[embassy_executor::task]
async fn telemetry_task(adc: ADC1) {
    loop {
        let reading = adc.read().await;
        TELEMETRY_CHANNEL.send(reading).await;
        Timer::after(Duration::from_secs(30)).await;
    }
}
```

## PAC / HAL Layers

```
PAC (Peripheral Access Crate)  — raw register access, auto-generated
  ↓
HAL (Hardware Abstraction Layer) — safe Rust API over PAC
  ↓
BSP (Board Support Package)    — board-specific pin mappings
```

Use HAL, not PAC directly. PAC is for HAL implementors.

## Sensor Reading Pattern

```rust
use embedded_hal::i2c::I2c;

struct Bme280<I2C> { i2c: I2C, addr: u8 }

impl<I2C: I2c> Bme280<I2C> {
    fn read_temperature(&mut self) -> Result<f32, I2C::Error> {
        let mut buf = [0u8; 3];
        self.i2c.write_read(self.addr, &[0xFA], &mut buf)?;
        let raw = ((buf[0] as u32) << 12) | ((buf[1] as u32) << 4) | ((buf[2] as u32) >> 4);
        Ok(self.compensate_temperature(raw))
    }
}
```

## Communication Patterns

```rust
// UART (serial)
let mut uart = Uart::new(p.USART1, p.PA10, p.PA9, config);
uart.write(b"AT+MQTT\r\n").await?;

// SPI
let mut spi = Spi::new(p.SPI1, sck, mosi, miso, config);
let mut cs = Output::new(p.PA4, Level::High);
cs.set_low();
spi.transfer(&mut buf).await?;
cs.set_high();

// I2C
let mut i2c = I2c::new(p.I2C1, scl, sda, config);
i2c.write_read(0x76, &[0xD0], &mut chip_id).await?;
```

## RTIC (Real-Time Interrupt-driven Concurrency)

```rust
#[rtic::app(device = stm32f4xx_hal::pac)]
mod app {
    #[shared] struct Shared { buffer: Buffer }
    #[local] struct Local { led: Pin }

    #[init]
    fn init(ctx: init::Context) -> (Shared, Local) { ... }

    #[task(binds = TIM2, shared = [buffer])]
    fn timer_tick(mut ctx: timer_tick::Context) {
        ctx.shared.buffer.lock(|buf| buf.push(reading));
    }
}
```

## Key Rules

- **No heap allocation** unless absolutely necessary (use `heapless` crate)
- **No unwrap in production** — handle every error
- **Power management:** sleep between operations, wake on interrupt
- **Watchdog timer:** always enabled, reset in main loop
REFEOF

cat > iot-dev/references/ota-updates.md << 'REFEOF'
# OTA Update Strategies

## A/B Partition Strategy

```
Flash Layout:
┌──────────────┐
│ Bootloader   │  (read-only, never updated OTA)
├──────────────┤
│ Partition A  │  ← currently running
├──────────────┤
│ Partition B  │  ← download new firmware here
├──────────────┤
│ Config/NVS   │  (persistent across updates)
└──────────────┘
```

1. Download firmware to inactive partition (B)
2. Verify signature
3. Set boot flag to B
4. Reboot
5. New firmware runs health check
6. If healthy: mark B as confirmed
7. If unhealthy: watchdog reboots → bootloader falls back to A

## Signature Verification

```
Build server signs firmware with Ed25519 private key
Device has Ed25519 public key (in bootloader, immutable)

Verification:
1. Download firmware image + signature file
2. Compute SHA-256 hash of firmware
3. Verify Ed25519 signature against hash using embedded public key
4. If invalid: reject, do not flash
```

Never skip verification. Never update the verification key via OTA.

## Rollback Triggers

| Trigger | Action |
|---------|--------|
| Boot loop (3 failed boots) | Watchdog reboot → bootloader selects previous partition |
| Health check fails | Firmware marks itself unhealthy → reboot to previous |
| Manual rollback command | Cloud sends rollback command via MQTT |
| Connectivity lost >5min after update | Auto-rollback (can't report status = probably broken) |

## Delta Updates

For bandwidth-constrained devices:
- Generate binary diff (bsdiff) between old and new firmware
- Device applies patch to current firmware → writes result to inactive partition
- Typical savings: 60-90% smaller than full image
- Tradeoff: device needs enough RAM to apply patch

## Update Flow

```
Cloud                           Device
  │                               │
  ├── ota/notify ────────────────►│  "v1.3.0 available"
  │                               │
  │◄── ota/status ────────────────┤  "downloading"
  │                               │  ... download chunks ...
  │◄── ota/status ────────────────┤  "verifying"
  │                               │  ... signature check ...
  │◄── ota/status ────────────────┤  "applying"
  │                               │  ... flash + reboot ...
  │◄── ota/status ────────────────┤  "success" (or "rollback")
```

## Status Reporting

```json
{
  "device_id": "th100-a1b2c3",
  "update_id": "upd-2025-001",
  "status": "success",
  "from_version": "1.2.0",
  "to_version": "1.3.0",
  "duration_s": 45,
  "timestamp": "2025-01-15T10:30:00Z"
}
```

## Key Rules

- **Never update bootloader via OTA** — if bootloader is broken, device is bricked
- **Always verify before flashing** — cryptographic signature, not just checksum
- **Rollback must be automatic** — don't rely on cloud to trigger rollback
- **Resumable downloads** — interrupted download resumes, doesn't restart
- **Staged rollout** — update 1% → 10% → 50% → 100%, with monitoring between stages
REFEOF

cat > video-streaming/references/streaming-protocols.md << 'REFEOF'
# Streaming Protocol Comparison

| Protocol | Latency | Browser | Infrastructure | Best For |
|----------|---------|---------|----------------|----------|
| **RTSP** | <1s | ❌ (needs plugin/native) | Camera → server | Camera ingestion |
| **WebRTC** | <500ms | ✅ | STUN/TURN/SFU | Live viewing in browser |
| **HLS** | 6-30s (LL-HLS: 2-4s) | ✅ | CDN/S3 | Recording playback, VOD |
| **DASH** | 6-30s | ✅ | CDN | Similar to HLS, less Apple |
| **SRT** | <1s | ❌ | Point-to-point | Contribution feed, unreliable networks |
| **RTMP** | 1-3s | ❌ (Flash dead) | Media server | Legacy ingest (still used) |

## When to Use Each for Remote Monitoring

- **RTSP:** Camera → server ingestion. All IP cameras speak RTSP. Don't expose to browsers.
- **WebRTC:** Live viewing in browser/mobile. Sub-second latency. Requires TURN for NAT traversal.
- **HLS:** Recording playback. Store segments in S3. Works everywhere. Accept 6s+ latency.
- **SRT:** Site-to-cloud contribution over unreliable links. Built-in error correction.

## Typical Pipeline

```
Camera ──RTSP──► Ingest Server ──┬──WebRTC──► Live Viewers
                                 └──HLS────► Recording (S3)
```

## Protocol Details

### RTSP
- Port 554 (TCP) + RTP (UDP or TCP interleaved)
- URL: `rtsp://user:pass@camera-ip:554/stream1`
- Authentication: Basic or Digest (Digest preferred)
- No encryption natively — tunnel over VPN or use RTSPS (TLS)

### WebRTC
- P2P or SFU (prefer SFU for monitoring — centralized control)
- ICE for NAT traversal: STUN (80% of cases), TURN (fallback)
- Codec: H.264 (universal), VP8/VP9 (better compression, less hardware support)
- Signaling: custom (WebSocket typically)

### HLS
- HTTP-based — works with any CDN
- Segments: 6s default (2s for LL-HLS)
- Playlist: `.m3u8` manifest, `.ts` or `.fmp4` segments
- Adaptive bitrate: multiple renditions in master playlist

### SRT
- UDP-based with ARQ (automatic repeat request)
- Configurable latency buffer (tradeoff: latency vs reliability)
- Encryption: AES-128/256 built-in
- Good for: 2-20 Mbps over lossy links (cellular, satellite)
REFEOF

cat > video-streaming/references/codec-settings.md << 'REFEOF'
# Codec Settings for Video Surveillance

## H.264 vs H.265

| Feature | H.264 (AVC) | H.265 (HEVC) |
|---------|-------------|---------------|
| Compression | Baseline | ~40% better at same quality |
| CPU encode cost | Lower | 2-3x higher |
| Hardware support | Universal | Most modern devices |
| Browser support | Universal | Safari, some Chrome |
| Licensing | MPEG LA pool | Complex, patent pools |
| Recommendation | Default choice | Use when bandwidth is critical |

## Recommended Profiles for Surveillance

### H.264
- **Main Profile, Level 4.0** — 1080p@30fps, good balance
- **High Profile, Level 4.1** — 1080p@30fps, better compression, more CPU
- **Baseline Profile** — only for very constrained devices (no B-frames)

### H.265
- **Main Profile, Level 4.0** — 1080p@30fps
- **Main 10 Profile** — 10-bit color depth (rarely needed for surveillance)

## Bitrate Ladders

### Adaptive Streaming (HLS/DASH)

| Rendition | Resolution | FPS | H.264 Bitrate | H.265 Bitrate |
|-----------|-----------|-----|---------------|---------------|
| High | 1920×1080 | 15 | 4 Mbps | 2.5 Mbps |
| Medium | 1280×720 | 15 | 2 Mbps | 1.2 Mbps |
| Low | 640×360 | 10 | 500 Kbps | 300 Kbps |
| Thumbnail | 320×180 | 5 | 150 Kbps | 100 Kbps |

### Fixed Bitrate for Recording
- 1080p@15fps surveillance: 2-4 Mbps CBR (constant bitrate)
- VBR with cap: target 2 Mbps, max 6 Mbps (spikes during motion)

## Keyframe Interval

- **Live streaming:** 1-2 seconds (for fast channel switching)
- **Recording:** 2-4 seconds (balance between seek time and compression)
- **Low bandwidth:** 4-6 seconds (better compression, slower seek)

Rule: keyframe interval = segment duration for HLS (if 6s segments, use 6s keyframes)

## Hardware vs Software Encoding

| Factor | Hardware (GPU/ASIC) | Software (CPU) |
|--------|-------------------|----------------|
| Speed | Real-time, many streams | 1-4 streams per core |
| Quality per bit | Slightly lower | Better (more tuning options) |
| Cost | GPU required | CPU-only |
| Flexibility | Limited codec options | Any codec, any setting |
| Recommendation | Production (many cameras) | Development, single stream |

### Hardware Options
- **NVIDIA NVENC:** excellent H.264/H.265, use with FFmpeg or GStreamer
- **Intel QSV:** good, available on most Intel CPUs
- **AMD VCE/VCN:** decent, less common in servers
- **Raspberry Pi:** hardware H.264 encode via V4L2 (limited to 1080p@30fps)
REFEOF

cat > video-streaming/references/gstreamer-pipelines.md << 'REFEOF'
# GStreamer Pipeline Patterns

## RTSP Ingestion

```bash
# Basic RTSP receive and display
gst-launch-1.0 rtspsrc location=rtsp://admin:pass@192.168.1.100:554/stream1 \
  latency=100 ! rtph264depay ! h264parse ! avdec_h264 ! videoconvert ! autovideosink

# RTSP receive, keep H.264 encoded (no decode)
gst-launch-1.0 rtspsrc location=rtsp://camera:554/stream1 \
  latency=200 protocols=tcp ! rtph264depay ! h264parse ! queue ! fakesink
```

## Transcoding

```bash
# H.264 → H.265 transcoding
gst-launch-1.0 rtspsrc location=rtsp://camera:554/stream1 \
  ! rtph264depay ! h264parse ! avdec_h264 \
  ! videoconvert ! x265enc bitrate=2000 speed-preset=fast \
  ! h265parse ! mp4mux ! filesink location=output.mp4

# Resize and re-encode
gst-launch-1.0 rtspsrc location=rtsp://camera:554/stream1 \
  ! rtph264depay ! h264parse ! avdec_h264 \
  ! videoscale ! video/x-raw,width=1280,height=720 \
  ! x264enc bitrate=2000 speed-preset=fast tune=zerolatency \
  ! h264parse ! mp4mux ! filesink location=output.mp4
```

## Recording to File

```bash
# Record RTSP to MP4 (passthrough, no re-encode)
gst-launch-1.0 rtspsrc location=rtsp://camera:554/stream1 \
  ! rtph264depay ! h264parse ! mp4mux ! filesink location=recording.mp4

# Segmented recording (new file every 5 minutes)
gst-launch-1.0 rtspsrc location=rtsp://camera:554/stream1 \
  ! rtph264depay ! h264parse \
  ! splitmuxsink location=recording_%05d.mp4 max-size-time=300000000000
```

## HLS Output

```bash
# RTSP → HLS segments
gst-launch-1.0 rtspsrc location=rtsp://camera:554/stream1 \
  ! rtph264depay ! h264parse \
  ! hlssink2 playlist-root=https://cdn.example.com/cam1 \
    location=segment_%05d.ts \
    playlist-location=playlist.m3u8 \
    target-duration=6 max-files=10
```

## WebRTC Output (with webrtcbin)

```python
# Python GStreamer for WebRTC (conceptual)
pipeline = Gst.parse_launch("""
    rtspsrc location=rtsp://camera:554/stream1 latency=100
    ! rtph264depay ! h264parse ! queue
    ! rtph264pay config-interval=-1 pt=96
    ! webrtcbin name=webrtc bundle-policy=max-bundle
""")

webrtc = pipeline.get_by_name("webrtc")
webrtc.connect("on-negotiation-needed", on_negotiation_needed)
webrtc.connect("on-ice-candidate", on_ice_candidate)
```

## Tee (Fork Pipeline)

```bash
# Live WebRTC + HLS recording from single RTSP source
gst-launch-1.0 rtspsrc location=rtsp://camera:554/stream1 latency=100 \
  ! rtph264depay ! h264parse ! tee name=t \
  t. ! queue ! rtph264pay ! webrtcbin \
  t. ! queue ! hlssink2 target-duration=6 location=seg_%05d.ts playlist-location=live.m3u8
```

## Key Rules

- **Use `queue` between branches** of a tee to prevent blocking
- **`latency=100-200`** on rtspsrc for low-latency live viewing
- **`protocols=tcp`** if UDP is unreliable on the network
- **Passthrough when possible** — avoid decode/re-encode unless you need to resize or change codec
- **`speed-preset=fast` or `ultrafast`** for real-time encoding (not `slow`/`veryslow`)
REFEOF

cat > video-streaming/references/webrtc-architecture.md << 'REFEOF'
# WebRTC Architecture for Video Monitoring

## Core Components

```
Camera ──RTSP──► Media Server ──WebRTC──► Browser
                     │
                  STUN/TURN
                     │
                  Signaling (WebSocket)
```

## ICE / STUN / TURN

- **ICE (Interactive Connectivity Establishment):** finds the best path between peers
- **STUN:** discovers public IP. Works for ~80% of NAT types. Free/lightweight.
- **TURN:** relays media when direct connection fails. Required for symmetric NAT. Bandwidth cost.

```
Viewer ──── STUN ────► discovers public IP
Viewer ──── direct ──► Media Server  (if possible)
Viewer ──── TURN ────► relay ────► Media Server  (fallback)
```

**Always deploy TURN.** Without it, ~20% of viewers can't connect.

## SFU vs MCU vs P2P

| Topology | Description | Best For |
|----------|-------------|----------|
| **P2P** | Direct camera-to-viewer | 1:1 calls, <5 viewers |
| **SFU** | Server forwards streams (no transcoding) | Monitoring (10-1000 viewers) |
| **MCU** | Server mixes into single stream | Video conferencing (not monitoring) |

**Use SFU for monitoring.** Scales to many viewers per camera without transcoding overhead.

## SFU Implementations

### Pion (Go)
```go
// Pion SFU — lightweight, Go-native
peerConnection, _ := webrtc.NewPeerConnection(config)
// Add track from RTSP ingest
videoTrack, _ := webrtc.NewTrackLocalStaticRTP(
    webrtc.RTPCodecCapability{MimeType: webrtc.MimeTypeH264}, "video", "camera-1")
peerConnection.AddTrack(videoTrack)
// Forward RTP packets from RTSP source to track
```

- Pros: lightweight, easy to embed, excellent Go ecosystem
- Cons: build your own SFU logic (or use ion-sfu)

### mediasoup (Node.js)
```javascript
// mediasoup — full SFU with room management
const worker = await mediasoup.createWorker();
const router = await worker.createRouter({ mediaCodecs });
const transport = await router.createWebRtcTransport(transportOptions);
const producer = await transport.produce({ kind: 'video', rtpParameters });
// Consumers subscribe to producer
```

- Pros: battle-tested, room management built-in, good for multi-camera dashboards
- Cons: Node.js (more resource-heavy than Go)

## Signaling (WebSocket)

```
Viewer                    Signaling Server              Media Server
  │                            │                            │
  ├── "join camera-1" ────────►│                            │
  │                            ├── "new viewer" ───────────►│
  │                            │◄── SDP offer ──────────────┤
  │◄── SDP offer ──────────────┤                            │
  ├── SDP answer ─────────────►│                            │
  │                            ├── SDP answer ─────────────►│
  │◄── ICE candidates ────────►│◄── ICE candidates ────────►│
  │                            │                            │
  │◄═══════════ WebRTC media stream (direct or via TURN) ══►│
```

## Latency Optimization

1. **No transcoding on the SFU** — passthrough H.264 from camera
2. **Short STUN/TURN timeout** — fail fast to TURN if direct path doesn't work
3. **Trickle ICE** — start streaming before all ICE candidates are gathered
4. **Jitter buffer tuning** — reduce from default 200ms to 50-100ms for monitoring
5. **PLI (Picture Loss Indication)** — request keyframe immediately on viewer connect

## Key Rules

- **SFU, not P2P** for monitoring (centralized control, scales to many viewers)
- **Always have TURN** — 20% of connections need it
- **H.264 passthrough** — don't re-encode on the SFU
- **Signaling is separate from media** — WebSocket for signaling, UDP for media
REFEOF

cat > edge-agent/references/edge-architectures.md << 'REFEOF'
# Edge Computing Architectures

## Pattern: Local Processing + Cloud Sync

```
Devices ──MQTT──► Edge Gateway ──────► Cloud
                      │
                  Local Processing
                  Local Dashboard
                  Local Storage (7 days)
```

Edge gateway handles: data collection, filtering, aggregation, local alerting.
Cloud receives: summaries, alerts, aggregated metrics (not raw telemetry).

## Pattern: Store-and-Forward

For intermittent connectivity:
1. Edge collects all data locally
2. Queues data for cloud upload
3. When connected: sync queue (oldest first or priority-based)
4. Cloud acknowledges receipt → edge deletes synced data
5. Bounded buffer: when full, drop oldest non-critical data

## Edge-Cloud Handoff Decisions

| Process Locally When | Process in Cloud When |
|---------------------|----------------------|
| Latency < 100ms needed | Complex analytics / ML training |
| Bandwidth is constrained | Cross-site correlation |
| Privacy requires local processing | Long-term storage |
| Must work offline | Dashboard for multiple sites |

## K3s for Edge Deployment

```yaml
# Lightweight Kubernetes for edge nodes
# Install: curl -sfL https://get.k3s.io | sh -
# Single node, <512MB RAM

apiVersion: apps/v1
kind: Deployment
metadata:
  name: edge-gateway
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: mqtt-broker
        image: eclipse-mosquitto:2
        resources:
          limits: { memory: "128Mi", cpu: "200m" }
      - name: edge-processor
        image: edge-processor:latest
        resources:
          limits: { memory: "256Mi", cpu: "500m" }
```

## Resource Budgets

| Hardware | RAM | CPU | Storage | Use Case |
|----------|-----|-----|---------|----------|
| Raspberry Pi 4 (4GB) | 4GB | 4-core ARM | 32-256GB SD | Light edge, <50 sensors |
| Raspberry Pi CM4 | 2-8GB | 4-core ARM | eMMC/NVMe | Industrial edge module |
| NVIDIA Jetson Nano | 4GB | 4-core ARM + 128 CUDA | 32GB eMMC | Edge ML inference |
| NVIDIA Jetson Orin Nano | 8GB | 6-core ARM + 1024 CUDA | 128GB NVMe | Multi-camera ML |
| Intel NUC | 8-32GB | 4-6 core x86 | 256GB-1TB NVMe | Full edge platform |

### Budget Allocation (4GB edge device)
- OS + K3s: ~500MB
- MQTT broker: 128MB
- Edge processor: 256MB
- ML inference: 1-2GB
- Buffer/cache: 1GB
- Reserve: 500MB

## Key Rules

- **Edge must work without cloud** — offline operation is not optional
- **Bounded storage** — always set retention limits, never fill the disk
- **Watchdog everything** — auto-restart crashed processes
- **Remote management** — SSH/VPN access for debugging (with auth)
- **Atomic updates** — edge software updates follow same A/B pattern as firmware
REFEOF

cat > edge-agent/references/edge-ml.md << 'REFEOF'
# Edge ML Inference

## ONNX Runtime for Edge

```python
import onnxruntime as ort
import numpy as np

# Load model with TensorRT optimization (NVIDIA)
session = ort.InferenceSession(
    "person_detect_int8.onnx",
    providers=["TensorrtExecutionProvider", "CUDAExecutionProvider", "CPUExecutionProvider"]
)

# Run inference
input_name = session.get_inputs()[0].name
result = session.run(None, {input_name: preprocessed_frame})
boxes, scores = result[0], result[1]
```

Provider priority: TensorRT > CUDA > CPU. Falls back automatically.

## TensorFlow Lite

```python
import tflite_runtime.interpreter as tflite

interpreter = tflite.Interpreter(model_path="model.tflite")
interpreter.allocate_tensors()
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

interpreter.set_tensor(input_details[0]["index"], input_data)
interpreter.invoke()
output = interpreter.get_tensor(output_details[0]["index"])
```

## Model Optimization

### Quantization (INT8)
- **Post-training quantization:** no retraining, ~2% accuracy loss, 4x smaller, 2-3x faster
- **Quantization-aware training:** retrain with quantization, <1% accuracy loss
- Always validate accuracy after quantization on representative dataset

### Pruning
- Remove low-magnitude weights (30-50% sparsity typical)
- Retrain after pruning to recover accuracy
- Best combined with quantization

### Knowledge Distillation
- Train small "student" model to mimic large "teacher" model
- Student is 5-10x smaller with similar accuracy
- Good for: deploying cloud-grade accuracy on edge hardware

## Benchmarking

```bash
# ONNX Runtime benchmark
python -c "
import onnxruntime as ort, numpy as np, time
sess = ort.InferenceSession('model.onnx')
inp = np.random.randn(1,3,640,640).astype(np.float32)
# Warmup
for _ in range(10): sess.run(None, {'input': inp})
# Benchmark
times = []
for _ in range(100):
    t = time.monotonic()
    sess.run(None, {'input': inp})
    times.append(time.monotonic() - t)
print(f'Mean: {np.mean(times)*1000:.1f}ms, P95: {np.percentile(times,95)*1000:.1f}ms')
"
```

## When Edge Inference Is Worth It

✅ **Use edge inference when:**
- Latency requirement <100ms (can't afford round-trip to cloud)
- Bandwidth is constrained (can't stream full video to cloud)
- Privacy requires local processing (video stays on-premises)
- Volume: processing every frame locally is cheaper than streaming to cloud

❌ **Use cloud inference when:**
- Model is too large for edge hardware
- Need to correlate across multiple sites
- Edge hardware cost exceeds cloud inference cost
- Model changes frequently (easier to update cloud)
REFEOF

cat > edge-agent/references/sync-patterns.md << 'REFEOF'
# Edge-Cloud Sync Patterns

## Event Sourcing at Edge

```
Edge stores events (immutable facts):
  [timestamp, device_id, event_type, data]

On sync:
  Send unsent events to cloud (ordered by timestamp)
  Cloud applies events to its state
  Edge marks events as synced
```

Benefits: never lose data, cloud can reconstruct full history, idempotent replay.

## CRDTs (Conflict-Free Replicated Data Types)

When edge and cloud both modify the same data:

- **G-Counter:** only increment (count of alerts)
- **PN-Counter:** increment and decrement
- **LWW-Register:** last writer wins with timestamp
- **OR-Set:** add/remove from set, concurrent adds both preserved

```
Edge: config.threshold = 80 (at T1)
Cloud: config.threshold = 90 (at T2)
Sync: T2 > T1 → threshold = 90 (LWW)
```

Use CRDTs for device configuration that can be modified from edge or cloud.

## Last-Write-Wins vs Vector Clocks

### LWW (Simple)
- Each write has a timestamp
- Higher timestamp wins on conflict
- **Problem:** clock skew between edge and cloud

### Vector Clocks (Precise)
- Each node has a logical clock: `{edge: 3, cloud: 5}`
- Detects true conflicts (concurrent writes)
- **Problem:** complexity, growing clock vectors

**Recommendation:** Use LWW with NTP-synced clocks for most cases.
Use vector clocks only for critical data where conflicts must be explicitly resolved.

## Partial Sync

Don't sync everything. Strategies:
- **Changed-only:** track dirty flag per record, sync only dirty records
- **Time-based:** sync records modified since last sync timestamp
- **Priority-based:** alerts sync first, telemetry summaries next, raw data last

```
Sync priority queue:
1. Alerts (immediate — sync within 5s of connectivity)
2. Device status changes (next — within 30s)
3. Aggregated telemetry (batched — every 5 minutes)
4. Raw telemetry (background — when idle bandwidth available)
```

## Handling Clock Skew

Edge devices may have inaccurate clocks (no NTP, RTC drift, battery loss).

Mitigations:
- **NTP sync on boot** (if internet available)
- **Relative timestamps** — monotonic clock for intervals, wall clock for display
- **Cloud assigns canonical timestamp** on receipt (edge timestamp is metadata, not truth)
- **Sequence numbers** — monotonic counter per device, independent of clock

## Sync Protocol

```
Edge                            Cloud
  │                               │
  ├── sync request ──────────────►│  {last_sync_id: 12345}
  │                               │
  │◄── changes since 12345 ──────┤  cloud→edge changes
  │                               │
  ├── edge changes ──────────────►│  edge→cloud changes
  │                               │
  │◄── ack {new_sync_id: 12389} ─┤
  │                               │
  Edge updates last_sync_id       │
```

## Key Rules

- **Idempotent sync** — replaying the same data produces the same result
- **Bounded queue** — don't let sync queue grow unbounded when offline
- **Conflict resolution strategy** — decide before building (LWW, CRDT, or manual)
- **Compression** — gzip sync payloads, especially telemetry batches
REFEOF

cat > ml-engineer/references/computer-vision.md << 'REFEOF'
# Computer Vision for Surveillance

## Object Detection Models

| Model | Size | Speed (GPU) | Speed (Edge) | mAP@0.5 | Use Case |
|-------|------|-------------|--------------|---------|----------|
| YOLOv8-nano | 3.2M | 1.2ms | 40ms (Jetson) | 37.3 | Edge real-time |
| YOLOv8-small | 11.2M | 2.0ms | 80ms (Jetson) | 44.9 | Edge balanced |
| YOLOv8-medium | 25.9M | 4.0ms | 180ms (Jetson) | 50.2 | Cloud or powerful edge |
| SSD MobileNetV2 | 4.3M | 3.5ms | 50ms (Jetson) | 22.0 | Very constrained edge |
| RT-DETR-l | 32M | 5.0ms | N/A | 53.0 | Cloud, high accuracy |

## Detection vs Classification vs Segmentation

- **Classification:** "Is there a person?" → yes/no + confidence
- **Detection:** "Where are the people?" → bounding boxes + confidence
- **Segmentation:** "What pixels are people?" → pixel-level mask
- **For surveillance:** Detection is the sweet spot (location + count, reasonable cost)

## Model Selection for Monitoring

| Task | Recommended Model | Notes |
|------|-------------------|-------|
| Person detection | YOLOv8-nano/small | Most common, well-supported |
| Vehicle detection | YOLOv8-small | Needs more capacity than person |
| Intrusion (zone) | YOLOv8-nano + zone logic | Detection + geofence check |
| PPE detection | YOLOv8-small (custom trained) | Hard hat, vest, gloves |
| Fire/smoke | YOLOv8-small (custom trained) | Small dataset, needs augmentation |

## Transfer Learning

```python
from ultralytics import YOLO

# Load pretrained model
model = YOLO("yolov8n.pt")

# Fine-tune on custom dataset
results = model.train(
    data="custom_dataset.yaml",
    epochs=100,
    imgsz=640,
    batch=16,
    lr0=0.001,  # lower than from-scratch
    freeze=10,  # freeze first 10 layers
)
```

Dataset requirements:
- Minimum: 100 images per class (500+ recommended)
- Balanced: similar count per class
- Representative: various angles, lighting, weather
- Annotated: YOLO format (class x_center y_center width height)

## Evaluation Metrics

- **mAP@0.5:** mean Average Precision at 50% IoU — primary metric
- **mAP@0.5:0.95:** stricter, averages over IoU thresholds 0.5-0.95
- **Precision:** of all detections, how many are correct
- **Recall:** of all actual objects, how many did we detect
- **F1:** harmonic mean of precision and recall

For surveillance, **recall matters more than precision** — missing a person is worse than a false alarm.
But track false positive rate — too many false alarms cause alert fatigue.
REFEOF

cat > ml-engineer/references/anomaly-detection.md << 'REFEOF'
# Anomaly Detection for IoT Monitoring

## Statistical Methods

### Z-Score
```python
z = (value - mean) / std
anomaly = abs(z) > 3  # 3 standard deviations
```
- Simple, fast, no training
- Fails for non-Gaussian distributions
- Fails for seasonal data

### IQR (Interquartile Range)
```python
Q1, Q3 = np.percentile(data, [25, 75])
IQR = Q3 - Q1
anomaly = (value < Q1 - 1.5*IQR) or (value > Q3 + 1.5*IQR)
```
- Robust to outliers
- Good for non-Gaussian data
- Static thresholds (no learning)

## ML-Based Methods

### Isolation Forest
```python
from sklearn.ensemble import IsolationForest
model = IsolationForest(contamination=0.05, random_state=42)
model.fit(training_data)
predictions = model.predict(new_data)  # -1 = anomaly, 1 = normal
```
- Good general-purpose anomaly detector
- No assumptions about distribution
- `contamination` param = expected anomaly rate

### Autoencoder
```python
# Train on NORMAL data only
model = Sequential([
    Dense(64, activation='relu', input_shape=(n_features,)),
    Dense(16, activation='relu'),   # bottleneck
    Dense(64, activation='relu'),
    Dense(n_features, activation='linear')
])
model.compile(optimizer='adam', loss='mse')
model.fit(normal_data, normal_data, epochs=50)

# Anomaly = high reconstruction error
reconstruction = model.predict(new_data)
error = np.mean((new_data - reconstruction)**2, axis=1)
anomaly = error > threshold  # threshold from validation set
```
- Learns normal patterns, flags deviations
- Good for complex, multivariate data
- Requires sufficient normal training data

### Prophet (Facebook)
```python
from prophet import Prophet
model = Prophet(interval_width=0.99)
model.fit(df)  # df with 'ds' (timestamp) and 'y' (value) columns
forecast = model.predict(future)
anomaly = (actual < forecast.yhat_lower) | (actual > forecast.yhat_upper)
```
- Handles seasonality natively (daily, weekly, yearly)
- Good for: temperature, energy, traffic patterns
- Less good for: high-frequency data (>1Hz)

## Choosing Threshold vs Model-Based

| Approach | When to Use |
|----------|-------------|
| Fixed threshold | Simple sensors, known operating range (e.g., temperature 15-35°C) |
| Statistical (z-score) | Stable processes, Gaussian distribution |
| Isolation Forest | Multiple features, no clear distribution, general purpose |
| Autoencoder | Complex patterns, high-dimensional data |
| Prophet | Strong seasonality, time-series with trend |

## Handling Seasonal Patterns

1. **Decompose:** separate trend, seasonality, residual
2. **Detect on residual:** anomalies in the deseasonalized signal
3. **Time-aware thresholds:** different thresholds for day/night, weekday/weekend
4. **Rolling baseline:** 7-day or 30-day rolling statistics

## Evaluation: False Positive/Negative Tradeoff

For monitoring alerts:
- **False positive (false alarm):** alert when nothing is wrong → alert fatigue
- **False negative (missed):** no alert when something is wrong → equipment damage

| Metric | Target (typical) |
|--------|-----------------|
| False positive rate | < 5% (1 in 20 alerts is false) |
| Detection rate (recall) | > 90% (catch 9 out of 10 real anomalies) |
| Detection lead time | > 24h before failure (for maintenance planning) |

Tune threshold to business cost: cost of false alarm vs cost of missed failure.
REFEOF

cat > ml-engineer/references/mlops.md << 'REFEOF'
# MLOps for IoT/Video ML

## MLflow for Experiment Tracking

```python
import mlflow

mlflow.set_experiment("person-detection-v3")

with mlflow.start_run():
    mlflow.log_params({"model": "yolov8n", "epochs": 100, "imgsz": 640})
    # ... training ...
    mlflow.log_metrics({"mAP50": 0.82, "precision": 0.88, "recall": 0.79})
    mlflow.log_artifact("best.onnx")
    mlflow.pytorch.log_model(model, "model")
```

## Model Registry

```python
# Register model
mlflow.register_model("runs:/abc123/model", "person-detector")

# Promote to production
client = mlflow.tracking.MlflowClient()
client.transition_model_version_stage("person-detector", version=3, stage="Production")
```

Stages: None → Staging → Production → Archived

## Deployment Options

| Tool | Best For | Complexity |
|------|----------|------------|
| FastAPI + ONNX | Simple REST API, single model | Low |
| BentoML | Multiple models, packaging | Medium |
| TorchServe | PyTorch models, batching | Medium |
| Triton | Multi-framework, GPU optimization | High |

### FastAPI (Recommended for IoT)
```python
from fastapi import FastAPI
import onnxruntime as ort

app = FastAPI()
session = ort.InferenceSession("model.onnx")

@app.post("/predict")
async def predict(image: UploadFile):
    frame = preprocess(await image.read())
    result = session.run(None, {"input": frame})
    return {"detections": postprocess(result)}
```

## A/B Deployment

### Shadow Mode
- New model runs alongside production, results logged but not served
- Compare accuracy/latency/resource usage before switching
- Zero risk to users

### Canary
- Route 5% of traffic to new model
- Monitor metrics (accuracy, latency, error rate)
- Gradually increase: 5% → 25% → 50% → 100%
- Auto-rollback if error rate increases

## Drift Detection

### Data Drift
Input distribution changes (e.g., new camera angle, different lighting).
- Monitor: feature distribution (KL divergence, KS test)
- Tool: Evidently AI

### Concept Drift
Relationship between input and output changes (e.g., new uniform that looks different).
- Monitor: model accuracy on labeled samples
- Requires periodic labeling of production data

```python
from evidently.metrics import DataDriftPreset
from evidently.report import Report

report = Report(metrics=[DataDriftPreset()])
report.run(reference_data=training_data, current_data=production_data)
# Alert if drift detected in >30% of features
```

## Key Rules

- **Version everything:** model, training data, preprocessing code, config
- **Reproducibility:** any experiment can be re-run from logged parameters
- **Monitoring is not optional:** drift detection from day one
- **Rollback plan:** every deployment has a one-click rollback to previous version
REFEOF

cat > ml-engineer/references/edge-deployment.md << 'REFEOF'
# Edge Model Deployment

## ONNX Export

### From PyTorch
```python
import torch

model = load_trained_model()
model.eval()
dummy_input = torch.randn(1, 3, 640, 640)

torch.onnx.export(
    model, dummy_input, "model.onnx",
    input_names=["input"], output_names=["boxes", "scores"],
    dynamic_axes={"input": {0: "batch"}, "boxes": {0: "batch"}, "scores": {0: "batch"}},
    opset_version=17
)
```

### From TensorFlow
```python
import tf2onnx
model = tf.keras.models.load_model("model.h5")
spec = (tf.TensorSpec((None, 640, 640, 3), tf.float32, name="input"),)
model_proto, _ = tf2onnx.convert.from_keras(model, input_signature=spec, output_path="model.onnx")
```

## Post-Training INT8 Quantization

```python
from onnxruntime.quantization import quantize_static, CalibrationDataReader

class CalibReader(CalibrationDataReader):
    def __init__(self, calibration_images):
        self.data = iter(calibration_images)
    def get_next(self):
        try: return {"input": next(self.data)}
        except StopIteration: return None

quantize_static(
    model_input="model_fp32.onnx",
    model_output="model_int8.onnx",
    calibration_data_reader=CalibReader(calib_images),  # 100-500 representative images
    quant_format=QuantFormat.QDQ
)
```

## TFLite Conversion

```python
converter = tf.lite.TFLiteConverter.from_saved_model("saved_model/")
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset = representative_data_gen
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.int8
converter.inference_output_type = tf.int8
tflite_model = converter.convert()
```

## Validation After Optimization

```python
# Compare FP32 and INT8 outputs
fp32_session = ort.InferenceSession("model_fp32.onnx")
int8_session = ort.InferenceSession("model_int8.onnx")

for image in validation_set:
    fp32_result = fp32_session.run(None, {"input": image})
    int8_result = int8_session.run(None, {"input": image})
    # Compare mAP, precision, recall
    # Accept if accuracy drop < 2%
```

## Deployment Packaging

```dockerfile
FROM nvcr.io/nvidia/l4t-ml:r35.2.1-py3  # Jetson base image

COPY model_int8.onnx /app/model.onnx
COPY inference.py /app/
COPY requirements.txt /app/

RUN pip install -r /app/requirements.txt
CMD ["python", "/app/inference.py"]
```

## Versioning and Update Strategy

```
/models/
  person-detect/
    v3.1.0/
      model_int8.onnx
      metadata.json    # accuracy, hardware targets, dependencies
      validation.json  # benchmark results on target hardware
    v3.0.0/
      ...
  active → v3.1.0 (symlink)
```

Update flow:
1. Download new model version to edge
2. Run validation suite on device (100 test images)
3. If accuracy ≥ threshold: swap symlink to new version
4. If fails: keep current version, report failure

## Key Rules

- **Always validate after quantization** — never deploy without accuracy check
- **Test on actual target hardware** — emulated benchmarks lie
- **Keep previous version** on device for instant rollback
- **Model + preprocessing must be versioned together** — mismatched preprocessing breaks accuracy
REFEOF

cat > data-engineer/references/time-series.md << 'REFEOF'
# Time-Series Databases for IoT

## Comparison

| Feature | InfluxDB | TimescaleDB | ClickHouse |
|---------|----------|-------------|------------|
| Type | Native time-series | PostgreSQL extension | Columnar OLAP |
| Query language | InfluxQL / Flux | SQL | SQL |
| Write throughput | ~500K pts/s | ~200K rows/s | ~1M rows/s |
| Compression | Good (10-15x) | Good (10-20x) | Excellent (20-40x) |
| Aggregation | Good | Excellent (SQL) | Excellent |
| Ecosystem | Telegraf, Grafana | PostgreSQL tools | Grafana, dbt |
| Operations | Easy | Medium (PG tuning) | Medium-Hard |
| Best for | Simple IoT, fast start | SQL teams, mixed workloads | High-volume analytics |

## When to Use Each

- **InfluxDB:** <100K devices, simple queries, fast setup, Telegraf integration
- **TimescaleDB:** SQL team, complex queries, joins with relational data, existing PostgreSQL
- **ClickHouse:** >100K devices, high write throughput, heavy analytics, cost-sensitive storage

## Schema Design for IoT Telemetry

### Wide table (recommended)
```sql
CREATE TABLE telemetry (
    time        TIMESTAMPTZ NOT NULL,
    device_id   TEXT NOT NULL,
    site_id     TEXT NOT NULL,
    temperature DOUBLE PRECISION,
    humidity    DOUBLE PRECISION,
    battery_v   DOUBLE PRECISION
);
-- TimescaleDB: convert to hypertable
SELECT create_hypertable('telemetry', 'time');
CREATE INDEX ON telemetry (device_id, time DESC);
```

### Narrow table (flexible but slower)
```sql
CREATE TABLE metrics (
    time       TIMESTAMPTZ NOT NULL,
    device_id  TEXT NOT NULL,
    metric     TEXT NOT NULL,      -- 'temperature', 'humidity'
    value      DOUBLE PRECISION
);
```

Wide is better for fixed schemas. Narrow for dynamic/unknown metrics.

## Downsampling & Retention

```sql
-- TimescaleDB continuous aggregate (auto-downsampling)
CREATE MATERIALIZED VIEW telemetry_hourly
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 hour', time) AS bucket,
       device_id,
       avg(temperature) as avg_temp,
       max(temperature) as max_temp,
       min(temperature) as min_temp,
       count(*) as samples
FROM telemetry
GROUP BY bucket, device_id;

-- Retention policy: drop raw data after 30 days
SELECT add_retention_policy('telemetry', INTERVAL '30 days');
-- Keep hourly aggregates for 1 year
SELECT add_retention_policy('telemetry_hourly', INTERVAL '1 year');
```

## Key Rules

- **Partition by time** — all time-series DBs do this; ensure queries filter on time
- **Tag/index on device_id** — always filter by device + time range
- **Downsample early** — raw data at 1s intervals → 1min aggregates → 1hr aggregates
- **Set retention policies** — infinite storage is not a plan
REFEOF

cat > data-engineer/references/kafka-pipelines.md << 'REFEOF'
# Kafka Pipelines for IoT

## Topic Design

### Partition Key Strategy
- **By device_id:** all messages from one device go to same partition → ordering guaranteed per device
- **Partition count:** start with 12-24 (can increase later, cannot decrease)

```
Topics:
  telemetry.raw          — all raw device telemetry (key: device_id)
  telemetry.aggregated   — 1-minute summaries (key: device_id)
  alerts.detected        — anomaly/threshold alerts (key: device_id)
  commands.outbound      — commands to devices (key: device_id)
  devices.status         — device online/offline events (key: device_id)
```

### Retention
- **Log retention:** time-based (7 days for raw telemetry) or size-based
- **Compacted topics:** keep latest value per key (device status, config)
- **alerts:** longer retention (30-90 days for audit)

## Consumer Groups

```
consumer-group: telemetry-aggregator    → reads telemetry.raw, writes telemetry.aggregated
consumer-group: alert-engine            → reads telemetry.raw, writes alerts.detected
consumer-group: dashboard-feeder        → reads telemetry.aggregated, updates dashboard cache
consumer-group: long-term-storage       → reads telemetry.aggregated, writes to TimescaleDB
```

Each consumer group gets independent progress. Multiple groups can read same topic.

## Exactly-Once Semantics

**When needed:** billing events, alert state changes, anything where duplicates cause harm.
**Cost:** higher latency (~100ms), more broker coordination, idempotent producer required.

```python
producer = KafkaProducer(
    enable_idempotence=True,
    transactional_id="alert-processor-1"
)
producer.init_transactions()
producer.begin_transaction()
producer.send("alerts.detected", value=alert)
producer.commit_transaction()
```

**Most IoT telemetry doesn't need exactly-once.** At-least-once with idempotent consumers is cheaper.

## Schema Registry

| Format | Size | Schema Evolution | Tooling |
|--------|------|-----------------|---------|
| Avro | Small (binary) | Excellent | Confluent Schema Registry |
| Protobuf | Small (binary) | Good | Buf, Confluent |
| JSON Schema | Large (text) | Basic | Confluent, any |

**Recommendation:** Avro for high-throughput telemetry. JSON Schema for low-volume, human-readable.

## Dead-Letter Queue

```
telemetry.raw → [consumer] → success → telemetry.aggregated
                           → failure → telemetry.raw.dlq
```

After 3 retries, send to DLQ. Monitor DLQ size. Alert if growing.

## Stream Processing

| Tool | Latency | Complexity | Best For |
|------|---------|------------|----------|
| Kafka Streams | Low | Medium | Java/Kotlin teams, moderate complexity |
| Apache Flink | Very low | High | Complex event processing, exactly-once |
| ksqlDB | Low | Low | SQL-based, simple transformations |

For IoT: Kafka Streams is usually sufficient. Flink if you need complex windowing or exactly-once across topics.
REFEOF

cat > data-engineer/references/video-storage.md << 'REFEOF'
# Video Storage (Object Storage)

## Bucket Structure

```
s3://video-recordings/
  └── {site_id}/
      └── {camera_id}/
          └── {date}/
              ├── segments/
              │   ├── 2025-01-15T10-00-00_000.ts
              │   ├── 2025-01-15T10-00-06_001.ts
              │   └── ...
              ├── playlists/
              │   └── 2025-01-15T10-00-00.m3u8
              └── thumbnails/
                  ├── 2025-01-15T10-00-00.jpg
                  └── ...
```

Key: `{site_id}/{camera_id}/{date}/segments/{timestamp}_{seq}.ts`

## Lifecycle Policies

```json
{
  "Rules": [
    {
      "ID": "hot-to-warm",
      "Filter": {"Prefix": ""},
      "Transitions": [
        {"Days": 7, "StorageClass": "STANDARD_IA"},
        {"Days": 30, "StorageClass": "GLACIER_IR"},
        {"Days": 90, "StorageClass": "GLACIER"}
      ],
      "Expiration": {"Days": 365}
    }
  ]
}
```

| Tier | Duration | Storage Class | Access | Cost |
|------|----------|---------------|--------|------|
| Hot | 0-7 days | Standard | Instant | $$$ |
| Warm | 7-30 days | IA / Infrequent | Instant, higher retrieval | $$ |
| Cold | 30-90 days | Glacier IR | Minutes | $ |
| Archive | 90-365 days | Glacier | Hours | ¢ |
| Delete | >365 days | — | — | Free |

## HLS Segment Management

- Segment duration: 6 seconds (standard) or 2 seconds (LL-HLS)
- Playlist: rolling window (last 10 segments for live) + full VOD playlist
- Clean up: delete segments when lifecycle policy expires, or compact into MP4

## Presigned URLs for Playback

```python
import boto3

s3 = boto3.client("s3")
url = s3.generate_presigned_url(
    "get_object",
    Params={"Bucket": "video-recordings", "Key": playlist_key},
    ExpiresIn=3600  # 1 hour
)
# Return presigned URL to frontend for HLS.js playback
```

Never expose S3 bucket publicly. Always use presigned URLs with short expiry.

## Cost Optimization

- **Don't store what you don't need:** motion-only recording saves 60-80% storage
- **Downsample for archive:** keep 1080p for 7 days, then transcode to 720p or 480p
- **Use S3-compatible (MinIO)** for on-premises: same API, customer-controlled storage
- **Calculate cost per camera:**
  - 1080p@15fps, H.264, 4Mbps = ~1.8 GB/hour = ~43 GB/day
  - S3 Standard: $0.023/GB = ~$1/day/camera
  - After 7 days → IA: ~$0.35/day/camera
  - With motion-only (30% activity): ~$0.30/day/camera (hot)
REFEOF

echo "✅ Part 2: Core reference files created (continuing...)"
