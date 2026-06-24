---
name: ship-milestone
description: >
  Close out a milestone: discover what changed, fold durable deltas back into the typed docs, tick
  roadmap acceptance, and open a PR for human review. Invoked via "ship this", "close the milestone",
  "wrap up and open a PR", or /ship-milestone. Derives deltas from the real code↔doc diff (via
  drift-check), not from a hand-kept work doc. Opens the PR but never merges.
---

# Ship-milestone

The lifecycle closer. Replaces the heavyweight "build doc → fold back → delete" ritual: deltas are
discovered from real state, durable facts are folded into their typed homes, and the human reviews
the result as a PR.

## Human-in-the-loop contract

- **Autonomous:** running drift-check to find deltas, drafting the fold-back edits, drafting the
  roadmap ticks, assembling the PR.
- **Gated (hard — outward):** durable-doc edits route through `doc-route` / `supersede-adr` (their
  own gates apply). The PR is opened for **human review and merge** — the skill never merges. Each
  delta that reverses a decision stops for the human (via `supersede-adr`).

## Steps

1. **Discover deltas.** Run `drift-check` to surface every place the milestone's code now diverges
   from the durable docs. This is the delta list — derived, not bookkept.
2. **Fold back, by type.** For each delta, route via `doc-route`:
   - rule changed → `standards`
   - design/rationale changed → `architecture`
   - decision made → `new-adr`; decision reversed → `supersede-adr`
   - new term → `glossary-guard`
   Trim any behavioral prose that crept into durable docs — shipped behavior lives in code/tests.
3. **Tick the roadmap.** Mark the milestone's acceptance items done; remove the shipped milestone
   from the roadmap (it's forward-only). Confirm the acceptance was actually met, observably.
4. **Run finishing-check.** Invoke `finishing-check` so the universal coherence checks and the
   project's `verify`/`invariants` gates pass before the PR.
5. **Open the PR.** Assemble a PR with the change, the folded-back doc edits, and a summary of
   decisions recorded. Open it for review. **Do not merge** — the human reviews and merges.

## Notes

- No work-doc to delete — this system doesn't persist build scratch. If a milestone spanned
  multiple sessions, reconstruct context from the roadmap (the durable plan anchor), not a scratch
  file.
- If `layers.roadmap` is false in config, skip step 3's roadmap mechanics and just fold back + PR.
