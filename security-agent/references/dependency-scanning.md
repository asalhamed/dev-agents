# Dependency Scanning Reference

Tools and processes for detecting vulnerable dependencies across stacks.

---

## Rust

### cargo audit

Checks `Cargo.lock` against the RustSec Advisory Database.

```bash
# Install
cargo install cargo-audit

# Run
cargo audit

# JSON output for CI parsing
cargo audit --json

# Fix automatically where possible
cargo audit fix
```

**Output interpretation:**
- `warning` — advisory exists but may not affect your usage
- `vulnerability` — confirmed security issue, action required
- Each entry shows: advisory ID (RUSTSEC-YYYY-NNNN), affected crate, patched versions

### cargo deny

Broader checks: advisories, licenses, banned crates, duplicate versions.

```bash
# Install
cargo install cargo-deny

# Initialize config
cargo deny init  # Creates deny.toml

# Run all checks
cargo deny check

# Run specific check
cargo deny check advisories
cargo deny check licenses
```

**deny.toml essentials:**

```toml
[advisories]
db-path = "~/.cargo/advisory-db"
vulnerability = "deny"    # Fail on vulnerabilities
unmaintained = "warn"     # Warn on unmaintained crates

[licenses]
allow = ["MIT", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause", "ISC"]
deny = ["GPL-3.0"]

[bans]
deny = [
    { name = "openssl", wrappers = ["native-tls"] },  # Prefer rustls
]
```

### CI Integration (GitHub Actions)

```yaml
- name: Security audit
  run: |
    cargo install cargo-audit
    cargo audit
```

---

## Scala / JVM

### sbt-dependency-check (OWASP)

Uses the OWASP National Vulnerability Database (NVD).

```scala
// project/plugins.sbt
addSbtPlugin("net.vonbuchholtz" % "sbt-dependency-check" % "5.0.0")

// build.sbt
dependencyCheckFailBuildOnCVSS := 7.0  // Fail on High+
dependencyCheckSuppressionFile := "dependency-check-suppressions.xml"
```

```bash
# Run check
sbt dependencyCheck

# Report at: target/scala-2.13/dependency-check-report.html
```

### Snyk (JVM)

```bash
# Authenticate
snyk auth

# Test project
snyk test --all-projects

# Monitor (continuous)
snyk monitor --all-projects
```

---

## Node / TypeScript

### npm audit

```bash
# Run audit
npm audit

# Only show high+ severity
npm audit --audit-level=high

# JSON output
npm audit --json

# Auto-fix (updates within semver range)
npm audit fix

# Force fix (may include breaking changes)
npm audit fix --force
```

**Severity levels:** `info` → `low` → `moderate` → `high` → `critical`

### yarn audit

```bash
# Run audit
yarn audit

# Filter severity
yarn audit --level high

# JSON output
yarn audit --json
```

### Snyk (Node)

```bash
snyk test
snyk monitor  # Continuous monitoring with alerts
```

---

## Go

### govulncheck

Official Go vulnerability scanner — checks if your code actually calls vulnerable functions
(not just whether the dependency is in `go.sum`).

```bash
# Install
go install golang.org/x/vuln/cmd/govulncheck@latest

# Check current module
govulncheck ./...

# JSON output
govulncheck -json ./...

# Check binary
govulncheck -mode=binary my-binary
```

**Why govulncheck is special:** It performs call graph analysis — only reports vulnerabilities
in functions your code actually reaches, reducing false positives.

---

## Handling Findings

### Triage Process

1. **Is the vulnerability reachable?**
   - Does your code actually use the affected function/module?
   - govulncheck (Go) does this automatically; for other stacks, check manually

2. **What's the severity?**
   - CVSS score: Critical (9.0-10.0), High (7.0-8.9), Moderate (4.0-6.9), Low (0.1-3.9)
   - Consider your context — a client-side XSS in a server-only library is low real risk

3. **What's the fix?**

| Action | When |
|--------|------|
| **Upgrade** | Patched version available, no breaking changes. Always preferred. |
| **Pin to safe version** | Can't upgrade yet (breaking changes), but a specific safe version exists. |
| **Exception with justification** | Vulnerability is not reachable in your code, or risk is accepted. Document in suppression file with expiry date. |
| **Replace dependency** | Library is abandoned, no patch coming. Find alternative. |

### Exception Documentation

```xml
<!-- OWASP dependency-check suppression -->
<suppress until="2026-06-01">
  <notes>CVE-2026-XXXX: Only affects XML parsing module which we don't use.
         Reviewed by: @security-lead on 2026-04-01</notes>
  <cve>CVE-2026-XXXX</cve>
</suppress>
```

```toml
# cargo deny
[[advisories.ignore]]
id = "RUSTSEC-2026-0001"
reason = "We don't use the affected TLS feature. Re-evaluate by 2026-06-01."
```

---

## CI Integration Strategy

### Build Gate Policy

| Severity | Action |
|----------|--------|
| **Critical** | ❌ Fail build. Must fix before merge. |
| **High** | ⚠️ Fail build by default. Can be suppressed with documented justification + expiry. |
| **Moderate** | ⚠️ Warning in PR comment. Track in backlog. |
| **Low** | ℹ️ Informational. Batch into periodic dependency updates. |

### GitHub Actions Example

```yaml
name: Security Scan
on: [pull_request]

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Rust
      - name: Cargo audit
        if: hashFiles('Cargo.lock') != ''
        run: |
          cargo install cargo-audit
          cargo audit

      # Node
      - name: npm audit
        if: hashFiles('package-lock.json') != ''
        run: npm audit --audit-level=high

      # Go
      - name: govulncheck
        if: hashFiles('go.sum') != ''
        run: |
          go install golang.org/x/vuln/cmd/govulncheck@latest
          govulncheck ./...
```

### Scheduled Scans

Run dependency scans on a schedule (not just on PRs) to catch newly disclosed
vulnerabilities in already-deployed code:

```yaml
on:
  schedule:
    - cron: '0 6 * * 1'  # Every Monday at 6:00 UTC
```

### Automated Updates

Use Dependabot or Renovate to automatically create PRs for dependency updates:

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "cargo"
    directory: "/"
    schedule:
      interval: "weekly"
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
```
