# Persona Template

Structured template for creating user personas. Fill in each section based on
user research data (interviews, surveys, analytics).

---

## Template

### [Persona Name]

| Field | Details |
|-------|---------|
| **Name** | [Fictional but representative name] |
| **Age** | [Age or age range] |
| **Role** | [Job title or life role relevant to the product] |

#### Goals

1. [Primary goal — what they most want to accomplish with this product]
2. [Secondary goal]
3. [Tertiary goal, if applicable]

#### Pain Points

1. [Current frustration that this product could address]
2. [Another friction point in their workflow or experience]
3. [Optional third pain point]

#### Context of Use

- **When:** [Time of day, frequency — e.g., "Daily during morning standup"]
- **Where:** [Physical context — e.g., "At desk, on mobile during commute"]
- **How:** [Device, environment — e.g., "Laptop with dual monitors, often multitasking"]

#### Technical Literacy

**[Novice / Intermediate / Expert]**

[Brief description — e.g., "Comfortable with spreadsheets and basic web apps, but
avoids command-line tools and custom configurations."]

#### Devices

- Primary: [e.g., MacBook Pro 14"]
- Secondary: [e.g., iPhone 15, used for quick checks]

#### Quote

> "[A one-liner in their voice that captures their attitude toward the product or problem space]"

---

## Field Guidance

| Field | Guidance |
|-------|----------|
| **Name** | Use a name that's easy to reference in conversations ("What would Sarah think of this?"). Avoid joke names. |
| **Age & Role** | Ground the persona in a realistic demographic. Don't make everyone 28 and a PM. |
| **Goals** | Focus on *outcomes*, not features. "Finish expense reports quickly" not "Use the CSV upload feature." |
| **Pain Points** | Based on real research data, not assumptions. Each should be addressable by design decisions. |
| **Context of Use** | Drives design decisions: mobile-first? offline support? glanceable info? |
| **Technical Literacy** | Determines UI complexity, onboarding needs, error message style, feature discoverability approach. |
| **Devices** | Affects responsive design priorities, touch targets, screen real estate assumptions. |
| **Quote** | Makes the persona feel real. Pull from actual interview quotes when possible. |

---

## Example Persona

### Maria Chen

| Field | Details |
|-------|---------|
| **Name** | Maria Chen |
| **Age** | 34 |
| **Role** | Operations Manager at a mid-size e-commerce company (50 employees) |

#### Goals

1. Get a clear picture of daily order fulfillment status without digging through multiple tools
2. Quickly identify and resolve order issues (stuck payments, shipping delays) before customers complain
3. Generate weekly reports for leadership without manual spreadsheet work

#### Pain Points

1. Currently checks 3 different dashboards (warehouse, payments, shipping) to get a full picture — takes 20+ minutes each morning
2. Finds out about problems reactively (customer complaint) instead of proactively (alert)
3. Weekly report requires manual copy-paste from multiple sources, takes 2 hours, error-prone

#### Context of Use

- **When:** Daily, 8-9 AM for morning review. Checks phone for alerts throughout the day. Generates reports Friday afternoon.
- **Where:** Open-plan office (laptop) and on-the-go (phone for alerts)
- **How:** Laptop with single external monitor. Phone for push notifications and quick status checks.

#### Technical Literacy

**Intermediate**

Comfortable with web apps, dashboards, and filtering data. Can write basic spreadsheet
formulas. Prefers visual data (charts, status badges) over raw numbers. Won't write SQL
or use APIs, but can set up simple integrations if guided.

#### Devices

- Primary: Dell laptop with 24" external monitor (Windows 11, Chrome)
- Secondary: iPhone 14, used for alerts and quick status checks during the day

#### Quote

> "I just want to open one screen in the morning and know if anything needs my attention. I shouldn't have to play detective to find out an order is stuck."
