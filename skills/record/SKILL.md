---
name: record
description: >
  Write a resolved fact into the living spec (a glossary term or an ADR) and keep it coherent.
  Use proactively the moment a durable fact settles, even if the user never says "record" or "ADR":
  a decision made, a library/tool/protocol/schema chosen, a rule or constraint set, a term's meaning
  pinned, or a past decision reversed. Also on "record this", "write an ADR", "add to the glossary",
  "supersede that decision", /record, or when spec-out, ship-out, or audit needs to write the spec.
  Drafts for human ratification; durable writes are gated.
---

# Record

The single writer of the **living spec**, which holds two kinds of durable knowledge:

- **Glossary**: what words mean (living, edited in place).
- **ADRs**: what was decided (immutable; reverse only by superseding). Everything durable that isn't
  a term is an ADR: architecture, rules, constraints, technology choices, deviations.

`audit` checks code against what you record.

## Human-in-the-loop contract

- **Autonomous:** classifying the fact, choosing the slot, drafting the entry.
- **Gated (light):** glossary edits. Confirm before writing.
- **Gated (hard):** ADRs are immutable. Present the draft, get an explicit go-ahead, then write.
  Never edit an existing ADR in place.

## Routing

**Durable-fact test:** does this change a rule, design, decision, or term? If not, it's behavior or
progress: leave it to code and tests, and stop. If so:

| Fact | Slot |
|---|---|
| a **term** (project vocabulary) | glossary entry |
| a **decision / rule / constraint / design / deviation** | a new **ADR** (supersede if it reverses one) |

Doc locations: glossary `docs/GLOSSARY.md`; ADRs `docs/decisions/` or `docs/adr/`. Else the agent
doc (`CLAUDE.md`/`AGENTS.md`), else ask. Create a doc lazily on the first real entry.

## Glossary

The project's **ubiquitous language**: the canonical term per concept, mirrored everywhere and
enforced against code by `audit`. A pure term list, no implementation or decisions. A relationship
("an Order owns its line items") is a decision, so it's an ADR. Sharpen fuzzy terms; keep the
avoid-list current.

```
**Term**:
One or two sentences. What it IS, not what it does.
_Avoid_: synonym1, synonym2
```

## ADR format (light)

```markdown
# <NNNN>: <decision stated as a choice>

<1-3 sentences: context, decision, why.>
```

Add `Considered options` or `Consequences` only when they earn it. Number by incrementing the
highest id in the dir.

**Status:** no `Status` line means live. Never write `Status: accepted`. The only status ever written
is `Status: superseded by <id>`, so a reader (and `audit`) tells live from dead by that one line.

### Record an ADR only when all three hold

1. **Hard to reverse.**
2. **Surprising without context.**
3. **A real trade-off.**

If any fail, skip it.

## Superseding

Reverse an ADR only by writing a new one that supersedes it.

**Merits gate (first):** argue the reversal on technical merits, fresh, as if no ADR existed. Never
"the old one is inconvenient." If the merits favor change, supersede; else keep it and record nothing.

Then: draft the new ADR with a `Supersedes: <old-id>` line; add `Status: superseded by <new-id>`
under the old title (never touch its body). Write both or neither.

## Steps

1. Restate the fact in one sentence; run the durable-fact test and route it.
2. For an ADR reversing another, run the merits gate, then the three-test gate.
3. Draft in the slot's format.
4. Confirm (hard gate for ADRs), then write. One fact, one home.
