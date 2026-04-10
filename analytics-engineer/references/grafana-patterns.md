# Grafana Patterns for IoT/Monitoring Dashboards

## Dashboard Organization

Use a three-level hierarchy:

1. **Fleet Overview** — All devices, all sites, key aggregate metrics
2. **Site/Group Drill-Down** — Devices at a specific site, filtered by type
3. **Single Device** — Full detail for one device: telemetry, alerts, logs

Link dashboards with data links so users can click from overview → drill-down → device.

### Folder Structure

```
IoT Platform/
├── Fleet Overview
├── Site Drill-Down
├── Device Detail
├── Alert Dashboard
├── Video Streams
└── Executive Summary
```

## Panel Types

### Time-Series (Sensor Data)

Best for: temperature, humidity, CPU usage, bandwidth — any metric over time.

```json
{
  "type": "timeseries",
  "title": "Temperature - Last 24h",
  "fieldConfig": {
    "defaults": {
      "unit": "celsius",
      "thresholds": {
        "mode": "absolute",
        "steps": [
          { "color": "blue", "value": null },
          { "color": "green", "value": 15 },
          { "color": "yellow", "value": 35 },
          { "color": "red", "value": 45 }
        ]
      }
    }
  },
  "options": {
    "tooltip": { "mode": "multi" },
    "legend": { "displayMode": "table", "placement": "bottom" }
  }
}
```

**Query (Prometheus):**
```promql
avg by (device_id) (
  iot_sensor_temperature_celsius{site_id="$site"}
)
```

**Query (InfluxDB Flux):**
```flux
from(bucket: "iot")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r._measurement == "telemetry")
  |> filter(fn: (r) => r._field == "temperature")
  |> filter(fn: (r) => r.site_id == "${site}")
  |> aggregateWindow(every: 5m, fn: mean)
```

### Stat Panel (Uptime %)

Best for: single big number KPIs — uptime, device count, alert count.

```json
{
  "type": "stat",
  "title": "Fleet Uptime",
  "fieldConfig": {
    "defaults": {
      "unit": "percent",
      "thresholds": {
        "mode": "absolute",
        "steps": [
          { "color": "red", "value": null },
          { "color": "yellow", "value": 95 },
          { "color": "green", "value": 99 }
        ]
      },
      "decimals": 2
    }
  },
  "options": {
    "graphMode": "area",
    "textMode": "value_and_name"
  }
}
```

### Table (Fleet List)

Best for: device inventory, alert lists, firmware versions.

```json
{
  "type": "table",
  "title": "Device Fleet",
  "fieldConfig": {
    "overrides": [
      {
        "matcher": { "id": "byName", "options": "uptime_pct" },
        "properties": [
          { "id": "unit", "value": "percent" },
          {
            "id": "thresholds",
            "value": {
              "mode": "absolute",
              "steps": [
                { "color": "red", "value": null },
                { "color": "yellow", "value": 95 },
                { "color": "green", "value": 99 }
              ]
            }
          },
          { "id": "custom.displayMode", "value": "color-background" }
        ]
      },
      {
        "matcher": { "id": "byName", "options": "device_name" },
        "properties": [
          {
            "id": "links",
            "value": [{
              "title": "Device Detail",
              "url": "/d/device-detail?var-device_id=${__data.fields.device_id}"
            }]
          }
        ]
      }
    ]
  }
}
```

### Geomap (Device Locations)

Best for: geographic distribution, regional outage visualization.

```json
{
  "type": "geomap",
  "title": "Device Locations",
  "options": {
    "view": { "id": "fit" },
    "layers": [
      {
        "type": "markers",
        "config": {
          "style": {
            "size": { "fixed": 8 },
            "color": { "field": "uptime_pct", "fixed": "green" },
            "symbol": { "fixed": "circle" }
          }
        }
      }
    ]
  }
}
```

### Alert List

Best for: showing active/recent alerts inline on dashboards.

```json
{
  "type": "alertlist",
  "title": "Active Alerts",
  "options": {
    "showOptions": "current",
    "maxItems": 20,
    "sortOrder": 1,
    "stateFilter": {
      "firing": true,
      "pending": true,
      "noData": true,
      "normal": false
    }
  }
}
```

## Variables

Define at the dashboard level for interactive filtering.

### Device Selector

```json
{
  "name": "device_id",
  "label": "Device",
  "type": "query",
  "query": "SELECT device_id AS __value, device_name AS __text FROM dim_devices WHERE is_active ORDER BY device_name",
  "multi": true,
  "includeAll": true,
  "refresh": 2
}
```

### Site Selector

```json
{
  "name": "site",
  "label": "Site",
  "type": "query",
  "query": "SELECT DISTINCT site_id AS __value, site_name AS __text FROM dim_sites ORDER BY site_name",
  "multi": false,
  "includeAll": true,
  "refresh": 1
}
```

### Device Type Filter

```json
{
  "name": "device_type",
  "label": "Type",
  "type": "custom",
  "query": "camera,sensor,gateway,controller",
  "multi": true,
  "includeAll": true
}
```

### Chained Variables

Make device selector depend on site:

```sql
-- device_id query, filtered by $site
SELECT device_id AS __value, device_name AS __text
FROM dim_devices
WHERE site_id IN ($site) AND is_active
ORDER BY device_name
```

## Alerting

### Threshold Alerts

Simple boundary checks — the most common for IoT.

```yaml
# Grafana alert rule (conceptual)
- alert: DeviceOffline
  condition: uptime_pct < 50
  for: 10m
  labels:
    severity: critical
  annotations:
    summary: "Device {{ $labels.device_id }} uptime dropped below 50%"

- alert: HighTemperature
  condition: avg(temperature) > 45
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Temperature above 45°C on {{ $labels.device_id }}"
```

### Anomaly Alerts

Detect deviations from normal patterns — harder but catches novel issues.

**Approach:** Compare current value to rolling average ± N standard deviations.

```promql
# Alert when current telemetry deviates >3 stddev from 24h average
abs(
  iot_sensor_temperature_celsius
  - avg_over_time(iot_sensor_temperature_celsius[24h])
) > 3 * stddev_over_time(iot_sensor_temperature_celsius[24h])
```

### Notification Channels

| Channel | Use Case |
|---------|----------|
| Slack/Teams | Team-wide alerts, non-critical warnings |
| PagerDuty/OpsGenie | Critical on-call alerts, device outages |
| Email | Daily/weekly alert digests |
| Webhook | Integration with ticketing (Jira, ServiceNow) |

**Routing by severity:**
- `critical` → PagerDuty + Slack `#incidents`
- `warning` → Slack `#alerts`
- `info` → Email digest only

## IoT-Specific Dashboard Patterns

### Device Status Panel

A table showing each device with color-coded status:

| Device | Type | Site | Status | Uptime (24h) | Last Seen |
|--------|------|------|--------|---------------|-----------|
| cam-001 | camera | HQ | 🟢 Online | 99.8% | 2s ago |
| sensor-042 | sensor | Warehouse | 🟡 Degraded | 87.3% | 3m ago |
| gw-007 | gateway | Remote-A | 🔴 Offline | 12.1% | 4h ago |

**Status logic:**
- 🟢 Online: last heartbeat < 5 minutes ago
- 🟡 Degraded: last heartbeat 5–30 minutes ago OR uptime < 95%
- 🔴 Offline: last heartbeat > 30 minutes ago

### Connectivity Rate Panel

Time-series showing percentage of fleet online over time:

```promql
# Fleet connectivity rate
count(up{job="iot_devices"} == 1) / count(up{job="iot_devices"}) * 100
```

Display as a time-series with:
- Green fill above 98%
- Yellow fill 95–98%
- Red fill below 95%

### Alert Heatmap

Show alert density by hour-of-day and day-of-week to identify patterns:

```json
{
  "type": "heatmap",
  "title": "Alert Heatmap (Hour × Day)",
  "options": {
    "color": {
      "scheme": "Oranges",
      "mode": "scheme"
    },
    "yAxis": {
      "unit": "short"
    }
  }
}
```

**Query (SQL):**
```sql
SELECT
  extract(dow from triggered_at) as day_of_week,
  extract(hour from triggered_at) as hour_of_day,
  count(*) as alert_count
FROM fct_alerts
WHERE triggered_at >= now() - interval '30 days'
GROUP BY 1, 2
```

### Firmware Distribution

Pie or bar chart showing firmware versions across the fleet:

```sql
SELECT firmware_version, count(*) as device_count
FROM dim_devices
WHERE is_active
GROUP BY 1
ORDER BY 2 DESC
```

## Data Sources

### Prometheus

Best for: real-time metrics, alerting, short-term storage (15–30 days).

```yaml
# datasource provisioning
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    url: http://prometheus:9090
    access: proxy
    isDefault: true
```

**IoT usage:** Device exporters push metrics → Prometheus scrapes → Grafana queries.

### InfluxDB

Best for: time-series telemetry with long retention, high cardinality device tags.

```yaml
datasources:
  - name: InfluxDB
    type: influxdb
    url: http://influxdb:8086
    access: proxy
    jsonData:
      version: Flux
      organization: iot-platform
      defaultBucket: telemetry
    secureJsonData:
      token: $INFLUX_TOKEN
```

**IoT usage:** Ingest telemetry via line protocol, tag by device_id/site_id, downsample with tasks.

### TimescaleDB

Best for: SQL-native time-series, complex joins with relational data (devices, customers).

```yaml
datasources:
  - name: TimescaleDB
    type: postgres
    url: timescaledb:5432
    database: iot
    user: grafana_reader
    jsonData:
      sslmode: require
      timescaledb: true
    secureJsonData:
      password: $TSDB_PASSWORD
```

**IoT usage:** Hypertables for telemetry, continuous aggregates for hourly/daily rollups, standard SQL joins with dimension tables.

### ClickHouse

Best for: high-volume analytics, log analysis, columnar queries over billions of rows.

```yaml
datasources:
  - name: ClickHouse
    type: grafana-clickhouse-datasource
    url: http://clickhouse:8123
    jsonData:
      defaultDatabase: iot
    secureJsonData:
      password: $CH_PASSWORD
```

**IoT usage:** MergeTree tables partitioned by date, materialized views for pre-aggregation, excellent for alert log analysis and fleet-wide queries.

## Dashboard Best Practices

1. **Consistent time ranges** — Default to 24h for operational, 7d for trends
2. **Auto-refresh** — 30s for real-time, 5m for operational, off for reports
3. **Annotations** — Mark deployments, firmware updates, known outages
4. **Row repeats** — Use variable + row repeat to show per-site or per-type sections
5. **Dashboard links** — Cross-link overview ↔ drill-down ↔ detail
6. **Permissions** — Viewer for operations, Editor for platform team, Admin restricted
