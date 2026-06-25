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

Keep the **living spec** living. Find every place shipped code contradicts the spec, in both
directions, and surface it. The companion guard `record` writes the spec; this one checks code
against it. The agent surfaces the conflict; the human decides which side is wrong.

## What counts as drift

The living spec is glossary plus ADRs, so check code against both:

- **Decisions / rules / constraints (ADRs).** Code violates a decision or rule an ADR asserts, or an
  ADR still asserts something the code has moved past.
- **Terms (glossary).** Code uses a word the glossary bans (`_Avoid_`), names something against the
  canonical term, or uses a concept that has no entry yet.

Not drift: shipped behavior that no rule, decision, or term governs. The spec doesn't track
behavior; don't flag code just for existing.

## Human-in-the-loop contract

- **Autonomous:** scanning code against the spec, identifying contradictions, presenting each with
  enough context to decide.
- **Gated (hard, human picks):** every finding stops for a decision. Never silently edit code or
  spec to "fix" drift.

## Steps

1. Read the living spec, glossary and ADRs. Auto-detect locations (`docs/GLOSSARY.md`;
   `docs/decisions/`|`docs/adr/`), else the agent doc, else ask. Skip superseded ADRs: one carrying
   a `Status: superseded by ...` line, or one another ADR's `Supersedes:` line points to (check both
   directions). Audit code only against live decisions.
2. For each spec claim, check whether the code still honors it, both directions (code vs spec, spec
   vs code).
3. Present each finding: the claim, where the spec says it, where the code diverges, the resolutions.
   One finding per independently-fixable divergence; don't merge unrelated drifts into one.
4. **The human picks** per finding:
   - **Fix the code** to honor the spec, or
   - **Change the spec.** For a reversal, write a superseding ADR via `record` (the merits gate
     applies); for a term (banned word, wrong name, or a concept with no entry), add or update the
     glossary via `record`.
5. Apply only the chosen resolution; re-check to confirm it's gone.
