---
name: spec-out
description: Spec out a feature or design through a relentless interview, landing the resolved facts in the living spec. User-invoked.
disable-model-invocation: true
argument-hint: <feature or design to spec out>
---

# Spec-out

Turn a fuzzy idea into living spec. Interrogate a plan branch by branch until nothing important is
implicit, then hand the resolved facts to `record` to write. You question; the human answers. You
write nothing yourself.

## Human-in-the-loop contract

- **Autonomous:** asking, proposing options, mapping the decision tree, reading the existing spec.
- **Gated:** every write goes through `record`. The human decides what gets recorded.

## Loop

1. **Read the ground.** Skim the spec (glossary, ADRs). Treat settled records as given; reopening one
   is a *supersede*, not a quiet override.
2. **Map the tree.** Restate the plan as named open branches.
3. **Interrogate one branch at a time.** Ask the single sharpest question that most cuts uncertainty:
   a hidden assumption, edge case, failure mode, or conflict with an existing decision. Recommend
   your best answer with it. If the code or spec already answers, read it instead of asking.
4. **Use the project's vocabulary.** Phrase questions in glossary terms; flag any fuzzy or
   conflicting term.
5. **Done = nothing important left implicit.** Each branch is resolved or explicitly parked.

## Output

- One concise resolution per branch, **acceptance-shaped** for anything observable.
- A handoff list of resolved durable facts. `record` classifies each into glossary or ADR; don't
  pre-route them.
