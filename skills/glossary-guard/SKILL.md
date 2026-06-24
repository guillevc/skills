---
name: glossary-guard
description: >
  Keep code and docs aligned with the canonical glossary. Model-invoked when introducing new terms,
  naming identifiers, or shaping API payloads; also triggers on "check terms", "is this the right
  word", "vocabulary check", or /glossary-guard. Flags undefined terms, banned synonyms, and
  project-defined naming invariants — and proposes glossary updates for the human to ratify.
---

# Glossary-guard

Shared language is infrastructure. This guard keeps the words in code and docs matching the
glossary, and keeps the glossary current as new concepts appear — so vocabulary stays tight
*during* work, not patched afterward.

## Human-in-the-loop contract

- **Autonomous:** scanning for term drift, detecting undefined or off-vocabulary words, drafting a
  proposed glossary entry (term + definition + avoid-list).
- **Gated (light confirm):** the human ratifies vocabulary — confirms a new term, its definition,
  and which synonyms to ban — before the glossary is edited. Naming is a human call.

## What it checks

Load `.in-the-loop.json` for the glossary path and any naming `invariants`, then:

1. **Undefined terms.** A concept used in code/docs/conversation that has no glossary entry →
   propose one (1–2 sentences, "what it IS, not what it does") with an `_Avoid_:` list of synonyms.
2. **Banned synonyms.** A word used where the glossary's `_Avoid_` list says to prefer another →
   flag and suggest the canonical term.
3. **Naming invariants.** Run the project's `invariants` greps (e.g. "no snake_case in API JSON",
   "no Get-prefix on getters"). These are project-defined in config, not hardcoded — flag matches.
4. **Code mirrors glossary.** Identifiers (types, functions, fields) should reflect glossary terms.
   Flag drift between the name in code and the canonical term.

## Steps

1. Detect the issue and classify it (undefined / banned synonym / invariant / mismatch).
2. Draft the fix: a glossary entry, a rename suggestion, or a flagged invariant violation.
3. For glossary additions/edits, **confirm with the human** before writing — they own the vocabulary.
4. For code naming, propose the rename; the human applies it (or approves applying it).

## Entry format

```
**Term**:
One or two sentences. Define what it IS, not what it does.
_Avoid_: synonym1, synonym2
```
