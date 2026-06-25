# in-the-loop

**Human-in-the-loop, spec-driven development around a living spec.** Your living spec is the source the agent builds from and stays coherent with — and you ratify every durable or outward step.

The **living spec** is the heart — not a frozen up-front document but two kinds of durable knowledge that stay coherent *with* code as it changes:

- a **glossary** — what your words mean;
- **ADRs** — what you decided (architecture, rules, constraints, technology, deviations — every durable choice).

It doubles as engineered context: typed, fresh, and token-cheap for the agent to consume.

Most agent setups are *autonomy-forward*: the agent interviews you, then writes and acts on its own. `in-the-loop` is *ratification-forward*: **no durable or irreversible change lands without an explicit human gate** — and gate strength tracks reversibility, so cheap stuff stays frictionless and only immutable/outward actions earn a full review.

## Install

```sh
# browse and select skills to install
npx skills add guillevc/in-the-loop

# specific skill
npx skills add guillevc/in-the-loop --skill <name>
```

Zero-config. Skills auto-detect your doc layout by convention (`docs/GLOSSARY.md`, `docs/decisions/` or `docs/adr/`); if a project keeps docs elsewhere, they read your `CLAUDE.md`/`AGENTS.md`, else ask once. Docs are created lazily on first real content; nothing is scaffolded upfront.

## The principle

> Agent explores, proposes, drafts. Human decides and ratifies. No durable or irreversible state change without an explicit human gate.

Gate strength tracks reversibility:

| Class | Examples | Gate |
|---|---|---|
| Ephemeral / reversible | exploration, drafts, scratch, queries | **none** — agent autonomous |
| Durable, mutable | glossary add/edit | **light confirm** |
| Durable, immutable / outward | ADR write, supersede, commit, PR | **hard gate** — draft + explicit ratify |

Every skill declares its gates in a **Human-in-the-loop contract** section.

## The living spec

Two durable *kinds* of knowledge — they behave differently, so they're separate docs:

| Doc | Holds | Nature | Written by |
|---|---|---|---|
| **glossary** | canonical terms; code mirrors them | living — edited in place | `record` |
| **ADRs** | one decision per file: architecture, rules, constraints, deviations | immutable — supersede, never rewrite | `record` |

**The durable-fact rule:** the spec changes *only* when durable fact changes — a term → glossary, any decision/rule/constraint → an ADR. Everything else (progress, status, shipped behavior) lives in code + tests. Code documents behavior; don't restate it in the spec.

**ADRs are light:** title + 1–3 sentences by default; add sections only when they earn it. Only record one when all three hold — **hard to reverse · surprising without context · a real trade-off** — otherwise skip it.

**Planning is optional and external.** Keep a `roadmap.md` if you want one (hand-maintained); `ship` reads its goal from a roadmap entry or your prompt — neither privileged. The system doesn't own planning.

## Skills

Four skills. Two ambient guards that fire during work; two verbs you invoke.

| Skill | Role | Invocation |
|---|---|---|
| `spec-out` | Discover — interrogate a plan until nothing important is implicit; hand resolved facts to `record` | **`/spec-out`** (user) |
| `record` | Write the living spec — a glossary term or an ADR (incl. supersede, with the merits gate) | guard (model) |
| `drift-check` | Check code against the living spec — decisions, rules, terms; human picks the fix | guard (model) |
| `ship` | Build a unit from a goal + the spec → reconcile → verify → optionally commit/PR (never merges) | **`/ship`** (user) |

### How each skill is invoked

`disable-model-invocation` (a Claude Code frontmatter field) decides this; there's no portable standard, so the intent is documented here too.

- **Guards — model-invoked, fire autonomously during any work:** `record` (when a durable fact crystallizes) and `drift-check` (when code and spec diverge). One writes the spec, one checks code against it.
- **Verbs — user-invoked only (`disable-model-invocation: true`):** `spec-out` (deliberate discovery) and `ship` (deliberate build + outward delivery). Neither auto-fires.

## Workflow

Two moves you make; the guards do the rest automatically.

```
  /spec-out ─────────────► discover
     │   interrogate until nothing important is implicit
     │   resolved facts ─► record ─► living spec (glossary + ADRs)
     ▼
  /ship ─────────────────► build
     │   brief the goal (prompt or roadmap) + read the spec
     │   implement (ask when the spec is silent; new decisions ─► record)
     │   drift-check ─► reconcile ─► record   (keep spec coherent)
     │   verify (run tests)
     ▼
  commit / PR ───────────► deliver (you review + merge; ship never merges)
```

| Phase | Skill | Who | Input → Output |
|---|---|---|---|
| **Discover** | `spec-out` | you | a rough plan → resolved facts (→ `record` writes the spec) |
| *(spec writes)* | `record` | guard (auto) | a resolved fact → a glossary entry or ADR |
| **Build & deliver** | `ship` | you | a goal + the spec → an implementation, reconciled spec, gated PR |
| *(coherence)* | `drift-check` | guard (auto) | code↔spec divergence → human picks the fix |

Ad-hoc work needs neither verb — just code; `record` and `drift-check` fire during any work to keep the spec coherent. `ship` is for the deliberate "build this unit properly and deliver it" move.

## License

MIT
