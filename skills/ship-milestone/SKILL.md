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
- **Gated (hard — outward):** durable-doc edits go through their own gate (via `doc-route` /
  `supersede-adr` if installed, else inline with the same draft-then-approve step). The PR is opened
  for **human review and merge** — the skill never merges. Each delta that reverses a decision stops
  for the human.

## Steps

1. **Discover deltas.** Find every place the milestone's code now diverges from the durable docs —
   the delta list, derived not bookkept. Use `drift-check` if installed; otherwise diff the code
   against the durable docs yourself, looking both ways (code vs doc, doc vs code).
2. **Fold back, by type.** For each delta, send it to its slot (use `doc-route` if installed;
   otherwise apply the routing directly):
   - rule changed → `standards`
   - design/rationale changed → `architecture`
   - decision made → new ADR (`new-adr`); decision reversed → superseding ADR (`supersede-adr`)
   - new term → glossary (`glossary-guard`)
   Trim any behavioral prose that crept into durable docs — shipped behavior lives in code/tests.
3. **Tick the roadmap.** Mark the milestone's acceptance items done; remove the shipped milestone
   from the roadmap (it's forward-only). Confirm the acceptance was actually met, observably.
4. **Run the finishing checks.** Use `finishing-check` if installed; otherwise run the project's
   verify command and assert doc coherence yourself before the PR.
5. **Open the PR.** Assemble a PR with the change, the folded-back doc edits, and a summary of
   decisions recorded. Open it for review. **Do not merge** — the human reviews and merges.

## Notes

- Orchestrator: each step names a sibling skill to use if installed, but states the action so it
  runs without them. Doc locations are auto-detected by convention (else the agent doc, else ask).
- No work-doc to delete — this system doesn't persist build scratch. If a milestone spanned
  multiple sessions, reconstruct context from the roadmap (the durable plan anchor), not a scratch
  file.
- If the project keeps no roadmap, skip step 3's roadmap mechanics and just fold back + PR.
