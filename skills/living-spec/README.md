# living-spec

**Spec-driven development with a human in the loop.** The agent builds from a living spec and stays coherent with it; you ratify every durable or outward step.

Most agent setups are *autonomy-forward*: the agent interviews you, then writes and acts alone. `living-spec` is **ratification-forward**: nothing durable or irreversible lands without an explicit human gate, and gate strength tracks reversibility, so reversible work stays frictionless while only immutable or outward actions earn a full review.

The **living spec** is two kinds of durable knowledge, kept coherent *with* the code as it changes:

- a **glossary**: what your words mean;
- **ADRs**: what you decided (architecture, rules, constraints, technology, deviations).

It doubles as engineered context for the agent: typed, fresh, token-cheap.

## What it looks like

A glossary entry pins a word; an ADR pins a decision:

```markdown
# docs/GLOSSARY.md
**Idempotency key**:
A client token that makes a retried request a no-op.
_Avoid_: dedup id, request id
```

```markdown
# docs/decisions/0007-optimistic-locking.md
# 0007: Optimistic locking on writes, not pessimistic
Concurrent edits are rare and lock contention hurt throughput in load tests, so writers
compare-and-set on a version column and retry on conflict.
```

`record` is the only thing that writes these; `audit` enforces both against the code.

## Install

```sh
npx skills add guillevc/living-spec            # browse and select
npx skills add guillevc/living-spec --skill <name>
```

Zero-config. Skills auto-detect your doc layout (`docs/GLOSSARY.md`, `docs/decisions/`), else read your `CLAUDE.md`/`AGENTS.md`, else ask once. Docs are created lazily on first content.

## The principle

> Agent explores, proposes, drafts. Human decides and ratifies. No durable or irreversible state change without an explicit human gate.

| Class | Examples | Gate |
|---|---|---|
| Ephemeral, reversible | exploration, drafts, queries | **none**, agent autonomous |
| Durable, mutable | glossary add/edit | **light confirm** |
| Durable, immutable, outward | ADR write, supersede, commit, PR | **hard**: draft, then ratify |

## The living spec

| Doc | Holds | Nature |
|---|---|---|
| **glossary** | canonical terms; code mirrors them | living, edited in place |
| **ADRs** | one decision per file: architecture, rules, constraints, deviations | immutable; supersede, never rewrite |

**Durable-fact rule:** the spec changes *only* when durable fact changes. A term goes to the glossary; any decision, rule, or constraint becomes an ADR. Everything else (progress, status, behavior) lives in code and tests; don't restate it.

**ADRs are light:** a title plus 1-3 sentences, recorded only when all three hold: hard to reverse, surprising without context, a real trade-off.

**The spec trails the code:** a decision earns an immutable ADR only after code proves it. Until then it's a mutable draft in the ephemeral brief, never in the ADR directory, so discovery stays unconstrained and the spec never churns.

**Planning is optional and external.** Keep a hand-maintained `roadmap.md` if you want; `develop` reads its goal from a roadmap entry or your prompt, neither privileged.

## Skills

Five skills: three verbs you invoke, two guards the agent fires on its own during any work.

| Skill | Invocation | Role |
|---|---|---|
| `init-spec` | **`/init-spec`** | Cold-start: extract the terms and decisions baked into an existing codebase. Run once at adoption. |
| `develop` | **`/develop`** | One loop from idea to shipped: interrogate, build against the spec, freeze the decisions the code proved, verify, optionally commit/PR (never merges). Stop at the confirm gate to think without building. |
| `reconcile` | **`/reconcile`** | Sweep the whole spec against the whole codebase after out-of-band changes. The human-triggered global drift check. |
| `record` | guard | Write the spec: a glossary term or an ADR (including supersede, with the merits gate). |
| `audit` | guard | Check what the agent touched against the spec, both directions; the human picks the fix. |

**Invocation** is set by `disable-model-invocation`, a Claude Code field with no portable standard. On Claude Code it hard-blocks the model from firing a verb, so the three verbs are yours alone. On other Agent-Skills harnesses the field is ignored; the verbs then rely on plain, non-triggering descriptions, a best-effort gate rather than a guarantee.

## Workflow

```
/init-spec   once on an existing repo: extract implicit terms + decisions → record

/develop     discover → [confirm gate] → build → freeze → verify → commit/PR
```

- **discover**: interrogate the plan to a draft brief; record nothing yet.
- **confirm gate**: stop here for pure thinking, or approve the build.
- **build**: the code tests the drafts; re-enter discover on a mind-change.
- **freeze**: run `audit`, then `record` the decisions the code proved.
- **deliver**: you review and merge; `develop` never merges.

Ad-hoc work needs no verb: just code, and `record` and `audit` fire during any work to keep the spec coherent.

**Out-of-band drift.** `audit` only checks what the agent touched, and the guards fire only when the agent runs, so code changed without it (a teammate's edit, a hand-merged PR) branches the spec with no guard firing; by design there's no commit or CI gate. **`/reconcile`** is the catch-up: a human-triggered sweep of the whole spec against the whole codebase. Run it before a merge or release. The spec may lag between sweeps, the accepted trade for zero automation.

## License

MIT
