---
name: doc-route
description: >
  Route a resolved fact into the correct typed durable-doc slot — or to code/tests if it isn't a
  durable fact at all. Model-invoked whenever you are about to write documentation, record a
  decision, or capture something learned. Also triggers on "where does this go", "document this",
  "write this down", or /doc-route. Prevents behavior/progress from leaking into durable docs.
---

# Doc-route

The keystone guard. Before anything gets written to a durable doc, classify it and send it to the
right place. Most doc rot comes from putting the wrong *kind* of fact in a durable doc; this skill
is the gate that stops it.

## Human-in-the-loop contract

- **Autonomous:** classifying the fact, identifying the target slot, drafting the wording.
- **Gated (light confirm):** the human confirms the slot before the write. Routing is a *proposal*
  ("this is a decision → ADR"), not an action. Decisions that route to an ADR escalate to the hard
  gate in `new-adr` / `supersede-adr`.

## Doc locations

Auto-detect the durable docs by convention (`docs/standards.md`, `docs/architecture.md`,
`docs/decisions/` or `docs/adr/`, `docs/GLOSSARY.md` or `CONTEXT.md`, `docs/roadmap.md`). If a
project keeps them elsewhere, check its `CLAUDE.md`/`AGENTS.md`; else ask once. Create a doc lazily
on first real content — don't write a blank file. Where a sibling skill is named below, use it if
installed; otherwise do its action inline.

## The routing rule

Classify the fact, then send it to its slot:

| The fact is… | Goes to | Notes |
|---|---|---|
| A **rule** (must/should, API or engineering policy) | `standards` | feature-agnostic, normative |
| A **design or rationale** (why the system is shaped this way) | `architecture` | not shipped behavior |
| A **decision** (a consolidated choice: library, schema, protocol, deviation) | a new **ADR** | record it (use `new-adr` if installed); if it contradicts an existing ADR, supersede it (use `supersede-adr`) |
| A **term** (project vocabulary) | `glossary` | add the term (use `glossary-guard` if installed) |
| A **planning item** (unbuilt work, acceptance) | `roadmap` | forward-only, shallow |
| **Shipped behavior / progress / status** | **code + tests** | NOT a durable doc — let tests capture it |

## The durable-fact test (apply before routing to any durable doc)

> Does this change a **rule, a design, or a decision**?

- **No** → it does not belong in a durable doc. It's behavior or progress → code/tests, or a roadmap
  tick. Stop; do not edit standards/architecture/ADRs.
- **Yes** → route per the table above, confirm the slot with the human, then write (or hand off).

## Steps

1. Restate the fact in one sentence.
2. Apply the durable-fact test. If it fails, say where it actually belongs and stop.
3. If it passes, name the target slot and draft the wording in that doc's style.
4. **Confirm the slot with the human** before writing. For decisions, use `new-adr` /
   `supersede-adr` if installed (they carry the hard gate); otherwise write the ADR into the ADR
   dir yourself, presenting the draft for approval first.
5. On confirmation, write only to the chosen slot. Don't restate the same fact in a second doc —
   one fact, one home.
