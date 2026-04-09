# Journey Map Template

Visualize a user's end-to-end experience through a specific flow. Captures actions,
thoughts, emotions, pain points, and opportunities at each stage.

---

## Template

### Journey: [Name of the Journey]

**Persona:** [Which persona is taking this journey]
**Scenario:** [Brief description of what they're trying to accomplish]
**Goal:** [The desired end state]

---

| | Stage 1: [Name] | Stage 2: [Name] | Stage 3: [Name] | Stage 4: [Name] | Stage 5: [Name] |
|---|---|---|---|---|---|
| **User Actions** | [What the user does] | [What the user does] | [What the user does] | [What the user does] | [What the user does] |
| **Thoughts** | [Internal monologue] | [Internal monologue] | [Internal monologue] | [Internal monologue] | [Internal monologue] |
| **Emotion** | [😊 😐 😤] | [😊 😐 😤] | [😊 😐 😤] | [😊 😐 😤] | [😊 😐 😤] |
| **Pain Points** | [Friction / frustration] | [Friction / frustration] | [Friction / frustration] | [Friction / frustration] | [Friction / frustration] |
| **Opportunities** | [How we could improve] | [How we could improve] | [How we could improve] | [How we could improve] | [How we could improve] |

---

## Stage Guidance

**Typical stages for a feature interaction:**

1. **Awareness** — User learns the feature exists
2. **Onboarding** — User starts using the feature for the first time
3. **Usage** — Core interaction with the feature
4. **Problem** — Something goes wrong or causes confusion
5. **Resolution** — User resolves the issue (or gives up)

Adapt stages to the specific journey. Not every journey has all five. Some may have
more (e.g., a purchase journey: Browse → Compare → Decide → Purchase → Delivery → Return).

**Emotion scale:**
- 😊 Delighted — exceeds expectations, pleasant surprise
- 🙂 Satisfied — works as expected, no friction
- 😐 Neutral — neither good nor bad
- 😕 Frustrated — friction, confusion, minor annoyance
- 😤 Angry — blocked, broken, considering abandoning

---

## Example Journey Map

### Journey: Updating Notification Preferences

**Persona:** Maria Chen (Operations Manager)
**Scenario:** Maria is getting too many email notifications and wants to switch to push notifications for urgent alerts only, and a daily digest for everything else.
**Goal:** Receive only urgent alerts as push notifications; get a daily summary email for non-urgent items.

---

| | Awareness | Finding Settings | Configuring | Testing | Confirming |
|---|---|---|---|---|---|
| **User Actions** | Receives 15th email notification today. Decides to change settings. | Clicks profile icon → looks for "Settings" → scrolls through settings categories → finds "Notifications" | Sees a long list of notification types (23 items). Tries to figure out which ones are "urgent." Toggles individual items. Looks for "push" vs "email" options. | Changes one setting, waits to see if it worked. Triggers a test order to see what notification arrives. | Checks that push notification arrived. Checks email to see if digest comes tomorrow morning. |
| **Thoughts** | "I can't keep up with all these emails. There must be a way to control this." | "Where are notification settings? Profile? Settings? Preferences? ...Ah, found it." | "Why are there so many options? I just want urgent stuff on my phone and a summary email. Which of these are 'urgent'?" | "Did it save? There was no confirmation. Let me test it..." | "OK, the push came through. I'll check email tomorrow to see if the digest works." |
| **Emotion** | 😤 Frustrated | 😕 Mildly frustrated | 😤 Overwhelmed | 😕 Uncertain | 🙂 Cautiously satisfied |
| **Pain Points** | Too many notifications, no easy way to batch-manage them from the notification itself | Notification settings buried 3 levels deep, no direct link from a notification | 23 individual toggles with no grouping, no "urgent only" preset, no explanation of what each notification type means | No save confirmation, no way to send a test notification, no preview of what the digest looks like | No immediate feedback on digest — has to wait until tomorrow to know if it worked |
| **Opportunities** | Add "Manage notifications" link at the bottom of every email notification | Add a "Notification preferences" shortcut in the main settings nav, not nested under profile | Group notifications by category (Orders, Payments, System). Offer presets: "Urgent only", "Daily digest", "Everything". Add descriptions for each type. | Show save confirmation toast. Add "Send test notification" button. Show digest preview. | Send a confirmation: "Your notification preferences have been updated. You'll receive your first daily digest tomorrow at 9 AM." |

---

## Tips for Creating Journey Maps

1. **Base it on research** — interviews, session recordings, support tickets. Not assumptions.
2. **One persona, one goal** — don't mix multiple users or goals in one map.
3. **Include the emotional journey** — the emotional curve often reveals the biggest opportunities.
4. **Focus on pain points with the highest severity × frequency** — these are your design priorities.
5. **Share with the team** — journey maps are communication tools, not documentation artifacts.
