# dbt Patterns for IoT/Monitoring Analytics

## Project Structure

```
models/
├── staging/          # 1-to-1 with source tables
│   ├── stg_devices.sql
│   ├── stg_telemetry.sql
│   ├── stg_alerts.sql
│   └── stg_video_streams.sql
├── intermediate/     # Business logic, joins, aggregations
│   ├── int_device_daily_uptime.sql
│   ├── int_alert_enriched.sql
│   └── int_telemetry_hourly.sql
├── marts/            # Final tables for dashboards
│   ├── dim_devices.sql
│   ├── dim_sites.sql
│   ├── fct_device_uptime.sql
│   ├── fct_alerts.sql
│   └── fct_telemetry_summary.sql
├── sources.yml
└── schema.yml
```

## Staging Models

One model per source table. Minimal transformation: rename columns, cast types, filter soft-deletes.

```sql
-- models/staging/stg_devices.sql
with source as (
    select * from {{ source('iot', 'raw_devices') }}
),

renamed as (
    select
        device_id::varchar        as device_id,
        device_name               as device_name,
        device_type               as device_type,
        site_id::varchar          as site_id,
        customer_id::varchar      as customer_id,
        firmware_version          as firmware_version,
        installed_at::timestamp   as installed_at,
        is_active::boolean        as is_active,
        _loaded_at::timestamp     as loaded_at
    from source
    where not _is_deleted
)

select * from renamed
```

```sql
-- models/staging/stg_telemetry.sql
with source as (
    select * from {{ source('iot', 'raw_telemetry') }}
),

renamed as (
    select
        event_id::varchar         as telemetry_id,
        device_id::varchar        as device_id,
        metric_name               as metric_name,
        metric_value::float       as metric_value,
        recorded_at::timestamp    as recorded_at,
        _loaded_at::timestamp     as loaded_at
    from source
)

select * from renamed
```

```sql
-- models/staging/stg_alerts.sql
with source as (
    select * from {{ source('iot', 'raw_alerts') }}
),

renamed as (
    select
        alert_id::varchar         as alert_id,
        device_id::varchar        as device_id,
        alert_type                as alert_type,
        severity                  as severity,
        triggered_at::timestamp   as triggered_at,
        resolved_at::timestamp    as resolved_at,
        acknowledged_by           as acknowledged_by,
        is_false_positive::boolean as is_false_positive
    from source
)

select * from renamed
```

## Intermediate Models

Business logic lives here. Joins across staging models, time-based aggregations, derived metrics.

```sql
-- models/intermediate/int_device_daily_uptime.sql
-- Calculate daily uptime per device from heartbeat telemetry
with heartbeats as (
    select
        device_id,
        date_trunc('day', recorded_at) as report_date,
        count(*) as heartbeat_count,
        min(recorded_at) as first_seen,
        max(recorded_at) as last_seen
    from {{ ref('stg_telemetry') }}
    where metric_name = 'heartbeat'
    group by 1, 2
),

expected as (
    -- Assume heartbeat every 60 seconds = 1440 per day
    select 1440 as expected_heartbeats_per_day
)

select
    h.device_id,
    h.report_date,
    h.heartbeat_count,
    e.expected_heartbeats_per_day,
    round(
        h.heartbeat_count::float / e.expected_heartbeats_per_day * 100, 2
    ) as uptime_pct,
    h.first_seen,
    h.last_seen
from heartbeats h
cross join expected e
```

```sql
-- models/intermediate/int_telemetry_hourly.sql
-- Hourly rollups of sensor data with rolling averages
with hourly as (
    select
        device_id,
        metric_name,
        date_trunc('hour', recorded_at) as hour,
        avg(metric_value) as avg_value,
        min(metric_value) as min_value,
        max(metric_value) as max_value,
        count(*) as sample_count
    from {{ ref('stg_telemetry') }}
    where metric_name != 'heartbeat'
    group by 1, 2, 3
)

select
    *,
    avg(avg_value) over (
        partition by device_id, metric_name
        order by hour
        rows between 23 preceding and current row
    ) as rolling_24h_avg
from hourly
```

```sql
-- models/intermediate/int_alert_enriched.sql
-- Enrich alerts with device and site context
select
    a.alert_id,
    a.device_id,
    d.device_name,
    d.device_type,
    d.site_id,
    a.alert_type,
    a.severity,
    a.triggered_at,
    a.resolved_at,
    a.is_false_positive,
    extract(epoch from (a.resolved_at - a.triggered_at)) / 60.0
        as resolution_minutes
from {{ ref('stg_alerts') }} a
left join {{ ref('stg_devices') }} d using (device_id)
```

## Mart Models

Final dimensional and fact tables consumed by dashboards.

```sql
-- models/marts/dim_devices.sql
select
    d.device_id,
    d.device_name,
    d.device_type,
    d.site_id,
    d.customer_id,
    d.firmware_version,
    d.installed_at,
    d.is_active,
    latest_uptime.uptime_pct as latest_uptime_pct,
    latest_uptime.report_date as latest_uptime_date
from {{ ref('stg_devices') }} d
left join lateral (
    select uptime_pct, report_date
    from {{ ref('int_device_daily_uptime') }}
    where device_id = d.device_id
    order by report_date desc
    limit 1
) latest_uptime on true
```

```sql
-- models/marts/fct_device_uptime.sql
-- Daily uptime facts for fleet dashboards
select
    u.device_id,
    d.device_name,
    d.device_type,
    d.site_id,
    d.customer_id,
    u.report_date,
    u.uptime_pct,
    u.heartbeat_count,
    u.first_seen,
    u.last_seen
from {{ ref('int_device_daily_uptime') }} u
join {{ ref('stg_devices') }} d using (device_id)
```

```sql
-- models/marts/fct_alerts.sql
select
    alert_id,
    device_id,
    device_name,
    device_type,
    site_id,
    alert_type,
    severity,
    triggered_at,
    resolved_at,
    is_false_positive,
    resolution_minutes,
    date_trunc('day', triggered_at) as alert_date
from {{ ref('int_alert_enriched') }}
```

## Incremental Models

For time-series IoT data, use incremental materialization to avoid reprocessing history.

```sql
-- models/marts/fct_telemetry_summary.sql
{{
    config(
        materialized='incremental',
        unique_key=['device_id', 'metric_name', 'hour'],
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    )
}}

select
    device_id,
    metric_name,
    hour,
    avg_value,
    min_value,
    max_value,
    sample_count,
    rolling_24h_avg
from {{ ref('int_telemetry_hourly') }}

{% if is_incremental() %}
    where hour > (select max(hour) from {{ this }})
{% endif %}
```

**Key incremental patterns for IoT:**
- Use `merge` strategy with a composite unique key (device + metric + time bucket)
- Filter on the time column in the `is_incremental()` block
- Set `on_schema_change='append_new_columns'` so new metrics don't break the model
- Run full refreshes weekly/monthly: `dbt run --full-refresh -s fct_telemetry_summary`

## Testing

### Built-in Tests

```yaml
# models/schema.yml
version: 2

models:
  - name: stg_devices
    columns:
      - name: device_id
        tests:
          - not_null
          - unique
      - name: device_type
        tests:
          - accepted_values:
              values: ['camera', 'sensor', 'gateway', 'controller']
      - name: site_id
        tests:
          - relationships:
              to: ref('stg_sites')
              field: site_id

  - name: fct_device_uptime
    columns:
      - name: uptime_pct
        tests:
          - not_null
      - name: device_id
        tests:
          - not_null
```

### Custom Tests

```sql
-- tests/assert_uptime_within_bounds.sql
-- Uptime percentage should be 0-100
select *
from {{ ref('fct_device_uptime') }}
where uptime_pct < 0 or uptime_pct > 100
```

```sql
-- tests/assert_no_future_telemetry.sql
-- No telemetry should be timestamped in the future
select *
from {{ ref('stg_telemetry') }}
where recorded_at > current_timestamp + interval '5 minutes'
```

```sql
-- tests/assert_alert_resolution_positive.sql
-- Resolution time should never be negative
select *
from {{ ref('fct_alerts') }}
where resolution_minutes < 0
```

### Generic Custom Test

```sql
-- tests/generic/test_value_in_range.sql
{% test value_in_range(model, column_name, min_val, max_val) %}
select *
from {{ model }}
where {{ column_name }} < {{ min_val }}
   or {{ column_name }} > {{ max_val }}
{% endtest %}
```

## Documentation

```yaml
# models/schema.yml (documentation section)
version: 2

models:
  - name: fct_device_uptime
    description: >
      Daily device uptime facts. One row per device per day.
      Uptime is calculated from heartbeat telemetry — the ratio
      of received heartbeats to expected heartbeats (1 per minute).
    columns:
      - name: device_id
        description: Unique device identifier
      - name: uptime_pct
        description: >
          Percentage of expected heartbeats received (0-100).
          Below 95% typically indicates connectivity issues.
      - name: report_date
        description: Calendar date for this uptime measurement

sources:
  - name: iot
    description: Raw IoT platform data loaded by ingestion pipelines
    database: analytics
    schema: raw
    tables:
      - name: raw_devices
        description: Device registry from the IoT platform
        loaded_at_field: _loaded_at
        freshness:
          warn_after: { count: 12, period: hour }
          error_after: { count: 24, period: hour }
      - name: raw_telemetry
        description: Device telemetry events (heartbeats, sensor readings)
        loaded_at_field: _loaded_at
        freshness:
          warn_after: { count: 1, period: hour }
          error_after: { count: 6, period: hour }
```

## IoT-Specific Patterns

### Device Uptime Calculation

Two approaches depending on data:

1. **Heartbeat-based** (shown above): Count received vs expected heartbeats
2. **Gap-based**: Mark device as "down" when gap between consecutive events exceeds threshold

```sql
-- Gap-based uptime detection
with events as (
    select
        device_id,
        recorded_at,
        lead(recorded_at) over (
            partition by device_id order by recorded_at
        ) as next_event_at
    from {{ ref('stg_telemetry') }}
),

gaps as (
    select
        device_id,
        recorded_at,
        next_event_at,
        extract(epoch from (next_event_at - recorded_at)) as gap_seconds,
        case
            when extract(epoch from (next_event_at - recorded_at)) > 300
            then extract(epoch from (next_event_at - recorded_at)) - 60
            else 0
        end as downtime_seconds
    from events
)

select
    device_id,
    date_trunc('day', recorded_at) as report_date,
    86400 - sum(downtime_seconds) as uptime_seconds,
    round((86400 - sum(downtime_seconds)) / 864.0, 2) as uptime_pct
from gaps
group by 1, 2
```

### Rolling Averages for Sensor Data

```sql
-- 1-hour and 24-hour rolling averages for temperature sensors
select
    device_id,
    recorded_at,
    metric_value as current_temp,
    avg(metric_value) over (
        partition by device_id
        order by recorded_at
        range between interval '1 hour' preceding and current row
    ) as rolling_1h_avg,
    avg(metric_value) over (
        partition by device_id
        order by recorded_at
        range between interval '24 hours' preceding and current row
    ) as rolling_24h_avg
from {{ ref('stg_telemetry') }}
where metric_name = 'temperature'
```

### Alert Rate Aggregation

```sql
-- Daily alert rates by device type and severity
select
    date_trunc('day', triggered_at) as alert_date,
    device_type,
    severity,
    count(*) as alert_count,
    count(*) filter (where is_false_positive) as false_positive_count,
    round(
        count(*) filter (where is_false_positive)::float / nullif(count(*), 0) * 100,
        2
    ) as false_positive_rate,
    avg(resolution_minutes) as avg_resolution_min,
    percentile_cont(0.5) within group (order by resolution_minutes)
        as median_resolution_min
from {{ ref('fct_alerts') }}
group by 1, 2, 3
```
