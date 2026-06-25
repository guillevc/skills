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

| Doc | Holds | Changes when | Written by |
|---|---|---|---|
| standards | rules (API/engineering rulebook) | a rule changes | `doc-route` (you ratify) |
| architecture | design + rationale (not shipped behavior) | a design decision changes | `doc-route` |
| decisions (ADRs) | one decision per file, immutable | a new decision is made (supersede, never rewrite) | `new-adr` / `supersede-adr` |
| glossary | canonical terms; code mirrors them | a term is added/redefined | `glossary-guard` |
| roadmap | forward-only index of unbuilt work, shallow | work is planned or shipped | `unfold` plans, `ship-milestone` ticks |

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

### How each skill is invoked

`disable-model-invocation` (a Claude Code frontmatter field) decides this; there is no portable standard, so the intent is documented here too.

- **Guards — model-invoked, fire autonomously during any work:** `doc-route`, `drift-check`, `glossary-guard`. You rarely call these by name; they trigger when you're about to write a doc, when code and docs diverge, or when vocabulary drifts.
- **Reach — model-invoked, called by a sibling skill or by you:** `new-adr`, `supersede-adr`, `finishing-check`.
- **Explorer — model-invoked or `/unfold`:** `unfold`. Auto-fires before a non-trivial change; writes nothing, so auto-firing is safe.
- **User-invoked only — `/ship-milestone`:** the one skill that never auto-fires. Building and delivering is a deliberate, outward act, so it waits for you to ask (`disable-model-invocation: true`).

## Workflow

The loop, end to end. Guards run continuously underneath every phase.

```
  /unfold ───────────────► shape the living spec
     │   (grill until every branch maps to a slot)
     ▼
  doc-route / new-adr ────► land decisions into the spec
     │   (standards · architecture · ADRs · glossary · roadmap)
     ▼
  /ship-milestone ───────► build from the spec
     │   reads spec → implements (asks when ambiguous)
     │   drift-check + doc-route ─► reconcile docs ◄─ keep spec living
     │   finishing-check ────────► verify + coherence gate
     ▼
  commit / PR ───────────► deliver (you review + merge)
```

| Phase | Skill(s) | Who triggers | Input → Output |
|---|---|---|---|
| **Shape** | `unfold` | model or you | a rough plan → resolved branches tagged by slot, acceptance-shaped statements |
| **Land decisions** | `doc-route`, `new-adr`, `supersede-adr`, `glossary-guard` | guards (auto) + you ratify | a resolved fact → an entry in the right spec doc |
| **Build** | `ship-milestone` | you (`/ship-milestone`) | the living spec + your answers → an implementation |
| **Reconcile** | `drift-check` → `doc-route`/`supersede-adr` | inside `ship-milestone`, or auto | code↔doc deltas → coherent docs |
| **Check & deliver** | `finishing-check`, then commit/PR | inside `ship-milestone` | the change → a gated PR (never merged) |

**Building the spec docs:** you don't write them by hand. A fact resolved in `unfold` (or surfaced mid-build) is routed by `doc-route` to its one home per the durable-fact rule — rule → standards, design → architecture, decision → ADR (`new-adr`), term → glossary (`glossary-guard`), unbuilt work → roadmap. Each doc is created lazily on its first real entry; you ratify every durable write.

## License

MIT
