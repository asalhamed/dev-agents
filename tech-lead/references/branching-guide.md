# Branching Guide for Tech Lead

## Creating a Feature Branch

When a feature-kickoff is approved, create the branch before assigning any tasks:

```bash
# Always branch from main
git checkout main
git pull origin main
git checkout -b feature/F-012-live-video-alerts
git push -u origin feature/F-012-live-video-alerts
```

Include the branch name in every task brief — dev agents commit to this branch.

## Assigning Work on the Branch

In each task brief, specify:
```markdown
### Context
**Branch:** `feature/F-012-live-video-alerts`
**Commit prefix:** `feat(video): ... Refs: F-012, T-003`
```

## Parallel Work: Sub-Branches

If tasks are parallelizable and risk merge conflicts (e.g., backend + android + video all touching shared interfaces), use sub-branches:

```
feature/F-012-live-video-alerts           ← main feature branch
  ├── feature/F-012-live-video-alerts/backend   ← backend-dev commits here
  ├── feature/F-012-live-video-alerts/android   ← android-dev commits here
  └── feature/F-012-live-video-alerts/video     ← video-streaming commits here
```

**Rule:** Sub-branches merge into the feature branch, not main.

When all sub-branch work is done:
```bash
# Merge sub-branches into feature branch
git checkout feature/F-012-live-video-alerts
git merge feature/F-012-live-video-alerts/backend
git merge feature/F-012-live-video-alerts/android
git merge feature/F-012-live-video-alerts/video
```

Then run integration/E2E tests on the merged feature branch before opening the PR to main.

## Merging to Main

When all tasks are complete, reviewer has approved, and product-owner has signed off:

```bash
# Squash merge to keep main history clean
git checkout main
git merge --squash feature/F-012-live-video-alerts
git commit -m "feat: live video feed with motion alerts

Refs: F-012
Tasks: T-001 through T-007
ADR: ADR-015"
git push origin main

# Delete feature branch
git push origin --delete feature/F-012-live-video-alerts
```

Use squash merges to keep main history clean and readable. Each feature = one commit on main.

## Cutting a Release

```bash
# Tag from main when ready for production
git checkout main
git pull origin main
git tag -a v1.2.0 -m "Release v1.2.0

Features: F-012, F-013"
git push origin v1.2.0

# Create release branch for future hotfixes
git checkout -b release/v1.2.0
git push origin release/v1.2.0
```

The release tag triggers the production deploy workflow. The release branch is kept alive for hotfixes.

## Hotfix Flow

```bash
# Branch from main (or from release branch if patching old release)
git checkout -b hotfix/H-001-video-crash main

# Fix, test, commit with hotfix reference
git commit -m "fix(video): handle null frame in decoder

Refs: H-001"

# PR to main
# If the fix also needs to land in a release branch:
git checkout release/v1.2.0
git cherry-pick <commit-sha>
git push origin release/v1.2.0
```

## Branch Status in Feature Kickoff

Update the feature-kickoff status table as work progresses:

| Task ID | Agent | Status | Branch | Notes |
|---------|-------|--------|--------|-------|
| T-001 | backend-dev | ✅ Complete | feature/F-012/backend | Merged to feature branch |
| T-002 | video-streaming | 🔄 In Progress | feature/F-012/video | PR open |
| T-003 | android-dev | ⏳ Not Started | — | Waiting on T-002 |

## Common Mistakes

| Mistake | What happens | Prevention |
|---------|-------------|------------|
| Commit directly to main | Bypasses review + CI gates | Branch protection: no direct push |
| Start on wrong branch | Work gets mixed with another feature | Always check branch before starting |
| Forget branch in task brief | Agent commits to wrong branch | Template: branch is a required field |
| Merge sub-branch directly to main | Skips feature-level integration test | Sub-branches merge to feature, not main |
| Leave feature branch after merge | Stale branches accumulate | Delete feature branch in the squash merge step |
