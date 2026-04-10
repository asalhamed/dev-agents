# Time-Series Databases for IoT

## Comparison

| Feature | InfluxDB | TimescaleDB | ClickHouse |
|---------|----------|-------------|------------|
| Type | Native time-series | PostgreSQL extension | Columnar OLAP |
| Query language | InfluxQL / Flux | SQL | SQL |
| Write throughput | ~500K pts/s | ~200K rows/s | ~1M rows/s |
| Compression | Good (10-15x) | Good (10-20x) | Excellent (20-40x) |
| Aggregation | Good | Excellent (SQL) | Excellent |
| Ecosystem | Telegraf, Grafana | PostgreSQL tools | Grafana, dbt |
| Operations | Easy | Medium (PG tuning) | Medium-Hard |
| Best for | Simple IoT, fast start | SQL teams, mixed workloads | High-volume analytics |

## When to Use Each

- **InfluxDB:** <100K devices, simple queries, fast setup, Telegraf integration
- **TimescaleDB:** SQL team, complex queries, joins with relational data, existing PostgreSQL
- **ClickHouse:** >100K devices, high write throughput, heavy analytics, cost-sensitive storage

## Schema Design for IoT Telemetry

### Wide table (recommended)
```sql
CREATE TABLE telemetry (
    time        TIMESTAMPTZ NOT NULL,
    device_id   TEXT NOT NULL,
    site_id     TEXT NOT NULL,
    temperature DOUBLE PRECISION,
    humidity    DOUBLE PRECISION,
    battery_v   DOUBLE PRECISION
);
-- TimescaleDB: convert to hypertable
SELECT create_hypertable('telemetry', 'time');
CREATE INDEX ON telemetry (device_id, time DESC);
```

### Narrow table (flexible but slower)
```sql
CREATE TABLE metrics (
    time       TIMESTAMPTZ NOT NULL,
    device_id  TEXT NOT NULL,
    metric     TEXT NOT NULL,      -- 'temperature', 'humidity'
    value      DOUBLE PRECISION
);
```

Wide is better for fixed schemas. Narrow for dynamic/unknown metrics.

## Downsampling & Retention

```sql
-- TimescaleDB continuous aggregate (auto-downsampling)
CREATE MATERIALIZED VIEW telemetry_hourly
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 hour', time) AS bucket,
       device_id,
       avg(temperature) as avg_temp,
       max(temperature) as max_temp,
       min(temperature) as min_temp,
       count(*) as samples
FROM telemetry
GROUP BY bucket, device_id;

-- Retention policy: drop raw data after 30 days
SELECT add_retention_policy('telemetry', INTERVAL '30 days');
-- Keep hourly aggregates for 1 year
SELECT add_retention_policy('telemetry_hourly', INTERVAL '1 year');
```

## Key Rules

- **Partition by time** — all time-series DBs do this; ensure queries filter on time
- **Tag/index on device_id** — always filter by device + time range
- **Downsample early** — raw data at 1s intervals → 1min aggregates → 1hr aggregates
- **Set retention policies** — infinite storage is not a plan
