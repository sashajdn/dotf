---
name: xstack
description: Use when the user wants Codex to run, extend, or apply the xstack AI-infrastructure investment intelligence workflow, including market history and calendars, X post capture, high-precision filtering, AI hardware/semiconductor/power bottleneck research, company or ticker memos, end-of-day reports, scenario-based investment decision support, Codex/Claude LLM harnesses, or wiki report generation under ~/wiki/investments.
---

# xstack

Operate `xstack` as a high-precision AI infrastructure investment intelligence system.

## Repo

Default path:

```bash
cd ~/repos/xstack
```

If missing:

```bash
find "$HOME" -maxdepth 3 -type d -name xstack 2>/dev/null
```

## Report Paths

Default wiki targets:

```bash
XSTACK_COMPANY_REPORTS_DIR="${XSTACK_COMPANY_REPORTS_DIR:-$HOME/wiki/investments/xstack/reports}"
XSTACK_EOD_REPORTS_DIR="${XSTACK_EOD_REPORTS_DIR:-$HOME/wiki/investments/reports/summaries/eod}"
```

Expected outputs:

```text
~/wiki/investments/xstack/context-index.md
~/wiki/investments/xstack/reports/<company-slug>.<ticker>.md
~/wiki/investments/reports/summaries/eod/<YYYY><MM><DD>.md
~/wiki/investments/xstack/portfolio/active-top8-plus-hedges.md
```

## Context Index

Use `~/wiki/investments/xstack/context-index.md` as the first stop when a task depends on prior xstack research, active portfolio state, X captures, decision logs, watchlists, runbooks, signals, or raw-data locations.

Before changing rankings, creating a new memo, interpreting a fresh X capture, or recommending a portfolio action:

1. Open the context index.
2. Follow its start-here table to the relevant canonical files.
3. Use its `rg` commands to search the wiki/log/repo context before drawing conclusions.
4. Update the index when creating a new canonical state file, important research memo, watchlist, signal file, raw capture, or decision-log convention.

Useful default searches:

```bash
rg -n "<query>" ~/wiki/investments/xstack ~/wiki/investments/log/xstack
rg -n "Decision:|Decision delta|Action Read|Action candidate|Rejected|Pullback-only|No change" ~/wiki/investments/xstack ~/wiki/investments/log/xstack
rg -n "Order ID|Submitted|PreSubmitted|Limit|first tranche|submitted" ~/wiki/investments/xstack ~/wiki/investments/log/xstack
rg -n "Research Queue|Next Gate|Known unknowns|Research tasks|Raise Priority" ~/wiki/investments/xstack ~/wiki/investments/log/xstack
```

Company reports are canonical living documents. Overwrite the same company report as research improves and rely on git history in the wiki repo for prior versions. Keep a timeline of important company events inside the report itself. Report filenames must not contain spaces; normalize separators to hyphens.

For portfolio construction, treat `~/wiki/investments/xstack/portfolio/active-top8-plus-hedges.md` as the canonical async state file. Read it before changing rankings, position sizing, hedge candidates, or the active research queue. Proposed top-K names are candidates, not commitments; reject, defer, or replace any candidate that fails evidence, valuation, or portfolio-fit gates. Every accept/reject/replace/sizing decision must include a written rationale, evidence quality, portfolio impact, and what would change the decision.

## Runbooks

XStack runbooks are harness-agnostic markdown files:

```text
~/repos/xstack/runbooks/pre-market/RUNBOOK.md
~/repos/xstack/runbooks/post-market/RUNBOOK.md
```

When the user asks to run `xstack runbook pre`, `xstack runbook post`, the pre-market runbook, or the post-market runbook, do not require a CLI command. Open the relevant markdown file, follow its checklist, read the state files it references, and write the requested log/state updates. This must work for Codex, Claude, or any other LLM harness that can read and write markdown.

Runbooks must be aware of the current portfolio: positions, working orders, fills, cash by currency, account value, active alerts, and manual user changes. If the current state is ambiguous, ask concise clarifying questions before making a material recommendation. If the safe action is inaction, say so and record the ambiguity.

Runbooks must always check both the current portfolio and the full active watchlist unless the user explicitly narrows the run. Treat ticker-specific prompts as emphasis, not permission to ignore watchlist or portfolio-wide implications.

Runbook outputs must follow the log rules under `~/wiki/investments/log/xstack/.AGENTS.md`: append-only, versioned new entries, and no silent cleanup of prior decisions.

## Backpack Market History And Calendar Fallback

Use the isolated `xstack-backpack` binary for credential-free U.S. security
history, documented market metadata, and the event feeds used by Backpack's
public stock-calendar page:

```bash
XSTACK_BACKPACK_BIN="${XSTACK_BACKPACK_BIN:-$HOME/.local/bin/xstack-backpack}"
test -x "$XSTACK_BACKPACK_BIN"
```

For a pre-market, post-market, or daily portfolio report:

1. Build a deduplicated ticker set from the broker-backed current portfolio,
   full active watchlist, relevant thesis comparisons, and `SPY`. Do not infer
   portfolio coverage from Backpack.
2. Capture `universe`, derive the explicitly supported U.S. ticker intersection,
   and retain unsupported portfolio/watchlist names as named coverage gaps.
   Never silently drop them.
3. Run `bundle` for the supported intersection with `1d` history beginning at
   least five years plus 14 calendar days before the latest required session.
   Set the history end to the day after the latest required date because the end
   bound is exclusive.
4. Request the relevant forward calendar window, no more than 93 days, and keep
   the default raw artifact persistence enabled.
5. Require envelope schema `xstack.backpack/v1`, `status: ok`, and a raw artifact
   for every source receipt before using the result.
6. Treat `documented_market_api` receipts as fallback market observations, not
   licensed broker truth. Treat `undocumented_web_calendar` receipts as
   vendor-estimated discovery and verify material events with issuer IR,
   SEC/exchange filings, or official macro/central-bank sources.
7. Never silently substitute Backpack for an unsupported local Asian listing,
   an unavailable portfolio asset, broker state, FX, rates, credit, options, or
   corporate-action reconciliation.

Example scheduled input capture:

```bash
"$XSTACK_BACKPACK_BIN" bundle \
  --ticker NVDA,MSFT,MU,TSM,SPY \
  --history-from 2021-07-01 \
  --history-to 2026-07-30 \
  --calendar-from 2026-07-29 \
  --calendar-to 2026-08-05 \
  --benchmark SPY \
  --country US \
  --summary-only \
  --out "$HOME/.local/share/xstack/public/runs/2026-07-29/backpack.json"
```

Dates in examples are illustrative; derive session-aware dates for each run.
Do not use `--no-persist-raw` in a scheduled workflow. If the binary is missing,
the command fails, any requested endpoint fails, a ticker is unsupported, or
the result is stale/incomplete, continue producing the daily report and name
the missing/degraded coverage in the source-quality section and a concise
footnote. Missing data is unknown, never a neutral market signal.

The full connector contract and installation steps are in:

```text
~/repos/xstack/docs/market/BACKPACK.md
```

## Operating Principles

- Optimize for precision. Noise is worse than missing a marginal signal.
- Treat X home timeline capture as opportunistic discovery, not complete coverage.
- Treat curated X accounts/lists/searches as the coverage backbone.
- Exclude crypto unless the user explicitly overrides this.
- Focus on AI infrastructure bottlenecks: semis, memory, foundry, equipment, packaging, networking/optics, power, energy, cooling, hyperscaler capex, and Japan/Korea supply chain.
- Store raw captured data before analysis so downstream decisions are replayable.
- Be aggressive about surfacing asymmetric opportunities, but never hand-wave the thesis.
- Separate facts, estimates, inferences, and speculation.
- Frame research across two horizons: `1-2 year` immediate bottlenecks that can drive near-term earnings revisions, and `5-10 year` structural branches such as humanoid robotics, drones, autonomous factories, and edge AI hardware. Do not let long-horizon themes displace near-term capital candidates without strong evidence of revenue materiality or superior expected value.

## Daily capability preflight

For every scheduled pre-market or post-market report, run the canonical prompt's
preflight before interpreting missing data:

```bash
"$HOME/repos/xstack/tools/preflight-market-brief" \
  --expected-cwd /Users/alexjperkins \
  --output "$HOME/wiki/investments/agent-scratchpad/<session-date>/preflight.json"
```

Treat the emitted states as authoritative capability evidence, not as investment
signals. Use only `AVAILABLE`, `AVAILABLE_PARTIAL`, `AVAILABLE_EOD`,
`NOT_YET_OPEN`, `BLOCKED_BY_POLICY`, `NOT_COLLECTED_OPTIONAL`,
`FAILED_AFTER_RETRY`, `UNAVAILABLE`, and `CONFIG_MISMATCH`. Never call a source
unavailable merely because it was not attempted, the requested session is in the
future, it is optional, policy blocks it, coverage is partial, or the first probe
failed.

Record a capability matrix with source, policy state, first probe, retry,
fallback, timestamp, exact safe error, freshest substitute, and decision impact.
`UNAVAILABLE` is allowed only after discovery, functional probe, one retry, and a
fallback all fail. Optional uncollected sources and future sessions do not
degrade a report. Reject an unqualified “unavailable” during validation.

A failed live-quote probe is decision-critical only when the current run window
or a proposed action requires executable/live pricing. During an Asia-open or
weekend prior-close carry run, use the timestamped completed close and treat the
quote failure as non-degrading unless missing extended-hours movement could
plausibly change the conclusion. A broker guidance gate may independently keep
the report degraded.

Read [source capabilities](references/source-capabilities.md) before collecting
X, crypto, FX/rates, options/flows, or live/fallback market data.

## Research Mode

Use this mode for a ticker, company, bottleneck, or sector memo. The research component must be deep enough to support both an LLM agent and a human investment decision. Do not stop at summaries.

For a given ticker/company, collect everything necessary to decide whether the idea deserves capital:

- timeline of important company events that changed business quality, bottleneck exposure, valuation, or risk;
- business model and segment economics;
- AI hardware-stack role and bottleneck exposure;
- products, customers, competitors, substitutes, and supply-chain dependencies;
- revenue, margin, capex, cash flow, balance sheet, and valuation drivers;
- guidance, earnings transcripts, filings, investor decks, and credible industry sources;
- Japan/Korea/Taiwan/global listing context when relevant;
- historical cyclicality, inventory cycle, pricing power, and capacity additions;
- management quality and capital allocation;
- consensus assumptions and where they may be wrong;
- bear case, fraud/accounting/governance/geopolitical risks;
- near-term catalysts and long-term compounding path;
- market-implied expectations when current prices are available.

Research must be both general and thesis-specific:

1. Explain the company on its own terms.
2. Explain the company in the context of the AI and hardware vertical stack bottleneck thesis.

Do not allow false positives into research conclusions. If evidence is weak, say so and keep the item as a research lead rather than a conclusion.

## Investment Decision Framework

Use this only after research mode has enough evidence. Produce decision support, not vague bullish/bearish commentary.

### 1. First Principles

Start from the physical and economic bottleneck:

- What scarce resource constrains AI scaling?
- Why is it scarce: physics, manufacturing complexity, capex, yield, supply chain, regulation, power, or time?
- Who controls the scarce resource?
- Who captures economics if demand persists?
- What must be true for the opportunity to matter?

For hardware bottlenecks, use a defensible logic thread. Example for DRAM/HBM:

```text
AI training/inference demand -> accelerator shipments -> HBM bits per accelerator
-> wafer starts/yield/packaging capacity -> supply tightness -> pricing/margins
-> company earnings revision -> valuation/position decision.
```

### 2. Second-Order Effects

Reason beyond the obvious winner:

- supplier beneficiaries;
- substitution risks;
- margin transfer across the value chain;
- capex beneficiaries and losers;
- inventory cycle effects;
- regulatory/geopolitical constraints;
- power/grid/cooling knock-on effects;
- Japan/Korea/Taiwan supply-chain exposure.

### 3. Evidence Quality

Classify every key claim:

- Primary source: filing, transcript, company statement, capex disclosure.
- Strong secondary source: reputable analyst, trade publication, supply-chain report.
- Weak secondary source: X thread, anonymous source, unverified translation.
- Market-implied signal: price, volume, options, estimates revision.

Call out contradiction and missing evidence. Known unknowns are acceptable only when named.

### 4. Scenario Branches

Frame decisions as branches:

```text
If X happens, then Y is likely because Z.
If X does not happen, then A is the fallback interpretation.
If contrary signal B appears, reduce/exit/research further.
```

Each branch needs:

- trigger;
- expected market interpretation;
- affected tickers;
- action candidate;
- invalidation condition;
- confidence.

### 5. Price And Valuation Math

When discussing buy/sell/add/trim candidates, include explicit math:

- current price when available;
- base/upside/downside cases;
- revenue, margin, EPS, FCF, or multiple assumptions;
- rough expected value;
- position sizing logic for an aggressive, smaller-capital, high-risk portfolio;
- what would make the math wrong.

If current price or financial data is stale or unavailable, say so and mark the estimate incomplete. Browse or use market data tools when the user asks for current decisions or when prices may have changed.

### 6. Execution Price Discipline

When suggesting prospective orders, classify the order intent before suggesting a limit price. The limit should express the intent, not just an attractive valuation level.

Use these order classes:

| Order class | Purpose | Limit discipline |
|---|---|---|
| `participation starter` | Establish desired exposure now after the investment decision has cleared. | Use a marketable or near-marketable limit with modest headroom, usually `0.5-1.5%` above indicative ask depending on liquidity, volatility, spread, market hours, and gap risk. Do not miss desired exposure over rounding-error savings. |
| `pullback add` | Add only if price improves. | Below-market limit is intentional. Missing is acceptable. |
| `stress / dislocation order` | Buy only if forced selling or abnormal volatility creates a materially better entry. | Far-below-market limit. Missing is expected. |

This is an investment workflow, not a day-trading workflow. Once research has cleared and the desired action is a `participation starter`, missing the position over a small below-market limit is a process failure. Do not disguise a desired investment starter as a pullback order. If the thesis is intact or improved and the position remains under target, judge the current price against the 1-5 year expected return and use a marketable / near-marketable limit with explicit headroom. Conversely, if the order is a true `pullback add` or `stress / dislocation order`, missing the fill is acceptable and should not be chased.

For every prospective price suggestion, state:

- whether the order is a `participation starter`, `pullback add`, or `stress / dislocation order`;
- current / indicative price and whether it is live, premarket, stale, or user-provided;
- proposed limit and the reason for its headroom or discount;
- maximum extra cost versus the preferred valuation entry;
- whether missing the fill is acceptable;
- whether a marketable limit, IOC limit, day limit, or alert is the right execution tool;
- what price action would turn the order into a chase.

Judgment matters. Do not apply the `0.5-1.5%` starter headroom mechanically when spreads are wide, liquidity is poor, the stock is gapping vertically, or the thesis has not cleared. Conversely, do not use an ideal pullback price for a desired starter merely because it looks more disciplined.

### 7. Utility Score

Score the signal:

```text
utility = expected_profit_potential
        * confidence
        * novelty
        * source_quality
        * market_linkage
        - risk_penalty
        - noise_penalty
```

Report:

- utility score;
- confidence score;
- risk score;
- time horizon;
- why this is worth attention now.

## Required Output For A Ticker Memo

Use this order:

1. Decision-useful summary.
2. Timeline of important company events.
3. Company fundamentals.
4. What the company builds.
5. Hardware primer.
6. AI vertical-stack bottleneck relevance.
7. First-principles mechanism.
8. Evidence table with source quality.
9. Bull/base/bear cases.
10. Scenario branches and triggers.
11. Price/valuation math.
12. Known unknowns and disconfirming evidence.
13. Research tasks still required.
14. Utility, confidence, and risk scores.

## Common Commands

Initialize:

```bash
cargo run -p xstack-cli -- init
```

Add a curated source:

```bash
cargo run -p xstack-cli -- sources add --kind x-account --value @jukan05 --reason "AI infra supply chain"
```

Run fixture replay:

```bash
cargo run -p xstack-cli -- run --fixture examples/fixtures/posts.json
```

Write EOD report:

```bash
cargo run -p xstack-cli -- report eod
```

Write company/ticker report:

```bash
cargo run -p xstack-cli -- report company --company Micron --ticker MU
```

Inspect or run the read-only market connector:

```bash
"${XSTACK_BACKPACK_BIN:-$HOME/.local/bin/xstack-backpack}" capabilities
"${XSTACK_BACKPACK_BIN:-$HOME/.local/bin/xstack-backpack}" bundle \
  --ticker NVDA,MSFT,MU,TSM,SPY \
  --history-from 2021-07-01 \
  --history-to 2026-07-30 \
  --calendar-from 2026-07-29 \
  --calendar-to 2026-08-05 \
  --benchmark SPY \
  --country US \
  --summary-only
```

Search existing reports before substantial edits:

```bash
cargo run -p xstack-cli -- report search "Micron"
cargo run -p xstack-cli -- report search "HBM"
```

For authenticated X capture and deterministic source ladders, read
[source capabilities](references/source-capabilities.md). Scheduled X capture is
permitted only when the authoritative workflow prompt or owner explicitly
authorizes the preconfigured connector. That approval never extends to editing a
scraper to bypass controls or to any mutation on X.

## Validation

After code changes:

```bash
cargo fmt
cargo check
cargo test
cargo test -p xstack-backpack
```

For report path changes:

```bash
cargo run -p xstack-cli -- --db .xstack/dev.sqlite3 init
cargo run -p xstack-cli -- --db .xstack/dev.sqlite3 run --fixture examples/fixtures/posts.json --source-id fixture
cargo run -p xstack-cli -- --db .xstack/dev.sqlite3 report eod
cargo run -p xstack-cli -- --db .xstack/dev.sqlite3 report company --company "Micron" --ticker MU
cargo run -p xstack-cli -- report search "Micron"
```

For scheduled-report changes, also run the preflight, parse its JSON, verify that
every report use of “unavailable” has a matching terminal capability record, and
confirm that `NOT_YET_OPEN` and `NOT_COLLECTED_OPTIONAL` did not cause
`report_status: DEGRADED`.
