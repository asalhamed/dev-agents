# IoT Fleet Metrics Reference

## Device Availability

### Uptime Percentage

The percentage of time a device is operational and reachable.

**Heartbeat-based calculation:**
```
uptime_pct = (received_heartbeats / expected_heartbeats) × 100
```

- Expected heartbeats: 1 per minute = 1,440 per day
- A device with 1,425 heartbeats in 24h → 98.96% uptime
- Threshold: ≥99% = healthy, 95–99% = degraded, <95% = critical

**Gap-based calculation:**
```
downtime = sum of gaps exceeding threshold (e.g., >5 minutes)
uptime_pct = ((total_period - downtime) / total_period) × 100
```

Use gap-based when heartbeat frequency varies or devices report on events only.

### Connectivity Rate

Percentage of fleet currently online at a point in time.

```
connectivity_rate = (devices_online / total_active_devices) × 100
```

- "Online" = heartbeat received within last 5 minutes
- Track over time to detect fleet-wide outages vs individual failures
- Typical healthy fleet: >98% connectivity rate

### Mean Time Between Failures (MTBF)

Average time a device runs before going offline.

```
MTBF = total_uptime_hours / number_of_failures
```

Track per device model and firmware version to identify hardware/software issues.

## Alert Metrics

### Alert Volume

Total alerts generated per time period.

| Granularity | Use Case |
|-------------|----------|
| Per hour | Real-time ops monitoring |
| Per day | Trend analysis |
| Per week | Executive reporting |

Segment by: severity, alert type, device type, site.

### False Positive Rate

```
false_positive_rate = (false_positive_alerts / total_alerts) × 100
```

- Target: <10% false positive rate
- Track per alert rule to identify noisy rules
- High FP rate → tune thresholds or add hysteresis

### Mean Time to Detect (MTTD)

Time from when an issue occurs to when an alert fires.

```
MTTD = alert_triggered_at - issue_actual_start_time
```

In practice, approximate using:
- Time of last normal telemetry reading before the alert
- `MTTD ≈ alert_triggered_at - last_normal_reading_at`

Target: <5 minutes for critical issues, <15 minutes for warnings.

### Mean Time to Respond (MTTR)

Time from alert firing to acknowledgment or resolution.

```
MTTR = alert_resolved_at - alert_triggered_at
```

Break into sub-metrics:
- **Time to Acknowledge (MTTA):** alert → first human response
- **Time to Resolve (MTTR):** alert → issue resolved

| Severity | MTTA Target | MTTR Target |
|----------|-------------|-------------|
| Critical | <5 min | <1 hour |
| Warning | <30 min | <4 hours |
| Info | <4 hours | <24 hours |

### Alert Escalation Rate

```
escalation_rate = (escalated_alerts / total_alerts) × 100
```

Indicates whether first-responders can handle issues or need to escalate.

## Video Metrics

### Stream Uptime %

Percentage of time a camera's video stream is active and healthy.

```
stream_uptime = (time_streaming / expected_streaming_time) × 100
```

- Expected streaming time depends on schedule (24/7 vs business hours)
- "Healthy" stream = receiving frames, no decode errors, acceptable bitrate
- Target: ≥99.5% for 24/7 cameras

### Recording Coverage %

Percentage of expected recording time that is actually recorded to storage.

```
recording_coverage = (recorded_duration / expected_duration) × 100
```

Gaps caused by: stream interruptions, storage failures, NVR issues, network drops.

Track per camera and aggregate per site.

### Bandwidth Utilization

```
bandwidth_per_camera = avg_bitrate × stream_count (main + sub-streams)
site_bandwidth = sum(bandwidth_per_camera) for all cameras at site
utilization_pct = site_bandwidth / site_bandwidth_capacity × 100
```

| Stream Quality | Typical Bitrate |
|----------------|-----------------|
| 4K main | 8–16 Mbps |
| 1080p main | 4–8 Mbps |
| 720p sub | 1–2 Mbps |
| Thumbnail | 0.1–0.5 Mbps |

Alert when utilization exceeds 80% of capacity.

### Video Quality Score

Composite metric combining:
- Frame rate stability (target: ±2 fps from configured rate)
- Bitrate consistency
- Packet loss rate (<0.1% target)
- I-frame interval regularity

## Business Metrics

### Devices per Customer

```
avg_devices_per_customer = total_active_devices / active_customers
```

Track distribution — a few large customers vs many small ones changes support strategy.

### Sites per Customer

```
avg_sites_per_customer = total_active_sites / active_customers
```

Multi-site customers need cross-site dashboards and aggregated alerting.

### Alerts per Device per Day

```
alerts_per_device_day = total_alerts_in_period / (active_devices × days_in_period)
```

- Healthy: <0.5 alerts/device/day
- Noisy: >2 alerts/device/day → review alert rules
- Compare across device types and firmware versions

### Customer Health Score

Composite metric for account health:

| Factor | Weight | Healthy | At Risk |
|--------|--------|---------|---------|
| Fleet uptime | 30% | >99% | <95% |
| Alert volume trend | 20% | Decreasing | Increasing |
| False positive rate | 15% | <5% | >20% |
| MTTR | 15% | <1h | >4h |
| Support ticket rate | 20% | <1/week | >5/week |

## Dashboard Hierarchy

### Executive (Daily/Weekly)

**Audience:** Leadership, account managers
**Refresh:** Daily or on-demand
**Metrics:**
- Fleet-wide uptime % (daily/weekly trend)
- Total active devices and growth
- Alert volume trend (week over week)
- Customer health scores
- Revenue-impacting incidents
- SLA compliance percentage

### Operational (Hourly)

**Audience:** Operations team, NOC
**Refresh:** Every 5 minutes
**Metrics:**
- Current connectivity rate
- Devices offline right now (with duration)
- Active alerts by severity
- Alert rate (last 1h vs baseline)
- Recent deployments/firmware updates
- Site-level uptime breakdown

### Real-Time (Seconds)

**Audience:** NOC, incident responders
**Refresh:** Every 10–30 seconds
**Metrics:**
- Live connectivity count
- Streaming device heartbeats
- Alert feed (as they fire)
- Video stream status
- Network bandwidth utilization
- Geographic status map with live updates

## Anomaly Indicators

### Sudden Drop in Telemetry Volume

**Signal:** Telemetry ingestion rate drops >20% from baseline within 15 minutes.

**Possible causes:**
- Network outage affecting a site or region
- Ingestion pipeline failure
- Cloud provider incident
- DNS resolution failure

**Detection:**
```sql
-- Compare current hour to same hour yesterday
WITH current_hour AS (
    SELECT count(*) as current_count
    FROM stg_telemetry
    WHERE recorded_at >= date_trunc('hour', now())
),
baseline AS (
    SELECT count(*) / 7.0 as avg_count
    FROM stg_telemetry
    WHERE recorded_at >= now() - interval '7 days'
    AND extract(hour from recorded_at) = extract(hour from now())
)
SELECT
    current_count,
    avg_count as baseline_count,
    (1 - current_count / nullif(avg_count, 0)) * 100 as drop_pct
FROM current_hour, baseline
```

### Spike in Error Rate

**Signal:** Error telemetry or failed commands increase >3× baseline.

**Possible causes:**
- Bad firmware update rolled out
- Backend API degradation
- Certificate expiration
- Time sync drift

**Detection:** Track error_count / total_event_count ratio. Alert when it exceeds 3× the 7-day rolling average.

### Connectivity Cluster Failures

**Signal:** Multiple devices at the same site go offline simultaneously.

**Possible causes:**
- Site-level network outage
- Power failure
- Gateway/router failure
- ISP issue

**Detection:**
```sql
-- Find sites where >30% of devices went offline in last 15 minutes
SELECT
    site_id,
    count(*) as offline_count,
    count(*) * 100.0 / total_devices as offline_pct
FROM dim_devices d
LEFT JOIN (
    SELECT device_id, max(recorded_at) as last_seen
    FROM stg_telemetry
    WHERE metric_name = 'heartbeat'
    GROUP BY 1
) t USING (device_id)
JOIN (
    SELECT site_id, count(*) as total_devices
    FROM dim_devices WHERE is_active GROUP BY 1
) s USING (site_id)
WHERE d.is_active
AND (t.last_seen IS NULL OR t.last_seen < now() - interval '15 minutes')
GROUP BY site_id, total_devices
HAVING count(*) * 100.0 / total_devices > 30
```

### Telemetry Value Drift

**Signal:** Sensor readings gradually drift outside normal range over days/weeks.

**Possible causes:**
- Sensor calibration degradation
- Environmental change
- Hardware aging

**Detection:** Compare 7-day rolling average to 30-day rolling average. Alert when they diverge by >2 standard deviations.

### Firmware-Correlated Failures

**Signal:** Devices on a specific firmware version show higher failure rate.

**Detection:**
```sql
SELECT
    firmware_version,
    count(*) as device_count,
    avg(uptime_pct) as avg_uptime,
    count(*) filter (where uptime_pct < 95) as degraded_count
FROM fct_device_uptime u
JOIN dim_devices d USING (device_id)
WHERE report_date >= current_date - 7
GROUP BY 1
ORDER BY avg_uptime ASC
```
