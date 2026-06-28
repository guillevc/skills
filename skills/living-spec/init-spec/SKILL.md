---
name: init-spec
description: Bootstrap a living spec on an existing codebase by extracting the terms and decisions already baked into the code. Run once when adopting living-spec. User-invoked.
disable-model-invocation: true
argument-hint: <optional path or area to focus on>
---

# Init-spec

Cold-start the **living spec** on a repo that has none: reverse-engineer the vocabulary and decisions
already implicit in the code. You propose; `record` writes; the human ratifies. Runs once, at
adoption.

## Steps

1. **Check it's needed.** If a spec exists, stop and point the human at `record` and `audit`. Check
   every home `record` writes to: `docs/GLOSSARY.md`, `docs/decisions/`, and the agent doc
   `CLAUDE.md`/`AGENTS.md` for an existing glossary or ADR section, its fallback home when no `docs/`
   structure exists.
2. **Survey.** Read the code, README, and agent doc. Pull the **ubiquitous language** (recurring
   domain nouns) and the **decisions baked in** (datastore, protocols, hard limits, deliberate
   deviations).
3. **Filter hard.** Keep only ADR-worthy decisions: hard to reverse, surprising, a real trade-off.
   Most code choices fail; drop them. Keep terms that are load-bearing vocabulary, not incidental.
4. **Propose.** Present the draft: terms (one-line meaning) and decisions (1-3 sentence rationale).
   The human edits, cuts, approves.
5. **Write the approved set via `record`.**
