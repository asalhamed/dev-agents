# Incident Runbook Template

Reference template for operational runbooks. Every alert should have a corresponding
runbook linked in the alert's `runbook_url` annotation.

---

## Template Structure

```markdown
# Runbook: [Alert Name]

## Metadata
- **Severity:** P1 / P2 / P3
- **Service:** [service name]
- **SLO:** [related SLO if applicable]
- **Last Updated:** [date]
- **Author:** [team/person]

## Symptoms
What does this alert look like? What will the on-call engineer observe?
- [Observable symptom 1]
- [Observable symptom 2]
- [Dashboard link]

## Initial Triage (first 5 minutes)
Run these commands in order to understand the situation:
1. `command-1` — what it tells you
2. `command-2` — what it tells you
3. `command-3` — what it tells you
4. `command-4` — what it tells you
5. `command-5` — what it tells you

## Common Causes (by frequency)
Ordered from most likely to least likely:

### Cause 1: [Most common cause]
- **How to confirm:** [diagnostic step]
- **Mitigation:** [fix steps]

### Cause 2: [Second most common]
- **How to confirm:** [diagnostic step]
- **Mitigation:** [fix steps]

### Cause 3: [Less common]
- **How to confirm:** [diagnostic step]
- **Mitigation:** [fix steps]

## Escalation Path
| Condition | Escalate To | Channel |
|-----------|-------------|---------|
| Not resolved in 15 min | [senior engineer] | #incident-response |
| Customer-facing impact | [engineering manager] | #incident-response + page |
| Data loss suspected | [CTO / data team] | phone call |

## Post-Incident Actions
- [ ] Write post-mortem within 48 hours
- [ ] Update this runbook with any new findings
- [ ] Create follow-up tickets for permanent fixes
- [ ] Verify SLO error budget status
```

---

## Completed Example: High Error Rate on Order Service

# Runbook: OrderServiceHighErrorRate

## Metadata
- **Severity:** P1 (page immediately)
- **Service:** order-service
- **SLO:** SLO-001 (Availability 99.9%)
- **Last Updated:** 2024-03-15
- **Author:** order-team

## Symptoms
- Alert `OrderServiceHighBurnRate` is firing
- Error rate on `order-service` exceeds 1% (14.4x burn rate)
- Users may see 500 errors when placing or viewing orders
- Dashboard: https://grafana.internal/d/order-service-overview

## Initial Triage (first 5 minutes)

Run these in order:

```bash
# 1. Check current error rate
curl -s 'http://prometheus:9090/api/v1/query?query=sum(rate(http_requests_total{service="order-service",status=~"5.."}[5m]))/sum(rate(http_requests_total{service="order-service"}[5m]))' | jq '.data.result[0].value[1]'

# 2. Check pod health — are pods running and ready?
kubectl get pods -l app=order-service -n production -o wide

# 3. Check recent logs for error patterns
kubectl logs -l app=order-service -n production --since=10m --tail=100 | grep -i "error\|panic\|fatal" | head -20

# 4. Check if database is reachable and healthy
kubectl exec -it $(kubectl get pod -l app=order-service -n production -o jsonpath='{.items[0].metadata.name}') -n production -- curl -s http://localhost:8080/health/ready

# 5. Check recent deployments (was something just deployed?)
kubectl rollout history deployment/order-service -n production | tail -5
```

## Common Causes (by frequency)

### Cause 1: Bad deployment (most common — ~40% of incidents)

A recent deployment introduced a bug causing 5xx errors.

- **How to confirm:** Check if error rate spike correlates with a recent deployment:
  ```bash
  kubectl rollout history deployment/order-service -n production
  ```
  Compare deployment timestamp with error rate spike on Grafana.

- **Mitigation:**
  1. Roll back to previous version:
     ```bash
     kubectl rollout undo deployment/order-service -n production
     ```
  2. Wait 2-3 minutes for pods to stabilize
  3. Verify error rate is dropping:
     ```bash
     curl -s 'http://prometheus:9090/api/v1/query?query=sum(rate(http_requests_total{service="order-service",status=~"5.."}[2m]))/sum(rate(http_requests_total{service="order-service"}[2m]))' | jq '.data.result[0].value[1]'
     ```
  4. Notify the team in #order-team that deployment was rolled back

### Cause 2: Database connection exhaustion (~30% of incidents)

PostgreSQL connection pool is exhausted, causing timeouts.

- **How to confirm:** Check connection pool metrics:
  ```bash
  curl -s 'http://prometheus:9090/api/v1/query?query=db_connections_active{service="order-service"}' | jq '.data.result[0].value[1]'
  ```
  Also check PostgreSQL directly:
  ```bash
  kubectl exec -it postgres-0 -n production -- psql -U order_service -c "SELECT count(*) FROM pg_stat_activity WHERE datname='orders';"
  ```

- **Mitigation:**
  1. If connections are maxed out, restart pods to release connections:
     ```bash
     kubectl rollout restart deployment/order-service -n production
     ```
  2. If a specific query is holding connections, identify and kill it:
     ```bash
     kubectl exec -it postgres-0 -n production -- psql -U order_service -c "SELECT pid, state, query_start, query FROM pg_stat_activity WHERE datname='orders' AND state='active' ORDER BY query_start LIMIT 10;"
     ```
  3. Consider temporarily increasing max connections if this is a traffic spike

### Cause 3: Upstream dependency failure (~20% of incidents)

A downstream service (payment-service, inventory-service) is failing, causing cascading errors.

- **How to confirm:** Check error rates on dependent services:
  ```bash
  curl -s 'http://prometheus:9090/api/v1/query?query=sum(rate(http_requests_total{status=~"5.."}[5m])) by (service)' | jq '.data.result[]'
  ```

- **Mitigation:**
  1. If payment-service is down: order-service should degrade gracefully (orders can be created but not confirmed)
  2. If inventory-service is down: check if circuit breaker is open:
     ```bash
     kubectl logs -l app=order-service -n production --since=5m | grep "circuit"
     ```
  3. Escalate to the owning team of the failing dependency

### Cause 4: Infrastructure issue (~10% of incidents)

Node failure, network partition, or Kubernetes control plane issue.

- **How to confirm:**
  ```bash
  kubectl get nodes
  kubectl describe node <node-name> | grep -A5 "Conditions"
  ```

- **Mitigation:**
  1. If a node is NotReady, pods will reschedule automatically — wait 5 minutes
  2. If multiple nodes are affected, escalate to infrastructure team immediately

## Escalation Path

| Condition | Escalate To | Channel |
|-----------|-------------|---------|
| Not resolved in 15 minutes | Senior backend engineer (on-call secondary) | #incident-response |
| Customer-facing for > 30 minutes | Engineering Manager | #incident-response + phone |
| Data inconsistency suspected | Data team lead | #incident-response + #data-team |
| Payment flow affected | Payment team on-call | #incident-response + page |

## Post-Incident Actions

- [ ] Write post-mortem within 48 hours (use template in Confluence)
- [ ] Update this runbook if a new cause was discovered
- [ ] Check SLO error budget consumption — if > 50% consumed, flag to product
- [ ] Create follow-up tickets for:
  - [ ] Permanent fix for root cause
  - [ ] Improved monitoring if detection was slow
  - [ ] Circuit breaker tuning if cascading failure
- [ ] Review deployment pipeline if caused by bad deploy (canary? automated rollback?)
