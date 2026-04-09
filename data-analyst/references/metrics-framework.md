# Metrics Frameworks

Reference for choosing, defining, and instrumenting success metrics.
Every feature must have measurable success criteria before work begins.

---

## HEART Framework (Google)

**Use for:** UX-focused features, product improvements, user experience measurement.

The HEART framework measures user experience across five dimensions.
For each dimension, define Goals → Signals → Metrics.

| Dimension | Definition | Example Metrics |
|-----------|-----------|----------------|
| **Happiness** | User satisfaction and sentiment | NPS score, CSAT rating, satisfaction survey results |
| **Engagement** | Depth and frequency of interaction | Sessions per week, features used per session, time on task |
| **Adoption** | New users or new feature uptake | New users/week, % of users who tried feature in first 7 days |
| **Retention** | Users who continue using the product/feature over time | 7-day retention, 30-day retention, churn rate |
| **Task Success** | Ability to complete intended tasks efficiently | Task completion rate, time-to-complete, error rate |

### Goals → Signals → Metrics Process

1. **Goal:** What user outcome do you want? (e.g., "Users can manage notification preferences easily")
2. **Signal:** What user behavior indicates the goal is met? (e.g., "Users complete preference changes without abandoning")
3. **Metric:** How do you measure the signal? (e.g., "Preference update completion rate > 90%")

### Example: Notification Preferences Feature

| Dimension | Goal | Signal | Metric |
|-----------|------|--------|--------|
| Happiness | Users feel in control of notifications | Fewer support tickets about notifications | Support tickets tagged "notifications" ↓ 40% |
| Engagement | Users actively manage preferences | Users visit and interact with preferences page | Preference page visits/month; preference_updated events/user |
| Adoption | Users discover and use the feature | New users set preferences in first session | % of new users who visit preferences within 7 days |
| Retention | Users don't unsubscribe entirely | Fewer full unsubscribes | Unsubscribe rate ↓ 30% |
| Task Success | Preference changes are easy | Users complete changes without errors | Task completion rate > 95%; avg time < 30 seconds |

---

## Pirate Metrics (AARRR)

**Use for:** Growth and business metrics, product-market fit, funnel optimization.

| Stage | Definition | Typical Metrics |
|-------|-----------|----------------|
| **Acquisition** | How do users find you? | Visitors, signups, channel attribution, CAC |
| **Activation** | Do users have a good first experience? | Onboarding completion, first key action (e.g., first order), time-to-value |
| **Retention** | Do users come back? | DAU/MAU ratio, cohort retention curves, churn rate |
| **Referral** | Do users tell others? | Referral invites sent, viral coefficient, NPS |
| **Revenue** | Do users pay? | ARPU, LTV, conversion rate (free → paid), MRR |

### Funnel Thinking

Each stage is a conversion step. Measure drop-off between stages to find the biggest lever:

```
Acquisition (10,000 visitors)
    ↓ 20% convert
Activation (2,000 complete onboarding)
    ↓ 40% return
Retention (800 active after 30 days)
    ↓ 10% refer
Referral (80 send invites)
    ↓ 50% convert to paid
Revenue (400 paying customers)
```

**Biggest lever:** Activation (20% → 30% would add 1,000 more activated users).

---

## Leading vs Lagging Indicators

| Type | Definition | Examples |
|------|-----------|---------|
| **Leading** | Predictive — changes before the outcome. Actionable now. | Feature adoption rate, preference page visits, support ticket volume |
| **Lagging** | Historical — confirms the outcome happened. Measured after the fact. | Monthly revenue, quarterly churn, annual NPS |

### Why You Need Both

- **Leading indicators** let you course-correct before it's too late
- **Lagging indicators** confirm whether the course correction worked
- A feature dashboard should show 2-3 leading indicators and 1-2 lagging indicators

### Example

| Feature | Leading (act now) | Lagging (confirm later) |
|---------|-------------------|------------------------|
| Notification preferences | Preference page visits, preference_updated events | Unsubscribe rate (30-day), support tickets |
| Checkout redesign | Cart-to-checkout ratio, form field error rate | Checkout completion rate (weekly), revenue per session |

---

## Choosing a Framework

| Situation | Framework | Why |
|-----------|-----------|-----|
| UX feature (preferences, onboarding, settings) | HEART | Measures user experience directly |
| Growth initiative (referrals, onboarding, pricing) | AARRR | Maps to business funnel stages |
| Any feature | Leading/Lagging | Complements either framework above |

You can combine them: use HEART for the feature's UX metrics and AARRR to see how
the feature affects the broader business funnel.

---

## Guardrail Metrics

**Definition:** Metrics that must NOT degrade when you ship a feature. They protect against
unintended negative consequences.

**Common guardrail metrics:**

| Guardrail | Protects Against |
|-----------|-----------------|
| Page load time (p95) | Feature bloating page weight |
| Error rate (5xx) | Feature introducing bugs |
| Core task completion rate | Feature confusing users on existing flows |
| SecurityAlert delivery rate | Notification changes silencing critical alerts |
| Revenue per session | UX changes reducing purchasing intent |

### Rules

1. Define guardrail metrics **before** shipping — not after you notice a problem
2. Set explicit thresholds: "p95 load time must not increase by more than 200ms"
3. If a guardrail is breached during A/B testing, halt the experiment
4. Guardrails are non-negotiable — you can't trade safety for feature metrics
