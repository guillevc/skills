---
name: drift-check
description: >
  Detect contradictions between code and the durable docs (ADRs, standards, architecture), then
  let the human decide how to resolve each one. Model-invoked while building or reviewing changes;
  also triggers on "check for drift", "do the docs still match", "audit docs vs code", or
  /drift-check. Never auto-fixes — it stops and the human picks.
---

# Drift-check

Find places where shipped code contradicts what the durable docs say, in both directions. This is
the executable form of "stop on drift": the agent surfaces the conflict, the human decides whether
the code is wrong or the doc is now wrong.

## Human-in-the-loop contract

- **Autonomous:** scanning code against the durable docs, identifying contradictions, presenting
  them with enough context to decide.
- **Gated (hard — human picks):** every finding stops for a decision. The agent never silently
  edits code or docs to "fix" drift. A doc fix that reverses a decision is done as a superseding ADR
  (use `supersede-adr` if installed).

## Config

Reads `.in-the-loop.json` for the durable-doc paths if present; otherwise auto-detect
(`docs/standards.md`, `docs/architecture.md`, `docs/decisions/` or `docs/adr/`). Where a sibling
skill is named below, use it if installed; otherwise do its action inline.

## Steps

1. Read the durable docs (standards, architecture, ADRs) — paths from config or auto-detected.
2. For each durable claim, check whether the code still honors it. Look both ways:
   - **Code contradicts a doc** — code violates a rule/decision/design the docs assert.
   - **Doc contradicts code** — a doc still asserts something the code has moved past (stale claim).
3. Present each finding as: the claim, where the doc says it, where the code diverges, and the two
   resolution paths.
4. **The human picks** per finding:
   - **(a) Fix the code** to honor the doc, or
   - **(b) Change the doc.** If this *reverses a decision*, don't edit the ADR — write a superseding
     one (use `supersede-adr` if installed). For a rule/design update, route it to the right doc
     (use `doc-route` if installed).
5. Apply only the chosen resolution. Re-run the relevant check to confirm the contradiction is gone.

## Use as delta source for ship-milestone

`ship-milestone` calls `drift-check` to *discover* what changed during a milestone — the deltas to
fold back into durable docs come from the real code↔doc diff, not a hand-kept work-doc list. Same
human-picks gate applies to each delta.

## Don't

- Don't fix drift silently — surfacing and deferring to the human is the whole point.
- Don't treat shipped-behavior mismatches as drift. Durable docs aren't supposed to track behavior;
  only flag contradictions of a *rule, design, or decision*.
