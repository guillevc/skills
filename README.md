# living-spec

**Human-in-the-loop, spec-driven development around a living spec.** Your living spec is the source the agent builds from and stays coherent with, and you ratify every durable or outward step.

The **living spec** is the heart: two kinds of durable knowledge, kept coherent *with* code as it changes.

- a **glossary**: what your words mean;
- **ADRs**: what you decided (architecture, rules, constraints, technology, deviations: every durable choice).

It doubles as engineered context: typed, fresh, token-cheap.

Most agent setups are *autonomy-forward*: the agent interviews you, then writes and acts on its own. `living-spec` is *ratification-forward*. No durable or irreversible change lands without an explicit human gate, and gate strength tracks reversibility, so cheap reversible work stays frictionless while only immutable or outward actions earn a full review.

## Install

```sh
# browse and select skills to install
npx skills add guillevc/living-spec

# specific skill
npx skills add guillevc/living-spec --skill <name>
```

Zero-config. Skills auto-detect your doc layout by convention (`docs/GLOSSARY.md`, `docs/decisions/` or `docs/adr/`). If a project keeps docs elsewhere, they read your `CLAUDE.md`/`AGENTS.md`, else ask once. Docs are created lazily on first real content; nothing is scaffolded upfront.

## The principle

> Agent explores, proposes, drafts. Human decides and ratifies. No durable or irreversible state change without an explicit human gate.

Gate strength tracks reversibility:

| Class | Examples | Gate |
|---|---|---|
| Ephemeral, reversible | exploration, drafts, scratch, queries | **none**: agent autonomous |
| Durable, mutable | glossary add/edit | **light confirm** |
| Durable, immutable, outward | ADR write, supersede, commit, PR | **hard gate**: draft, then explicit ratify |

Every skill declares its gates in a **Human-in-the-loop contract** section.

## The living spec

Two durable *kinds* of knowledge. They behave differently, so they're separate docs:

| Doc | Holds | Nature | Written by |
|---|---|---|---|
| **glossary** | canonical terms; code mirrors them | living, edited in place | `record` |
| **ADRs** | one decision per file: architecture, rules, constraints, deviations | immutable; supersede, never rewrite | `record` |

**The durable-fact rule:** the spec changes *only* when durable fact changes. A term goes to the glossary; any decision, rule, or constraint goes to an ADR. Everything else (progress, status, shipped behavior) lives in code and tests. Code documents behavior; don't restate it in the spec.

**ADRs are light:** title plus 1-3 sentences by default; add sections only when they earn it. Record one only when all three hold (hard to reverse, surprising without context, a real trade-off), otherwise skip it.

**Planning is optional and external.** Keep a `roadmap.md` if you want one (hand-maintained); `ship-out` reads its goal from a roadmap entry or your prompt, neither privileged. The system doesn't own planning.

## Skills

Four skills. Two ambient guards that fire during work; two verbs you invoke.

| Skill | Role | Invocation |
|---|---|---|
| `spec-out` | Discover: interrogate a plan until nothing important is implicit; hand resolved facts to `record` | **`/spec-out`** (user) |
| `record` | Write the living spec: a glossary term or an ADR (including supersede, with the merits gate) | guard (model) |
| `audit` | Check code against the living spec (decisions, rules, terms); human picks the fix | guard (model) |
| `ship-out` | Build a unit from a goal plus the spec, reconcile, verify, optionally commit/PR (never merges) | **`/ship-out`** (user) |

### How each skill is invoked

`disable-model-invocation` (a Claude Code frontmatter field) decides this. There's no portable standard, so the intent is documented here too.

- **Guards, model-invoked, fire autonomously during any work:** `record` (when a durable fact crystallizes) and `audit` (when code and spec diverge). One writes the spec, one checks code against it.
- **Verbs, user-invoked only (`disable-model-invocation: true`):** `spec-out` (deliberate discovery) and `ship-out` (deliberate build and outward delivery). Neither auto-fires.

## Workflow

Two moves you make; the guards do the rest automatically.

```
  /spec-out ─────────────► discover
     │   interrogate until nothing important is implicit
     │   resolved facts ─► record ─► living spec (glossary + ADRs)
     ▼
  /ship-out ─────────────► build
     │   brief the goal (prompt or roadmap) + read the spec
     │   implement (ask when the spec is silent; new decisions ─► record)
     │   audit ─► reconcile ─► record   (keep spec coherent)
     │   verify (run tests)
     ▼
  commit / PR ───────────► deliver (you review + merge; ship-out never merges)
```

| Phase | Skill | Who | Input to output |
|---|---|---|---|
| **Discover** | `spec-out` | you | a rough plan to resolved facts (`record` writes the spec) |
| *(spec writes)* | `record` | guard (auto) | a resolved fact to a glossary entry or ADR |
| **Build & deliver** | `ship-out` | you | a goal plus the spec to an implementation, reconciled spec, gated PR |
| *(coherence)* | `audit` | guard (auto) | code/spec divergence; human picks the fix |

Ad-hoc work needs neither verb. Just code; `record` and `audit` fire during any work to keep the spec coherent. `ship-out` is the deliberate "build this unit and deliver it" move.

## License

MIT
