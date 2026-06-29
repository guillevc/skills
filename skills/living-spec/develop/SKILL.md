---
name: develop
description: Take a unit of work from fuzzy idea to shipped, on one loop. Interrogate the plan, build against the spec, freeze the decisions the code proved, verify, optionally commit or open a PR. Stop at the confirm gate to think without building. Never merges. User-invoked.
disable-model-invocation: true
argument-hint: <feature, design, or goal to develop>
---

# Develop

One loop from idea to shipped, against the **living spec** (glossary + ADRs). **The spec trails the
code:** a decision earns an immutable ADR only after code proves it; until then it's a mutable draft
in the brief, never in the ADR directory.

## Gates

- **Autonomous:** ask, brief, draft decisions, run checks, assemble the PR.
- **Hard:** the confirm gate before any code change; the draft review before freezing; durable writes
  go through `record`; **every commit**, defaulting to one commit on the current branch, with branch,
  push, and PR only on request. **Never merge.**

## The loop

Spine: **discover → confirm gate → build → freeze → verify → deliver**. The confirm gate is a **hard
stop**: never write code until the user gives an explicit go-ahead. **Re-enter discover** from build
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
2. **Confirm gate (hard stop).** Present the brief and wait. Write no code until the user gives an
   explicit go-ahead; no go-ahead, no build. Stopping here is a valid end: pure discovery, nothing
   built, nothing frozen.
3. **Build.** Decide reversible choices on your own; the code tests them. A hard-to-reverse choice
   becomes a **draft decision** in the brief: honor it as the current working decision when making
   further choices, but keep it mutable. Rework it, never treat it as a ratified ADR, never write it
   to `docs/decisions/` yet.
4. **Re-enter discover** whenever building or review changes your mind. Reworking a draft is an edit,
   not a supersede.
5. **Freeze (post-code).** Run `audit`. Present the full set of draft decisions and term changes the
   code proved, in one place, for the user to review before anything sets in stone. Fold survivors into
   the spec via `record`, which gates each ADR and glossary edit. An ADR stays **soft** until step 7
   commits it: rework or drop it in place, no supersede. Trim behavioral prose that crept in. Surface
   pre-existing drift you didn't cause; don't fix it or grow scope.
6. **Verify.** Run the project's tests (`go test ./...`, the `package.json` script, the make/just
   target, else ask). Must pass.
7. **Deliver.** Default is a **single commit to the current branch**, and it waits for the user's
   explicit approval: present what you'd commit and wait. A local commit is a hard gate, not a
   reversible step; commit nothing without a go-ahead, outward-facing or not. Branch, push, or open a
   PR **only on the user's explicit request**; none is the default. **Never merge.**

Ad-hoc work skips `develop`; the guards (`record`, `audit`) fire during any work. The spec carries a
unit across sessions; un-frozen drafts don't.
