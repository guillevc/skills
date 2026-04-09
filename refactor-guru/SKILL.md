---
name: refactor-guru
description: >
  Use when the user asks to refactor code, clean up messy code, or code "feels wrong" — hard
  to test, follow, or change. Also when they mention specific smells (god class, long method,
  feature envy, shotgun surgery, spaghetti code, tight coupling), ask "why is this code so
  hard to change/test/read," want to break up a large class or method, or say things like
  "this is a mess," "I keep having to change 10 files," "this class does too much," or
  "I can't write tests for this." Also when they have a structural goal ("make this pluggable,"
  "I need to add N more export formats," "we need to deploy independently," "I want to support
  undo") or a comprehension problem ("I can never remember how billing works," "new devs take
  weeks to understand this," "the code works but I can't explain it").
---

# Code Refactoring

Diagnose structural problems in code using three lenses: pain (what hurts now), intent (what
the code needs to become), and comprehension (what's hard to understand). Apply the smallest
change that solves the real problem. Language-agnostic.

## When to Use

- User shows code and asks "what's wrong with this?" or "how can I improve this?"
- User describes pain: brittle tests, cascading changes, files that grow endlessly
- User mentions smells by name or informal equivalents ("spaghetti code," "this does too much")
- User wants to apply a specific design pattern or refactoring technique
- User asks why code is hard to change, test, or understand
- User has a structural goal or upcoming need: "make this pluggable," "I need to add N more X,"
  "we need to deploy these independently," "I want to support undo/redo"
- User struggles to understand code: "I can never remember how X works," "new devs take weeks,"
  "the code works but I can't explain it," "what does this even do"

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

## Quick Reference — Common Intent → Pattern

| Goal | Likely Pattern | Key Technique |
|------|---------------|---------------|
| Add N more variants (formats, providers, rules) | Strategy | Extract Interface + Extract Class per variant |
| Make pluggable/extensible | Strategy / Observer | Extract Interface + dependency injection |
| Support undo/redo | Command + Memento | Extract Method → Command objects |
| Deploy modules independently | Facade | Extract Class + boundary interface |
| React to changes elsewhere | Observer | Extract event interface |
| Handle object in multiple states | State | Replace Type Code with State/Strategy |
| Simplify complex subsystem access | Facade | Hide Delegate + Extract Class |

---

## Step 1: Understand the Context

Before diagnosing, establish:

1. **What code?** Read it carefully. Understand what it does.
2. **What's the driver?** Identify which lens is strongest — they're not mutually exclusive, and
   requests often combine signals. Lead with the strongest one.
   - **Pain**: Something hurts now — hard to change, test, read, keeps breaking
   - **Intent**: Upcoming need — "I need to add X," "make this pluggable," "support Y"
   - **Comprehension**: Hard to understand — "can't follow this," "new devs struggle," "can't explain it"
3. **What language?** Idiomatic solutions differ across languages.
4. **How mature?** Prototype vs production changes the threshold for action.
5. **Is now the right time?** Rule of Three: first time, just do it; second time, wince; third time, refactor. Best times: before adding a feature, when fixing a bug, during code review.

**Routing:**
- Pain / "what's wrong?" → **Step 2** (smell detection)
- Structural goal / upcoming need → **Step 2B** (structural gap analysis), optionally **Step 2** too
- Understanding struggle → **Step 2C** (domain alignment), optionally **Step 2** too
- Mixed signals → lead with the strongest driver, draw from other lenses as needed
- Problem described, no code → Ask to see the code first
- Asks about a specific pattern/technique → **Step 4** or **Step 5**
- Wants to refactor specific code → **Step 2**, move quickly to **Step 6**
- No clear signal → default to **Step 2** (smell detection)

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

## Step 2B: Structural Gap Analysis (Intent-Driven)

Use this lens when the user has an upcoming need or structural goal. Smell detection finds
things that already hurt. Structural gap analysis finds things that are *about to* hurt — it
prevents the smell from forming. This is the refactoring equivalent of "make the change easy,
then make the easy change."

### 1. Understand the current structure

How is the relevant behavior organized now? What are the extension points (or lack thereof)?
Where are the boundaries?

### 2. Understand what the goal requires

| Intent signal | Structural requirement |
|---------------|----------------------|
| "Add N more X" (formats, providers, strategies) | Open for extension without modifying existing code |
| "Make this pluggable" | Defined extension points, interface-based composition |
| "Deploy independently" | Low coupling, clear module boundaries, no shared mutable state |
| "Support undo" | Operations captured as objects, state snapshots |
| "Make this testable in isolation" | Dependency inversion, injectable collaborators |
| "Support multiple X simultaneously" | Strategy/State composition instead of hardcoded behavior |
| "React to changes in X" | Event/subscription mechanism instead of polling or direct calls |

### 3. Name the gap

State it concretely: "Export formats are hardcoded in a switch in `ReportGenerator.export()`.
Adding a format means editing this method. No extension point exists."

### 4. Find the bridging pattern

Match the gap against each pattern's **"Problem it solves"** description in
`references/patterns-catalog.md`. The structural requirement maps directly to a pattern's intent.

| Structural need | Primary pattern | Why |
|----------------|----------------|-----|
| Extensibility (add N more X) | Strategy | Encapsulate each variant behind an interface |
| Pluggability | Strategy / Observer | Define extension points via composition |
| Independent deployment | Facade / Mediator | Establish module boundaries with minimal interfaces |
| Undo/redo | Command + Memento | Capture operations as objects with state snapshots |
| Testability | Dependency Inversion + Strategy | Inject collaborators behind interfaces |
| React to changes | Observer | Decouple notification from the thing that changed |
| Multiple simultaneous behaviors | Decorator / Composite | Stack or compose behaviors |

→ Proceed to **Step 4** with the identified pattern/technique.

---

## Step 2C: Domain Alignment Analysis (Comprehension-Driven)

Use this lens when code is hard to reason about because its structure doesn't match the domain
or the reader's mental model. Smell detection asks "what's structurally wrong?" Domain alignment
asks "why can't people understand this?" Sometimes code has no traditional smells but is still
incomprehensible because the structure doesn't match how people think about the problem.

### 1. Identify the domain concepts

What real-world things does this code deal with? List them. Examples: billing cycles,
subscriptions, permissions, order fulfillment, pricing tiers, notification preferences.

### 2. Check if concepts are explicit in the code

For each domain concept: is there a named entity (class, module, function group) that
represents it? Or is the concept implicit?

| Symptom | What it means |
|---------|--------------|
| Logic for concept X spread across 3+ files | Concept is implicit — not represented as a unit |
| Method named `processData` or `handleStuff` | Name doesn't reflect domain — reader can't build mental model |
| Primitive fields like `status: int` or `type: string` | Domain value has no home for its rules |
| Long method with commented sections | Sections are unnamed concepts fighting to get out |
| Deep nesting or complex conditionals | Decision logic is implicit — the "why" is hidden |

### 3. Name the misalignment

State it: "The concept of 'billing cycle' doesn't exist as an entity. Its logic is split
between `UserService.charge()`, `PaymentController.process()`, and `utils/billing.js`. A
reader has to trace three files to understand billing."

### 4. Pick the restructuring technique

The fix is almost always one or more of:
- **Extract Class** — make the implicit concept a first-class entity
- **Rename Method / Rename Class** — align names with domain language
- **Move Method** — gather scattered logic into the concept's new home
- **Replace Data Value with Object** — give domain values a proper type
- **Extract Method** — name the unnamed sections within long methods

→ Proceed to **Step 3**, framing the explanation around comprehensibility rather than pain.

---

## Step 3: Name and Explain the Problem

1. **Name the problem** using standard terminology (e.g., "This is Feature Envy" for smells,
   "There's no extension point for X" for structural gaps, "The concept of X is invisible in the
   code" for domain misalignment)
2. **Point to the specific code** — line numbers, method names, class names
3. **Explain why it's a problem in THIS code** — concrete consequence, not abstract theory. E.g.:
   - Pain: "`OrderProcessor.calculateDiscount()` accesses 6 fields from `Customer` and only 1 from its own class. Every time `Customer` changes, `OrderProcessor` breaks."
   - Intent: "Payment logic is hardcoded to Stripe in `checkout()`. Adding PayPal means editing this method, risking regressions in existing Stripe flows."
   - Comprehension: "Billing logic is split across three files. A new developer has to trace all three to understand how a charge happens."
4. **Name the category** so the user builds a mental model ("This is a Coupler — excessive dependency between classes")
5. **Explain why it developed** — business pressure, "just two more lines" growth, copy-paste under deadline, inheritance for reuse instead of modeling, or overzealous prior refactoring. Naming the cause prevents recurrence.

---

## Step 4: Suggest the Refactoring Technique

For each problem, there are specific refactoring techniques from the catalog. Don't just name
the technique — explain what it means in terms of concrete steps for this code.

For pain-driven cases, the technique follows from the smell. For intent-driven cases, the
technique often follows from the pattern identified in Step 2B — the pattern tells you *what*
structure to create, the technique tells you *how* to get there mechanically.

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

For intent-driven cases (Step 2B), the pattern is often identified first and the technique
follows from it — the reverse of the smell-driven flow. This is fine. The important thing
is that the pattern genuinely solves the structural need, not that it was discovered in a
particular order.

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
- The stated intent is speculative ("we might need to...") — wait until the need is concrete.
  YAGNI applies even more to intent-driven refactoring than to pain-driven
- Comprehension can be fixed with better names and comments alone — don't restructure code
  when renaming methods and adding a docblock would suffice
- The code is "over-engineered" but the abstractions are carrying their weight — don't remove
  patterns just because "simpler is better." The question is whether the complexity is justified
  by what the code actually needs to do

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
