---
name: develop
description: Take a unit of work from fuzzy idea to shipped, on one loop. Interrogate the plan, build against the spec, freeze the decisions the code proved, verify, optionally commit or open a PR. Stop at the confirm gate to think without building. Never merges. User-invoked.
disable-model-invocation: true
argument-hint: <feature, design, or goal to develop>
---

# Develop

One loop from idea to shipped, against the **living spec** (glossary + ADRs). Discovery, build, and
freeze interleave. **The spec trails the code:** a decision earns an immutable ADR only after code
proves it; until then it's a mutable draft in the brief, never in the ADR directory.

## Gates

- **Autonomous:** ask, brief, implement, run checks, assemble the PR.
- **Hard:** the confirm gate before building; durable writes go through `record`; confirm the
  commit/PR. **Never merge.**

## The loop

```
discover ─►(confirm gate)─► build ─► freeze
                 ▲    re-enter discover on mind-change
```

1. **Discover.** Skim the spec; treat settled records as given. Restate the plan as named branches.
   Interrogate one at a time: the sharpest question that cuts the most uncertainty, your recommended
   answer with it. If the spec or code already answers, read it. Output a **draft brief**: one
   resolution per branch, acceptance-shaped. **Record nothing**: the brief constrains the build
   without being written. Write pre-code only when the human asks (a fact something outside this loop
   needs now, or insurance against context loss).
2. **Confirm gate.** Present the brief. Stopping here is a valid end: pure discovery, nothing frozen.
   Continue only on an explicit go-ahead.
3. **Build.** Default freely on reversible choices; the code tests the drafts. A hard-to-reverse
   choice goes to `record`, never guessed.
4. **Re-enter discover** whenever building or review changes your mind. Reworking a draft is an edit,
   not a supersede.
5. **Freeze (post-code).** Run `audit`; fold survivors back via `record`. Trim behavioral prose that
   crept in. Surface pre-existing drift you didn't cause; don't fix it or grow scope.
6. **Verify.** Run the project's tests (`go test ./...`, the `package.json` script, the make/just
   target, else ask). Must pass.
7. **Deliver.** Optionally commit, or assemble a PR. Confirm. **Never merge.**

Ad-hoc work skips `develop`; the guards (`record`, `audit`) fire during any work. The spec carries a
unit across sessions; un-frozen drafts don't.
