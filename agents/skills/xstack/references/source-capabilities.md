# XStack source capabilities

Read this reference when a scheduled or current-market workflow needs X,
live/fallback prices, crypto, FX/rates, options, short interest, or direct-flow
evidence.

## Availability contract

Use the canonical workflow's capability states. Perform capability discovery, a
functional probe, one retry, and a documented fallback before using
`UNAVAILABLE`. Preserve exact safe errors and timestamps. Never treat a source
state as a market signal.

## X discovery

The preconfigured local capture is an approved scheduled connector only when the
canonical prompt or owner explicitly permits it. Use the existing checked-in
scripts; do not write new scraping or access-control-bypass logic.

```bash
cd "$HOME/repos/xstack"
node tools/x/scrape-search.js \
  --preset ai-stack-priority \
  --since-hours 12 \
  --mode live \
  --limit 250 \
  --scrolls 6 \
  --user-data-dir "$HOME/.xstack/chrome-copy" \
  --output ".xstack/<run-id>-x-priority.json"
```

Use `--mode both` only for bounded ticker/bottleneck research. Use narrower
presets such as `ls-electric` or `800vdc` for confluence checks. Record preset or
queries, window, start/end time, result count, per-query errors, and the raw JSON
path. Zero results are not neutral sentiment unless coverage completion is
proved.

For an exact permitted permalink:

```bash
node tools/x/scrape-status.js \
  --url 'https://x.com/<handle>/status/<id>' \
  --user-data-dir "$HOME/.xstack/chrome-copy" \
  --output ".xstack/<run-id>.json"
```

Never post, message, like, follow, or change account state.

## Market prices and history

Use licensed or broker-backed market data first. For supported U.S. securities,
use `xstack-backpack` documented endpoints as fallback. Require the
`xstack.backpack/v1` envelope, `status: ok`, and persisted raw receipts in
scheduled work. If a quote endpoint fails, retry once; then use a primary or
exchange source where available, otherwise the latest completed close with an
explicit timestamp and market-state label.

Treat live-quote failure as decision-critical only when the run window or a
proposed action needs live/executable pricing. It is normally non-degrading in a
closed-session prior-close carry report when the completed close is sufficient.

Do not silently replace unsupported Asian listings, broker state, FX, rates,
options, or corporate-action reconciliation with Backpack.

## Crypto diagnostic

Use a reliable 24/7 spot venue first. The default credential-free probe is:

```text
https://api.coinbase.com/v2/prices/BTC-USD/spot
https://api.coinbase.com/v2/prices/ETH-USD/spot
```

Timestamp the observation and retain a receipt. If spot fails after retry, use
clearly labeled exchange-traded BTC/ETH proxies and their latest completed
session. Keep spot and ETF timestamps distinct.

## FX and rates

Prefer official central-bank, Treasury, or FRED observations. Label latest daily
official data `AVAILABLE_EOD`, not live. Use a reputable current market source
when live levels are decision-critical. Preserve series identifiers, observation
dates, units, and retrieval times.

Relevant FX pairs include USD/KRW, USD/JPY, and USD/TWD. Relevant rates include
the Treasury curve, real yields, and inflation expectations when material.

## Options, short interest, and direct flows

Collect only when supported by reliable Cboe, exchange, FINRA, issuer, or
licensed evidence and when decision-relevant. Otherwise classify
`NOT_COLLECTED_OPTIONAL`; do not degrade the report and do not make direct flow,
positioning, dealer-gamma, or short-interest claims. Price-relative-performance
signatures are not proof of flows.
