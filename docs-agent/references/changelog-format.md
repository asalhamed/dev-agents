# Keep a Changelog Format

Reference for maintaining a human-readable changelog following the
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) convention.

---

## Structure

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New features not yet released

## [1.2.0] - 2024-03-15

### Added
- ...

### Fixed
- ...
```

**Rules:**
- `[Unreleased]` is always at the top — accumulates changes until the next release
- Version sections are in reverse chronological order (newest first)
- Each version has a date in `YYYY-MM-DD` format
- Link version numbers to diff URLs at the bottom of the file

---

## Change Types

Use exactly these six categories. Only include categories that have entries.

| Type | When to Use | Example |
|------|------------|---------|
| **Added** | New features or capabilities | "Added notification preferences API" |
| **Changed** | Changes to existing functionality | "Changed pagination from offset to cursor-based" |
| **Deprecated** | Features that will be removed in a future version | "Deprecated `GET /users` offset pagination (use cursor)" |
| **Removed** | Features removed in this version | "Removed legacy XML export endpoint" |
| **Fixed** | Bug fixes | "Fixed order total calculation rounding error" |
| **Security** | Security-related changes, vulnerability fixes | "Fixed SQL injection in order search endpoint" |

---

## Semantic Versioning

Format: `MAJOR.MINOR.PATCH`

| Bump | When | Example |
|------|------|---------|
| **MAJOR** | Breaking changes — API consumers must update their code | Removing an endpoint, changing response schema |
| **MINOR** | New features that are backward-compatible | Adding a new endpoint, adding optional fields |
| **PATCH** | Bug fixes and minor improvements, backward-compatible | Fixing a calculation error, correcting a typo in error messages |

### Decision Flow

1. Did you remove or rename an endpoint/field? → **MAJOR**
2. Did you change the type or meaning of an existing field? → **MAJOR**
3. Did you add a new endpoint or optional field? → **MINOR**
4. Did you fix a bug without changing the API contract? → **PATCH**

---

## What NOT to Include

- Internal refactors that don't change behavior
- Test additions or changes
- CI/CD pipeline changes
- Dependency updates (unless they fix a security issue → Security)
- Documentation-only changes
- Developer tooling changes

**Rule of thumb:** If a consumer of your API/library wouldn't notice the change, it doesn't belong in the changelog.

---

## Breaking Change Format

Breaking changes deserve extra attention:

```markdown
### Changed
- **BREAKING:** Renamed `user_id` field to `customer_id` in Order response.
  Migration: update all consumers to read `customer_id` instead of `user_id`.
```

Always:
1. Mark with **BREAKING:** prefix
2. Explain what changed
3. Provide migration guidance

---

## Example Changelog

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Notification preferences API (GET and PATCH endpoints)
- Pause-all-notifications toggle

## [2.0.0] - 2024-03-15

### Changed
- **BREAKING:** Renamed `user_id` to `customer_id` in Order response schema.
  Migration: update all consumers to read `customer_id`.
- **BREAKING:** Error responses now use RFC 7807 Problem Details format.
  Migration: update error parsing to read `type`, `title`, `status`, `detail` fields.

### Added
- Cursor-based pagination on `GET /orders` (replaces offset pagination)
- `cancelledAt` field on Order response

### Deprecated
- Offset pagination query parameters (`page`, `per_page`) — will be removed in 3.0.0

### Removed
- Legacy XML export endpoint (`GET /orders/export.xml`)

## [1.1.0] - 2024-02-01

### Added
- Order cancellation endpoint (`POST /orders/{id}/cancel`)
- Order status filter on list endpoint (`GET /orders?status=confirmed`)

### Fixed
- Order total calculation now correctly rounds to 2 decimal places
- Fixed race condition in concurrent order confirmation

## [1.0.0] - 2024-01-15

### Added
- Initial release
- Create, read, list orders
- Add items to orders
- Confirm orders
- JWT authentication
- Health check endpoints (`/health/live`, `/health/ready`)

[Unreleased]: https://github.com/example/order-service/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/example/order-service/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/example/order-service/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/example/order-service/releases/tag/v1.0.0
```
