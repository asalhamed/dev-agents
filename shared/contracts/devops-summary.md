# Contract: devops-agent → reviewer

**Producer:** devops-agent  
**Consumer:** reviewer  
**Trigger:** devops-agent completes an infrastructure or pipeline change

---

## Required Fields

```markdown
## DEVOPS SUMMARY

### Task Reference
**Task ID:** [T-NNN]
**Agent:** devops-agent
**Task:** [copy from task brief]
**Change type:** CI pipeline | K8s manifest | Docker | Config | Secrets wiring

### Blast Radius
**Scope:** Pod | Service | Namespace | Cluster
**Environments affected:** dev | staging | prod | all
**Additive or breaking:** Additive (safe to merge anytime) | Breaking (requires deploy window)

### Rollback Plan
<!-- REQUIRED: Exact steps to revert. "revert the commit" is not sufficient. -->
[step-by-step rollback procedure]

### Files Changed
| File | Change |
|------|--------|
| `path/to/file` | [what changed and why] |

### Validation Performed
<!-- REQUIRED: Check all that apply -->
- [ ] `kubectl apply --dry-run=server` passed
- [ ] `kustomize build overlays/prod` produces valid YAML
- [ ] Pipeline YAML linted (actionlint / gitlab-ci-lint)
- [ ] Docker build succeeded locally
- [ ] No plaintext secrets in diff (scanned with `git diff | grep -iE 'password|secret|token|key'`)
- [ ] Resource limits present on all new/modified containers
- [ ] Liveness and readiness probes present on all new/modified containers
- [ ] No `latest` image tag in any manifest

### Security Checklist
- [ ] No secrets in repo (all via external-secrets / vault / sealed-secrets)
- [ ] Container runs as non-root (runAsNonRoot: true)
- [ ] readOnlyRootFilesystem: true (where possible)
- [ ] allowPrivilegeEscalation: false
- [ ] NetworkPolicy: deny-all default with explicit allows (if cluster policy requires it)

### Notes for Reviewer
[Anything to watch for in staging/prod — timing, dependencies, order of operations]

### Escalations Required
[none | escalate to architect: [reason] | requires human approval: [reason]]
```

---

## Validation (reviewer must check on receipt)

- [ ] Blast radius and rollback plan are both present and specific
- [ ] Validation checklist is filled in (not all blank)
- [ ] Security checklist is filled in
- [ ] No `latest` tag (hard gate)
- [ ] No secrets in diff (hard gate)

**If any required field is missing or a hard gate fails:** reject immediately.
