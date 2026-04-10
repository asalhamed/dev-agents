# Runbook Library

## Video Pipeline Failure
**Symptoms:** No live video feeds, WebRTC connection failures, HLS 404s
**Triage:**
1. Check media server pods: `kubectl get pods -l app=media-server`
2. Check RTSP connectivity to cameras: `ffprobe rtsp://camera-ip:554/stream1`
3. Check TURN server: `turnutils_uclient -t turn.example.com`
**Mitigation:** Restart media server pods. If camera unreachable, check network.
**Escalation:** Video engineer → DevOps → VP Engineering (if >30 min)

## Device Mass Disconnect
**Symptoms:** >10% of devices show offline simultaneously
**Triage:**
1. Check MQTT broker health: `mosquitto_sub -t '$SYS/broker/clients/connected'`
2. Check broker CPU/memory: `kubectl top pods -l app=mqtt-broker`
3. Check recent deployments: `kubectl rollout history`
**Mitigation:** Scale broker if overloaded. Rollback if recent deployment.
**Escalation:** Backend engineer → IoT engineer → VP Engineering

## MQTT Broker Overload
**Symptoms:** High publish latency, connection refusals, CPU >90%
**Triage:**
1. Check message rate: `emqx_ctl metrics | grep received`
2. Check subscription count and retained messages
3. Check for subscription loops or wildcard abuse
**Mitigation:** Scale horizontally (add broker node). Rate limit misbehaving clients.
**Escalation:** IoT engineer → DevOps

## Database Connection Exhaustion
**Symptoms:** 5xx errors, slow queries, "too many connections" in logs
**Triage:**
1. Check active connections: `SELECT count(*) FROM pg_stat_activity`
2. Check for long-running queries: `SELECT * FROM pg_stat_activity WHERE state != 'idle' ORDER BY duration DESC`
3. Check connection pool settings
**Mitigation:** Kill long-running queries. Increase pool size (temporary). Fix query or add index.
**Escalation:** Backend engineer → DBA

## Object Storage Full
**Symptoms:** Recording failures, upload errors, S3 5xx responses
**Triage:**
1. Check bucket size and growth rate
2. Check lifecycle policy is active
3. Check for stuck uploads or orphaned segments
**Mitigation:** Delete expired segments manually. Fix lifecycle policy. Expand storage.
**Escalation:** DevOps → Data engineer

## Edge Node Offline
**Symptoms:** No data from specific site, all devices at site show offline
**Triage:**
1. Check edge node connectivity (ping, SSH)
2. Check edge services: `kubectl get pods` (on edge K3s)
3. Check network uplink (cellular/satellite status)
**Mitigation:** Remote reboot if accessible. Dispatch field team if not. Edge buffer preserves data.
**Escalation:** DevOps → Customer success (notify customer)
