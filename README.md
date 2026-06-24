# in-the-loop

**Human-in-the-loop, spec-driven development around a living spec.** Your typed durable docs are the spec: skills build from them, keep code and docs in sync both ways, and gate every durable or outward step on you.

The **living spec** is the heart — not a frozen up-front document but typed durable docs (standards, architecture, decisions, glossary, roadmap) that you *build from* and that stay coherent *with* code as it changes. It doubles as engineered context: typed, fresh, and token-cheap for the agent to consume.

Most agent setups are *autonomy-forward*: the agent interviews you, then writes and acts on its own. `in-the-loop` is *ratification-forward*: **no durable or irreversible change lands without an explicit human gate** — and gate strength tracks reversibility, so cheap stuff stays frictionless and only immutable/outward actions earn a full review.

## Install

```sh
# browse and select skills to install
npx skills add guillevc/in-the-loop

# specific skill
npx skills add guillevc/in-the-loop --skill <name>
```

Zero-config. Skills auto-detect your doc layout by convention (`docs/`, `docs/decisions/` or
`docs/adr/`, `GLOSSARY.md` or `CONTEXT.md`, …). The few project specifics that can't be detected —
a verify command, custom invariants — are read from your `CLAUDE.md`/`AGENTS.md` if present, else
asked once. Docs are created lazily on first real content; nothing is scaffolded upfront.

## The principle

> Agent explores, proposes, drafts. Human decides and ratifies. No durable or irreversible state change without an explicit human gate.

Gate strength tracks reversibility:

| Class | Examples | Gate |
|---|---|---|
| Ephemeral / reversible | exploration, drafts, scratch, queries | **none** — agent autonomous |
| Durable, mutable | roadmap tick, glossary add, design prose | **light confirm** — one-key approve |
| Durable, immutable / cross-file / outward | ADR write, supersede flip, milestone ship, PR | **hard gate** — draft + explicit ratify |

Every skill declares its gates in a **Human-in-the-loop contract** section: what it does autonomously vs what needs ratification.

## The living spec

The spec is **typed by durability** — each doc changes only when its kind of fact changes. Together they're the source the agent builds from and reconciles against:

| Doc | Holds | Changes when |
|---|---|---|
| standards | rules (API/engineering rulebook) | a rule changes |
| architecture | design + rationale (not shipped behavior) | a design decision changes |
| decisions (ADRs) | one decision per file, immutable | a new decision is made (supersede, never rewrite) |
| glossary | canonical terms; code mirrors them | a term is added/redefined |
| roadmap | forward-only index of unbuilt work, shallow | work is planned or shipped |

**The durable-fact rule:** durable docs change *only* when durable fact changes — rule → standards, design/rationale → architecture, decision → ADR. Everything else (progress, status, shipped behavior) lives in code + tests, not docs. Code documents shipped behavior; don't restate it.

**Authority order** on conflict: ADRs > standards > architecture > code (later ADR supersedes earlier).

## Skills

| Skill | Role | Gate |
|---|---|---|
| `unfold` | Shape the living spec — explore a plan/design until every branch is open | none (explores only) |
| `doc-route` | Route a resolved fact into its slot in the living spec | light confirm |
| `drift-check` | Keep the spec living — detect code↔doc contradictions; human picks the fix | hard gate (human picks) |
| `glossary-guard` | Keep the spec's vocabulary tight — flag terms/identifiers/API casing that drift | light confirm |
| `new-adr` | Record a consolidated decision into the spec as an ADR | hard gate (immutable) |
| `supersede-adr` | Reverse a decision — superseding ADR, flip the old to `superseded` | hard gate (cross-file) |
| `ship-milestone` | Build a milestone from the living spec, reconcile docs, optionally PR | gated build + outward |
| `finishing-check` | End-gate: spec↔code coherence + project verify/invariants | advisory |

`doc-route`, `drift-check`, `glossary-guard` are model-invoked guards (run during work). The rest are invoked by a guard or the user.

## License

MIT
