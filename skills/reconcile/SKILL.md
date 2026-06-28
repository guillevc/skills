---
name: reconcile
description: Sweep the whole living spec against the whole codebase to catch drift after out-of-band changes. The deliberate, human-triggered global pass. User-invoked.
disable-model-invocation: true
argument-hint: <optional area to scope the sweep to>
---

# Reconcile

The whole-repo drift check. Where `audit` fires scoped during work, `reconcile` is the global pass
you trigger by hand: the entire spec against the entire codebase, after changes that landed without
the agent in the loop (a teammate's edit, a hand-merged PR).

Run `audit`'s method, but across the entire spec and codebase instead of a touched scope. Run it
before a merge or release; the spec may lag between runs, and this is the catch-up.
