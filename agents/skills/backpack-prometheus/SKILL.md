---
name: backpack-prometheus
description: Investigate Backpack service performance or product behavior with strictly read-only Prometheus queries, source-backed metric discovery, and falsifiable hypotheses. Use on demand for Backpack investigations; do not use for alert or dashboard administration.
---

# Backpack Prometheus investigations

**Prometheus investigation is strictly read only.** Query metrics and metadata
through this skill's bounded `scripts/prometheus-query.py` using the local AWS
profile for the selected core account. The helper sends GET requests only to
allowlisted AMP query routes. Never write samples, change rules or silences,
edit dashboards, or modify AWS or Kubernetes resources as part of this skill.
The local AWS profile may have broader permissions; the read-only boundary
here is the command and the agent's behavior, not IAM. Keep credentials out
of output, reports, and Git. If the profile is unavailable, report the access
gap and continue with source analysis.

Find the Backpack control checkout from the task workspace, or use the
organisation checkout at `~/eng/backpack`. Read its `map/META.md` section
"Exchange Prometheus routes" and this skill's
`references/investigation.md` before querying. The map owns cluster,
account, workspace, and Grafana routing. Verify source and deployment paths
against the mapped `repos/` checkouts.

Before a long analysis, state the affected path, UTC window, hypothesis, null
hypothesis, and the observation that distinguishes them. For product questions,
define the eligible cohort and denominator. For performance, trace inputs,
queues, batches, processing, outputs, and downstream consumers. Compare rates,
errors, saturation, lag, and p50/p95/p99/p99.9 with sample counts. Aggregate
compatible histogram buckets before deriving quantiles; a histogram p100 is
not an exact worst observation. Apply queueing laws only when their assumptions
hold. Treat coincident latency changes as a lead, not proof of cause.

Find candidate metrics in `repos/bpx-backend`, `repos/bpx-custody`, and
`repos/observability` by searching `#[instrument]`, registry declarations, and
recording call sites. Confirm units, labels, and update conditions, then check
the deployment and scrape configuration in `repos/ops-kube`. Use exact metric
selectors and bounded cluster and time ranges. Explain absent series using
deployment, scrape, and remote-write evidence before calling a metric zero.

Report copyable PromQL, UTC evaluation window, workspace and cluster, source
and deployment references, evidence for and against each hypothesis, the
conclusion and its uncertainty, and a next discriminating check. Include a
verified Grafana Explore link only when its data source UID and URL format are
known.
