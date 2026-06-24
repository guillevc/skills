---
name: finishing-check
description: >
  End-gate run before a PR or commit: verify durable docs and code are coherent, then run the
  project's own verify command and invariant checks. Invoked via "finishing check", "is this ready",
  "pre-PR check", or /finishing-check. Advisory — it reports pass/fail and stops on failure, but the
  human decides whether to proceed.
---

# Finishing-check

A final sweep before work is called done. When the guards (`doc-route`, `drift-check`,
`glossary-guard`) are installed they catch most issues *during* work and this is a confirmation;
installed alone, it is the sole coherence gate.

## Config

Reads `.in-the-loop.json` for `verify`, `invariants`, and `layers` if present. Without config, run
the universal checks only and ask the user for a verify command; skip project checks that have no
source.

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
3. **Roadmap current** (if `layers.roadmap`): acceptance for shipped work is ticked; shipped
   milestones removed.
4. **Links resolve.** Cross-doc references resolve by heading name (the system's link convention).

## Project checks (from `.in-the-loop.json`)

5. **Verify.** Run the project's `verify` command (build/test/lint). Must pass.
6. **Invariants.** Run each configured `invariants` grep and assert its `must` (e.g. "section [0-9]"
   absent in docs, no snake_case in API JSON). These are project-defined, not hardcoded.

## Output

Report each check as pass/fail with a one-line reason. On any failure, stop and name the fix path —
do not proceed silently. The human decides whether to fix now, defer, or override.
