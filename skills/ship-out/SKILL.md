---
name: ship-out
description: Build a unit of work from the living spec — brief it, implement, reconcile the spec, verify, and optionally commit or open a PR. Never merges. User-invoked.
disable-model-invocation: true
---

# Ship-out

Take a unit of work from goal to shipped. The **living spec** (glossary + ADRs) is what you build
*from* and reconcile *to*. The goal can come from your prompt or a roadmap entry — neither
privileged. No work doc, no persisted plan: the brief is ephemeral, the spec is durable.

## Human-in-the-loop contract

- **Autonomous:** briefing the goal, implementing against the spec, drafting the fold-back, running
  the checks, assembling the PR.
- **Gated:** when the spec is silent or a new durable decision is needed, **stop and ask** — never
  guess a decision (hand it to `record`). The commit/PR is **outward**: opened for human review and
  merge. **Never merge.**

## Steps

1. **Brief the goal.** Take the goal (prompt or roadmap entry) and the relevant living spec, and
   restate it as scope + acceptance — a tiny ephemeral brief. Confirm it with the human. Don't
   proceed on a guess; gather missing context now.
2. **Build against the spec.** Implement. Where the spec is silent or ambiguous, ask rather than
   invent. A choice that consolidates into a durable decision stops and goes to `record`.
3. **Reconcile.** Run `audit` to surface where the new code diverges from the spec; fold the
   deltas back via `record` (new/superseding ADRs, glossary updates). Trim any behavioral prose that
   crept into the spec — shipped behavior lives in code + tests.
4. **Verify.** Run the project's verify command (detect it: `go.mod` → `go test ./...`,
   `package.json` → its test script, a `justfile`/`Makefile` → the test target; else read the agent
   doc or ask). Must pass.
5. **Deliver.** Optionally commit, or assemble a PR with the change, the folded-back spec edits, and
   a summary of decisions recorded. Both are outward — confirm with the human. **Never merge.**

## Notes

- Ad-hoc work doesn't need `ship-out` — just code; the guards (`record`, `audit`) fire during any
  work. `ship-out` is the deliberate "build this unit properly and deliver it" move.
- The living spec carries a unit across sessions — no scratch file. If context is lost mid-build,
  reload the spec and the goal, and continue.
