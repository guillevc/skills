---
name: supersede-adr
description: >
  Reverse or replace an existing decision by writing a new superseding ADR and flipping the old one
  to superseded — never by editing the old ADR in place. Invoked by drift-check or unfold when a new
  decision contradicts a settled ADR, or directly via "supersede ADR", "change that decision",
  /supersede-adr. Cross-file and irreversible-in-spirit, so it requires explicit human ratification.
---

# Supersede-adr

Decisions change; ADRs don't. When a settled decision is reversed, the mechanism is a *new* ADR that
supersedes the old one — preserving the history of why the choice was made and why it changed.

## Human-in-the-loop contract

- **Autonomous:** drafting the superseding ADR, identifying which ADR it replaces, drafting the
  status flip.
- **Gated (hard — cross-file):** this writes a new immutable record *and mutates another file's
  status*. The human ratifies both the new ADR and the supersede link before anything is written.

## The merits gate

A decision is only reopened on its **merits** — never because it's inconvenient, and never defended
just because an ADR asserts it. Before superseding:

1. Argue the technical merits of the change fresh, as if no ADR existed.
2. If the merits favor change, supersede. If they don't, keep the existing ADR and record nothing.

This is the only sanctioned way to override an ADR. Silent contradiction in code is drift (see
`drift-check`), not a decision.

## Steps

1. Identify the existing ADR being reversed (ADR dir from `.in-the-loop.json` `docs.adr_dir` if
   present, else auto-detect `docs/decisions/` or `docs/adr/`).
2. Confirm the merits favor change (see merits gate above).
3. Draft the new ADR using this template, including a **Supersedes: <old-id>** reference:

   ```markdown
   # <NNNN> — <decision stated as a choice>

   - **Status:** accepted
   - **Date:** <YYYY-MM-DD>
   - **Supersedes:** <old-id>

   ## Context
   <The forces driving the reversal — what changed since the old decision.>

   ## Decision
   <The new choice.>

   ## Consequences
   <What this enables and costs versus the superseded decision.>
   ```
4. Draft the status change to the old ADR: `status: superseded` with a **Superseded by: <new-id>**
   pointer. Do not alter the old ADR's body — only its status/header.
5. **Present both edits for ratification.** Nothing is written until the human approves the pair.
6. On approval, write the new ADR and apply the status flip to the old one — atomically, both or
   neither.

## Note

Foundational ADRs stay full even when superseded; low-value superseded ADRs may be tombstoned
(reduced to a pointer). Ask the human which when the old ADR is trivial.
