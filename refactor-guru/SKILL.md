---
name: refactor-guru
description: >
  Use when the user asks to refactor code, clean up messy code, or code "feels wrong" — hard
  to test, follow, or change. Also when they mention specific smells (god class, long method,
  feature envy, shotgun surgery, spaghetti code, tight coupling), ask "why is this code so
  hard to change/test/read," want to break up a large class or method, or say things like
  "this is a mess," "I keep having to change 10 files," "this class does too much," or
  "I can't write tests for this."
---

# Code Smell Detection & Refactoring

Diagnose structural problems in code using the Fowler/Kerievsky/Beck smell taxonomy and GoF
design patterns. The goal: identify what's causing pain and apply the smallest change that
removes it. Language-agnostic.

## When to Use

- User shows code and asks "what's wrong with this?" or "how can I improve this?"
- User describes pain: brittle tests, cascading changes, files that grow endlessly
- User mentions smells by name or informal equivalents ("spaghetti code," "this does too much")
- User wants to apply a specific design pattern or refactoring technique
- User asks why code is hard to change, test, or understand

**Don't use when:** Code is a prototype/spike, about to be replaced, or the user just wants a feature added (refactor only if it enables the feature).

## Quick Reference — Most Common Smell → Fix

| Pain | Likely Smell | Primary Fix |
|------|-------------|-------------|
| Method is 200+ lines | Long Method | Extract Method |
| Class has 30+ fields | Large Class | Extract Class |
| Same 4 params everywhere | Data Clumps | Introduce Parameter Object |
| Huge switch/case keeps growing | Switch Statements | Replace Conditional with Polymorphism |
| Method uses another class's data more than its own | Feature Envy | Move Method |
| One change touches 10+ files | Shotgun Surgery | Move Method / Move Field (consolidate) |
| One class changes for unrelated reasons | Divergent Change | Extract Class (split by responsibility) |
| Two classes know too much about each other | Inappropriate Intimacy | Move Method + Hide Delegate |
| Copy-pasted code blocks | Duplicate Code | Extract Method / Extract Superclass |
| Getters/setters only, no behavior | Data Class | Move behavior into the data class |

---

## Step 1: Understand the Context

Before diagnosing, establish:

1. **What code?** Read it carefully. Understand what it does.
2. **What's the pain?** The pain tells you which smells matter.
3. **What language?** Idiomatic solutions differ across languages.
4. **How mature?** Prototype vs production changes the threshold for action.
5. **Is now the right time?** Rule of Three: first time, just do it; second time, wince; third time, refactor. Best times: before adding a feature, when fixing a bug, during code review.

**Routing:**
- Code shown + "what's wrong?" → **Step 2**
- Problem described, no code → Ask to see the code, then **Step 2**
- Asks about a specific pattern/technique → **Step 4** or **Step 5**
- Wants to refactor specific code → **Step 2**, move quickly to **Step 6**

---

## Step 2: Detect the Smell

Analyze the code against the five smell categories. Most code has multiple smells — focus on
the one causing the most pain, not every smell you can find.

### The Five Categories

Think of these as lenses to look through:

**Bloaters** — Things that have grown too large to manage
- Long Method, Large Class, Primitive Obsession, Long Parameter List, Data Clumps

**Object-Orientation Abusers** — OO principles applied incorrectly or incompletely
- Switch Statements, Temporary Field, Refused Bequest, Alternative Classes with Different Interfaces

**Change Preventers** — Code structures that make changes ripple everywhere
- Divergent Change (one class changes for many reasons), Shotgun Surgery (one change touches many classes), Parallel Inheritance Hierarchies

**Dispensables** — Things that could be removed to make code cleaner
- Duplicate Code, Lazy Class, Data Class, Dead Code, Speculative Generality, Comments (as deodorant)

**Couplers** — Excessive coupling between classes
- Feature Envy, Inappropriate Intimacy, Message Chains, Middle Man

For the full catalog with all smells, their symptoms, and mapped refactoring techniques,
read `references/smells-catalog.md`.

### How to Identify the Primary Smell

Start from the user's pain, not from a checklist:

- "I keep changing this file for unrelated reasons" → **Divergent Change**
- "Every small change requires editing 10+ files" → **Shotgun Surgery**
- "This method is 200 lines long" → **Long Method**
- "This class has 30 fields" → **Large Class**
- "I pass the same 4 parameters everywhere" → **Data Clumps** or **Long Parameter List**
- "There's a huge switch/case I keep extending" → **Switch Statements**
- "This method uses more of another class than its own" → **Feature Envy**
- "These two classes know too much about each other" → **Inappropriate Intimacy**
- "Half this subclass is overriding parent to do nothing" → **Refused Bequest**
- "I can't test this without mocking everything" → often **Feature Envy** or **Inappropriate Intimacy**
- "There's a lot of copy-pasted code" → **Duplicate Code**
- "This class is just getters and setters" → **Data Class**

When multiple smells are present, prioritize the one that:
1. Is causing the immediate pain the user described
2. Is the root cause (other smells are often symptoms of a deeper one)
3. Will yield the most benefit when fixed

---

## Step 3: Name and Explain the Smell

1. **Name the smell** using standard terminology (e.g., "This is Feature Envy")
2. **Point to the specific code** — line numbers, method names, class names
3. **Explain why it's a problem in THIS code** — concrete consequence, not abstract theory. E.g.: "`OrderProcessor.calculateDiscount()` accesses 6 fields from `Customer` and only 1 from its own class. Every time `Customer` changes, `OrderProcessor` breaks."
4. **Name the category** so the user builds a mental model ("This is a Coupler — excessive dependency between classes")
5. **Explain why it developed** — business pressure, "just two more lines" growth, copy-paste under deadline, inheritance for reuse instead of modeling, or overzealous prior refactoring. Naming the cause prevents recurrence.

---

## Step 4: Suggest the Refactoring Technique

For each smell, there are specific refactoring techniques from the catalog. Don't just name
the technique — explain what it means in terms of concrete steps for this code.

For the complete mapping of smells to techniques, read `references/smells-catalog.md`.
For the full technique catalog organized by category, read `references/refactoring-techniques.md`.

### Presenting the Refactoring

Structure your recommendation as:

1. **The technique name** (e.g., "Extract Class")
2. **What it means for this code** — translate the abstract technique into specific actions: "Pull the discount calculation logic and the three fields it uses (`loyaltyTier`, `purchaseHistory`, `discountRules`) out of `OrderProcessor` into a new `DiscountCalculator` class"
3. **The sequence of steps** — refactoring is safest done in small, verifiable steps. List them.
4. **What to watch out for** — side effects, callers that need updating, tests that need adjusting

When multiple techniques apply, recommend the simplest one that solves the problem. Mention
alternatives briefly in case the user's constraints make the primary recommendation impractical.

### Refactoring Safety

Refactoring should be a series of small changes, each leaving the code in a working state.
Two key rules:

- **Never mix refactoring and new features in the same change.** Separate them at least into
  distinct commits. When both are interleaved, it's harder to review, harder to revert, and
  harder to tell what broke if tests fail.
- **If tests break after refactoring, there are only two possibilities:** you made an error in
  the refactoring (fix it), or the tests were too tightly coupled to implementation details
  (the tests are at fault — refactor them too, or write higher-level tests).

---

## Step 5: Map to a GoF Design Pattern (When Applicable)

Not every refactoring leads to a design pattern, and you should never force a pattern where
a simpler refactoring suffices. But when a pattern naturally fits, name it and explain why.

### Common Smell → Pattern Mappings

| Smell | Pattern | When the mapping applies |
|-------|---------|--------------------------|
| Switch Statements | Strategy or State | When the switch selects behavior based on a type/state that changes |
| Switch Statements | Factory Method | When the switch creates different objects based on a type |
| Parallel Inheritance Hierarchies | Bridge | When two hierarchies vary independently |
| Duplicate Code (algorithmic) | Template Method | When algorithms share structure but differ in steps |
| Long Method (with conditionals) | Chain of Responsibility | When the method is a chain of condition→action checks |
| Feature Envy (data+behavior elsewhere) | Move to where data lives | Not a pattern — just Move Method. Patterns aren't always the answer |
| Large Class (multiple responsibilities) | Facade | When the class is a monolith that could expose simpler interfaces |
| Message Chains | Mediator | When objects talk through long chains and a central coordinator would simplify |
| Inappropriate Intimacy | Mediator | When two classes are too tightly coupled and need an intermediary |
| Temporary Field | Null Object | When fields are null "most of the time" and require null checks |
| Data Class + logic elsewhere | Move behavior into the data class | Again, not a pattern — just proper encapsulation |
| Alternative Classes with Different Interfaces | Adapter | When you need to unify interfaces you can't change |
| Speculative Generality | Remove the abstraction | Anti-pattern: premature use of patterns is itself a smell |

For the complete GoF pattern catalog with problem descriptions and usage guidance,
read `references/patterns-catalog.md`.

### Key Pattern Relationships

Patterns are not isolated — understanding how they relate helps you pick the right one:

- **Factory Method is a specialization of Template Method.** A factory method can serve as one step in a larger template method.
- **State is an extension of Strategy.** Both delegate to helper objects, but Strategy makes them independent and unaware of each other. State allows states to know about and trigger transitions to other states.
- **Bridge, State, Strategy, and Adapter** all have similar structures (composition + delegation) but solve different problems. Don't confuse them.
- **Decorator changes the skin; Strategy changes the guts.** Decorator wraps to add behavior, Strategy swaps internals.
- **Facade and Mediator both organize complexity**, but Facade simplifies access without adding behavior (subsystem is unaware of it), while Mediator centralizes communication between aware components.
- **Command and Strategy** both parameterize with an action. Command is about deferring/queuing/undoing operations. Strategy is about swapping algorithms.
- **Template Method uses inheritance (static); Strategy uses composition (dynamic, switchable at runtime).**

For the complete relationships table, read `references/patterns-catalog.md`.

### When Recommending a Pattern

1. **Explain what problem the pattern solves** in general terms
2. **Show why this code has that exact problem** — the mapping should feel natural, not forced
3. **Show how the pattern would look** in this codebase, in this language
4. **Mention the tradeoff** — patterns add indirection and structure. Is the complexity warranted?

---

## Step 6: Show Before/After

This is the most valuable part. Always show concrete code.

### Format

```
**Before** — [brief description of the problem]

[code block in the user's language showing the problematic code]

**After** — [brief description of what changed and why]

[code block showing the refactored code]
```

### Guidelines

- Use the **same language** as the user's code
- Keep the before/after **focused** — show the relevant part, not the entire file
- The after code should be **complete enough to be usable**, not pseudocode
- If the refactoring involves multiple files/classes, show all of them
- Add brief inline comments only where the transformation might not be obvious
- If the refactoring is large, break it into **incremental steps** — show each intermediate state

---

## Step 7: Flag When NOT to Refactor

Not every smell warrants action. Explicitly tell the user when refactoring would be premature.

**Don't refactor when:**
- Code is stable, tested, and won't change — the smell is cosmetic
- It's a prototype or spike — wait for design to stabilize
- The fix adds more complexity than the smell causes (3-case switch → Strategy = 4 new classes)
- Code is about to be replaced or rewritten
- Duplication is coincidental, not structural (different purposes, independent evolution)
- Test suite is absent — recommend writing tests first
- The "fix" is applying a pattern for its own sake

**When you skip refactoring, say so explicitly** — e.g.: "This is technically a Long Method at 45 lines, but the logic is linear and has one reason to change. Extracting would scatter it without real gain. Leave it unless it grows further." The user should trust that when you DO recommend refactoring, it genuinely matters.

---

## Common Mistakes

- **Refactoring everything at once** — Fix the smell causing pain, not every smell you can find. Multiple smells are normal; prioritize the root cause.
- **Forcing a design pattern** — Patterns solve specific problems. A 3-case switch doesn't need Strategy; it needs to actually hurt before you add 4 new classes.
- **Mixing refactoring with feature work** — Separate into distinct commits. Interleaving makes it harder to review, revert, and diagnose test failures.
- **Refactoring without tests** — Write tests first, then refactor. If tests break after refactoring, either the refactoring has a bug or the tests were coupled to implementation.
- **Premature DRY** — Two methods that look similar but serve different purposes and will evolve independently are coincidental duplication, not structural. Extracting creates coupling.
- **Over-splitting classes** — Shotgun Surgery often results from over-applying Divergent Change fixes. If one change now touches 10 tiny classes, you split too aggressively.
- **Ignoring "don't refactor" signals** — Stable code that won't change, prototypes, code about to be replaced, or absent test suites are all reasons to leave it alone.

---

## Reference Files

Read these when you need the full catalog or want to verify a technique:

- **`references/smells-catalog.md`** — All 22+ smells with symptoms, consequences, and mapped refactoring techniques
- **`references/refactoring-techniques.md`** — All 66 refactoring techniques organized by category
- **`references/patterns-catalog.md`** — All 23 GoF patterns with problem descriptions, usage guidance, and relationships
