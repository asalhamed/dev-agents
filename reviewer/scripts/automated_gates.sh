#!/usr/bin/env bash
# automated_gates.sh — Run mechanical hard-gate checks before human/agent review
#
# Usage: ./automated_gates.sh <repo-root> [--stack rust|scala3|scala2|typescript]
#
# Checks for violations that are objectively detectable without reading context.
# Exit code 0 = all gates pass, non-zero = at least one gate failed.

set -euo pipefail

REPO="${1:-.}"
STACK="${2:---stack auto}"

if [[ "$STACK" == "--stack" ]]; then
  STACK="${3:-auto}"
fi

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

VIOLATIONS=0
WARNINGS=0

fail() {
  VIOLATIONS=$((VIOLATIONS + 1))
  echo -e " ${RED}✗ BLOCKING${NC}: $1 — $2"
}

warn() {
  WARNINGS=$((WARNINGS + 1))
  echo -e " ${YELLOW}⚠ WARNING${NC}: $1 — $2"
}

pass() {
  echo -e " ${GREEN}✓${NC} $1"
}

detect_stack() {
  if [[ -f "$REPO/Cargo.toml" ]]; then echo "rust"
  elif [[ -f "$REPO/build.sbt" ]]; then
    if grep -q 'scalaVersion.*"3\.' "$REPO/build.sbt" 2>/dev/null; then echo "scala3"
    else echo "scala2"; fi
  elif [[ -f "$REPO/package.json" ]]; then echo "typescript"
  elif [[ -f "$REPO/go.mod" ]]; then echo "go"
  else echo "unknown"; fi
}

if [[ "$STACK" == "auto" ]]; then STACK=$(detect_stack); fi

echo "════════════════════════════════════════════════"
echo " Automated Hard-Gate Checks"
echo " Repo: $REPO"
echo " Stack: $STACK"
echo "════════════════════════════════════════════════"
echo ""

# ── Universal checks ──────────────────────────────────────────────

echo "▸ Secrets scan"
SECRETS_PATTERN='(password|secret|token|api_key|apikey|private_key)\s*[:=]\s*["'"'"'][^"'"'"']{4,}'
if grep -rniE "$SECRETS_PATTERN" "$REPO/src" "$REPO/k8s" "$REPO/deploy" 2>/dev/null | grep -v "test" | grep -v ".md" | head -5; then
  fail "Secrets in source" "Potential hardcoded secrets found — see lines above"
else
  pass "No hardcoded secrets detected"
fi

echo ""
echo "▸ Debug/log statements in production code"
if grep -rnE '(println!|System\.out\.println|console\.log|dbg!)' "$REPO/src" 2>/dev/null \
   | grep -v "test" | grep -v "_test\." | grep -v "spec\." | grep -v "#\[cfg(test)\]" | head -5; then
  fail "Debug statements" "println/console.log/dbg! found in non-test code"
else
  pass "No debug statements in production code"
fi

echo ""
echo "▸ Docker/K8s 'latest' tag"
if grep -rn ':latest' "$REPO/k8s" "$REPO/deploy" "$REPO/Dockerfile"* "$REPO/docker-compose"* 2>/dev/null | head -5; then
  fail "'latest' tag" "Never use :latest in prod manifests — use content hash or git SHA"
else
  pass "No :latest tags found"
fi

# ── Rust-specific checks ─────────────────────────────────────────
if [[ "$STACK" == "rust" ]]; then
  echo ""
  echo "▸ Rust: unwrap()/expect() in non-test code"
  if grep -rn '\.unwrap()' "$REPO/src" 2>/dev/null \
     | grep -v "#\[cfg(test)\]" | grep -v "mod tests" | grep -v "_test\.rs" | head -5; then
    fail ".unwrap() in prod" "Use Result/Option propagation (?) instead"
  else
    pass "No unwrap() in production code"
  fi

  echo ""
  echo "▸ Rust: unsafe blocks without safety comment"
  if grep -rnB1 'unsafe {' "$REPO/src" 2>/dev/null | grep -v "SAFETY" | grep "unsafe {" | head -5; then
    fail "Unsafe without SAFETY" "Every unsafe block needs a // SAFETY: comment"
  else
    pass "All unsafe blocks have SAFETY comments (or none exist)"
  fi

  echo ""
  echo "▸ Rust: panic!/unreachable! in domain code"
  if grep -rn 'panic!\|unreachable!' "$REPO/src/domain" 2>/dev/null | head -5; then
    fail "panic! in domain" "Domain code must be total — use Result<T, E> instead"
  else
    pass "No panics in domain layer"
  fi
fi

# ── Scala-specific checks ────────────────────────────────────────
if [[ "$STACK" == "scala3" || "$STACK" == "scala2" ]]; then
  echo ""
  echo "▸ Scala: var in domain/application layers"
  if grep -rn '\bvar\b' "$REPO/src/main/"*"/domain" "$REPO/src/main/"*"/application" 2>/dev/null | head -5; then
    fail "var in domain/app" "Use val only — no mutable state in domain or application"
  else
    pass "No var in domain/application layers"
  fi

  echo ""
  echo "▸ Scala: null usage"
  if grep -rn '\bnull\b' "$REPO/src/main" 2>/dev/null | grep -v "// null" | head -5; then
    fail "null found" "Use Option/Either — no null anywhere"
  else
    pass "No null usage"
  fi

  echo ""
  echo "▸ Scala: .get on Option"
  if grep -rn '\.get\b' "$REPO/src/main" 2>/dev/null | grep -v "getString\|getInt\|getConfig\|getOrElse" | head -5; then
    warn ".get on Option" "Possible unsafe .get — verify these are not Option.get"
  else
    pass "No unsafe .get calls detected"
  fi

  echo ""
  echo "▸ Scala: throw in domain layer"
  if grep -rn '\bthrow\b' "$REPO/src/main/"*"/domain" 2>/dev/null | head -5; then
    fail "throw in domain" "Use typed error channel (Either/ZIO error) — no exceptions in domain"
  else
    pass "No throw in domain layer"
  fi
fi

# ── TypeScript-specific checks ───────────────────────────────────
if [[ "$STACK" == "typescript" ]]; then
  echo ""
  echo "▸ TypeScript: 'any' type"
  if grep -rn ': any\b\|: any;' "$REPO/src" 2>/dev/null | grep -v "node_modules" | grep -v ".test." | grep -v ".spec." | head -5; then
    fail "'any' type" "No any types — use proper typing"
  else
    pass "No 'any' types in source"
  fi

  echo ""
  echo "▸ TypeScript: console.log in non-test code"
  if grep -rn 'console\.\(log\|warn\|error\|debug\)' "$REPO/src" 2>/dev/null \
     | grep -v ".test." | grep -v ".spec." | grep -v "__tests__" | head -5; then
    fail "console.log in prod" "Remove console statements from production code"
  else
    pass "No console statements in production code"
  fi
fi

# ── Infrastructure checks ────────────────────────────────────────
if [[ -d "$REPO/k8s" || -d "$REPO/deploy" ]]; then
  echo ""
  echo "▸ K8s: resource limits"
  DEPLOYMENTS=$(find "$REPO/k8s" "$REPO/deploy" -name "deployment*.yaml" -o -name "deployment*.yml" 2>/dev/null)
  for f in $DEPLOYMENTS; do
    if ! grep -q 'resources:' "$f" 2>/dev/null; then
      fail "Missing resource limits" "$f has no resources: block"
    fi
    if ! grep -q 'livenessProbe:' "$f" 2>/dev/null; then
      fail "Missing liveness probe" "$f has no livenessProbe"
    fi
    if ! grep -q 'readinessProbe:' "$f" 2>/dev/null; then
      fail "Missing readiness probe" "$f has no readinessProbe"
    fi
  done
  if [[ -z "$DEPLOYMENTS" ]]; then
    pass "No deployment manifests to check"
  else
    pass "K8s manifests checked"
  fi
fi

# ── DDD layer boundary check ─────────────────────────────────────
echo ""
echo "▸ Infrastructure types in domain layer"
INFRA_PATTERNS='(sqlx|diesel|doobie|slick|actix|axum|tokio::net|reqwest|hyper|http::|kafka|rdkafka)'
if [[ -d "$REPO/src/domain" ]] || [[ -d "$REPO/src/main" ]]; then
  DOMAIN_DIR=$(find "$REPO/src" -type d -name "domain" 2>/dev/null | head -1)
  if [[ -n "$DOMAIN_DIR" ]]; then
    if grep -rnE "$INFRA_PATTERNS" "$DOMAIN_DIR" 2>/dev/null | head -5; then
      fail "Infra in domain" "Infrastructure types found in domain layer — must be in infrastructure layer"
    else
      pass "Domain layer is clean of infrastructure imports"
    fi
  fi
fi

# ── Summary ───────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════"
if [[ $VIOLATIONS -gt 0 ]]; then
  echo -e " ${RED}RESULT: $VIOLATIONS BLOCKING issue(s), $WARNINGS warning(s)${NC}"
  echo " Review cannot proceed until blocking issues are fixed."
  exit 1
elif [[ $WARNINGS -gt 0 ]]; then
  echo -e " ${YELLOW}RESULT: 0 blocking, $WARNINGS warning(s)${NC}"
  echo " Manual review can proceed — warnings are non-blocking."
  exit 0
else
  echo -e " ${GREEN}RESULT: All automated gates pass${NC}"
  echo " Ready for manual review."
  exit 0
fi
