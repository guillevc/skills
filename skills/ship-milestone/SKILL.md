---
name: ship-milestone
description: Build a milestone from the living spec — implement, reconcile docs, optionally commit or open a PR. Never merges.
disable-model-invocation: true
---

# Ship-milestone

Take a milestone from living spec to shipped. The typed durable docs *are* the spec — this skill
builds from them, then reconciles what the build learned back into them, so code and docs stay
coherent. No throwaway work doc: the spec is the durable docs, the deltas come from real state.

## Human-in-the-loop contract

- **Autonomous:** reading the living spec, implementing against it, drafting the fold-back edits and
  the PR, running the checks.
- **Gated:** durable-doc writes go through their own gate (via `doc-route` / `supersede-adr` if
  installed, else inline draft-then-approve). When the spec is ambiguous or a new durable decision
  is needed, **stop and ask** — never guess a decision. The commit/PR is **outward**: opened for
  human review and merge; the skill never merges.

## Steps

1. **Load the living spec.** Read the milestone's roadmap entry plus the durable docs it builds
   against — relevant ADRs, standards, architecture, glossary. Gather any missing context from the
   human now; don't proceed on a guess.
2. **Build against the spec.** Implement the milestone. Where the spec is silent or ambiguous, ask
   rather than invent. A choice that consolidates into a durable decision stops for the human and is
   recorded (use `new-adr` / `supersede-adr` if installed).
3. **Fold back, by type.** Reconcile what the build surfaced — new decisions and any code↔doc drift —
   into the typed docs (use `drift-check` to find drift and `doc-route` to route, if installed;
   otherwise diff and route inline):
   - rule changed → `standards`
   - design/rationale changed → `architecture`
   - decision made → new ADR (`new-adr`); decision reversed → superseding ADR (`supersede-adr`)
   - new term → glossary (`glossary-guard`)
   Trim any behavioral prose that crept into durable docs — shipped behavior lives in code/tests.
4. **Tick the roadmap.** Mark the milestone's acceptance done; remove the shipped milestone (the
   roadmap is forward-only). Confirm the acceptance was actually met, observably.
5. **Run the finishing checks.** Use `finishing-check` if installed; otherwise run the project's
   verify command and assert doc coherence yourself.
6. **Deliver.** Optionally commit, or assemble a PR with the change, the folded-back doc edits, and
   a summary of decisions recorded. Both are **outward** — confirm with the human. **Never merge.**

## Notes

- Orchestrator: each step names a sibling skill to use if installed, but states the action so it
  runs without them. Doc locations are auto-detected by convention (else the agent doc, else ask).
- The living spec carries the milestone across sessions — no scratch file to persist or delete. If
  context is lost mid-build, reload the spec (step 1) and continue.
- If the project keeps no roadmap, skip step 4 and build → fold back → deliver.
