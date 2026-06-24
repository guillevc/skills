---
name: setup-in-the-loop
description: >
  Bootstrap the in-the-loop docs system in a project: interview for the project's doc layout, verify
  command, and invariants, then generate the .in-the-loop.json config the other skills read. Run
  once after installing the skills, or via "set up in-the-loop", "configure the docs system",
  /setup-in-the-loop. Light-confirm — writes config and optional doc skeletons only on approval.
---

# Setup-in-the-loop

One-time bootstrap. The skills are project-agnostic; this generates the per-project config that
points them at your doc paths and gates. Keep it short — infer what you can from the repo, ask only
what you can't.

## Human-in-the-loop contract

- **Autonomous:** scanning the repo to infer existing doc layout, drafting the config, drafting any
  missing doc skeletons.
- **Gated (light confirm):** the human approves the config and any new files before they're written.

## Steps

1. **Detect existing docs.** Scan for a docs directory, ADRs, a glossary, a standards/architecture
   doc, a roadmap. Propose paths from what's found.
2. **Ask only the gaps:**
   - Doc paths not auto-detected (glossary, adr_dir, standards, architecture, roadmap). Any the
     project won't use → omit.
   - **Verify command** — the build/test/lint command finishing-check should run.
   - **Invariants** — project-specific bans to enforce (greps + where + must absent/present). Suggest
     common ones (no doc section-numbers, no snake_case in API JSON) but let the human choose.
   - **Layers** — does the project use a roadmap layer? work docs? (default: roadmap on, work docs
     off — this system derives deltas from drift-check, not persisted build scratch).
3. **Draft `.in-the-loop.json`** with the resolved values, validated against `config.schema.json`
   (in this skill folder). Show it for approval.
4. **Offer doc skeletons.** For any chosen doc path that doesn't exist yet, offer to create one from
   `templates/` in this skill folder (`standards.md`, `architecture.md`, `GLOSSARY.md`, `roadmap.md`,
   `ADR-TEMPLATE.md`). Write only on approval.
5. **On approval, write** `.in-the-loop.json` and any approved skeletons.

## Config shape

```json
{
  "docs": {
    "glossary":     "docs/GLOSSARY.md",
    "adr_dir":      "docs/decisions",
    "standards":    "docs/standards.md",
    "architecture": "docs/architecture.md",
    "roadmap":      "docs/roadmap.md"
  },
  "verify": "go build ./... && go test ./...",
  "invariants": [
    { "grep": "section [0-9]", "in": "docs/", "must": "absent", "note": "link by heading name" }
  ],
  "layers": { "roadmap": true, "work_docs": false }
}
```

Omit any `docs` key the project doesn't use; skills skip absent slots.
