# Device Provisioning & Identity

## Certificate-Based Authentication (X.509)

Each device gets a unique X.509 client certificate. No shared secrets across a fleet.

```
Root CA (offline, air-gapped)
  └── Intermediate CA (per environment: staging, production)
       └── Device Certificate (per device, CN = device_id)
```

### Certificate Contents
- **CN (Common Name):** device ID (`th100-a1b2c3`)
- **SAN (Subject Alternative Name):** device ID, organization
- **Validity:** 2 years (with rotation before expiry)
- **Key size:** EC P-256 (smaller, faster than RSA on embedded)

## Device Identity Lifecycle

```
Manufacturing → Provisioning → Deployment → Active → Rotation → Retirement
```

1. **Manufacturing:** Generate key pair on device. CSR sent to provisioning service.
2. **Provisioning:** CA signs certificate. Device receives cert + intermediate CA.
3. **Deployment:** Device connects to MQTT broker using mTLS. Broker validates cert chain.
4. **Active:** Normal operation. Certificate monitored for expiry.
5. **Rotation:** 30 days before expiry, device requests new certificate via provisioning API.
6. **Retirement:** Certificate revoked via CRL or OCSP. Device decommissioned.

## Zero-Touch Provisioning

```
Device boots → connects to provisioning endpoint (bootstrap cert) →
  sends CSR + hardware attestation →
  receives production certificate + MQTT config →
  connects to production broker
```

Bootstrap certificate: short-lived (24h), limited permissions (can only reach provisioning API).

## Credential Rotation

```
1. Device generates new key pair
2. Device sends CSR to provisioning service (authenticated with current cert)
3. Service validates identity, signs new cert
4. Device receives new cert, tests connection
5. If successful: stores new cert, deletes old
6. If failed: keeps old cert, retries next cycle
```

## Fleet Management

- **Device registry:** central database mapping device_id → cert fingerprint, site, type, firmware version
- **Grouping:** by site, device type, firmware version (for targeted OTA)
- **Health monitoring:** track last-seen timestamp, cert expiry date, firmware version

## Security Rules

- Private keys never leave the device (generate on-device, not in cloud)
- No shared secrets or API keys across devices
- Certificate pinning for broker connection
- Revocation list checked by broker on every connection
