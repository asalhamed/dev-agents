# Glossary — Ubiquitous Language

Single source of truth for domain terms used across all agents.
When agents name types, events, or functions, they use these terms exactly.

---

## General DDD Terms

| Term | Definition | Example |
|------|-----------|---------| 
| **Aggregate** | A cluster of entities and value objects with a single root that enforces invariants. All mutations go through the root. | `Order` is an aggregate root containing `OrderItem` entities |
| **Aggregate Root** | The entry point entity of an aggregate. External code only references the root. | `Order.confirm()` — not `OrderItem.markConfirmed()` |
| **Value Object** | An immutable object defined by its attributes, not by identity. Two VOs with the same data are equal. Self-validating on construction. | `Email`, `Money`, `OrderId` |
| **Domain Event** | An immutable fact about something that happened in the domain. Always past tense. | `OrderPlaced`, `PaymentReceived`, `ItemShipped` |
| **Bounded Context** | A boundary within which a particular domain model applies. The same word can mean different things in different contexts. | "Order" in order-management vs. "Order" in fulfillment |
| **Anti-Corruption Layer (ACL)** | A translation layer that prevents external models from leaking into your domain. | `StripePaymentAdapter` translates Stripe's model to your `Payment` domain |
| **Repository** | An abstraction over persistence. Interface lives in domain layer; implementation in infrastructure. | `trait OrderRepository` (domain) / `PostgresOrderRepository` (infra) |
| **Use Case** | An application-layer service that orchestrates domain objects to fulfill a business scenario. Contains no business logic itself. | `ConfirmOrderUseCase` calls `order.confirm()` then `repo.save()` |

## Naming Conventions

| Category | Convention | Good | Bad |
|----------|-----------|------|-----|
| Domain events | Past tense, noun phrase | `OrderPlaced` | `PlaceOrder`, `OrderPlacing` |
| Commands | Imperative verb phrase | `ConfirmOrder` | `OrderConfirmation` |
| Value objects | Noun, domain language | `Money`, `Email` | `MoneyValue`, `EmailString` |
| Entities | Noun, domain language | `Order`, `Customer` | `OrderEntity`, `CustomerRecord` |
| Repositories | `[Entity]Repository` | `OrderRepository` | `OrderDao`, `OrderStore` |
| Errors | `[Context]Error.[Variant]` | `OrderError.EmptyOrder` | `Exception("empty")` |

## Project-Specific Terms

_Add project-specific domain terms below as they are defined in ADRs._

| Term | Context | Definition | Introduced in |
|------|---------|-----------|--------------| 
| _example:_ Channel | notification | A delivery mechanism: Email, SMS, or Push | ADR-012 |
| _example:_ EventCategory | notification | A class of domain events that trigger notifications | ADR-012 |

---

## Cross-Cutting Terms

| Term | Definition |
|------|-----------|
| **Threat Model** | A structured analysis of potential security threats against a system, using STRIDE or similar framework |
| **Attack Surface** | The sum of all points where an attacker could try to enter or extract data from a system |
| **Trust Boundary** | A point in a system where data crosses from one trust level to another (e.g., from internet to internal network) |
| **User Persona** | A fictional but research-based representation of a user segment with goals, pain points, and behaviors |
| **User Journey** | A step-by-step map of how a user interacts with a product to achieve a goal, including emotional state |
| **Usability Requirement** | A measurable target for how easily users can accomplish tasks |
| **PRD (Product Requirements Document)** | A document that defines what a feature should do, why it matters, and how success is measured |
| **Acceptance Criterion** | A testable condition (Given/When/Then) that must be true for a feature to be considered complete |
| **SLO (Service Level Objective)** | An internal target for service reliability (e.g., 99.9% availability over 28 days) |
| **SLI (Service Level Indicator)** | A metric used to measure service reliability (e.g., successful requests / total requests) |
| **Error Budget** | The allowed downtime or error rate before an SLO is breached (e.g., 43.2 minutes/month for 99.9% SLO) |
| **Bounded Context Map** | A diagram showing bounded contexts and how they relate to each other |

---

## Delivery & Process Terms

| Term | Definition |
|------|-----------|
| **Feature Kickoff** | A contract produced by tech-lead that captures scope, estimation, rollout plan, and pipeline-level Definition of Done for a feature |
| **Acceptance Testing** | Validation of a feature against PRD acceptance criteria (not code quality — that's code review) |
| **Scope Change Request** | Formal request to modify feature scope during implementation; requires product-owner approval |
| **Feature Flag** | A configuration toggle that controls whether a feature is visible to users, enabling gradual rollout without separate deployments |
| **Gradual Rollout** | Deploying code to production but enabling it progressively: internal → beta (5%) → GA (100%) |
| **Retrospective** | Post-delivery review capturing timeline accuracy, blockers, scope changes, and action items for improvement |

## Multi-Repo & Microservice Terms

| Term | Definition |
|------|-----------|
| **Platform Contracts** | A dedicated repository (`platform-contracts`) that is the single source of truth for all inter-service API specs, event schemas, and protocol definitions |
| **Contract-First Development** | Defining the inter-service contract (OpenAPI, Avro, Protobuf) before writing implementation code |
| **Producer Contract Test** | A test in the producing service's CI that verifies the service's actual output matches its declared contract spec |
| **Consumer Contract Test** | A test in the consuming service's CI that verifies the service can handle all valid messages defined in the producer's contract |
| **Service Contract Change** | A formal request to modify a shared contract, requiring compatibility analysis and ordered rollout across all consuming services |
| **Backward Compatibility** | A contract change where existing consumers continue to work without modification (e.g., adding an optional field) |
| **Schema Registry** | A centralized service that stores and validates event schemas, enforcing compatibility rules on schema evolution |
| **Trunk-Based Development** | A branching strategy where `main` is always deployable and feature work happens on short-lived feature branches |
| **Independent Deployability** | The property that a service can be built, tested, and deployed without touching any other service's repository |

---

## IoT, Camera, and Edge Ubiquitous Language

The terms below are reserved across all agents that touch devices, cameras, edge nodes,
or the fleet update plane. Use these names exactly when modeling aggregates, value
objects, and domain events — do not invent parallel vocabulary.

| Term | Definition |
|------|-----------|
| **Device** | A physical unit under our management plane: camera, sensor, gateway, or edge node. Has a unique `DeviceIdentity`. |
| **DeviceIdentity** | The cryptographic identity of a device, bound to hardware at manufacturing (TPM / secure element / fuse). Value object. |
| **DeviceClass** | A group of devices sharing hardware, firmware base, and update policy (e.g., `Camera.DoorbellV2`, `Gateway.IndustrialA`). |
| **EdgeGateway** | A device that aggregates other devices behind it and mediates cloud connectivity. |
| **EdgeNode** | A compute-capable edge unit running containerized workloads (K3s / MicroK8s). Distinct from a plain `Device` — it runs our code, not just firmware. |
| **Telemetry** | A stream of timestamped, typed measurements emitted by a device. Always schema-registered (see `schema-registry.md`). |
| **VideoStream** | A continuous or on-demand sequence of encoded video frames originating from a camera. Identified by `(DeviceId, StreamProfileId)`. |
| **StreamProfile** | A named encoding/protocol configuration (codec, resolution, bitrate, transport). Value object. |
| **StreamMetadata** | Typed side-channel data on a `VideoStream` — CV inference results, motion events, operator annotations. |
| **FirmwareBundle** | An atomic, signed set of firmware artifacts installable on a device class. Identified by `(DeviceClass, Version)`. |
| **Cohort** | An explicitly defined subset of the fleet that receives a firmware rollout as a unit (see `firmware-ota-agent`). |
| **AttestationQuote** | A signed report from a device's hardware root of trust proving what it booted. Consumed by `firmware-ota-agent` and `security-agent`. |
| **Purpose** | The declared, written reason a capture exists. Owned by `privacy-agent`. Every `VideoStream`, biometric event, and derived artifact has one. |
| **ConsentRecord** | The persisted fact that a data subject consented to a specific `Purpose` under a specific notice version. Owned by `privacy-agent`. |
| **RetentionWindow** | The time-bound for which an artifact may be kept for a given `Purpose`. Deletion is automatic at expiry unless a legal hold overrides. |
| **DSAR** | Data-Subject Access Request — a data subject's invocation of access or erasure rights. Has a jurisdictional response deadline. |
| **RedactionPolicy** | The rule set applied to an artifact before export (face blur, plate blur, voice redaction). Value object. |
| **SecurityLevel (SL)** | IEC 62443 target security level (1–4) assigned to a zone or conduit. See `compliance-agent`. |
| **Zone** | IEC 62443 — a group of assets with common security requirements. |
| **Conduit** | IEC 62443 — a communication path between `Zone`s. |
| **SBOM** | Software Bill of Materials (CycloneDX / SPDX). Produced at build time; attached to every shipped artifact. |
| **Provenance** | An in-toto / SLSA attestation describing how an artifact was built. |

### Events (past-tense, domain-level)

| Event | Emitted by | Meaning |
|-------|------------|---------|
| `DeviceProvisioned` | `iot-dev` | A device received its long-term identity and trust anchors. |
| `DeviceAttested` | `iot-dev` + `security-agent` | A device presented a valid attestation quote. |
| `FirmwareBundlePublished` | `firmware-ota-agent` + `supply-chain-security-agent` | A signed `FirmwareBundle` entered the image repo. |
| `RolloutStageAdvanced` | `firmware-ota-agent` | A rollout advanced to the next cohort. |
| `RolloutHalted` | `firmware-ota-agent` | Auto-halt fired due to a health-gate breach. |
| `FirmwareInstalled` | device → `firmware-ota-agent` | A device reports a completed install. |
| `FirmwareRolledBack` | device → `firmware-ota-agent` | A device reverted to the previous slot. |
| `VideoStreamStarted` / `VideoStreamEnded` | `edge-media-agent` | Lifecycle of a `VideoStream`. |
| `StreamMetadataEmitted` | `edge-media-agent` | CV or motion metadata generated. |
| `ConsentGranted` / `ConsentRevoked` | `privacy-agent` | Lifecycle of a `ConsentRecord`. |
| `DSARReceived` / `DSARFulfilled` | `privacy-agent` | Lifecycle of a data-subject request. |
| `ArtifactDeleted` | `privacy-agent` + `data-engineer` | Verifiable deletion of an artifact class for a subject. |

---

_This glossary is maintained by the architect agent. When a new ADR introduces domain terms,
they should be added here under "Project-Specific Terms" or the IoT/Camera section above._
