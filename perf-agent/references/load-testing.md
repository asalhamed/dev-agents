# Load Testing Reference

Tools, patterns, and metrics for load testing APIs and services.

---

## k6

### Script Structure

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 10 },   // Ramp up to 10 VUs
    { duration: '5m', target: 10 },   // Stay at 10 VUs
    { duration: '1m', target: 50 },   // Ramp up to 50 VUs
    { duration: '5m', target: 50 },   // Stay at 50 VUs
    { duration: '2m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95th percentile < 500ms
    http_req_failed: ['rate<0.01'],    // Error rate < 1%
  },
};

export default function () {
  const res = http.get('http://localhost:3000/api/orders');

  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
    'body has orders': (r) => JSON.parse(r.body).data.length > 0,
  });

  sleep(1); // Think time between requests
}
```

### Running

```bash
# Run test
k6 run load-test.js

# Run with environment variables
k6 run -e BASE_URL=https://staging.example.com load-test.js

# Override VUs and duration
k6 run --vus 100 --duration 5m load-test.js

# Output to JSON for analysis
k6 run --out json=results.json load-test.js
```

### Output Interpretation

```
     ✓ status is 200
     ✓ response time < 500ms

     checks.........................: 100.00% ✓ 24680  ✗ 0
     http_req_duration..............: avg=45ms  min=12ms  med=38ms  max=890ms  p(90)=78ms  p(95)=120ms
     http_req_failed................: 0.00%   ✓ 0      ✗ 12340
     http_reqs......................: 12340   41.13/s
     iteration_duration.............: avg=1.04s min=1.01s med=1.03s max=1.89s  p(90)=1.07s p(95)=1.12s
     vus............................: 50      min=1     max=50
```

### CI Integration

```yaml
- name: Run load test
  run: |
    k6 run --out json=results.json load-test.js
    # Thresholds cause non-zero exit on failure
```

---

## Gatling

### Scala DSL

```scala
import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class OrderSimulation extends Simulation {

  val httpProtocol = http
    .baseUrl("http://localhost:3000")
    .acceptHeader("application/json")
    .contentTypeHeader("application/json")

  val browseOrders = scenario("Browse Orders")
    .exec(
      http("List Orders")
        .get("/api/orders")
        .check(status.is(200))
        .check(jsonPath("$.data").exists)
    )
    .pause(1.second, 3.seconds)
    .exec(
      http("Get Order Detail")
        .get("/api/orders/#{orderId}")
        .check(status.is(200))
    )

  val createOrder = scenario("Create Order")
    .exec(
      http("Create Order")
        .post("/api/orders")
        .body(StringBody("""{"items": [{"id": "item-1", "qty": 2}]}"""))
        .check(status.is(201))
        .check(header("Location").saveAs("orderUrl"))
    )

  setUp(
    browseOrders.inject(
      rampUsers(100).during(2.minutes),              // Ramp to 100 users over 2 min
      constantUsersPerSec(20).during(5.minutes),     // 20 new users/sec for 5 min
    ),
    createOrder.inject(
      rampUsers(50).during(2.minutes),
    ),
  ).protocols(httpProtocol)
    .assertions(
      global.responseTime.percentile(95).lt(500),
      global.successfulRequests.percent.gt(99.0),
    )
}
```

### Running

```bash
# With sbt
sbt "Gatling/testOnly com.example.OrderSimulation"

# Reports generated at: target/gatling/<simulation>/index.html
```

---

## autocannon (Node)

Quick HTTP benchmarking from the command line.

### CLI Usage

```bash
# Basic test: 100 connections, 30 seconds
autocannon -c 100 -d 30 http://localhost:3000/api/orders

# With custom headers
autocannon -c 50 -d 20 \
  -H "Authorization=Bearer eyJhbG..." \
  http://localhost:3000/api/orders

# POST request with body
autocannon -c 50 -d 20 \
  -m POST \
  -b '{"items":[{"id":"item-1","qty":2}]}' \
  -H "Content-Type=application/json" \
  http://localhost:3000/api/orders

# JSON output
autocannon -c 100 -d 30 -j http://localhost:3000/api/orders > results.json
```

### Output Fields

```
┌─────────┬────────┬────────┬────────┬────────┬───────────┬──────────┬────────┐
│ Stat    │ 2.5%   │ 50%    │ 97.5%  │ 99%    │ Avg       │ Stdev    │ Max    │
├─────────┼────────┼────────┼────────┼────────┼───────────┼──────────┼────────┤
│ Latency │ 12 ms  │ 35 ms  │ 156 ms │ 245 ms │ 42.33 ms  │ 38.12 ms │ 890 ms │
└─────────┴────────┴────────┴────────┴────────┴───────────┴──────────┴────────┘
┌───────────┬─────────┬─────────┬─────────┬─────────┬──────────┬─────────┬─────────┐
│ Stat      │ 1%      │ 2.5%    │ 50%     │ 97.5%   │ Avg      │ Stdev   │ Min     │
├───────────┼─────────┼─────────┼─────────┼─────────┼──────────┼─────────┼─────────┤
│ Req/Sec   │ 1,234   │ 1,456   │ 2,345   │ 2,890   │ 2,234.5  │ 345.6   │ 1,234   │
├───────────┼─────────┼─────────┼─────────┼─────────┼──────────┼─────────┼─────────┤
│ Bytes/Sec │ 1.23 MB │ 1.45 MB │ 2.34 MB │ 2.89 MB │ 2.23 MB  │ 345 kB  │ 1.23 MB │
└───────────┴─────────┴─────────┴─────────┴─────────┴──────────┴─────────┴─────────┘

Req/Bytes counts sampled once per second.
67k requests in 30s, 67 MB read
0 errors (0 timeouts)
```

---

## What to Measure

| Metric | What It Tells You | Target (typical API) |
|--------|-------------------|---------------------|
| **p50 latency** | Median user experience | < 100ms |
| **p95 latency** | Experience for most users | < 500ms |
| **p99 latency** | Worst-case (excluding outliers) | < 1000ms |
| **Throughput (req/s)** | How much load the system handles | Depends on capacity plan |
| **Error rate** | Reliability under load | < 0.1% at normal load, < 1% at peak |
| **CPU usage** | Headroom | < 70% at peak load |
| **Memory usage** | Leak detection, sizing | Stable (no upward trend) |

### What to Watch For

- **Latency spike at specific throughput** → likely hitting a bottleneck (DB connections, thread pool, etc.)
- **Error rate climbing with load** → resource exhaustion (connection pools, file descriptors)
- **Memory climbing over time** → memory leak (especially visible in soak tests)
- **CPU at 100% but low throughput** → CPU-bound bottleneck, optimize hot paths
- **CPU low but high latency** → I/O-bound, likely waiting on DB or external service

---

## Load Test Types

### Smoke Test

```
VUs: 1-2
Duration: 1-2 minutes
Purpose: Verify the test script works and baseline response times
```

Run first, always. Catches broken scripts before wasting time on full tests.

### Load Test

```
VUs: Expected normal load
Duration: 10-30 minutes
Purpose: Verify system handles expected traffic within SLOs
```

Simulates a typical day. Results should meet your SLO targets.

### Stress Test

```
VUs: 2-5x normal load, ramped up gradually
Duration: 10-20 minutes at peak
Purpose: Find the breaking point and observe degradation behavior
```

Questions answered: Where does it break? Does it degrade gracefully or crash? Does it recover?

### Soak Test (Endurance)

```
VUs: Normal load
Duration: 4-24 hours
Purpose: Find memory leaks, connection leaks, resource exhaustion over time
```

The slow-burn test. Memory leaks and connection pool exhaustion often only show up after hours.

### Spike Test

```
VUs: Sudden jump from low to very high, then back
Duration: Brief spike (1-5 minutes)
Purpose: Test auto-scaling and recovery from sudden traffic bursts
```

Simulates viral moments or flash sales.
