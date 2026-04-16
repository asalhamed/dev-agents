# ONVIF — Camera Interoperability

**Scope:** How the edge-media-agent discovers, authenticates, streams from, and subscribes
to events on ONVIF-compliant IP cameras. ONVIF is the de-facto interop standard; treat
vendor-specific APIs as fallback only.

## Why ONVIF
Without ONVIF, each camera vendor needs a custom integration. With ONVIF:
- One discovery mechanism (WS-Discovery on the LAN)
- One auth model (WS-Security UsernameToken / HTTP Digest)
- One metadata + streaming negotiation flow
- Portable PTZ and event handling across vendors

## Profiles (TODO — fill in Phase 3)
- **Profile S** — streaming (RTSP URIs, PTZ, events). Minimum for live viewing.
- **Profile T** — advanced streaming (H.265, analytics metadata, bidirectional audio).
- **Profile G** — recording and playback.
- **Profile M** — metadata and analytics (object detection events).

For each profile, document: required services, typical SOAP operations, how this agent
uses it.

## Discovery (TODO — fill in Phase 3)
WS-Discovery multicast (`239.255.255.250:3702`). Probe + ProbeMatch handshake. Fallback
to manual IP + credentials when multicast is disabled on the VLAN.

## Authentication (TODO — fill in Phase 3)
WS-Security UsernameToken (digest) for SOAP. HTTP Digest for RTSP. Always prefer TLS
(`https://` for device service endpoints, `rtsps://` where supported).

## Streaming negotiation (TODO — fill in Phase 3)
`GetProfiles` → pick profile → `GetStreamUri` → `rtsp://…`. Reuse the pipeline from
`streaming-protocols.md`.

## Events (TODO — fill in Phase 3)
PullPoint subscription for polling-friendly deployments; Basic Notification for push.
Map ONVIF events to internal domain events (see `shared/glossary.md`).

## PTZ (TODO — fill in Phase 3)
`GetPresets`, `GotoPreset`, `ContinuousMove`. Rate-limit PTZ commands; never expose raw
PTZ to untrusted clients.

## Security notes (TODO — fill in Phase 3)
- Many cameras ship with default credentials — rotate at provisioning time (coordinate
  with `iot-dev`)
- ONVIF services are often unauthenticated until a user is created — never expose to
  public networks
- Device firmware updates are typically vendor-specific, not ONVIF — see
  `firmware-ota-agent`

## See also
- `streaming-protocols.md` — transport selection
- `../../iot-dev/SKILL.md` — device provisioning
- `../../firmware-ota-agent/SKILL.md` — camera firmware updates
