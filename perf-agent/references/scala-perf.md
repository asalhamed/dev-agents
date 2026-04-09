# Scala / JVM Performance Reference

Benchmarking, profiling, and common performance pitfalls on the JVM.

---

## JMH Setup in sbt

### Dependencies

```scala
// project/plugins.sbt
addSbtPlugin("pl.project13.scala" % "sbt-jmh" % "0.4.7")

// build.sbt
enablePlugins(JmhPlugin)
```

### Benchmark Class

```scala
package com.example.benchmarks

import org.openjdk.jmh.annotations._
import java.util.concurrent.TimeUnit

@BenchmarkMode(Array(Mode.AverageTime))
@OutputTimeUnit(TimeUnit.MICROSECONDS)
@State(Scope.Thread)
@Warmup(iterations = 5, time = 1)
@Measurement(iterations = 10, time = 1)
@Fork(2)
class OrderBenchmark {

  @Param(Array("10", "100", "1000"))
  var orderSize: Int = _

  var items: List[OrderItem] = _

  @Setup
  def setup(): Unit = {
    items = (1 to orderSize).map(i => OrderItem(s"item-$i", i * 100)).toList
  }

  @Benchmark
  def createOrder(): Order = {
    Order.create(items)
  }

  @Benchmark
  def calculateTotal(): Long = {
    items.foldLeft(0L)(_ + _.priceCents)
  }
}
```

### Running

```bash
# Run all benchmarks
sbt "jmh:run"

# Run specific benchmark
sbt "jmh:run -i 10 -wi 5 -f 2 OrderBenchmark"

# With regex filter
sbt "jmh:run .*createOrder.*"

# Output as JSON for analysis
sbt "jmh:run -rf json -rff results.json"
```

### Key Annotations

| Annotation | Purpose |
|-----------|---------|
| `@Benchmark` | Marks a benchmark method |
| `@State(Scope.Thread)` | Each thread gets its own state instance |
| `@State(Scope.Benchmark)` | Shared state across threads |
| `@Setup` | Initialize state before benchmarks |
| `@TearDown` | Cleanup after benchmarks |
| `@Param` | Parameterize benchmarks |
| `@Fork(2)` | Number of JVM forks (isolates JIT effects) |
| `@Warmup` | Warm-up iterations (JIT compilation) |

---

## async-profiler

Low-overhead sampling profiler for the JVM. No agent attachment required on modern JVMs.

### CPU Profiling

```bash
# Download
wget https://github.com/async-profiler/async-profiler/releases/latest/download/async-profiler-3.0-linux-x64.tar.gz

# Profile a running JVM process
./asprof -d 30 -f cpu-flamegraph.html <pid>

# Profile with sbt
./asprof -d 30 -f cpu-flamegraph.html $(jps | grep sbt | awk '{print $1}')
```

### Allocation Profiling

```bash
# Track allocation sites
./asprof -d 30 -e alloc -f alloc-flamegraph.html <pid>

# Track only allocations > 512KB
./asprof -d 30 -e alloc --alloc 512k -f alloc-flamegraph.html <pid>
```

### Output Formats

```bash
# Flame graph (interactive HTML)
./asprof -d 30 -f output.html <pid>

# JFR format (for JDK Mission Control)
./asprof -d 30 -o jfr -f output.jfr <pid>

# Collapsed stacks (for custom processing)
./asprof -d 30 -o collapsed -f output.txt <pid>
```

---

## Common Scala/JVM Pitfalls

### 1. Boxing Primitives in Generic Collections

```scala
// ❌ List[Int] boxes every Int to java.lang.Integer
val numbers: List[Int] = (1 to 1000000).toList
val sum = numbers.foldLeft(0)(_ + _)  // Unbox-add-box per iteration

// ✅ Use Array for primitive storage
val numbers: Array[Int] = (1 to 1000000).toArray
var sum = 0
var i = 0
while (i < numbers.length) { sum += numbers(i); i += 1 }

// ✅ Or use specialized collections
import scala.collection.mutable.ArrayBuffer
val buf = ArrayBuffer.empty[Int]  // Still boxes internally in standard lib

// For truly unboxed: use Java primitive arrays or libraries like Spire
```

### 2. Implicit Conversion Overhead

```scala
// ❌ Implicit conversion creates temporary wrapper objects
implicit class RichInt(val n: Int) {
  def isEven: Boolean = n % 2 == 0
}
// Each call to .isEven allocates a RichInt

// ✅ Use value class (AnyVal) to avoid allocation
implicit class RichInt(val n: Int) extends AnyVal {
  def isEven: Boolean = n % 2 == 0
}
// Compiled to static method call, no allocation

// ✅ Or use extension methods in Scala 3
extension (n: Int)
  def isEven: Boolean = n % 2 == 0
```

### 3. Future/Promise Overhead

```scala
// ❌ Wrapping synchronous computation in Future
def getUser(id: UserId): Future[User] = Future {
  cache.get(id)  // Synchronous cache lookup wrapped in Future
}

// ✅ Use Future.successful for already-available values
def getUser(id: UserId): Future[User] =
  cache.get(id) match {
    case Some(user) => Future.successful(user)
    case None       => fetchFromDb(id)  // Only async when needed
  }
```

### 4. Excessive Case Class Copying

```scala
// ❌ Deep copy chain
val updated = order
  .copy(status = "confirmed")
  .copy(updatedAt = Instant.now)
  .copy(confirmedBy = Some(userId))
// Three allocations

// ✅ Single copy
val updated = order.copy(
  status = "confirmed",
  updatedAt = Instant.now,
  confirmedBy = Some(userId),
)
// One allocation
```

### 5. GC Pressure from Short-Lived Objects

```scala
// ❌ Creating tuples/options in tight loops
def processItems(items: Seq[Item]): Seq[Result] =
  items.map(i => (i.id, i.value))       // Tuple allocation
       .filter(_._2 > threshold)         // More tuples survive
       .map { case (id, v) => Result(id, v * 2) }

// ✅ Fuse operations, minimize intermediate objects
def processItems(items: Seq[Item]): Seq[Result] =
  items.collect {
    case i if i.value > threshold => Result(i.id, i.value * 2)
  }
```

---

## Cats Effect / ZIO Fiber Profiling

### Identifying Blocked Fibers (Cats Effect)

```scala
import cats.effect._
import cats.effect.unsafe.implicits.global

// Enable fiber monitoring
val runtime = IORuntime.builder()
  .setConfig(IORuntimeConfig().copy(
    traceBufferSize = 16  // Keep last 16 stack frames per fiber
  ))
  .build()

// Dump all fiber traces
IO.trace.flatMap(trace => IO.println(trace.toList))
```

### ZIO Fiber Dump

```scala
import zio._

// Dump all fibers
ZIO.dumpFibers.flatMap(dump => Console.printLine(dump))

// Fiber supervisor for tracking
val supervised = ZIO.succeed(()).supervised(FiberSupervisor.track)
```

### Fiber Leak Detection

Symptoms: growing memory usage, increasing fiber count, tasks that never complete.

```scala
// ❌ Fiber leak — spawned fibers never joined
def processAll(items: List[Item]): IO[Unit] =
  items.traverse_(item => processItem(item).start)  // Fire and forget!

// ✅ Join all fibers
def processAll(items: List[Item]): IO[List[Result]] =
  items.parTraverse(processItem)  // Structured concurrency
```

---

## GC Tuning Basics

### G1GC (Default since JDK 9)

```bash
# Good general-purpose defaults
java -XX:+UseG1GC \
     -Xms2g -Xmx2g \            # Fixed heap (avoids resize pauses)
     -XX:MaxGCPauseMillis=200 \  # Target max pause
     -XX:G1HeapRegionSize=16m \  # Region size (heap/2048 ≤ size ≤ 32m)
     -jar app.jar
```

**Best for:** Most workloads. Balanced throughput and latency.

### ZGC (Low Latency)

```bash
java -XX:+UseZGC \
     -Xms4g -Xmx4g \
     -jar app.jar
```

**Best for:** Latency-sensitive services (< 1ms GC pauses). Requires more memory (~2x heap).

### GC Log Analysis

```bash
# Enable GC logging
java -Xlog:gc*:file=gc.log:time,uptime,level,tags \
     -jar app.jar

# Analyze with GCViewer or GCEasy
# Upload gc.log to https://gceasy.io for quick analysis
```

**What to look for:**
- Pause times: are they within your SLO?
- Frequency: how often are collections happening?
- Promotion rate: objects moving to old gen too fast → increase young gen
- Full GC: should be rare. Frequent full GCs = heap too small or memory leak

### Heap Sizing Rules of Thumb

- **Xms = Xmx**: Avoid dynamic resizing overhead
- **Start at 2x live data set size**: Measure with heap dump, then set heap to 2-3x
- **Watch GC overhead**: If > 5% of CPU time is in GC, increase heap
- **ZGC**: Needs more headroom — 3-4x live data set
