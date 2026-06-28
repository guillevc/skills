# skills

Personal agent skills for AI coding agents.

## Install

```sh
# browse and select skills to install
npx skills add guillevc/skills

# specific skill
npx skills add guillevc/skills --skill <name>
```

## Skills

### misc

| Skill              | Description                                                                                                                                                                                                              |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `2-commit-fast`    | Fast auto-commit: analyzes staged git changes and commits with an intelligent conventional commit message — no confirmation needed.                                                                                      |
| `swift-factory-di` | Complete reference for [Factory](https://github.com/hmlongco/Factory) 2.x — the Swift dependency injection library by hmlongco. Covers API surface, scopes, property wrappers, testing patterns, and migration from 1.x. |
| `refactor-guru`    | Refactor code guided by smell identification, root-cause analysis, and intent-driven or comprehension-driven lenses. Helps clean up messy code, break up large classes/methods, and apply proven refactoring patterns.   |
| `test-doubles`     | Identify, classify, design, and create test doubles using Martin Fowler's taxonomy (Dummy, Fake, Stub, Spy, Mock). Language-agnostic — helps choose the right type, refactor brittle tests, and understand state vs behavior verification. |

### living-spec

A coordinated bundle for keeping a living spec (ADRs + glossary) in sync with code. See [skills/living-spec/README.md](skills/living-spec/README.md).

| Skill        | Description                                                                                                                                            |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `init-spec`  | Bootstrap a living spec on an existing codebase by extracting the terms and decisions already baked into the code. Run once when adopting living-spec. |
| `develop`    | Take a unit of work from fuzzy idea to shipped on one loop: interrogate the plan, build against the spec, freeze proven decisions, verify, optionally commit/PR. |
| `audit`      | Audit code against the living spec and let the human resolve each contradiction. Reports drift; never auto-fixes.                                       |
| `record`     | Write a resolved fact (a glossary term or an ADR) into the living spec and keep it coherent. Drafts for human ratification.                            |
| `reconcile`  | Sweep the whole living spec against the whole codebase to catch drift after out-of-band changes — the deliberate, human-triggered global pass.         |

## License

MIT
