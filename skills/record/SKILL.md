---
name: record
description: >
  Write a resolved fact into the living spec — a glossary term or an ADR — and keep it coherent.
  Use whenever a durable fact crystallizes: a decision is made, a rule or constraint is set, a term
  is pinned down, or an existing decision is reversed. Also on "record this", "write an ADR",
  "add to the glossary", "supersede that decision", /record. Drafts for human ratification; durable
  writes are gated.
---

# Record

The single writer of the **living spec**. The spec has exactly two kinds of durable knowledge, and
this skill writes both:

- **Glossary** — what words mean (living, edited in place).
- **ADRs** — what was decided (immutable; reverse only by superseding). Everything durable that
  isn't a term is an ADR: architecture, rules, constraints, technology choices, deliberate
  deviations.

`record` classifies a resolved fact, picks the slot, and writes it. The companion guard
`audit` checks code *against* what's recorded.

## Human-in-the-loop contract

- **Autonomous:** classifying the fact, choosing the slot, drafting the entry.
- **Gated (light):** glossary edits and roadmap-bound facts — confirm before writing.
- **Gated (hard):** ADRs are immutable. Present the draft and get an explicit go-ahead before
  writing a new ADR or a superseding one. Never edit an existing ADR in place.

## The durable-fact test (apply first)

> Does this change a **rule, a design, a decision, or a term**?

- **No** → it's behavior or progress. It does not belong in the living spec — let code + tests
  capture it. Stop.
- **Yes** → pick the slot and write.

## Routing

| The fact is… | Slot | How |
|---|---|---|
| a **term** (project vocabulary) | glossary | write/sharpen the entry (format below) |
| a **decision / rule / constraint / design / deviation** | a new **ADR** | write it (format below); if it reverses an existing ADR, **supersede** (below) |
| **shipped behavior / progress** | — | not the spec; code + tests |

Auto-detect doc locations: glossary at `docs/GLOSSARY.md`; ADRs at `docs/decisions/` or `docs/adr/`.
Else check the agent doc (`CLAUDE.md`/`AGENTS.md`), else ask. Create a doc lazily on first real
entry — never a blank file.

## Glossary

The glossary is the project's **ubiquitous language** — the canonical term for each concept,
mirrored everywhere (code, docs, conversation) and enforced against code by `audit`. It's a
pure term list: no implementation details, no decisions. A relationship between concepts ("an Order
owns its line items") is a *decision* → ADR, not a glossary entry. Sharpen fuzzy terms, challenge
conflicts with existing entries, keep the avoid-list current.

Optional one-line header naming the domain the project covers. Each entry:

```
**Term**:
One or two sentences. What it IS, not what it does.
_Avoid_: synonym1, synonym2
```

## ADR format (light by default)

```markdown
# <NNNN> — <decision stated as a choice>

<1–3 sentences: the context, what was decided, and why.>
```

Add `Status`, `Considered options`, or `Consequences` **only when they earn their place** — most
ADRs won't need them. Number by scanning the ADR dir for the highest id and incrementing.

### Only record an ADR when all three hold

1. **Hard to reverse** — changing your mind later costs something.
2. **Surprising without context** — a future reader will wonder "why this way?"
3. **A real trade-off** — there were genuine alternatives and one was chosen for reasons.

If any fail, skip the ADR — an obvious or trivially-reversible choice isn't worth a record.

## Superseding a decision

ADRs are immutable; reverse one only by writing a new ADR that supersedes it.

**The merits gate (do this first):** argue the reversal on its **technical merits**, fresh, as if no
ADR existed — never "the old ADR is inconvenient," never defend the old one just because it's
written. If the merits favor change, supersede. If not, keep the existing ADR and record nothing.

Then: draft the new ADR with a `Supersedes: <old-id>` line; mark the old one `Status: superseded by
<new-id>` (header only — never touch its body). Present both for ratification; write both or neither.

## Steps

1. Restate the fact in one sentence; apply the durable-fact test.
2. Pick the slot (term → glossary; decision/rule/etc → ADR).
3. For an ADR, apply the three-test gate; if reversing, run the merits gate.
4. Draft the entry in the slot's format.
5. **Confirm with the human** (hard gate for ADRs), then write. One fact, one home — don't restate
   it elsewhere.
