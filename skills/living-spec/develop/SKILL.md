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

Spine: **discover → confirm gate → build → freeze → verify → deliver**. Two edges bend it: you may
**stop at the confirm gate** (pure discovery, a valid end), and you **re-enter discover** from build
or review whenever your mind changes.

1. **Discover.** Map the plan into a tree of named branches, then walk it branch by branch, resolving
   each decision and its dependencies before the next. Interview the user until you both share one
   understanding of every branch; loop rather than settle for a single pass. Draft the brief only then.
   - **Interrogate** one branch at a time: ask the single sharpest question that cuts the most
     uncertainty, with your recommended answer. **Ask one question, then wait for the answer before
     the next.** Batching questions bewilders the user and defeats the interview. If the spec or code
     already answers, read it instead of asking.
   - **Sharpen vocabulary**: challenge a term that conflicts with the glossary, pin a fuzzy or
     overloaded one to a single canonical term, stress-test relationships with concrete edge-case
     scenarios, and when the user asserts how something works, check the code agrees.
   - **Brief**: one resolution per branch, acceptance-shaped. It constrains the build without being
     written. **Record nothing** pre-code unless the human asks (a fact something outside this loop
     needs now, or insurance against context loss).
2. **Confirm gate.** Present the brief. Stopping here is a valid end: pure discovery, nothing frozen.
   Continue only on an explicit go-ahead.
3. **Build.** Decide reversible choices on your own; the code tests the drafts. A hard-to-reverse
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
