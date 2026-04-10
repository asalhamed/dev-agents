# IoT Customer Onboarding Playbook

## Pre-Deployment Site Survey
- [ ] Network bandwidth test at each device location
- [ ] Firewall rules: MQTT (8883), HTTPS (443), NTP (123) outbound
- [ ] Power availability at sensor/camera locations
- [ ] WiFi coverage map (or cellular signal strength)
- [ ] Physical mounting points for cameras/sensors
- [ ] Environmental conditions (temperature, moisture, dust)

## Device Provisioning Steps
1. Unbox and register device serial numbers in platform
2. Connect device to provisioning network (WiFi or cellular)
3. Device auto-enrolls (zero-touch) or manual certificate install
4. Assign device to site/zone in platform
5. Verify device appears online in dashboard

## MQTT/Credentials Configuration
- Provision unique certificate per device (never shared credentials)
- Configure MQTT broker URL and port (from platform settings)
- Set telemetry interval (default: 30s, adjust per use case)
- Set alert thresholds (from customer's operating parameters)

## First Data Validation Checklist
- [ ] Device shows "online" in dashboard
- [ ] Telemetry data appearing at expected interval
- [ ] Values are in expected range (not all zeros, not noise)
- [ ] Timestamps are correct (NTP synced)
- [ ] Alert triggers correctly when threshold crossed (test alert)

## Monitoring Setup Verification
- [ ] Dashboard configured with customer's preferred views
- [ ] Alert rules set per customer's requirements
- [ ] Notification channels configured (email, SMS, webhook)
- [ ] Escalation rules defined (who gets P1 vs P2 alerts)

## Customer Training Outline (2 hours)
1. Dashboard navigation (30 min)
2. Alert configuration (30 min)
3. Mobile app setup (15 min)
4. Troubleshooting basics: device offline, connectivity issues (30 min)
5. Q&A and support process (15 min)
