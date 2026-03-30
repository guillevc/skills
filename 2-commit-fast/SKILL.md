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

## Step 3: Analyze the diff

Read the staged diff and identify:

- **What changed**: files added, modified, or deleted; functions or classes touched; config altered
- **The nature of the change**: is this a new feature, bug fix, refactor, docs update, test addition, dependency change, config tweak, CI change, style fix, or performance improvement?
- **The scope**: which single module, package, or component is affected

## Step 4: Build the commit message

### Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]
```

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

### Body

Add a body only when the subject alone doesn't explain why the change was made or when the diff is complex. Keep it to a sentence or two. Most commits don't need a body.

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

## Important

- Do not ask the user to confirm the message — just commit
- Do not generate multiple options — pick the best one
- Do not include co-authorship footers or AI attribution
- Do not run `git add` unless the user explicitly asked you to stage files
- Do not commit if nothing is staged
