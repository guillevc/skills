---
name: simple-english
description: Rewrite or write English at a CEFR level (default B1) so non-proficient readers understand it.
disable-model-invocation: true
---

# Simple English

Write English a **B1** reader (intermediate learner) understands on first
reading — and that stays **natural**: grammatical, idiomatic English a native
speaker would find normal. Natural beats simple every time. When a simple
phrasing sounds strange, take the natural phrasing with one harder word.

Default **B1**. If the user asks, target **A2** (simpler, ~1500-word range) or
**B2** (looser).

## Rules

- **Sentence ceiling ~20 words.** One idea per sentence. Split long ones.
- **Gloss an unavoidable hard/technical term on first use, then use it
  plainly:** "a firewall (a system that blocks dangerous network traffic)".
  Gloss once only.
- **Keep very common phrasal verbs** ("find out", "give up") — learners know
  these. Swap rare or formal verbs for a common one.
- **Say the literal meaning, not idioms or metaphors:** "this is very hard",
  not "this is an uphill battle".
- **Keep articles, prepositions, and verb endings.** Broken English is harder
  for learners, not easier.
- **Adult tone.** The reader has limited English, not limited intelligence.
- **Simplify the language, never the ideas** — unless asked.

## Output

Return the rewritten text only. No change notes unless the user asks.

## Self-check

Every sentence: ≤20 words? one idea? no unglossed rare word? no idiom? Then
read it aloud as prose — anything that sounds unnatural gets rewritten.

## Examples (B1)

> "Notwithstanding the considerable progress achieved in recent years, the
> implementation of the directive remains hampered by persistent
> administrative bottlenecks."

→ "There has been a lot of progress in recent years. But slow administrative
processes still make it hard to put the directive into practice."

> "The daemon exposes a REST API that facilitates the orchestration of
> downstream ingestion pipelines."

→ "The background service (daemon) offers a REST API. Other programs use this
API to start and control the processes that collect data."

The second keeps "REST API" (readers in that domain know it), glosses "daemon"
once, and cuts "facilitates the orchestration of".
