# Exchange Prometheus investigations

**Prometheus investigation is strictly read only.** Use this skill's GET-only
query command with an existing local AWS profile. Never write samples, change
recording or alerting rules, silence alerts, edit Grafana dashboards, or
modify Kubernetes or AWS resources during an investigation. Keep credentials
out of Git, process output, and reports. The profile can have broader AWS
permissions, so this is a command and workflow boundary rather than an IAM
boundary.

## Route the query

Use the Exchange route table in `~/eng/backpack/map/META.md` to
choose the environment and cluster. Trading has separate AMP workspaces.
Run these examples from the skill directory with Python 3.9 or newer and curl
8.4 or newer. The
existing `DevelopmentCoreEdit-448775934494` and
`ProductionCoreEdit-608464618807` profiles are examples. Use discovery to
confirm the emitted metric and label names.

```sh
python3 scripts/prometheus-query.py --environment development --profile DevelopmentCoreEdit-448775934494 \
  series --cluster development-core up \
  --start 2026-11-23T10:00:00Z --end 2026-11-23T10:15:00Z

python3 scripts/prometheus-query.py --environment development --profile DevelopmentCoreEdit-448775934494 \
  range 'sum by (job) (up{cluster="development-core"})' \
  --start 2026-11-23T10:00:00Z --end 2026-11-23T10:15:00Z --step 30
```

The `labels` and `series` operations take one exact metric and a cluster.
Use explicit cluster matchers in `instant` or `range` PromQL. Keep lookbacks
and offsets short. Restrict scope or aggregate if a result exceeds query
limits. When data is missing, check deployment timing, scrape selectors and
health, and remote-write filtering.

## Establish a testable hypothesis

Before extended analysis, record the affected user or service path,
environment, clusters, UTC window, expected behavior, hypothesis, null
hypothesis, and the observation that distinguishes them. For product
questions, define the eligible cohort and denominator and choose a
comparable baseline or control. Revise the hypotheses as evidence changes.

Find candidate metrics in `repos/bpx-backend`, `repos/bpx-custody`, and
`repos/observability`. Follow `#[instrument::registry(...)]`,
`#[instrument::instrument]`, and `global::meter(...)` to definitions and
recording call sites. Record type, unit, labels, and update condition.
Check existing dashboard PromQL. Verify the deployment and monitor in
`repos/ops-kube`, then confirm the emitted names and labels in AMP.

Trace upstream inputs, downstream consumers, persistence, queues, retries,
and backpressure. At each hop compare scrape coverage, traffic, errors,
latency, saturation, queue depth and lag, batch size and fill ratio, flush
cadence, and processing capacity.

## Performance and product examples

For an engine latency investigation, start with
`repos/bpx-backend/engine/src/metrics/mod.rs`. A batching hypothesis predicts
higher batch wait and changing fill or cadence, while an execution regression
would increase batch execution time at comparable batch sizes and load.
Compare arrival and service rates, stream latency and queue depth. Apply
Little's Law only during stable periods. Examine p50, p95, p99, p99.9,
sample counts, and exact worst observations where available. Break down by
cluster, node, deployment, and cohort. Aggregate compatible buckets before
computing percentiles. Treat histogram p100 as an estimate.

For a deposit product question, start with the custody poller in
`repos/bpx-custody/poller/direct/src/worker.rs`. Follow the conditions for
found, inserted, ignored, and rejected deposits through retries and
persistence before choosing a denominator. Compare matched blockchain and
deployment cohorts over equal windows to distinguish a change in arrivals
from a regression in insertion. Trace downstream processing before claiming
a customer-visible outcome.

## Report findings

Include exact copyable PromQL, UTC windows, workspace and clusters, source
and deployment references, evidence for and against each hypothesis,
conclusion, uncertainty, and the next discriminating check. Include a
verified Grafana Explore link when the datasource UID and link format are
established.
