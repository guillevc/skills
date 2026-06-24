---
name: unfold
description: >
  Explore a plan or design through relentless back-and-forth until every branch of the decision
  tree is open and resolved. Use when the user says "unfold", "let's think this through",
  "grill me", "poke holes in this", "what am I missing", or invokes /unfold — or before starting
  any non-trivial feature, design, or architectural change. The skill explores and questions; it
  does not write durable docs itself (it hands resolved points to doc-route).
---

# Unfold

Open a plan or design branch by branch. Interrogate assumptions, surface edge cases, and keep
the back-and-forth going until nothing important is left implicit. This is the *exploration* half
of the loop — the human answers, the agent questions. Resolution and durable writes happen later,
through `doc-route` and the ADR skills.

## Human-in-the-loop contract

- **Autonomous:** asking questions, proposing options, summarizing the open decision tree, reading
  existing docs to avoid re-litigating settled ground.
- **Gated:** nothing here writes durable state. `unfold` never edits docs or code. When a branch
  resolves into a fact worth keeping, it *proposes* handing off to `doc-route` / `new-adr` — the
  human decides whether to land it.

## Loop

1. **Read the ground first.** Load the project config (`.in-the-loop.json`) and skim the durable
   docs it points to — standards, architecture, existing ADRs, glossary, roadmap. Do not re-open
   anything already settled there; treat settled records as given unless the human reopens them.
2. **Map the tree.** State the plan/design back as a small set of open branches and unknowns. Name
   them so each can be tracked to closure.
3. **Interrogate, one branch at a time.** Ask the sharpest question that would most reduce
   uncertainty. Prefer questions that expose a hidden assumption, an edge case, a failure mode, or
   a conflict with an existing decision. One focused question per turn beats a wall of them.
4. **Use the project's vocabulary.** Phrase questions in glossary terms. If a new term surfaces that
   isn't defined, flag it and propose handing to `glossary-guard` — don't let undefined language
   accumulate.
5. **Watch for authority conflicts.** If a branch contradicts a settled ADR or standard, do not
   silently re-decide. Surface the conflict, argue the *merits* fresh (never "a doc says so"), and
   if the merits favor change, propose `supersede-adr` rather than quietly overriding.
6. **Keep going until typed-exit.** Done is not "feels resolved." Done is: **every branch maps to a
   slot** — a rule (→ standards), a design choice (→ architecture), a decision (→ ADR), a behavior
   (→ code/tests), or a planning item (→ roadmap). An unmapped branch means keep unfolding.

## Output

When the tree is fully open, produce:

- A concise resolution per branch, each tagged with its target slot.
- **Acceptance-shaped** statements for anything observable — phrased so they could drop straight
  into the roadmap as acceptance criteria, not freeform prose.
- A short list of proposed hand-offs: which resolutions want `doc-route`, `new-adr`, or
  `supersede-adr`.

Then stop and let the human decide what to land. Do not write docs from here.
