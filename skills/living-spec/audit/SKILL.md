---
name: audit
description: >
  Audit code against the living spec (ADRs and the glossary) and let the human resolve each
  contradiction. Use proactively whenever you write or change code that touches a documented
  decision, rule, or term, and after a build or before a commit/PR, even if the user doesn't ask.
  Also on "check for drift", "do the docs still match", "audit code vs spec", /audit, or when
  develop freezes. Reports; never auto-fixes. It stops and the human picks.
---

# Audit

Find where the code you touched contradicts the **living spec**, both directions, and surface it. The
human picks which side is wrong. Never auto-fix.

## What counts as drift

- **ADRs:** code violates a decision or rule, or an ADR asserts something the code has moved past.
- **Glossary:** code uses a banned word (`_Avoid_`), names something off the canonical term, or uses
  a concept with no entry.
- **Not drift:** shipped behavior no rule, decision, or term governs.

## Steps

1. Read the spec (glossary `docs/GLOSSARY.md`; ADRs `docs/decisions/`; else the agent
   doc; else ask). Skip superseded ADRs (a `Status: superseded by ...` line, or one another ADR's
   `Supersedes:` points to).
2. Check each live spec claim against the code, both directions.
3. Present each finding: the claim, where the spec says it, where the code diverges, the options.
   One finding per independently-fixable divergence. **Stop for the human to pick:** fix the code, or
   change the spec via `record`.
4. Apply only the chosen resolution; re-check to confirm it's gone.

**Scope.** Audit only what you touched. A whole-repo sweep is `reconcile`, a human-invoked skill;
never launch one on your own.
