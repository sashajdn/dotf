---
name: eng-task
description: Execute a scoped codebase change from system understanding through implementation, review, and verification. Use for engineering delivery, not a standalone design plan or code review.
---

# Engineering task

Produce two outcomes: a shared mental model that lets the engineer challenge the design, and a small, production-worthy change whose guarantee and limits are clear from code and evidence. Adapt the depth, artifacts, and approval cadence to the task. User instructions and applicable repository instructions take precedence.

## 1. Establish the contract

- Read the task, applicable `AGENTS.md` files, relevant code, tests, history, and operational configuration before editing. Explore broadly enough to find the real source of truth and side effects; keep the change itself narrow.
- State the problem, success criteria, affected actors, entry points, state transitions, downstream effects, and rollout constraints. Separate facts verified in code or data from assumptions.
- Assess security and performance where the task reaches them: trust boundaries, authorization and races; hot-path latency, I/O, allocations, state touched, and determinism. Do not turn a local change into an unrelated audit.
- For funds, authorization, deletion, or other high-impact changes, write the invariant before designing the fix. Trace every route to the irreversible effect. Identify when inputs become authoritative, who may change them, and how the decision stays valid at the side-effect boundary. For batch or cursor jobs, define whether partial success is allowed and what completeness signal justifies advancing state.
- Ask about one or more unresolved decisions only when the answer would materially change the solution and cannot be inferred. Ask early, continue independent work, and preserve answers and authorizations across turns.

## 2. Design and build shared understanding

- Compare plausible solutions when the choice is consequential. Choose the least complex design that satisfies the complete invariant; account for legitimate operations, migration, rollback, performance, and review cost. Explain why discarded alternatives fail or cost more.
- Invoke `$eng-shared` to build the engineer's mental model of the current system, problem, design, and alternatives. Use its local website and visual workflow at the depth the task needs.
- Follow the user's requested cadence. If they ask to approve a design or each logical code block, present a concrete, reviewable proposal and wait at that boundary. Otherwise progress without routine permission requests. Approval of one step persists for its dependent work.

## 3. Implement in short loops

- Make the smallest complete change in the current checkout. Reuse domain operations and local conventions; add schema, approval workflows, abstractions, or comments only when the invariant requires them. Comments should explain a lasting why.
- Use focused tests during implementation when they expose the business rule, help localize a failure, or the user requests TDD. Do not rerun expensive checks after every small edit. A full Rust workspace suite is usually CI's job unless the user or repository requires it.
- Attack the change as an adversary or skeptical operator: alternate entry points, multi-role actors, stale state, concurrency, partial batches, bad upstream data, restart and retry, and effects outside the edited file. Check the actual side effect and persisted state, not only an HTTP response.
- Revise the design when a bypass or unnecessary complexity appears. Subtract code and tests that do not defend behavior. Use independent, bounded research or review agents when requested or when they materially improve scrutiny; give them the goal, invariant, constraints, and enough source context to assess the change.

## 4. Review and verify proportionately

- Inspect the complete diff with no attachment to the design. For each reviewer finding, verify the claimed path against current code. Fix material issues; explain rejections using impact, likelihood, detectability, and the invariant. Do not dismiss an issue solely because it is outside the changed lines or unlikely.
- Choose evidence layers to match failure cost: code-path reasoning; focused unit or property tests; API, persistence, and integration tests; SQL or migration validation; concurrency, fault, load, benchmark, or one-off probes; independent review; and CI. Add a safe, authorized one-off check when it answers a material question, then decide whether it belongs in the permanent suite. Tests of business behavior are more valuable than tests that merely restate SQL or implementation details.
- Follow repository validation commands after the final relevant edit. Run the smallest local selections that cover changed behavior and affected callers; broaden only for a concrete risk or required gate. Report environment-dependent tests that could not run. Passing checks support a claim but do not prove absence of bugs: explain the guarantee from the code and state remaining assumptions.
- Distinguish implementation readiness from rollout readiness. Identify migrations, backfills, feature flags, dual-running, observation, and rollback constraints where they matter.

## 5. Publish and hand off

- Follow the repository's branch and PR rules. Commit coherent changes. If rebasing, verify the base and the resulting diff; a normal push may fail after rewritten commits. Use an exact-SHA `--force-with-lease` when necessary, never a blind force push, and verify the remote head.
- When publication is authorized, monitor `gh` checks to completion on the exact pushed SHA. Investigate and fix substantive failures; distinguish code faults from infrastructure failures. Recheck reviews after pushes, respecting PR comment and reviewer-request rules.
- Remove only task-owned temporary resources. Do not delete shared caches, unrelated files, or an artifact the engineer is still reviewing.
- Report the invariant and enforcement point, changed files, exact checks and results, CI/PR SHA, rollout constraints, and remaining risks. Make it possible for a skeptical peer to review the few lines that carry the guarantee.
