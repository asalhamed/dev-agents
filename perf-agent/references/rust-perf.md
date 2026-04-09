# Rust Performance Reference

Benchmarking, profiling, and common performance pitfalls in Rust.

---

## Criterion Benchmark Setup

### Cargo.toml

```toml
[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }

[[bench]]
name = "order_benchmarks"
harness = false
```

### Benchmark File Structure

```
benches/
└── order_benchmarks.rs
```

```rust
// benches/order_benchmarks.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};

fn bench_order_creation(c: &mut Criterion) {
    c.bench_function("create_order_10_items", |b| {
        b.iter(|| {
            let order = Order::new(black_box(OrderId::new()));
            // black_box prevents dead code elimination
            for i in 0..10 {
                order = order.add_item(black_box(make_item(i))).unwrap();
            }
            black_box(order)
        })
    });
}

fn bench_order_sizes(c: &mut Criterion) {
    let mut group = c.benchmark_group("order_creation");

    for size in [1, 10, 100, 1000] {
        group.bench_with_input(
            BenchmarkId::from_parameter(size),
            &size,
            |b, &size| {
                b.iter(|| {
                    let mut order = Order::new(OrderId::new());
                    for i in 0..size {
                        order = order.add_item(make_item(i)).unwrap();
                    }
                    black_box(order)
                });
            },
        );
    }
    group.finish();
}

criterion_group!(benches, bench_order_creation, bench_order_sizes);
criterion_main!(benches);
```

### Running

```bash
# Run all benchmarks
cargo bench

# Run specific benchmark
cargo bench -- order_creation

# Generate HTML report (opens in browser)
# Report at: target/criterion/report/index.html
```

### Interpreting Results

```
order_creation/10       time:   [1.2345 µs 1.2456 µs 1.2567 µs]
                        change: [-2.1234% -0.5678% +1.0123%] (p = 0.42 > 0.05)
                        No change in performance detected.
```

- Three values: `[lower bound, estimate, upper bound]` of the confidence interval
- `change` compares to the last saved baseline
- `p` value: < 0.05 means statistically significant change

---

## Flamegraph Generation

### cargo-flamegraph

```bash
# Install
cargo install flamegraph

# Generate (requires perf on Linux, dtrace on macOS)
cargo flamegraph --bin my-service

# With specific benchmark
cargo flamegraph --bench order_benchmarks -- --bench "order_creation"

# Output: flamegraph.svg (open in browser)
```

### perf (Linux)

```bash
# Record
perf record -g --call-graph dwarf target/release/my-service

# Generate flamegraph
perf script | inferno-collapse-perf | inferno-flamegraph > flamegraph.svg

# Install inferno tools
cargo install inferno
```

### Reading Flamegraphs

- **X-axis:** Proportion of total samples (wider = more time spent)
- **Y-axis:** Stack depth (bottom = entry point, top = leaf functions)
- **Hot frames:** Wide bars near the top — these are where CPU time is spent
- Look for: unexpected allocator frames (`alloc`, `malloc`), lock contention (`pthread_mutex`),
  serialization taking disproportionate time

---

## Common Rust Performance Pitfalls

### 1. Unnecessary `clone()` in Hot Paths

```rust
// ❌ Cloning in a loop
fn process_orders(orders: &[Order]) -> Vec<Summary> {
    orders.iter().map(|o| {
        let order = o.clone();  // Unnecessary allocation
        summarize(order)
    }).collect()
}

// ✅ Borrow instead
fn process_orders(orders: &[Order]) -> Vec<Summary> {
    orders.iter().map(|o| summarize(o)).collect()
}
```

**Detection:** Search for `.clone()` in hot paths. Profile with DHAT to find allocation sites.

### 2. Boxing Trait Objects

```rust
// ❌ Dynamic dispatch + heap allocation per item
fn process(items: Vec<Box<dyn Processor>>) { ... }

// ✅ Use enum dispatch when types are known
enum ProcessorKind { TypeA(TypeA), TypeB(TypeB) }

// ✅ Or use generics for static dispatch
fn process<P: Processor>(items: Vec<P>) { ... }
```

`Box<dyn Trait>` costs: heap allocation + vtable indirect call (prevents inlining).
Use when you genuinely need runtime polymorphism. Prefer enum dispatch or generics otherwise.

### 3. `fmt::Display` / `Debug` in Hot Paths

```rust
// ❌ format! allocates a String every time
log::debug!("Processing order {}", order.id);  // Even if debug logging is off,
                                                 // the format may still happen

// ✅ Use lazy formatting or check log level
if log::log_enabled!(log::Level::Debug) {
    log::debug!("Processing order {}", order.id);
}

// ✅ Or use tracing with lazy fields
tracing::debug!(order_id = %order.id, "Processing order");
```

### 4. `Vec` Reallocation

```rust
// ❌ Grows incrementally — multiple reallocations
let mut results = Vec::new();
for item in items {
    results.push(process(item));
}

// ✅ Pre-allocate
let mut results = Vec::with_capacity(items.len());
for item in items {
    results.push(process(item));
}

// ✅ Or use iterator (capacity inferred from size_hint)
let results: Vec<_> = items.iter().map(process).collect();
```

### 5. `Arc` Overhead

```rust
// Arc — atomic reference counting, thread-safe, ~30ns per clone/drop
// Rc  — non-atomic reference counting, single-threaded, ~5ns per clone/drop
// Owned — zero overhead, but value is moved

// Use Arc only when sharing across threads
// Use Rc only when sharing within a single thread
// Prefer owned data when sharing isn't needed
```

---

## Allocation Profiling

### DHAT (Valgrind)

```bash
# Build with debug info in release
cargo build --release

# Run under DHAT
valgrind --tool=dhat target/release/my-service

# Output: dhat.out.<pid>
# View at: https://nnethercote.github.io/dh_view/dh_view.html
```

Shows: total allocations, allocation sites, bytes allocated, peak memory.

### heaptrack

```bash
# Install (Ubuntu)
sudo apt install heaptrack

# Record
heaptrack target/release/my-service

# Analyze
heaptrack_gui heaptrack.my-service.<pid>.gz
```

Shows: allocation over time, leak candidates, top allocation sites, flamegraph of allocations.

---

## Zero-Cost Abstractions

### When Iterators Win

```rust
// ✅ Iterator — compiler optimizes to same as manual loop, often better
let sum: i64 = values.iter().filter(|v| v.is_valid()).map(|v| v.amount).sum();

// Equivalent manual loop (no faster, less readable)
let mut sum = 0i64;
for v in &values {
    if v.is_valid() {
        sum += v.amount;
    }
}
```

Iterators enable: loop fusion (no intermediate allocations), auto-vectorization, bounds check elimination.

### When Iterators Don't Win

```rust
// ❌ collect() into intermediate Vec just to iterate again
let filtered: Vec<_> = items.iter().filter(|i| i.active).collect();
let sum: i64 = filtered.iter().map(|i| i.value).sum();

// ✅ Chain instead
let sum: i64 = items.iter().filter(|i| i.active).map(|i| i.value).sum();
```

Intermediate `collect()` defeats fusion. Chain operations to keep lazy evaluation.

---

## Benchmarking Rules

1. **Always benchmark in release mode** — `cargo bench` does this by default; never draw conclusions from debug builds
2. **Use `black_box()`** — prevents the compiler from eliminating "unused" computed values
3. **Warm up** — criterion handles this automatically (configurable warm-up time)
4. **Be wary of dead code elimination** — if the compiler can prove a result is unused, it optimizes away the computation
5. **Disable CPU frequency scaling** for consistent results:
   ```bash
   sudo cpupower frequency-set --governor performance
   ```
6. **Close other programs** — background load adds noise
7. **Run multiple times** — criterion's statistical analysis needs sufficient samples
8. **Compare to baseline** — absolute numbers are less useful than relative changes
