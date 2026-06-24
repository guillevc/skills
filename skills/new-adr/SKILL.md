---
name: new-adr
description: >
  Draft an Architecture Decision Record for a consolidated choice (library, protocol, schema shape,
  deviation from a standard). Invoked by doc-route when a fact classifies as a decision, or directly
  via "write an ADR", "record this decision", /new-adr. Drafts for human ratification — ADRs are
  immutable, so nothing is written without an explicit go-ahead.
---

# New-adr

Record a consolidated decision as an immutable ADR. One decision per file. ADRs capture the durable
*why* — the reasoning that code can't express and that future work must not silently undo.

## Human-in-the-loop contract

- **Autonomous:** detecting that a fact is decision-shaped, drafting the ADR, picking the next number.
- **Gated (hard):** ADRs are immutable durable records. The human ratifies the full draft before it
  is written. Do not create an ADR from a choice that is still under debate — only from a
  *consolidated* one.

## When this fires

- `doc-route` classified a fact as a **decision**, or
- A consolidated choice was made: a library, protocol, schema shape, or a deliberate deviation from
  a standard.

If the decision *contradicts an existing ADR*, stop — use `supersede-adr` instead (never edit an
existing ADR).

## Don't write one yet if…

The choice is still being argued. ADRs record settled decisions, not the debate. If `unfold` is
still open on this branch, finish unfolding first. Premature ADRs freeze the wrong answer.

## Steps

1. Confirm the decision is consolidated (not mid-debate) and doesn't contradict an existing ADR.
2. Find the ADR directory and numbering — auto-detect (`docs/decisions/` or `docs/adr/`), else check
   the agent doc (`CLAUDE.md`/`AGENTS.md`) or ask; create the dir lazily if none exists. Pick the
   next id.
3. Draft ~10–25 lines using this template:

   ```markdown
   # <NNNN> — <decision stated as a choice>

   - **Status:** accepted
   - **Date:** <YYYY-MM-DD>

   ## Context
   <The forces that made a decision necessary — constraints, the problem, what was in tension.>

   ## Decision
   <What was chosen, stated plainly.>

   ## Consequences
   <What this enables and costs — the tradeoff accepted, not just the upside.>
   ```
4. **Present the full draft for ratification.** Do not write the file until the human approves.
5. On approval, write the new ADR file. Never modify existing ADRs from here.
