---
name: init-spec
description: Bootstrap a living spec on an existing codebase by extracting the terms and decisions already baked into the code. Run once when adopting living-spec. User-invoked.
disable-model-invocation: true
argument-hint: <optional: a path or area to focus on>
---

# Init-spec

Cold-start the **living spec** on a repo that doesn't have one yet. Read the existing code and
reverse-engineer the spec that's already implicit in it: the project's vocabulary and the decisions
baked into how it's built. You propose; `record` writes; the human ratifies.

This runs once, at adoption. Ongoing work uses the guards (`record`, `audit`) and `spec-out`.

## Human-in-the-loop contract

- **Autonomous:** surveying the codebase, extracting candidates, drafting the proposal.
- **Gated:** every write routes through `record`, so the three-test gate and ratification apply.
  Nothing lands without an explicit go-ahead.

## Steps

1. **Check it's needed.** If a spec already exists (`docs/GLOSSARY.md`, `docs/decisions/` or
   `docs/adr/`), stop: the repo is past cold-start. Point the human at `record` and `audit`.
2. **Survey the codebase.** Read the code, README, and agent doc (`CLAUDE.md`/`AGENTS.md`). Pull two
   things:
   - **Ubiquitous language:** the recurring domain nouns the code leans on (entities, key concepts).
   - **Decisions already baked in:** the datastore, the protocol between services, a hard limit, a
     deliberate deviation.
3. **Filter hard.** Keep only ADR-worthy decisions: each must be hard to reverse, surprising without
   context, and a real trade-off. Most code choices fail this; drop them. The value is the filter,
   not a dump. Glossary candidates stay if they're load-bearing vocabulary, not incidental names.
4. **Propose.** Present the draft: glossary terms (one-line meaning each) and ADR-worthy decisions
   (1-3 sentence rationale each). The human edits, cuts, and approves.
5. **Write the approved set via `record`.** It classifies each into glossary or ADR, applies the
   gates, and creates the docs on first entry. One fact, one home.
