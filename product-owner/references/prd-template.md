# Product Requirements Document (PRD) Template

Copy this template and fill in each section. Guidance in [brackets].

---

## 1. Overview

### Title
[Feature or product name — clear and specific, e.g., "Order Notification Preferences"]

### Summary
[2-3 sentences describing what this feature does and why it matters. Write it so someone
unfamiliar with the project can understand the intent.]

### Author
[Name and role of the PRD owner]

### Status
[Draft | In Review | Approved | In Progress | Shipped]

### Last Updated
[YYYY-MM-DD]

---

## 2. Problem Statement

### What problem are we solving?
[Describe the user's pain point in concrete terms. Use data if available:
"Users submit an average of 3 support tickets per month about missed order updates."]

### Who has this problem?
[Target user persona(s). Reference persona documents if they exist.]

### How are they solving it today?
[Current workaround — manual processes, competitor tools, or just suffering through it.]

### Why solve it now?
[Business context — what changed? Customer feedback volume? Competitive pressure?
Strategic alignment? Revenue impact?]

---

## 3. Goals & Success Metrics

### Goals
[List 2-4 specific, measurable outcomes this feature should achieve.]

1. [e.g., "Reduce order-related support tickets by 30% within 60 days of launch"]
2. [e.g., "Achieve 50% adoption of notification preferences within 30 days"]
3. [e.g., "Maintain current order completion rate (no regression)"]

### Non-Goals
[Explicitly state what this feature will NOT do. Prevents scope creep.]

- [e.g., "This feature does not include marketing email preferences"]
- [e.g., "We will not build a notification center UI in this phase"]

### Success Metrics

| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| [e.g., Support tickets about order updates] | [e.g., 150/month] | [e.g., <100/month] | [e.g., Zendesk tag count] |
| [e.g., Notification preference adoption] | [N/A] | [e.g., 50% of active users] | [e.g., Analytics event tracking] |

---

## 4. User Stories

[Write stories in "As a [role], I want [goal], so that [benefit]" format.
Include acceptance criteria for each.]

### Story 1: [Title]
**As a** [role], **I want** [goal], **so that** [benefit].

**Acceptance Criteria:**
- [ ] [Specific, testable condition]
- [ ] [Another condition]
- [ ] [Edge case to handle]

### Story 2: [Title]
**As a** [role], **I want** [goal], **so that** [benefit].

**Acceptance Criteria:**
- [ ] [Condition]
- [ ] [Condition]

[Add as many stories as needed. Group by epic if there are many.]

---

## 5. Scope

### In Scope
[Explicit list of what's included in this release.]

- [Feature/capability 1]
- [Feature/capability 2]

### Out of Scope
[What's explicitly excluded — may be addressed in future phases.]

- [Deferred feature 1]
- [Deferred feature 2]

### Phases (if applicable)

| Phase | Scope | Target Date |
|-------|-------|-------------|
| Phase 1 (MVP) | [Core functionality] | [Date] |
| Phase 2 | [Enhancements] | [Date] |
| Phase 3 | [Nice-to-haves] | [Date] |

---

## 6. Design & UX

### User Flows
[Link to user flow diagrams or describe the key flows in words.
What does the user do step by step?]

### Wireframes / Mockups
[Link to Figma, screenshots, or embed images. Even rough sketches help.]

### Key Design Decisions
[Document important UX decisions and their rationale.]

- [Decision 1 and why]
- [Decision 2 and why]

---

## 7. Technical Considerations

[This section is for the product owner to flag known technical constraints or questions.
Detailed technical design is the architect's job.]

### Known Constraints
- [e.g., "Must work with existing notification service (no replacement)"]
- [e.g., "Mobile app release cycle is 2 weeks — server changes must be backward compatible"]

### Dependencies
- [e.g., "Requires push notification infrastructure (owned by Platform team)"]
- [e.g., "Blocked by user settings migration (in progress, ETA April 15)"]

### Open Questions for Engineering
- [e.g., "Can we support per-channel notification preferences with the current schema?"]
- [e.g., "What's the latency impact of checking preferences on every notification send?"]

---

## 8. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| [e.g., Users don't discover the preferences page] | Medium | High | [Feature announcement email + in-app prompt] |
| [e.g., Push notification infrastructure not ready] | Low | High | [Fall back to email-only in Phase 1] |

---

## 9. Launch Plan

### Rollout Strategy
[e.g., "10% canary → 50% → 100% over 1 week"]

### Feature Flags
[e.g., "Behind `notification-preferences` flag, default off until launch"]

### Communication
- [ ] [Internal announcement to support team]
- [ ] [User-facing changelog entry]
- [ ] [In-app notification or email for existing users]

### Rollback Plan
[What happens if things go wrong? How do we revert?]

---

## 10. Appendix

### Related Documents
- [Link to persona documents]
- [Link to competitive analysis]
- [Link to previous PRDs for related features]

### Glossary
[Define any domain-specific terms that readers might not know.]

| Term | Definition |
|------|-----------|
| [Term 1] | [Definition] |
