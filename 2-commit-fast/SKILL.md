---
name: 2-commit-fast
description: >
  Fast auto-commit: analyzes staged git changes and commits with an intelligent conventional commit
  message — no confirmation needed. Use when the user says "commit", "fast commit", "quick commit",
  "auto commit", or invokes /2-commit-fast. Also trigger when the user says things like "commit this",
  "save my changes", "commit what I have staged", or any variation requesting a git commit without
  wanting to write the message themselves.
---

# Fast Commit

Analyze staged changes and commit instantly with a well-crafted conventional commit message. No confirmation step — speed is the point.

## Step 1: Check for staged changes

Run `git diff --cached --stat` to see what's staged.

If nothing is staged, check `git status` for unstaged changes. If there are unstaged changes, tell the user nothing is staged and suggest they stage files first. Do not run `git add` unless the user explicitly asks you to. If the repo is clean, say so and stop.

## Step 2: Gather context

Run these in parallel:

- `git diff --cached` — the full staged diff (this is the primary input for the commit message)
- `git log --oneline -20` — recent commit history, so you can match the project's existing scope conventions
- `git branch --show-current` — the branch name often encodes intent (e.g., `fix/null-user-lookup`, `feat/oauth-google`)

**Conversation context:** Before analyzing the diff, review what the user has been working on in this conversation. Tasks they described, bugs they debugged, or features they built are the strongest signal for the *why* behind a change. Prefer conversation context over guessing intent from code alone.

## Step 3: Analyze the diff

Determine **what** changed and **why**:

1. **Identify the what:** Which functions, classes, routes, or config keys were added, modified, or deleted? Which single module, package, or component is affected (this becomes the scope)?
2. **Determine the why** using these signals (in priority order):
   - **Conversation context** — what was the user trying to accomplish? This overrides all heuristics below.
   - **Branch name** — `fix/`, `feat/`, `chore/` prefixes directly indicate type and intent.
   - **Diff patterns that reveal intent:**
     - Conditional/guard clause added or changed around existing logic → likely `fix`
     - Return value or error handling changed → likely `fix`
     - New exported function/class/route/component → likely `feat`
     - Renamed symbols, moved code between files, extracted helpers with no new behavior → `refactor`
     - Only `.test.` / `.spec.` / `__tests__` files changed → `test`
     - Only `package.json`, lockfile, `.config` files → `chore` or `build`
3. **Gauge complexity:** Count files changed and total lines added/removed.

### Large diffs (>300 lines or >8 files)

For big diffs, don't try to describe everything. Instead:
- Identify the single unifying intent (e.g., "migrate from REST to GraphQL", "add user profile feature")
- If there is no unifying intent, describe the dominant change and note the secondary ones in the body
- Skim file names and hunks for the theme; don't get lost in implementation details

## Step 4: Build the commit message

### Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]
```

For breaking changes, append `!` after the type/scope:

```
type(scope)!: description

What breaks and how to migrate.
```

A breaking change always requires a body explaining what breaks.

### Type

Pick the type that best describes what the change does:

| Type       | Use when                                           |
|------------|----------------------------------------------------|
| `feat`     | New user-facing functionality                      |
| `fix`      | Bug fix                                            |
| `docs`     | Documentation only (README, comments, docstrings)  |
| `style`    | Formatting, whitespace — no logic change           |
| `refactor` | Code restructuring with no behavior change         |
| `test`     | Adding or updating tests                           |
| `chore`    | Maintenance: deps, configs, build scripts, tooling |
| `perf`     | Performance improvement                            |
| `ci`       | CI/CD pipeline changes                             |
| `build`    | Build system or external dependency changes        |
| `revert`   | Reverting a previous commit                        |

### Scope

Look at the recent commit log from Step 2 to understand what scopes the project already uses. Match those conventions — if the project uses `auth`, don't invent `authentication`. If the project has never used scopes, don't start now.

Rules:
- Scope should identify a single area of the codebase (a module, package, directory, or component)
- If the change touches multiple areas that don't share a single natural scope, omit the scope entirely — write `type: description` instead of `type(scope1, scope2): description`
- Never use comma-separated or slash-separated scopes

### Subject line

- Lowercase, imperative mood ("add", not "added" or "adds")
- 72 characters max for the entire subject line (including `type(scope): `)
- Describe what the change does, not which files were touched
- Be specific: `fix null pointer in user lookup` beats `fix bug`

**Anti-patterns — never generate these:**
- Vague: "update code", "fix issue", "improve handling", "make changes", "address feedback"
- Tautological: "refactor: refactor auth module", "fix: fix the bug"
- File-listing: "update user.ts and auth.ts"
- Over-broad: "improve application" or "update project"

If you catch yourself writing a vague subject, ask: *what specifically was broken/missing/wrong?* Name the concrete thing.

### Body

Add a body (1-3 sentences) when any of these are true:
- The change is a **fix** and the subject doesn't name the root cause
- The change is a **breaking change** (always explain what breaks)
- The diff touches >5 files or >150 lines
- The *why* is not obvious from the *what* (e.g., a performance fix that changes algorithm)

Skip the body when the subject fully explains a small, obvious change (rename, dep bump, typo fix).

## Step 5: Commit

Run the commit immediately:

```bash
git commit -m "type(scope): description"
```

Or with a body:

```bash
git commit -m "$(cat <<'EOF'
type(scope): description

Brief explanation of why, if needed.
EOF
)"
```

After committing, show the user the resulting commit hash and message.

## Examples

**Single-scope changes:**
```
feat(auth): add OAuth2 integration with Google provider
fix(api): resolve timeout on token refresh
docs(readme): update installation instructions for v2.0
chore(deps): update express to 4.19.2
test(auth): add tests for token expiration edge cases
```

**Multi-scope changes (scope omitted):**
```
refactor: rename internal helpers for consistency
chore: update linter config and CI pipeline
feat: add user profile page with API endpoint
```

**Breaking change:**
```
feat(api)!: require API key for all endpoints
```

**With body:**
```
fix(parser): handle unterminated string literals

Previously, an unterminated string caused an infinite loop in the tokenizer.
The parser now emits a diagnostic and recovers at the next newline.
```

## Important

- Do not ask the user to confirm the message — just commit
- Do not generate multiple options — pick the best one
- Do not include co-authorship footers or AI attribution
- Do not run `git add` unless the user explicitly asked you to stage files
- Do not commit if nothing is staged
