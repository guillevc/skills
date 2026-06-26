---
name: ship-out
description: Build a unit of work from the living spec. Brief it, implement, reconcile the spec, verify, and optionally commit or open a PR. Never merges. User-invoked.
disable-model-invocation: true
argument-hint: <goal, or a roadmap entry to build>
---

# Ship-out

Take a unit of work from goal to shipped. The **living spec** (glossary plus ADRs) is what you build
*from* and reconcile *to*. The goal comes from your prompt or a roadmap entry, neither privileged.
The brief is ephemeral; the spec is durable.

## Human-in-the-loop contract

- **Autonomous:** briefing, implementing, drafting the fold-back, running checks, assembling the PR.
- **Gated:** a new durable decision goes to `record`, never guessed. The commit/PR is outward:
  confirm it. **Never merge.**

## Steps

1. **Brief the goal.** Restate the goal plus the relevant spec as scope and acceptance, a tiny
   ephemeral brief. Confirm it only when the goal is non-trivial or the spec leaves real gaps.
2. **Build against the spec.** Default freely on local, reversible choices. Stop and ask only for a
   **durable decision** (cross-cutting or hard to reverse); hand it to `record`.
3. **Reconcile.** Run `audit` to surface where the new code diverges from the spec, and fold the
   deltas back via `record`: new or superseding ADRs, glossary updates. Trim behavioral prose that
   crept in. Surface pre-existing drift you didn't cause; don't fix it or grow this unit's scope.
4. **Verify.** Run the project's test command (`go.mod`→`go test ./...`, `package.json`→its test
   script, `justfile`/`Makefile`→the test target, else the agent doc or ask). Must pass.
5. **Deliver.** Optionally commit, or assemble a PR: the change, the spec edits, the decisions
   recorded. Confirm. **Never merge.**

## Notes

Ad-hoc work doesn't need `ship-out`; the guards (`record`, `audit`) fire during any work. The spec
carries a unit across sessions: if context is lost mid-build, reload the spec and goal and continue.
