# Eval: devops-agent — 002 — Rollback Plan Required

**Tags:** rollback, deployment safety, change management
**Skill version tested:** initial

---

## Input (task brief)

The devops-agent receives this task:

**Agent:** devops-agent
**Task ID:** T-010
**Task:** Update order-service Deployment to increase memory limit from 512Mi to 1Gi and add a new environment variable ORDER_BATCH_SIZE=100
**Stack:** K8s / Kustomize

Context: The order-service has been OOMKilling under peak load. The team wants to increase the memory limit and add a batch size config to reduce per-request memory usage. Current deployment is in k8s/base/deployment.yaml.

Definition of Done:
- Memory limit updated to 1Gi in base deployment
- ORDER_BATCH_SIZE added to ConfigMap
- Rollback plan documented
- Dry-run passes
- No secrets in diff

---

## Expected Behavior

The devops-agent should:
1. Update the deployment resource limits
2. Add ORDER_BATCH_SIZE to ConfigMap (not hardcoded in deployment)
3. Document a specific rollback plan BEFORE making changes
4. Run dry-run validation
5. Produce a valid `devops-summary` contract

---

## Pass Criteria

- [ ] Memory limit changed from 512Mi to 1Gi
- [ ] ORDER_BATCH_SIZE in ConfigMap, referenced via `configMapKeyRef` in deployment
- [ ] Rollback plan is specific: "revert deployment.yaml to previous memory limit, remove ORDER_BATCH_SIZE from configmap"
- [ ] Rollback plan is NOT just "kubectl rollout undo" — it addresses the ConfigMap change too
- [ ] `kustomize build` or `kubectl apply --dry-run=server` would pass
- [ ] Blast radius identified as "single service"
- [ ] Change marked as "additive" (safe to merge without deploy window)
- [ ] `devops-summary` contract produced with all required fields

---

## Fail Criteria

- No rollback plan documented → violates "rollback is not optional"
- ORDER_BATCH_SIZE hardcoded as env literal in deployment → should be in ConfigMap
- Rollback plan is only "kubectl rollout undo" without addressing ConfigMap → incomplete rollback
- Missing dry-run validation → skipped safety check
- Missing `devops-summary` contract → contract violation
