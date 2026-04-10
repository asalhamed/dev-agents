#!/bin/bash
set -e
cd /home/ahmed/.openclaw/workspace/dev-agents-review

###############################################################################
# REMAINING REFERENCE FILES
###############################################################################

mkdir -p growth-strategist/references partnerships-agent/references
mkdir -p marketing/references sales/references customer-success/references
mkdir -p finance/references legal/references hr/references
mkdir -p incident-responder/references compliance-agent/references
mkdir -p analytics-engineer/references

cat > growth-strategist/references/iot-verticals.md << 'EOF'
# IoT Verticals Analysis

## Oil & Gas
- **Market size:** $28B (industrial IoT in O&G by 2027)
- **Buyer:** VP Operations, Asset Manager
- **Use cases:** Pipeline monitoring, wellhead surveillance, tank level, leak detection
- **Buying process:** RFP-driven, 6-12 month sales cycle, pilot required
- **Requirements:** ATEX/IECEx (explosion-proof), satellite connectivity, -40°C to +60°C
- **Regulatory:** EPA leak detection (LDAR), pipeline safety (PHMSA)

## Utilities
- **Market size:** $14B (smart grid + water by 2027)
- **Buyer:** VP Grid Operations, Water Treatment Director
- **Use cases:** Grid monitoring, transformer health, water quality, leak detection
- **Buying process:** Public procurement, 12-18 months, compliance-heavy
- **Requirements:** NERC CIP compliance, long-range connectivity, 15+ year device life
- **Regulatory:** NERC CIP (power), Safe Drinking Water Act

## Manufacturing
- **Market size:** $200B (Industry 4.0 by 2027)
- **Buyer:** Plant Manager, VP Manufacturing, Reliability Engineer
- **Use cases:** Equipment health (vibration, temperature), quality control, energy
- **Buying process:** Champion-driven, 3-6 month pilot, prove ROI vs existing SCADA
- **Requirements:** Integration with existing SCADA/MES, high-frequency data, shop floor WiFi
- **Regulatory:** ISO 9001, OSHA, industry-specific (pharma: FDA 21 CFR Part 11)

## Smart Buildings
- **Market size:** $100B (smart buildings by 2027)
- **Buyer:** Facility Manager, VP Real Estate, Building Owner
- **Use cases:** HVAC optimization, occupancy, access control, energy management
- **Buying process:** Budget-driven, ROI on energy savings, 3-6 months
- **Requirements:** BACnet/Modbus integration, occupancy privacy, multi-tenant
- **Regulatory:** Energy codes (ASHRAE 90.1), ADA, local building codes

## Agriculture
- **Market size:** $15B (precision agriculture by 2027)
- **Buyer:** Farm Owner, Agronomist, Cooperative Manager
- **Use cases:** Soil moisture, weather, irrigation control, livestock tracking
- **Buying process:** Seasonal (buy before planting), price-sensitive, dealer-driven
- **Requirements:** Solar/battery power, cellular/LoRa connectivity, rugged
- **Regulatory:** Water rights, pesticide regulations (vary by region)

## Logistics
- **Market size:** $40B (fleet management + cold chain by 2027)
- **Buyer:** VP Logistics, Fleet Manager, Supply Chain Director
- **Use cases:** Fleet tracking, cold chain (temperature), asset tracking, driver safety
- **Buying process:** Fleet size-driven, 3-6 months, prove ROI on fuel/compliance
- **Requirements:** GPS + cellular, real-time alerts, regulatory compliance (FDA for food)
- **Regulatory:** FDA FSMA (food), DOT (fleet), FMCSA (drivers)
EOF

cat > growth-strategist/references/gtm-frameworks.md << 'EOF'
# GTM Frameworks for IoT

## Product-Led Growth (PLG) vs Sales-Led vs Channel-Led

### Product-Led Growth
- **How:** Self-serve signup, free tier, usage-based upgrade
- **Works for IoT when:** Software-only (no hardware), dev tools, API platform
- **Doesn't work for IoT when:** Hardware required, enterprise security, complex deployment
- **Examples:** Datadog (monitoring), Twilio (connectivity APIs)

### Sales-Led
- **How:** Outbound sales team, discovery → pilot → contract
- **Works for IoT when:** ACV >$50K, complex deployment, enterprise buyer
- **Typical IoT model:** sales-led with technical content marketing for inbound
- **Examples:** Samsara (fleet), Uptake (industrial analytics)

### Channel-Led
- **How:** Partners sell/deploy for you (SIs, VARs, distributors)
- **Works for IoT when:** Need local presence, install-heavy, fragmented market
- **Risk:** Lose customer relationship, margin pressure
- **Examples:** Security cameras (sold through integrators)

## Land and Expand

### Beachhead Definition
Pick ONE vertical + ONE use case. Win it. Then expand:

```
Phase 1: Oil & Gas → Wellhead Monitoring (5 customers)
Phase 2: Oil & Gas → Pipeline + Tank Level (expand within vertical)
Phase 3: Utilities → Water Treatment (adjacent vertical, same patterns)
Phase 4: Manufacturing → Equipment Health (different buyer, same platform)
```

### Expansion Triggers
- Device count increase (customer adding more sensors)
- New sites (same customer, new locations)
- New features (video add-on, analytics tier upgrade)
- New departments (operations → safety → maintenance)

## Why Focus Beats Breadth for IoT Startups

1. **Domain expertise compounds** — oil & gas expertise makes next O&G deal easier
2. **Reference customers matter** — "we monitor 500 wells" is more compelling than "we do IoT"
3. **Product-market fit is vertical-specific** — features that matter for O&G differ from manufacturing
4. **Sales cycle shortens** — standardized deployment playbook for one vertical
5. **Support costs decrease** — known environment, known issues, documented solutions
EOF

cat > partnerships-agent/references/iot-ecosystem.md << 'EOF'
# IoT Ecosystem Partners

## Camera Vendors
| Vendor | Market | Strengths | Integration |
|--------|--------|-----------|-------------|
| Hikvision | Budget/mid | Price, volume, feature-rich | ONVIF, proprietary SDK |
| Axis | Enterprise | Quality, cybersecurity, open platform | VAPIX, ONVIF, ACAP apps |
| Dahua | Budget/mid | Price, wide range | ONVIF, DHSDK |
| Hanwha | Enterprise | AI features, cybersecurity | ONVIF, Wisenet Open Platform |

## Sensor Platforms
| Platform | Type | Best For |
|----------|------|----------|
| Arduino | Prototyping | Education, PoC, low-volume |
| Particle | Production IoT | Fleet management, cellular built-in |
| Nordic (nRF) | BLE/Thread | Low-power, wearables, sensors |
| ESP32 | WiFi/BLE | Cost-sensitive, high volume |

## Connectivity
| Provider | Type | Use Case |
|----------|------|----------|
| Sierra Wireless | Cellular (LTE/5G) | Industrial cellular gateways |
| Cradlepoint | Cellular/SD-WAN | Site connectivity, failover |
| Starlink | Satellite | Remote sites, no cellular |
| Iridium | Satellite | Global coverage, low bandwidth |

## Edge Hardware
| Hardware | Compute | Best For |
|----------|---------|----------|
| NVIDIA Jetson Nano | 128 CUDA cores, 4GB | Entry ML inference |
| NVIDIA Jetson Orin | 1024+ CUDA, 8-64GB | Multi-camera ML |
| Raspberry Pi CM4 | ARM quad-core, 2-8GB | Light edge gateway |
| Industrial PCs (Advantech) | x86, 8-32GB | Full edge platform, harsh environment |

## Integration Levels
1. **Certified Compatible:** tested and documented, logo on website
2. **API Partner:** formal API integration, co-developed features
3. **OEM:** our software embedded in their hardware product
EOF

cat > partnerships-agent/references/partnership-models.md << 'EOF'
# Partnership Models

## Model Comparison

| Model | We Do | They Do | Revenue | Control |
|-------|-------|---------|---------|---------|
| **OEM** | Build into their product | Sell combined product | License fee per unit | Low (their brand) |
| **White-label** | Provide platform | Brand and sell as theirs | Platform fee | Low |
| **Referral** | Accept leads | Send leads to us | 10-20% referral fee | High |
| **Technology** | Integrate their tech | Integrate our tech | Mutual, no direct rev | High |
| **Channel/Reseller** | Provide product | Sell to their customers | Wholesale discount (30-40%) | Medium |
| **Marketplace** | Build listing | Feature in their store | Revenue share (15-30%) | High |

## Revenue Share Models
- **Referral:** 10-20% of first-year ACV per qualified lead
- **Reseller:** 30-40% margin on resale price
- **OEM:** per-unit license fee ($1-5/device/month) or annual platform fee
- **Marketplace:** platform takes 15-30% of transactions

## Exclusivity Considerations
- **Avoid exclusivity** early — limits future options
- If required: time-bound (12 months), scope-limited (one vertical/region)
- Minimum commitment: partner must deliver minimum volume/revenue
- Exit clause: if minimums not met, exclusivity reverts

## Partner Enablement
What partners need to succeed:
1. **Technical:** integration docs, sandbox, reference architecture
2. **Sales:** pitch deck, objection handling, competitive positioning
3. **Support:** escalation path, L1/L2 support training
4. **Marketing:** co-marketing budget, case study template, joint webinars
EOF

cat > marketing/references/iot-messaging.md << 'EOF'
# B2B IoT Messaging

## Lead with Outcomes, Not Features

❌ "Our platform supports MQTT, WebRTC, and real-time analytics"
✅ "Reduce field visits by 65% and detect issues in minutes, not days"

## Industry-Specific Messaging

### Oil & Gas
- Pain: "$2,200 per field visit, 48h to detect wellhead anomaly"
- Message: "Monitor every wellhead in real-time. Detect issues before they become incidents."
- Proof: "Acme Oil reduced field visits 70% and caught a pressure anomaly 36h before failure."

### Utilities
- Pain: "Aging infrastructure, limited visibility, regulatory pressure"
- Message: "See your entire grid in real-time. Comply with NERC CIP. Prevent outages."

### Manufacturing
- Pain: "Unplanned downtime costs $260K/hour (average)"
- Message: "Predict equipment failures before they stop your line."

## Common Objections & Responses

| Objection | Response |
|-----------|----------|
| "We already have SCADA" | "We complement SCADA with remote monitoring, video, and analytics" |
| "Security concerns" | "End-to-end encryption, SOC2 certified, option for on-prem" |
| "Too expensive" | "Calculate ROI together — most customers see payback in 90 days" |
| "We tried IoT before" | "What went wrong? We start with a 30-day pilot — prove value first" |

## ROI Calculator Approach
Inputs: number of sites, field visits/month, cost per visit, current incident response time
Outputs: projected savings, payback period, 3-year TCO comparison
Always let the customer input their own numbers — more credible than industry averages.
EOF

cat > marketing/references/content-calendar.md << 'EOF'
# Content Calendar for IoT/Monitoring

## Blog Cadence
- 2 posts/month minimum
- Alternate: 1 technical deep-dive + 1 business/ROI piece
- SEO target: 1 long-tail keyword per post

## SEO Keyword Strategy
Focus on long-tail technical keywords (lower competition, higher intent):
- "remote wellhead monitoring system" (not "IoT platform")
- "MQTT vs HTTP for IoT devices"
- "industrial camera RTSP integration"
- "predictive maintenance vibration sensor"

## Content Types by Funnel Stage

### Awareness
- Blog posts (SEO-driven)
- Industry reports / market analysis
- Social media (LinkedIn engineering posts)

### Consideration
- Technical whitepapers
- Case studies (customer/challenge/solution/results)
- Webinars with technical deep-dives
- Product comparison guides

### Conversion
- ROI calculator
- Free pilot offer
- Technical architecture review (consultation)
- Reference calls with existing customers

## Case Study Structure
1. **Customer:** who they are (industry, size, location)
2. **Challenge:** specific problem with quantified pain
3. **Solution:** what we deployed (architecture, timeline)
4. **Results:** measured outcomes (% reduction, $ savings, time saved)
5. **Quote:** customer testimonial

## Video Content
- Product demos (5-10 min)
- Customer testimonial videos (2-3 min)
- Technical tutorials (how to integrate, how to deploy)
- Monthly "what's new" product update
EOF

cat > marketing/references/technical-marketing.md << 'EOF'
# Technical Marketing Formats

## Whitepaper Structure (8-12 pages)
1. Executive Summary (1 page)
2. Problem Statement — industry challenge with data
3. Current Approaches — what exists, why it's insufficient
4. Our Approach — technical architecture (not a sales pitch)
5. Implementation — how it works in practice
6. Results — measurable outcomes (case study data)
7. Conclusion + Next Steps

## Case Study Template
```markdown
# [Customer Name]: [One-line result]

## Customer Profile
- Industry: [vertical]
- Size: [employees, revenue, sites]
- Location: [region]

## Challenge
[2-3 paragraphs: specific problem, quantified pain, what they tried before]

## Solution
[2-3 paragraphs: what we deployed, architecture overview, timeline]

## Results
- [Metric 1]: X% improvement (e.g., "65% fewer field visits")
- [Metric 2]: $Y savings (e.g., "$420K annual savings")
- [Metric 3]: time reduction (e.g., "incident detection: 48h → 15 min")

## Customer Quote
> "Quote from champion about the impact" — Name, Title
```

## ROI Calculator Design
- **Input fields:** current state (visits, incidents, costs, response time)
- **Calculations:** projected savings based on customer benchmarks
- **Output:** payback period, 3-year savings, cost comparison chart
- **Lead capture:** gate the detailed PDF report, not the calculator itself

## Webinar Planning
- **Duration:** 45 min (30 min content + 15 min Q&A)
- **Structure:** problem → approach → demo → results → Q&A
- **Promotion:** 3 weeks before, email + LinkedIn + partner co-promotion
- **Follow-up:** recording to attendees, slides + summary to registrants who didn't attend
EOF

cat > sales/references/iot-sales-process.md << 'EOF'
# IoT Enterprise Sales Process

## Stages

### 1. Awareness (2-4 weeks)
- Activities: inbound lead, outbound prospecting, event meeting
- Goal: identify potential fit and interest
- Exit: discovery call scheduled

### 2. Discovery (2-4 weeks)
- Activities: needs assessment, stakeholder mapping, site visit
- Goal: understand pain, quantify problem, identify champion + budget holder
- Exit: qualified opportunity (BANT: Budget, Authority, Need, Timeline)

### 3. Technical Evaluation (4-8 weeks)
- Activities: technical deep-dive, architecture review, security questionnaire
- Goal: prove technical fit, address integration concerns
- Exit: pilot approved

### 4. Pilot (30-90 days)
- Activities: deploy at 1 site, measure KPIs, weekly check-ins
- Goal: prove value with customer's own data
- Exit: pilot success criteria met

### 5. Procurement (4-12 weeks)
- Activities: proposal, legal review, pricing negotiation, security audit
- Goal: get to signed contract
- Exit: contract signed

### 6. Deployment (4-12 weeks)
- Activities: full deployment, training, go-live, handoff to customer success
- Goal: customer live and getting value
- Exit: handoff to customer success

## Pilot Design
- **Duration:** 30-60 days (not more — urgency matters)
- **Scope:** 1 site, 10-50 devices, 2-4 cameras
- **Success criteria:** defined upfront with customer (e.g., "detect X anomalies within Y time")
- **Cost:** free or nominal ($5K) — removes friction, shows confidence
- **Weekly check-in:** review data, adjust, build relationship

## Common Blockers
- Security team: prepare SOC2 report, security questionnaire answers, pen test results
- Procurement: long PO process → ask for pilot PO (smaller, faster approval)
- IT integration: existing SCADA/VMS conflicts → show coexistence architecture
- Budget: no allocated budget → help champion build business case
EOF

cat > sales/references/proposal-template.md << 'EOF'
# Technical Proposal Template

## Structure

### 1. Executive Summary (1 page)
- Customer's challenge (in their words)
- Our solution (high level)
- Expected outcomes (quantified)
- Investment summary

### 2. Understanding Your Needs (1-2 pages)
- Restate customer's pain points from discovery
- Current state assessment
- Desired future state

### 3. Proposed Solution (2-3 pages)
- Architecture overview (diagram)
- Components: devices, connectivity, platform, analytics
- Integration with existing systems (SCADA, BMS, VMS)
- Security architecture

### 4. Implementation Approach (1-2 pages)
- Phase 1: pilot (scope, timeline, deliverables)
- Phase 2: full deployment
- Phase 3: expansion / advanced features
- Project timeline (Gantt or milestone chart)

### 5. Pricing (1 page)
- Per device/month or per site/month
- One-time setup/implementation fees
- Optional add-ons (video, analytics, custom integrations)
- Volume discounts (if applicable)

### 6. SLA Commitments
- Platform uptime: 99.9%
- Alert delivery: < 5 minutes
- Support response: P1 < 1 hour, P2 < 4 hours
- Data retention: per contract terms

### 7. About Us (0.5 page)
- Company overview (brief)
- Relevant case studies (2-3 bullet summaries)
- Team qualifications

### 8. Next Steps
- Specific actions with dates
- Decision timeline
- Contact information
EOF

cat > sales/references/objection-handling.md << 'EOF'
# IoT Sales Objection Handling

## Framework: Acknowledge → Explore → Respond → Confirm

### "We're concerned about data security"
- **Acknowledge:** "Security is critical, especially with operational data."
- **Explore:** "What's your security team's biggest concern — data in transit, at rest, or access control?"
- **Respond:** "We use end-to-end encryption (TLS 1.3), SOC2 Type II certified, and we offer on-premises deployment if your data can't leave your network."
- **Confirm:** "Would a call between your security team and our CISO address the remaining concerns?"

### "We don't want vendor lock-in"
- **Acknowledge:** "Smart concern. Lock-in is a real risk in IoT."
- **Respond:** "Our devices use standard MQTT (not proprietary protocols). Data is always exportable. We support ONVIF cameras (not just specific brands). If you ever leave, your data and devices still work."

### "We can't justify the ROI"
- **Explore:** "Let's build the business case together. How many field visits per month? Average cost per visit?"
- **Respond:** Use ROI calculator with their numbers. Focus on: field visit reduction, faster incident response, insurance premium reduction, avoided incidents.
- **Confirm:** "Based on your numbers, payback is [X months]. Want to validate with a pilot?"

### "Integration with our existing SCADA/BMS/VMS is too complex"
- **Respond:** "We coexist with SCADA — we don't replace it. We add remote monitoring, video, and analytics on top. Integration is API-based (Modbus, OPC-UA, REST). We've done this at [reference customer]."

### "The reliability/uptime SLA isn't enough"
- **Explore:** "What uptime do you need? What's the cost of an hour of downtime for you?"
- **Respond:** "Our SLA is 99.9%. For critical sites, we offer on-premises edge processing — works even if internet goes down. Let's discuss what SLA matches your requirements."

### "We tried IoT before and it failed"
- **Explore:** "What happened? Was it connectivity, reliability, or lack of business value?"
- **Respond:** "That's why we do a 30-day pilot first. You see results with your own data before committing. And we've solved the common failure modes: offline-first architecture, cellular backup, automated alerting."
EOF

cat > customer-success/references/iot-onboarding.md << 'EOF'
# IoT Customer Onboarding Playbook

## Pre-Deployment Site Survey
- [ ] Network bandwidth test at each device location
- [ ] Firewall rules: MQTT (8883), HTTPS (443), NTP (123) outbound
- [ ] Power availability at sensor/camera locations
- [ ] WiFi coverage map (or cellular signal strength)
- [ ] Physical mounting points for cameras/sensors
- [ ] Environmental conditions (temperature, moisture, dust)

## Device Provisioning Steps
1. Unbox and register device serial numbers in platform
2. Connect device to provisioning network (WiFi or cellular)
3. Device auto-enrolls (zero-touch) or manual certificate install
4. Assign device to site/zone in platform
5. Verify device appears online in dashboard

## MQTT/Credentials Configuration
- Provision unique certificate per device (never shared credentials)
- Configure MQTT broker URL and port (from platform settings)
- Set telemetry interval (default: 30s, adjust per use case)
- Set alert thresholds (from customer's operating parameters)

## First Data Validation Checklist
- [ ] Device shows "online" in dashboard
- [ ] Telemetry data appearing at expected interval
- [ ] Values are in expected range (not all zeros, not noise)
- [ ] Timestamps are correct (NTP synced)
- [ ] Alert triggers correctly when threshold crossed (test alert)

## Monitoring Setup Verification
- [ ] Dashboard configured with customer's preferred views
- [ ] Alert rules set per customer's requirements
- [ ] Notification channels configured (email, SMS, webhook)
- [ ] Escalation rules defined (who gets P1 vs P2 alerts)

## Customer Training Outline (2 hours)
1. Dashboard navigation (30 min)
2. Alert configuration (30 min)
3. Mobile app setup (15 min)
4. Troubleshooting basics: device offline, connectivity issues (30 min)
5. Q&A and support process (15 min)
EOF

cat > customer-success/references/health-scoring.md << 'EOF'
# Customer Health Scoring

## Metrics to Track

| Metric | Green | Yellow | Red |
|--------|-------|--------|-----|
| Device uptime | >99% | 95-99% | <95% |
| Connectivity rate | >98% | 90-98% | <90% |
| Alert response time | <30min | 30min-2h | >2h or ignored |
| API usage | Stable/growing | Declining 10-20% | Declining >20% |
| Support tickets/month | 0-2 | 3-5 | >5 or escalations |
| Feature adoption | >3 features | 2-3 features | 1 feature only |
| NPS/CSAT | >8 | 6-8 | <6 |

## Scoring Model

```
Health Score = weighted average of component scores

Weights:
  Device uptime:      25%  (core value delivery)
  Support trend:      20%  (satisfaction signal)
  Feature adoption:   20%  (stickiness)
  API usage trend:    15%  (engagement)
  Alert response:     10%  (active usage)
  Connectivity rate:  10%  (infrastructure health)
```

- **Green:** score ≥ 80 — healthy, focus on expansion
- **Yellow:** score 50-79 — at risk, proactive engagement needed
- **Red:** score < 50 — churn risk, executive escalation

## Leading Indicators of Churn

1. **Device offline trend** — increasing number of offline devices over 4 weeks
2. **Support escalations** — repeated escalations on same issue
3. **Low feature adoption** — only using basic monitoring, ignoring analytics/video
4. **Declining API usage** — integration being deprecated or replaced
5. **Champion departure** — primary contact leaves the company
6. **Renewal silence** — no engagement 60 days before renewal
7. **Competitor mentions** — customer asks about competitor features

## Actions by Health Status

### Green (monthly touchpoint)
- Quarterly business review
- Share product roadmap, get feedback
- Identify expansion opportunities

### Yellow (weekly touchpoint)
- Root cause analysis of declining metrics
- Executive sponsor engagement
- Create action plan with timeline

### Red (daily until stabilized)
- Immediate escalation to CS leadership
- Executive-to-executive call
- Remediation plan with committed timeline
- Consider commercial concessions if warranted
EOF

cat > finance/references/iot-pricing-models.md << 'EOF'
# IoT SaaS Pricing Models

## Model Comparison

| Model | Pros | Cons | Best For |
|-------|------|------|----------|
| Per device/month | Simple, scales with fleet | Customers try to minimize devices | Standard IoT |
| Per site/month | Predictable for customer | Unfair for small vs large sites | Multi-site |
| Usage-based | Fair, aligns value | Unpredictable for customer | Video storage, API |
| Hybrid (base + usage) | Predictable + fair | Complex to explain | Enterprise IoT + video |

## Typical Pricing Ranges

### Per Device/Month
- Basic telemetry: $5-15/device/month
- Telemetry + alerts: $10-25/device/month
- Full platform (analytics, mobile): $15-50/device/month

### Per Camera/Month (Video)
- Live viewing only: $20-50/camera/month
- Live + recording (7 days): $50-100/camera/month
- Live + recording + analytics: $100-200/camera/month

### Per Site/Month
- Small site (<20 devices): $500-1,500/month
- Medium site (20-100 devices): $1,500-5,000/month
- Large site (100+ devices): custom pricing

## Cost Structure (per device)
- **Connectivity (cellular):** $5-15/device/month (biggest variable cost)
- **Cloud compute:** $0.50-2/device/month
- **Storage (telemetry):** $0.10-0.50/device/month
- **Storage (video):** $15-30/camera/month (at 30-day retention)
- **Support allocation:** $1-3/device/month

## Margin Analysis
- **Target gross margin:** 70-80%
- **Telemetry-only:** high margin (low COGS, mostly compute)
- **Video:** lower margin (storage costs, transcoding compute)
- **Cellular connectivity:** pass-through or slight markup
- **Hardware (if selling devices):** 20-40% margin (don't subsidize >50%)
EOF

cat > finance/references/financial-modeling.md << 'EOF'
# Financial Modeling for IoT SaaS

## Key Metrics

### Revenue
- **MRR:** Monthly Recurring Revenue = sum of all active subscriptions
- **ARR:** Annual Recurring Revenue = MRR × 12
- **Net Revenue Retention (NRR):** (Starting MRR + expansion - contraction - churn) / Starting MRR
  - Target: >110% (expansion exceeds churn)

### Churn
- **Gross churn:** MRR lost from downgrades + cancellations / Starting MRR
  - Target: <2% monthly (24% annual)
- **Logo churn:** customers lost / total customers
  - Target: <5% annual for enterprise

### Unit Economics
- **LTV:** ACV × gross margin ÷ annual churn rate
  - Example: $50K ACV × 75% margin ÷ 15% churn = $250K LTV
- **CAC:** total sales & marketing spend ÷ new customers acquired
  - Target: LTV/CAC > 3x
- **CAC payback:** CAC ÷ (ACV × gross margin)
  - Target: <18 months

## IoT-Specific Unit Economics

### Device-Level
```
Revenue per device: $25/month
COGS per device:
  - Cloud compute:   $1.50
  - Connectivity:    $8.00
  - Storage:         $0.50
  - Support:         $2.00
  Total COGS:        $12.00
Gross profit/device: $13.00 (52% margin)
```

### Hardware Margin (if selling devices)
- Don't sell hardware at cost — 20-40% margin minimum
- Hardware should not be a profit center — it's a channel to platform revenue
- Consider hardware-as-a-service (include device in monthly subscription)

## Runway Modeling

```
Runway (months) = Cash ÷ Monthly Burn

Monthly Burn = Payroll + Infrastructure + Office + Marketing + G&A - Revenue

Scenario Planning:
  Base case: current trajectory
  Optimistic: pipeline converts at 50%
  Conservative: no new customers, current churn rate
  Worst case: lose largest customer + no new sales
```

## Key Rules
- Revenue recognition: recognize monthly as service is delivered (not upfront)
- Hardware revenue: recognize on delivery (not subscription)
- Always model worst case: what happens if largest customer churns?
- Watch NRR: most important metric for IoT SaaS (expansion > churn = compounding growth)
EOF

cat > legal/references/video-privacy.md << 'EOF'
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
EOF

cat > legal/references/iot-liability.md << 'EOF'
# IoT Liability & SLA Drafting

## SLA Structure

### Uptime Commitments
| Tier | Uptime | Monthly Downtime | Credit |
|------|--------|------------------|--------|
| Standard | 99.5% | 3.6 hours | 10% |
| Premium | 99.9% | 43 minutes | 15% |
| Enterprise | 99.95% | 22 minutes | 25% |

Measurement: platform availability, not individual device connectivity.

### Alert Delivery SLA
- P1 alerts: delivered within 5 minutes of detection
- P2 alerts: delivered within 15 minutes
- Measurement: time from event to notification delivery (email/SMS/push)

## Liability Caps
- **Standard:** aggregate liability capped at fees paid in prior 12 months
- **Floor:** liability cap should be at least 1x annual fees (customer will negotiate up)
- **Ceiling:** never exceed 3x annual fees without executive approval

## Exclusions
Standard exclusions from SLA:
- Customer's network/internet connectivity failures
- Customer's hardware failures (cameras, sensors not supplied by us)
- Force majeure
- Scheduled maintenance (with 48h notice)
- Customer-caused issues (misconfiguration, API abuse)

## Warranty Limitations
- **No guarantee of detection:** "Platform provides monitoring tools; detection of all events is not guaranteed"
- **No guarantee of prevention:** monitoring ≠ prevention; we observe, we don't control
- **Sensor accuracy:** within manufacturer specifications; we're not liable for sensor errors

## Key Clauses
- **Data ownership:** customer owns their data; we process on their behalf
- **Data return:** on termination, data available for export for 30 days
- **Subprocessors:** list all cloud providers (AWS, etc.) as subprocessors
- **Insurance:** maintain $2M+ cyber liability insurance
EOF

cat > legal/references/data-residency.md << 'EOF'
# Data Residency Requirements

## By Region

### European Union (GDPR)
- Personal data (including video of people) must stay in EU unless adequate safeguards
- Options: EU cloud regions, Standard Contractual Clauses, Binding Corporate Rules
- Some customers require: specific EU country (Germany for German customers)

### Middle East
- UAE: data localization for government and financial services
- Saudi Arabia: PDPL requires data to stay in KSA for certain sectors
- Growing trend toward local data centers

### Asia-Pacific
- China: PIPL requires personal data to stay in China
- India: proposed data localization for "critical" personal data
- Australia: Australian Privacy Principles — no strict localization, but adequacy required

## By Industry
- **Financial services:** often require data in same country as operations
- **Healthcare:** HIPAA (US) — no strict localization, but BAA required
- **Government:** almost always requires on-premises or sovereign cloud
- **Oil & gas:** operational data sometimes classified as critical infrastructure

## Technical Approaches

### Regional Deployments
```
EU customers → eu-west-1 (Ireland) or eu-central-1 (Frankfurt)
US customers → us-east-1 (Virginia) or us-west-2 (Oregon)
ME customers → me-south-1 (Bahrain)
```

### Data Localization
- Video and telemetry: stored in customer's region only
- Metadata (anonymized): may be processed centrally for analytics
- Edge processing: keep raw data on-premises, send only summaries to cloud

### Customer-Controlled Encryption Keys
- Customer manages encryption keys (BYOK — Bring Your Own Key)
- We cannot access data without customer's key
- Adds complexity but addresses sovereignty concerns
EOF

cat > hr/references/iot-roles.md << 'EOF'
# IoT Startup Roles

## Embedded Software Engineer
**Skills:** Rust or C, MQTT, RTOS (FreeRTOS/Zephyr), PCB bring-up, oscilloscope
**Compensation (Senior, US):** $160K-$200K base + equity
**Interview questions:**
- Design an OTA update system with rollback capability
- Debug a sensor that reads correctly 95% of the time but gives noise 5%
- Explain MQTT QoS levels — when would you use each?
- Walk through power optimization for a battery-powered sensor

## Video Engineer
**Skills:** GStreamer, FFmpeg, WebRTC, RTSP, H.264/H.265, Linux video stack
**Compensation (Senior, US):** $170K-$210K base + equity
**Interview questions:**
- Design a pipeline for 50 RTSP cameras to WebRTC + HLS
- How do you debug a 3-second latency in a WebRTC stream?
- Compare SFU vs MCU for a monitoring use case
- Handle camera disconnect/reconnect without viewer interruption

## Android Developer
**Skills:** Kotlin, Jetpack Compose, CameraX, ExoPlayer, MVVM, Room
**Compensation (Senior, US):** $160K-$195K base + equity
**Interview questions:**
- Implement offline-first data sync for a monitoring app
- Integrate RTSP live feed in a Compose UI
- Design state management for a multi-camera dashboard
- Handle background location + push notifications

## ML Engineer
**Skills:** PyTorch, ONNX, TFLite, computer vision, edge deployment
**Compensation (Senior, US):** $180K-$230K base + equity
**Interview questions:**
- Deploy a person detection model on Jetson Nano at 15 FPS
- Design anomaly detection for vibration sensor data
- Quantize a model to INT8 — what accuracy loss is acceptable?
- Monitor model drift in production — what metrics and thresholds?

## Data Engineer
**Skills:** Kafka, ClickHouse/TimescaleDB, Python/Scala, Spark/Flink, dbt
**Compensation (Senior, US):** $160K-$200K base + equity
**Interview questions:**
- Design ingestion pipeline for 100K devices publishing every 30s
- Kafka topic design: partition key strategy for IoT telemetry
- Implement downsampling: raw (30 days) → hourly (1 year) → daily (forever)
- Handle late-arriving data in a streaming pipeline
EOF

cat > hr/references/startup-hiring.md << 'EOF'
# Startup Hiring Strategy

## Hiring Sequence (IoT Startup)

### Phase 1: Core (0-5 people)
1. **CTO/Tech Lead** — full-stack, can do backend + basic firmware + deployment
2. **Embedded Engineer** — firmware, device bring-up, MQTT
3. **Backend Engineer** — API, data pipeline, cloud infrastructure
Goal: working prototype with real devices

### Phase 2: Product (5-10 people)
4. **Video Engineer** — streaming pipeline, WebRTC, recording
5. **Android Developer** — mobile app for field users
6. **DevOps/SRE** — CI/CD, monitoring, infrastructure as code
Goal: deployable product for first customer

### Phase 3: Scale (10-20 people)
7. **ML Engineer** — anomaly detection, computer vision
8. **Data Engineer** — scale data pipeline, analytics
9. **Customer Success** — onboarding, support
10. **Sales** — first dedicated salesperson
Goal: repeatable deployment, multiple customers

## Generalists vs Specialists
- **Early stage:** generalists who can wear multiple hats
- **Growth stage:** specialists for critical functions (video, ML, embedded)
- **Rule:** hire specialists when a generalist becomes a bottleneck

## Remote vs In-Person
- **Remote advantages:** access to rare skills (embedded, video engineers are scarce)
- **In-person advantages:** faster early-stage iteration, culture building
- **Hybrid recommendation:** remote-first with quarterly in-person sprints

## Equity Guidelines
- **ISO (Incentive Stock Options):** tax-advantaged, US employees
- **Vesting:** 4-year vest, 1-year cliff (standard)
- **Early employees (1-5):** 0.5-2% each
- **Employees 6-15:** 0.1-0.5% each
- **Refresh grants:** annual, 25-50% of initial grant

## Rare Skills Pipeline
- Embedded engineers: 3-6 months to find (limited talent pool)
- Video engineers: 3-6 months (GStreamer/WebRTC expertise is rare)
- Strategy: build pipeline before you need to hire, attend niche conferences (Embedded World, RustConf)
EOF

cat > incident-responder/references/incident-severity.md << 'EOF'
# Incident Severity Definitions

## Severity Levels

| Level | Definition | Response Time | Comms Cadence |
|-------|-----------|---------------|---------------|
| **P1** | Platform down, data loss, security breach | 15 min | Every 30 min |
| **P2** | Degraded service, partial outage, >10% customers | 1 hour | Every 2 hours |
| **P3** | Minor degradation, single customer, workaround exists | 4 hours | Daily |

## P1 Examples
- Video platform completely down (no live feeds)
- Data loss (telemetry or video)
- Security breach (unauthorized access to customer data)
- >50% of devices disconnected simultaneously

## P2 Examples
- Live video degraded (frozen frames, high latency)
- Alert delivery delayed >15 minutes
- Single site completely offline
- API error rate >5%

## P3 Examples
- Dashboard slow but functional
- Single device model firmware bug
- Non-critical feature broken
- Single customer configuration issue

## Escalation Matrix

| Role | P1 | P2 | P3 |
|------|----|----|-----|
| On-call engineer | Immediate | 1 hour | 4 hours |
| Engineering manager | 15 min | 2 hours | Next business day |
| VP Engineering | 30 min | 4 hours | If unresolved 48h |
| CEO | 1 hour | If customer-facing 4h | Never |
| Customer comms | 30 min | 2 hours | Only if asked |

## On-Call Rotation
- Primary on-call: 1 week rotation
- Secondary on-call: backup if primary doesn't respond in 10 min
- Handoff: Monday 10 AM, documented in runbook
- Compensation: flat weekly rate + per-incident bonus for P1/P2
EOF

cat > incident-responder/references/postmortem-template.md << 'EOF'
# Blameless Postmortem Template

## Structure

```markdown
# Postmortem: [INC-YYYY-NNN] [Brief Description]

**Date:** YYYY-MM-DD
**Severity:** P1/P2/P3
**Duration:** X hours Y minutes
**Author:** [name]
**Reviewers:** [names]

## Summary
[2-3 sentences: what happened, impact, resolution]

## Timeline (UTC)
| Time | Event |
|------|-------|
| HH:MM | Alert fired / issue detected |
| HH:MM | On-call engineer engaged |
| HH:MM | Root cause identified |
| HH:MM | Mitigation applied |
| HH:MM | Service fully restored |

## Root Cause Analysis
[What actually caused the issue. Use 5 Whys or Fishbone if helpful.]

### 5 Whys
1. Why did the service fail? → [answer]
2. Why did [answer 1] happen? → [answer]
3. Why did [answer 2] happen? → [answer]
4. Why did [answer 3] happen? → [answer]
5. Why did [answer 4] happen? → [root cause]

## Contributing Factors
- [Factor 1 that made the issue worse or harder to detect]
- [Factor 2]

## What Went Well
- [Thing 1 that worked during incident response]
- [Thing 2]

## What Went Wrong
- [Thing 1 that didn't work or could be improved]
- [Thing 2]

## Action Items
| # | Action | Owner | Due Date | Priority |
|---|--------|-------|----------|----------|
| 1 | [Specific action] | @name | YYYY-MM-DD | High |
| 2 | [Specific action] | @name | YYYY-MM-DD | Medium |

## Lessons Learned
[1-2 paragraphs: what should we internalize from this?]
```

## Anti-Patterns
- **Blame:** "John forgot to..." → "The deployment process didn't enforce..."
- **Vague action items:** "Improve monitoring" → "Add alert for TURN allocation >70% — @devops by 2025-04-01"
- **No follow-through:** Action items without owners or dates are wish lists
- **Hindsight bias:** "We should have known..." — evaluate decisions with info available at the time
EOF

cat > incident-responder/references/runbook-library.md << 'EOF'
# Runbook Library

## Video Pipeline Failure
**Symptoms:** No live video feeds, WebRTC connection failures, HLS 404s
**Triage:**
1. Check media server pods: `kubectl get pods -l app=media-server`
2. Check RTSP connectivity to cameras: `ffprobe rtsp://camera-ip:554/stream1`
3. Check TURN server: `turnutils_uclient -t turn.example.com`
**Mitigation:** Restart media server pods. If camera unreachable, check network.
**Escalation:** Video engineer → DevOps → VP Engineering (if >30 min)

## Device Mass Disconnect
**Symptoms:** >10% of devices show offline simultaneously
**Triage:**
1. Check MQTT broker health: `mosquitto_sub -t '$SYS/broker/clients/connected'`
2. Check broker CPU/memory: `kubectl top pods -l app=mqtt-broker`
3. Check recent deployments: `kubectl rollout history`
**Mitigation:** Scale broker if overloaded. Rollback if recent deployment.
**Escalation:** Backend engineer → IoT engineer → VP Engineering

## MQTT Broker Overload
**Symptoms:** High publish latency, connection refusals, CPU >90%
**Triage:**
1. Check message rate: `emqx_ctl metrics | grep received`
2. Check subscription count and retained messages
3. Check for subscription loops or wildcard abuse
**Mitigation:** Scale horizontally (add broker node). Rate limit misbehaving clients.
**Escalation:** IoT engineer → DevOps

## Database Connection Exhaustion
**Symptoms:** 5xx errors, slow queries, "too many connections" in logs
**Triage:**
1. Check active connections: `SELECT count(*) FROM pg_stat_activity`
2. Check for long-running queries: `SELECT * FROM pg_stat_activity WHERE state != 'idle' ORDER BY duration DESC`
3. Check connection pool settings
**Mitigation:** Kill long-running queries. Increase pool size (temporary). Fix query or add index.
**Escalation:** Backend engineer → DBA

## Object Storage Full
**Symptoms:** Recording failures, upload errors, S3 5xx responses
**Triage:**
1. Check bucket size and growth rate
2. Check lifecycle policy is active
3. Check for stuck uploads or orphaned segments
**Mitigation:** Delete expired segments manually. Fix lifecycle policy. Expand storage.
**Escalation:** DevOps → Data engineer

## Edge Node Offline
**Symptoms:** No data from specific site, all devices at site show offline
**Triage:**
1. Check edge node connectivity (ping, SSH)
2. Check edge services: `kubectl get pods` (on edge K3s)
3. Check network uplink (cellular/satellite status)
**Mitigation:** Remote reboot if accessible. Dispatch field team if not. Edge buffer preserves data.
**Escalation:** DevOps → Customer success (notify customer)
EOF

cat > compliance-agent/references/soc2-controls.md << 'EOF'
# SOC2 Type II Control Mapping

## Security (CC6, CC7)

### CC6.1 — Logical Access Controls
- **Requirement:** restrict access to authorized users only
- **Implementation:**
  - SSO (SAML/OIDC) for all platform access
  - RBAC with principle of least privilege
  - MFA enforced for all admin accounts
  - API keys scoped to specific resources
- **Evidence:** IAM policy documents, access review logs, MFA enrollment report

### CC6.6 — Encryption
- **At rest:** AES-256 for all data stores (RDS, S3, ClickHouse)
- **In transit:** TLS 1.3 for all connections (MQTT, HTTPS, WebRTC)
- **Key management:** AWS KMS or customer-managed keys (BYOK)
- **Evidence:** encryption configuration screenshots, TLS scan results

### CC7.2 — Monitoring & Anomaly Detection
- **Requirement:** monitor for security events and anomalies
- **Implementation:**
  - Centralized logging (all services → ELK/Datadog)
  - Security event alerting (failed auth, privilege escalation, data access)
  - Intrusion detection on infrastructure
- **Evidence:** SIEM dashboard, alert rule definitions, sample alerts

## Availability (A1)

### A1.2 — Recovery & Incident Response
- **Requirement:** mechanisms to recover from incidents
- **Implementation:**
  - Documented incident response plan
  - Automated backups (daily, tested monthly)
  - Disaster recovery plan (RPO: 1 hour, RTO: 4 hours)
  - On-call rotation with escalation matrix
- **Evidence:** IR plan document, backup verification logs, DR test results

## Confidentiality (C1)

### C1.1 — Data Classification
- **Public:** marketing materials, documentation
- **Internal:** architecture diagrams, internal tools
- **Confidential:** customer data, telemetry, video
- **Restricted:** credentials, encryption keys, PII
- **Evidence:** data classification policy, handling procedures per class

## Processing Integrity (PI1)

### PI1.1 — Data Pipeline Accuracy
- **Requirement:** data is processed completely, accurately, timely
- **Implementation:**
  - Schema validation at ingestion
  - Idempotent processing (safe to replay)
  - Monitoring: data freshness, completeness metrics
  - Checksums for video segment integrity
- **Evidence:** schema validation rules, data quality dashboard, test results
EOF

cat > compliance-agent/references/gdpr-technical.md << 'EOF'
# GDPR Technical Measures

## Encryption

### At Rest
- AES-256 encryption for all databases and object storage
- Transparent Data Encryption (TDE) for PostgreSQL/ClickHouse
- S3 server-side encryption (SSE-S3 or SSE-KMS)

### In Transit
- TLS 1.3 minimum for all connections
- mTLS for device-to-broker (MQTT)
- DTLS for WebRTC media streams
- No plaintext protocols in production

## Access Control & Audit Logs

```json
{
  "timestamp": "2025-01-15T10:30:00Z",
  "actor": "user:jane@company.com",
  "action": "view_video",
  "resource": "camera:site-a/cam-01",
  "ip": "203.0.113.42",
  "result": "allowed"
}
```

Log all: authentication events, data access, configuration changes, admin actions.
Retain audit logs for 2 years minimum. Tamper-evident logging.

## Data Retention Automation
- Define retention policy per data type (telemetry: 30 days, video: 30 days, alerts: 1 year)
- Automated deletion job runs daily
- Verify deletion (spot-check that expired data is actually gone)
- Document: what was deleted, when, by what process

## Right to Erasure (Video Challenge)
- Video is continuous — can't easily delete one person
- **Approach 1:** Delete entire time range requested (overinclusive but simple)
- **Approach 2:** AI-based face redaction (expensive, imperfect)
- **Approach 3:** Metadata-only deletion (remove association, keep anonymized video)
- Document limitations in privacy policy
- Response deadline: 30 days from request

## Breach Notification
- **72-hour requirement:** notify supervisory authority within 72 hours of discovery
- **Content:** nature of breach, categories of data, approximate number of individuals, consequences, measures taken
- **Notification to individuals:** required if high risk to rights and freedoms
- **Preparation:** pre-drafted notification templates, designated breach response team
EOF

cat > compliance-agent/references/iot-security-standards.md << 'EOF'
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
EOF

echo "✅ Remaining reference files created"
