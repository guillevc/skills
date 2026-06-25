---
name: spec-out
description: Spec out a feature or design through a relentless interview, landing the resolved facts in the living spec. User-invoked.
disable-model-invocation: true
---

# Spec-out

Turn a fuzzy idea into living spec. Interrogate a plan or design branch by branch until nothing
important is left implicit, then let the resolved facts become durable entries. This is the
*discovery* half of the loop: the human answers, the agent questions. Writing is `record`'s job.

## Human-in-the-loop contract

- **Autonomous:** asking questions, proposing options, mapping the open decision tree, reading the
  existing spec to avoid re-litigating settled ground.
- **Gated:** `spec-out` writes nothing itself. When a fact resolves, it hands off to `record`
  (which carries the write gate). The human decides what gets recorded.

## Loop

1. **Read the ground first.** Skim the living spec (glossary and ADRs, wherever the project keeps
   them). Don't re-open anything settled there; treat settled records as given unless the human
   reopens them. If they do, that's a *supersede* decision, not a quiet override.
2. **Map the tree.** Restate the plan as a small set of open branches and unknowns, named so each
   can be tracked to closure.
3. **Interrogate, one branch at a time.** Ask the single sharpest question that most reduces
   uncertainty: one that exposes a hidden assumption, an edge case, a failure mode, or a conflict
   with an existing decision. One focused question per turn beats a wall of them.
4. **Use the project's vocabulary.** Phrase questions in glossary terms; when a new term surfaces,
   resolve it and hand it to `record`.
5. **Done = nothing important left implicit.** Every branch is either resolved or explicitly parked.
   A resolved branch that's a durable fact goes to `record`; one that's just behavior is left for
   the build.

## Output

- A concise resolution per branch.
- **Acceptance-shaped** statements for anything observable, phrased so they could brief a build
  (or seed a roadmap entry, if you keep one).
- A handoff list: which resolutions `record` should write to the living spec.
