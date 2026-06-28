---
name: record
description: >
  Write a resolved fact into the living spec (a glossary term or an ADR) and keep it coherent.
  Use proactively the moment a durable fact settles, even if the user never says "record" or "ADR":
  a decision made, a library/tool/protocol/schema chosen, a rule or constraint set, a term's meaning
  pinned, or a past decision reversed. Also on "record this", "write an ADR", "add to the glossary",
  "supersede that decision", /record, or when develop or audit needs to write the spec.
  Drafts for human ratification; durable writes are gated.
---

# Record

The single writer of the **living spec**: the **glossary** (what words mean, edited in place) and
**ADRs** (what was decided, immutable, reversed only by superseding).

## Gates

- **Autonomous:** classify the fact, choose the slot, draft the entry.
- **Light:** glossary edits; confirm before writing.
- **Hard:** ADRs are immutable. Present the draft, get explicit go-ahead, then write. Never edit an
  existing ADR in place.

## Route

**Durable-fact test:** does this change a rule, design, decision, or term? If not, it's behavior or
progress; leave it to code and tests, stop. If so:

| Fact | Slot |
|---|---|
| a **term** (project vocabulary) | glossary entry |
| a **decision / rule / constraint / design / deviation** | a new **ADR** (supersede if it reverses one) |

Locations: glossary `docs/GLOSSARY.md`; ADRs `docs/decisions/`; else the agent doc
(`CLAUDE.md`/`AGENTS.md`); else ask. Create lazily on first entry.

## Glossary

One canonical term per concept. Terms only. A relationship ("an Order owns its line items") is a
decision, so it's an ADR.

```
**Term**:
One or two sentences. What it IS, not what it does.
_Avoid_: synonym1, synonym2
```

## ADR

```markdown
# <NNNN>: <decision stated as a choice>

<1-3 sentences: context, decision, why.>
```

Add `Considered options` / `Consequences` only when they earn it. Number by incrementing the highest
id in the dir.

**Status:** no `Status` line means live. The only status ever written is `Status: superseded by
<id>`. Never write `Status: accepted`.

**Record an ADR only when all three hold:** hard to reverse, surprising without context, a real
trade-off. Else skip.

**Supersede** to reverse one. First the **merits gate:** argue the reversal fresh, as if no ADR
existed, never "the old one is inconvenient." If merits favor change, draft the new ADR with a
`Supersedes: <old-id>` line and add `Status: superseded by <new-id>` under the old title (never touch
its body). Write both or neither; else keep the old and record nothing.

## Steps

1. Restate the fact in one sentence; run the durable-fact test and route it.
2. For a reversal, run the merits gate, then the three-test gate.
3. Draft in the slot's format.
4. Confirm (hard gate for ADRs), then write. One fact, one home.
