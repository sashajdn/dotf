---
name: ibkr
description: Read, synchronize, verify, and project the user's Interactive Brokers portfolio through the local read-only IBKR Flex oracle. Use when Codex needs current broker-backed positions, quantities, marks, values, cash by currency, prior-day account state, portfolio coverage diagnostics, or broker reconciliation for xstack/pre-market investment analysis. Never use it to place, change, or cancel orders.
---

# IBKR Read-Only Portfolio

Use the installed `xstack-broker` binary as the only interface to private IBKR
state. It is a daily accounting oracle, not a trading client.

## Safety boundary

- Never place, submit, transmit, cancel, replace, or modify an order.
- Never open or print `ibkr.env`, identity files, raw/quarantine XML, or private
  snapshot JSON directly.
- Never print credentials, account identifiers, broker IDs, or raw XML.
- Never pass a token or Query ID as a command argument.
- Never use `cargo run` for a live broker operation.
- Do not install cron jobs or LaunchAgents. Let the Codex scheduled task invoke
  this skill.
- Treat Activity Flex state as prior-session accounting data, not proof of live
  quotes, working orders, fills after the cutoff, buying power, or margin state.

## Read workflow

Run commands from any directory using the installed binary:

```bash
"$HOME/.local/bin/xstack-broker" status
```

Proceed only when `ready=true`. Then run:

```bash
"$HOME/.local/bin/xstack-broker" sync
"$HOME/.local/bin/xstack-broker" verify-latest
"$HOME/.local/bin/xstack-broker" portfolio-latest
```

Interpret the stages as follows:

1. `sync` retrieves the configured Flex query, encrypts raw XML before durable
   storage, validates it, pseudonymizes identifiers, and signs the normalized
   snapshot.
2. `verify-latest` proves snapshot/signature integrity and prints only gate
   metadata.
3. `portfolio-latest` verifies the signature again and emits the permitted
   account-identifier-free projection containing positions, NAV, and cash.

Never bypass a failed parser, signature, coverage, or reconciliation check.

## Decision gate

Before using the projection, inspect:

- `captured_at_utc` and each statement date;
- `coverage.state` and `coverage.missing_sections`;
- `reconciliation_state`;
- `working_order_state`;
- `guidance_gate`;
- `parser_warnings`.

If coverage is incomplete, reconciliation is conflicted, the snapshot is stale,
or working-order state is unknown, write:

`BROKER STATE UNRECONCILED — NO ACTION-SPECIFIC GUIDANCE`

Positions and cash may still be described as an as-of accounting seed. Do not
provide personalized sizing, entry/exit prices, add/trim instructions, order
changes, or claims about current fills. Continue unaffected market and thesis
research.

Classify a signature-valid projection with disclosed coverage gaps as
`AVAILABLE_PARTIAL / UNRECONCILED`, not unavailable. Reserve `UNAVAILABLE` for a
failed status/discovery probe, one retry, and failure of every permitted safe
projection path. Never let a partial broker projection imply that the broker
tool itself is absent.

## Current known Flex-template gaps

Until a later verified snapshot proves otherwise, expect these live-query gaps:

- Net Asset Value section absent;
- Conid and listing/asset classification absent from position rows;
- tax-lot detail absent;
- cash-transaction amount/type fields incomplete;
- working orders unavailable from Activity Flex.

The projection must remain `Conflicted` while these gaps exist. Do not infer
missing values from wiki notes or market data.

## Credential setup

Normal scheduled reads require no interactive login. Credentials reside in the
owner-only file:

```text
~/.local/share/xstack/private/broker/ibkr.env
```

Only when the user explicitly asks to configure or rotate credentials, and both
variables are already exported in their dedicated Terminal, run:

```bash
"$HOME/repos/xstack/tools/broker/configure-env-file.sh"
```

Do not ask the user to paste either value into chat.

## Failure behavior

If `status`, `sync`, verification, or projection fails:

1. retain the exact safe error message;
2. if the error is caused by the execution sandbox or secret-operation boundary,
   retry the same installed read-only command once through the platform's normal
   approval/escalation path; never work around the boundary;
3. do not inspect secret or raw files;
4. classify the result with the canonical capability taxonomy;
5. mark portfolio coverage unavailable or partial;
6. suppress action-specific guidance;
7. continue any required daily report;
8. add a concise portfolio-access footnote with source, attempt time, retry,
   exact safe error, freshest substitute, and decision impact.

## Coverage-promotion checklist

Do not promote the oracle beyond `AVAILABLE_PARTIAL / UNRECONCILED` until a
verified projection demonstrates the required fields. Check the Flex template
for NAV, cash controls, instrument/listing metadata, lots, fills, and transaction
fields. Treat working-order visibility as a separate capability: Activity Flex
does not prove it. A future read-only TWS or Client Portal adapter requires
separate explicit approval and must preserve this skill's no-order-mutation
boundary.

Improved field coverage alone does not open the guidance gate. Coverage,
signature verification, freshness, reconciliation, working-order visibility,
and any required buying-power/margin controls must each pass independently.
