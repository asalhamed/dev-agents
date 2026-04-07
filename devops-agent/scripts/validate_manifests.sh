#!/usr/bin/env bash
# validate_manifests.sh — Pre-commit validation for K8s manifests, CI pipelines, and Dockerfiles
#
# Usage: ./validate_manifests.sh <repo-root>

set -euo pipefail

REPO="${1:-.}"

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

fail() { ERRORS=$((ERRORS + 1)); echo -e " ${RED}✗${NC} $1"; }
warn() { WARNINGS=$((WARNINGS + 1)); echo -e " ${YELLOW}⚠${NC} $1"; }
pass() { echo -e " ${GREEN}✓${NC} $1"; }

echo "════════════════════════════════════════════════"
echo " DevOps Manifest Validation"
echo " Repo: $REPO"
echo "════════════════════════════════════════════════"
echo ""

# ── Kustomize build ──────────────────────────────────────────────
echo "▸ Kustomize build validation"
OVERLAYS=$(find "$REPO/k8s/overlays" "$REPO/deploy/overlays" -name "kustomization.yaml" 2>/dev/null || true)
if [[ -n "$OVERLAYS" ]]; then
  for overlay_file in $OVERLAYS; do
    overlay_dir=$(dirname "$overlay_file")
    env_name=$(basename "$overlay_dir")
    if command -v kustomize &>/dev/null; then
      if kustomize build "$overlay_dir" > /dev/null 2>&1; then
        pass "kustomize build $env_name"
      else
        fail "kustomize build $env_name FAILED — missing refs or invalid YAML"
      fi
    elif command -v kubectl &>/dev/null; then
      if kubectl kustomize "$overlay_dir" > /dev/null 2>&1; then
        pass "kubectl kustomize $env_name"
      else
        fail "kubectl kustomize $env_name FAILED"
      fi
    else
      warn "Neither kustomize nor kubectl found — skipping build validation"
      break
    fi
  done
else
  pass "No kustomize overlays found (skipping)"
fi

# ── Docker build validation ──────────────────────────────────────
echo ""
echo "▸ Dockerfile checks"
DOCKERFILES=$(find "$REPO" -name "Dockerfile*" -not -path "*/node_modules/*" 2>/dev/null || true)
if [[ -n "$DOCKERFILES" ]]; then
  for df in $DOCKERFILES; do
    if grep -n ':latest' "$df" 2>/dev/null | head -3; then
      fail "$df uses :latest tag — pin to a specific version"
    else
      pass "$df — no :latest tags"
    fi
    if grep -q 'COPY \. \.' "$df" 2>/dev/null; then
      warn "$df copies entire context in one COPY — consider multi-stage for better caching"
    fi
    if ! grep -q 'USER\|runAsNonRoot' "$df" 2>/dev/null; then
      warn "$df — no USER directive (container may run as root)"
    fi
  done
else
  pass "No Dockerfiles found (skipping)"
fi

# ── Secrets scan ─────────────────────────────────────────────────
echo ""
echo "▸ Secrets in manifests"
MANIFEST_DIRS="$REPO/k8s $REPO/deploy $REPO/.github"
SECRETS_FOUND=false
for dir in $MANIFEST_DIRS; do
  if [[ -d "$dir" ]]; then
    if grep -rnliE '(password|secret|token|api_key|private_key)\s*[:=]\s*["'"'"'][a-zA-Z0-9]' "$dir" 2>/dev/null | grep -v "secretKeyRef\|ExternalSecret\|SealedSecret\|valueFrom" | head -5; then
      fail "Potential plaintext secrets in $dir"
      SECRETS_FOUND=true
    fi
  fi
done
if [[ "$SECRETS_FOUND" == "false" ]]; then
  pass "No plaintext secrets in manifests"
fi

# ── K8s manifest completeness ────────────────────────────────────
echo ""
echo "▸ K8s deployment completeness"
DEPLOYMENTS=$(find "$REPO/k8s" "$REPO/deploy" -name "deployment*.yaml" -o -name "deployment*.yml" 2>/dev/null || true)
for dep in $DEPLOYMENTS; do
  name=$(basename "$dep")
  if ! grep -q 'resources:' "$dep"; then fail "$name — missing resources: block"
  elif ! grep -q 'limits:' "$dep"; then fail "$name — has requests but missing limits"
  else pass "$name — resource limits present"; fi
  if ! grep -q 'livenessProbe:' "$dep"; then fail "$name — missing livenessProbe"
  else pass "$name — livenessProbe present"; fi
  if ! grep -q 'readinessProbe:' "$dep"; then fail "$name — missing readinessProbe"
  else pass "$name — readinessProbe present"; fi
  if ! grep -q 'securityContext:' "$dep"; then warn "$name — missing securityContext"
  else pass "$name — securityContext present"; fi
  if grep -q ':latest' "$dep" 2>/dev/null; then fail "$name — uses :latest tag"; fi
done
if [[ -z "$DEPLOYMENTS" ]]; then pass "No deployment manifests found (skipping)"; fi

# ── GitHub Actions lint ──────────────────────────────────────────
echo ""
echo "▸ CI pipeline validation"
WORKFLOWS=$(find "$REPO/.github/workflows" -name "*.yml" -o -name "*.yaml" 2>/dev/null || true)
if [[ -n "$WORKFLOWS" ]]; then
  if command -v actionlint &>/dev/null; then
    if actionlint "$REPO/.github/workflows/"* 2>&1 | head -10; then pass "actionlint passed"
    else warn "actionlint reported issues (see above)"; fi
  else
    warn "actionlint not installed — skipping CI lint"
  fi
  for wf in $WORKFLOWS; do
    if grep -n 'password:\|token:\|secret:' "$wf" 2>/dev/null | grep -v '\${{' | grep -v '#' | head -3; then
      fail "$(basename "$wf") — hardcoded credentials (use \${{ secrets.* }})"
    fi
  done
else
  pass "No GitHub Actions workflows found (skipping)"
fi

# ── Summary ───────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════"
if [[ $ERRORS -gt 0 ]]; then
  echo -e " ${RED}RESULT: $ERRORS error(s), $WARNINGS warning(s)${NC}"
  exit 1
elif [[ $WARNINGS -gt 0 ]]; then
  echo -e " ${YELLOW}RESULT: 0 errors, $WARNINGS warning(s)${NC}"
  exit 0
else
  echo -e " ${GREEN}RESULT: All checks pass${NC}"
  exit 0
fi
