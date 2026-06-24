---
name: glossary-guard
description: >
  Keep code and docs aligned with the canonical glossary. Use when introducing new terms, naming
  identifiers, or shaping API payloads, or on "check terms", "is this the right word", "vocabulary
  check", /glossary-guard. Flags undefined terms, banned synonyms, and naming invariants; proposes
  glossary updates for the human to ratify.
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

## Glossary location

Auto-detect the glossary (`docs/GLOSSARY.md` or `CONTEXT.md`); else check the agent doc
(`CLAUDE.md`/`AGENTS.md`) or ask. Create it lazily on the first term — don't write a blank file.
Naming invariants come from the agent doc if the project declares any; skip otherwise.

## What it checks

1. **Undefined terms.** A concept used in code/docs/conversation that has no glossary entry →
   propose one (1–2 sentences, "what it IS, not what it does") with an `_Avoid_:` list of synonyms.
2. **Banned synonyms.** A word used where the glossary's `_Avoid_` list says to prefer another →
   flag and suggest the canonical term.
3. **Naming invariants.** Run the naming invariants the project declares in its agent doc
   (e.g. "no snake_case in API JSON", "no Get-prefix on getters") — flag matches.
4. **Code mirrors glossary.** Identifiers (types, functions, fields) should reflect glossary terms.
   Flag drift between the name in code and the canonical term.

## Steps

1. Detect and classify (undefined / banned synonym / invariant / mismatch).
2. Draft the fix — a glossary entry, a rename, or a flagged violation.
3. Glossary edits: **confirm the vocabulary with the human** first — they own it. Renames: propose;
   the human applies.

## Entry format

```
**Term**:
One or two sentences. Define what it IS, not what it does.
_Avoid_: synonym1, synonym2
```
