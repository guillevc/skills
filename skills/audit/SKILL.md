---
name: audit
description: >
  Audit code against the living spec (ADRs and the glossary) and let the human resolve each
  contradiction. Use proactively whenever you write or change code that touches a documented
  decision, rule, or term, and after a build or before a commit/PR, even if the user doesn't ask.
  Also on "check for drift", "do the docs still match", "audit code vs spec", /audit, or when
  ship-out reconciles. Reports; never auto-fixes. It stops and the human picks.
---

# Audit

Keep the **living spec** living. Find every place shipped code contradicts the spec, both
directions, and surface it. `record` writes the spec; you check code against it. You surface the
conflict; the human decides which side is wrong.

## What counts as drift

The spec is glossary plus ADRs:

- **ADRs:** code violates a decision or rule, or an ADR asserts something the code has moved past.
- **Glossary:** code uses a banned word (`_Avoid_`), names something off the canonical term, or uses
  a concept with no entry.

Not drift: shipped behavior no rule, decision, or term governs. The spec doesn't track behavior.

## Human-in-the-loop contract

- **Autonomous:** scanning, identifying contradictions, presenting each with enough context to decide.
- **Gated (hard):** every finding stops for a decision. Never silently edit code or spec to "fix"
  drift.

## Steps

1. Read the spec. Locations: `docs/GLOSSARY.md`; `docs/decisions/`|`docs/adr/`, else the agent doc,
   else ask. Skip superseded ADRs: one with a `Status: superseded by ...` line, or one another ADR's
   `Supersedes:` points to. Audit against live decisions only.
2. Check each spec claim against the code, both directions.
3. Present each finding: the claim, where the spec says it, where the code diverges, the options. One
   finding per independently-fixable divergence.
4. **The human picks:** fix the code, or change the spec via `record` (a reversal is a superseding
   ADR; a term issue is a glossary edit).
5. Apply only the chosen resolution; re-check to confirm it's gone.
