---
name: test-doubles
description: >
  Identify, classify, design, and create test doubles using Martin Fowler's taxonomy (Dummy, Fake,
  Stub, Spy, Mock) in any programming language. Use this skill whenever the user needs help with
  test doubles, mocking, stubbing, faking, or test isolation. Trigger on: creating mocks or stubs
  for unit tests, deciding between state and behavior verification, choosing the right test double
  type, refactoring brittle over-mocked tests, classifying existing test doubles ("what kind of
  test double is this?"), writing fakes for integration testing, setting up test spies, replacing
  real dependencies in tests, debating classical vs mockist TDD, reducing test coupling to
  implementation details, or fixing tests that break on every refactor. Also trigger when the user
  mentions mocking frameworks (Mockito, unittest.mock, Sinon, jest.mock, Moq, gomock, testdouble.js,
  RSpec mocks, OCMock, Mockery, NSubstitute), or asks "should I mock this?" or "why are my tests
  so brittle?" Even if the user doesn't say "test double" explicitly, trigger when they're clearly
  struggling with test isolation, fake implementations, or verification strategy.
---

# Test Doubles — Classify, Design & Create

> Based on Martin Fowler's "Mocks Aren't Stubs" and Gerard Meszaros's xUnit Patterns taxonomy.
> Language-agnostic — works with any programming language and testing framework.

Test doubles replace real collaborators in tests. There are five distinct types, and choosing
the wrong one is the most common cause of brittle, hard-to-maintain test suites. This guide
helps you pick the right type, build it idiomatically, and avoid common traps.

---

## Step 1: Understand Context

Before recommending or writing anything, establish these facts:

1. **What are you testing?** — the system under test (SUT)
2. **What dependency needs replacing?** — the collaborator
3. **What language and test framework?** — for idiomatic code
4. **Why does this need a double?** — slow, nondeterministic, not yet built, hard to trigger edge cases
5. **What matters to verify?** — resulting state, or that specific interactions occurred

**Routing:**
- User has existing test double code to classify → skip to **Step 3**
- User wants to refactor existing tests → skip to **Step 5**
- User needs a new test double → continue to **Step 2**

---

## Step 2: Select the Right Test Double

Walk through this decision tree to pick the right type:

```
Does the test need the dependency to DO anything?
│
├─ NO → DUMMY
│       The dependency fills a constructor/method signature
│       but the test never actually calls it.
│
└─ YES
   │
   Does the test need a WORKING implementation (not just canned answers)?
   │
   ├─ YES → FAKE
   │        e.g., in-memory database, local filesystem, fake HTTP server.
   │        Has real business logic, just with shortcuts for speed/simplicity.
   │
   └─ NO
      │
      What does the test need to VERIFY?
      │
      ├─ RESULTING STATE (what happened) → STUB
      │   Returns canned responses so the SUT can run.
      │   The test asserts on the SUT's output/state — not on the stub.
      │
      └─ INTERACTIONS (what was called)
         │
         Do you need verification to happen AUTOMATICALLY
         (fail if unexpected call / missing expected call)?
         │
         ├─ YES → MOCK
         │        Pre-programmed with expectations.
         │        Verification happens on the mock object itself.
         │
         └─ NO → SPY
                  Records calls for later inspection.
                  You assert on the spy's recorded data in the test.
```

### Quick Reference

| Type  | Has logic? | Returns data? | Records calls? | Auto-verifies? | Use when...                                        |
|-------|-----------|--------------|---------------|---------------|---------------------------------------------------|
| Dummy | No        | No           | No            | No            | Filling signatures — the dep is never touched      |
| Fake  | Yes       | Yes (real)   | No            | No            | Need working behavior, real thing too slow/complex  |
| Stub  | No        | Yes (canned) | No            | No            | SUT needs specific input, you verify SUT state      |
| Spy   | No        | Yes (canned) | Yes           | No            | Need to check what was sent to a collaborator       |
| Mock  | No        | Yes (canned) | Yes           | Yes           | Need strict interaction verification up front       |

### State vs Behavior Verification

This is the fundamental fork:

- **State verification** — run the SUT, then check its output or final state. Stubs and Fakes
  support this. The test doesn't care HOW the SUT achieved the result, only WHAT the result is.
  This produces tests that survive refactoring because they're decoupled from internal implementation.

- **Behavior verification** — check that the SUT called specific methods with specific arguments.
  Mocks and Spies support this. The test is coupled to how the SUT works internally, which means
  changes to implementation can break tests even when behavior is unchanged.

**Default to state verification.** It produces more resilient tests. Use behavior verification only
when the interaction IS the important thing — sending an email, publishing a message, writing an
audit log, calling an external API. In those cases, the side effect is the behavior you care about,
and there's no resulting state to check on the SUT.

---

## Step 3: Classify Existing Test Doubles

When a user shows existing code and asks what kind of test double it is, classify by **usage pattern**,
not by what the framework calls it or what the class is named:

1. Has real business logic (even simplified)? → **Fake**
2. Passed around but never called in the test? → **Dummy**
3. Returns canned data AND the test asserts on recorded calls? → **Spy**
4. Returns canned data AND has pre-programmed expectations that auto-verify? → **Mock**
5. Returns canned data AND the test only asserts on SUT state? → **Stub**

Most testing frameworks blur these lines. A Jest `jest.fn()` can act as a stub, spy, or mock
depending on how you use it. A Mockito `mock()` is technically a stub until you call `verify()`.
Classify by usage, not by the framework's terminology.

After classifying, explain:
- What the double actually is vs what it's named/called
- Whether that type is appropriate for what the test is trying to verify
- If misclassified or misused, suggest the correct approach

---

## Step 4: Generate the Test Double

When writing test double code:

1. **Use idiomatic patterns** for the user's language and framework
2. **Prefer hand-written doubles** for Dummies, Fakes, and simple Stubs — they're easier to
   understand and maintain than framework-generated ones
3. **Use framework doubles** (Mockito, unittest.mock, etc.) for Spies and Mocks where the
   framework makes recording/verifying cleaner
4. **Show the complete test** that uses the double, not just the double in isolation — the
   test is where the verification strategy becomes clear
5. **Add a brief comment** explaining why this type was chosen

After generating, explain:
- Why this type of test double is the right choice here
- What verification strategy the test uses (state vs behavior)
- What would change if a different type were used (and why that would be worse)

For detailed multi-language examples and framework-specific patterns, read
`references/taxonomy-guide.md`.

---

## Step 5: Refactor Existing Tests

When improving existing test code, first identify whether the codebase follows the classical
(Detroit) or mockist (London) TDD style — this determines what "correct" looks like. If tests
mock every collaborator and verify all interactions, that's the mockist style. If they use real
objects and only double awkward dependencies, that's classical. Name the style explicitly in
your diagnosis so the user understands the tradeoff their codebase is making. When the user's
problem is brittleness from over-mocking, explain that shifting toward classical style (state
verification, real objects where practical) is the remedy — and frame it as a spectrum, not
an all-or-nothing switch.

Diagnose these common anti-patterns:

### Anti-Pattern 1: Mock Overuse (the most common problem)

**Symptom:** Tests break when you refactor internals, even though external behavior is unchanged.

**Why it happens:** Using mocks (behavior verification) where stubs (state verification) would
suffice. Every `expect(mock).toHaveBeenCalledWith(...)` is a coupling point to implementation.

**Fix:** Replace mocks with stubs. Assert on the SUT's outputs rather than on which methods it
called internally. Keep behavior verification only for genuine side effects (notifications, events,
external API calls).

### Anti-Pattern 2: Testing the Mock

**Symptom:** Test passes but doesn't actually verify anything useful about the SUT.

**Why it happens:** The mock's canned response is what gets asserted — you're verifying your own
setup, not the SUT's logic.

**Fix:** Assertions should target the SUT's behavior. If the test would pass with any canned
response, it's not testing anything real.

### Anti-Pattern 3: Missing Fakes for Complex Collaborators

**Symptom:** Dozens of stubs with increasingly elaborate canned responses that are hard to maintain.

**Why it happens:** The collaborator has complex stateful behavior that can't be realistically
represented by a few canned return values.

**Fix:** Write a Fake with simplified but real logic (e.g., `InMemoryUserRepository` backed by a
dictionary/map). Fakes need their own tests, but they pay for themselves when many tests share them.

### Anti-Pattern 4: Dummy Disguised as Stub

**Symptom:** A stub with canned responses, but the test never exercises the code path that uses them.

**Why it happens:** Someone set up a stub "just in case" when a null/empty dummy would suffice.

**Fix:** Replace with a Dummy. Simpler setup, clearer test intent.

### Anti-Pattern 5: Spy on Everything

**Symptom:** Every test records and asserts on every single interaction.

**Why it happens:** Defaulting to spies/mocks out of habit rather than asking "what does this test
actually need to verify?"

**Fix:** For each assertion, ask: "does this test care about the interaction, or the result?"
If the result, use a stub and assert on state.

---

## Classical vs Mockist TDD

These are two philosophies about when and how to use test doubles. Understanding which style a
codebase follows helps you make consistent recommendations.

| Factor                | Classical (Detroit school)              | Mockist (London school)                |
|-----------------------|----------------------------------------|----------------------------------------|
| Default double        | Real objects                           | Mocks for all collaborators            |
| When to use doubles   | Only for awkward collaborators          | Always                                 |
| Verification          | State                                  | Behavior                               |
| Test isolation        | SUT + real collaborators               | SUT only                               |
| Fixture setup         | Can be complex (Object Mother pattern) | Always simple (just mocks)             |
| Refactoring resilience| High — tests survive internal changes  | Lower — coupled to interactions        |
| Design feedback       | Less direct                            | Guides toward small, focused interfaces|
| TDD direction         | Middle-out (domain model first)        | Outside-in (UI layer inward)           |

Neither is universally better. **Classical is the safer default** for teams without a strong
established preference — it produces tests that are more resilient to refactoring. Mockist shines
during outside-in TDD where you're designing collaborator interfaces top-down and want the tests
to drive interface discovery.

When refactoring an existing test suite, match the team's existing style unless they're explicitly
asking to switch approaches.

---

## Reference

For detailed per-type definitions with multi-language code examples (Python, TypeScript, Java, Go,
Ruby, Swift, C#), framework-specific mapping tables, and extended anti-pattern analysis, read
`references/taxonomy-guide.md`.
