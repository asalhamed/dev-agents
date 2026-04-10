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
