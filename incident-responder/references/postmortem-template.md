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
