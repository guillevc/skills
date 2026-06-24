---
name: finishing-check
description: >
  End-gate run before a PR or commit: verify durable docs and code are coherent, then run the
  project's own verify command and invariant checks. Use before a PR or commit, or on "finishing
  check", "is this ready", "pre-PR check", /finishing-check. Advisory — it reports pass/fail and
  stops on failure, but the human decides whether to proceed.
---

# Finishing-check

A final sweep before work is called done. When the guards (`doc-route`, `drift-check`,
`glossary-guard`) are installed they catch most issues *during* work and this is a confirmation;
installed alone, it is the sole coherence gate.

## Where the project specifics come from

The verify command and any custom invariants are project facts, not config. In order:

1. **Detect the verify command** from the repo — `go.mod` → `go build ./... && go test ./...`,
   `package.json` → its test script, a `justfile`/`Makefile` → the test/check target.
2. **Read the agent doc** (`CLAUDE.md`/`AGENTS.md`) for a stated verify command or invariants
   (e.g. "no snake_case in API JSON", "no doc section-numbers").
3. **Else ask once**, and offer to record the answer in the agent doc so it persists.

## Human-in-the-loop contract

- **Autonomous:** running all checks, reporting results, pointing at failures.
- **Gated (advisory):** it does not auto-green or auto-fix. It reports; the human decides to proceed,
  fix, or override. Any fix routes through the appropriate skill (`doc-route`, `supersede-adr`).

## Universal checks (always run)

1. **Durable edits justified.** Every durable-doc change in the diff corresponds to a changed
   *rule, design, or decision* — not behavior or progress. Flag durable edits that are really
   behavior restatements.
2. **Decisions recorded.** Any consolidated choice or standard deviation in the diff has an ADR;
   any new term is in the glossary.
3. **Roadmap current** (if the project keeps a roadmap): acceptance for shipped work is ticked;
   shipped milestones removed.
4. **Links resolve.** Cross-doc references resolve by heading name (the system's link convention).

## Project checks

5. **Verify.** Run the detected/declared verify command (build/test/lint). Must pass.
6. **Invariants.** Run each invariant from the agent doc and assert it (e.g. "section [0-9]" absent
   in docs, no snake_case in API JSON). Skip if the project declares none.

## Output

Report each check as pass/fail with a one-line reason. On any failure, stop and name the fix path —
do not proceed silently. The human decides whether to fix now, defer, or override.
