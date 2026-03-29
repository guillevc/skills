---
name: swift-factory-di
description: >
  MUST USE for any question about the Swift "Factory" dependency injection library by hmlongco
  (also known as FactoryKit). This skill contains the complete API reference, best practices,
  testing patterns, and migration guides for Factory 2.x. Trigger on ANY of these situations:
  setting up Factory containers or registrations in Swift, choosing Factory scopes (.singleton,
  .cached, .shared, .graph, .unique), using Factory property wrappers (@Injected, @LazyInjected,
  @WeakLazyInjected, @DynamicInjected, @InjectedObject, @InjectedObservable), fixing flaky tests
  caused by Factory container state leaking between test cases, debugging circular dependency
  errors from Factory, mocking dependencies in SwiftUI previews with Factory, migrating from
  Factory 1.x to 2.0 syntax, reviewing or refactoring Factory container code, using ContainerTrait
  for parallel test isolation, configuring Factory contexts (.onTest, .onPreview, .onSimulator),
  or importing FactoryKit/Factory in Swift code. Even if the user doesn't say "Factory" by name,
  trigger if they mention Container.shared, SharedContainer, @Injected with keypaths like
  \.serviceName, or any Factory-specific API. Do NOT use for other DI frameworks (Swinject,
  swift-dependencies, Dagger), the factory design pattern in general, or generic DI concepts.
---

# Factory DI — Reference & Optimization Guide

> Based on [Factory](https://github.com/hmlongco/Factory) **2.5.3** by [Michael Long (hmlongco)](https://github.com/hmlongco) — a compile-time safe, container-based dependency injection framework for Swift.
>
> This skill is an unofficial community resource. Factory is licensed under the MIT License.

Factory is under 1000 lines of executable code, yet provides containers, scopes, contexts, decorators, parameter injection, and full SwiftUI integration. It requires no code generation, build scripts, or runtime reflection.

As of 2.5.0, the recommended import is `import FactoryKit` (not `import Factory`) to avoid SPM naming conflicts.

---

## Core Patterns

### Defining a Factory

Factories are computed properties on container extensions. Each returns a `Factory<T>` that wraps a closure producing the dependency:

```swift
extension Container {
    var networkService: Factory<NetworkServiceType> {
        self { URLSessionNetworkService() }
    }
}
```

The `self { ... }` syntax is shorthand for `Factory(self) { ... }`. The closure is `@Sendable`.

### Resolving Dependencies

```swift
// Direct resolution
let service = Container.shared.networkService()

// Property wrapper (uses Container.shared implicitly)
@Injected(\.networkService) var service

// From a custom container
@Injected(\MyContainer.networkService) var service
```

### Constructor Injection (Preferred)

Wire dependencies through the container itself — this keeps the dependency graph visible:

```swift
extension Container {
    var repository: Factory<UserRepository> {
        self { UserRepository(network: self.networkService()) }
    }
}
```

### Protocol-Based Registration

Always register against protocols for testability:

```swift
var networkService: Factory<NetworkServiceType> {  // protocol, not concrete
    self { URLSessionNetworkService() }
}
```

### Custom Containers

For modular apps, define separate containers per feature or module:

```swift
final class AuthContainer: SharedContainer {
    static let shared = AuthContainer()
    let manager = ContainerManager()

    var authService: Factory<AuthServiceType> {
        self { KeychainAuthService() }
    }
}
```

---

## Property Wrapper Selection Guide

Choosing the right wrapper matters for performance, correctness, and lifecycle:

| Wrapper | Resolves | Re-resolves | Holds | Use when |
|---------|----------|-------------|-------|----------|
| `@Injected` | At init | Never | Strong | Default choice. Dependency is needed immediately and won't change. |
| `@LazyInjected` | First access | Never | Strong | Resolution is expensive or has side effects; delay until actually needed. |
| `@WeakLazyInjected` | First access | If released | Weak | Breaking retain cycles or shared-scope dependencies you don't want to own. |
| `@DynamicInjected` | Every access | Every access | None | Dependency may change at runtime (e.g., after re-registration). Rare. |
| `@InjectedObject` | At init | Never | Strong (StateObject) | SwiftUI views needing an `ObservableObject` view model. Owns the instance. |
| `@InjectedObservable` | At init | Never | Strong (State) | SwiftUI views with iOS 17+ `@Observable` types. |

**Rules of thumb:**
- Start with `@Injected` unless you have a reason not to.
- In SwiftUI views, use `@InjectedObject` (pre-iOS 17) or `@InjectedObservable` (iOS 17+) instead of manually wrapping in `@StateObject`/`@State`.
- `@DynamicInjected` has a resolution cost on every property access — only use it when the registration genuinely changes at runtime.

### LazyInjected Extras

`@LazyInjected` exposes helpers through its projected value (`$`):

```swift
@LazyInjected(\.heavyService) var service

// Check if resolved yet
if let resolved = $service.resolvedOrNil() { ... }

// Force resolution
$service.resolve()
```

---

## Scope Selection Guide

Scopes control how long a resolved instance lives. The default is `.unique` (new instance every time).

```
Is the instance stateless / cheap to create?
  YES → .unique (default, no action needed)
  NO ↓

Should it live for the entire app lifetime?
  YES → .singleton
  NO ↓

Should it live until explicitly reset?
  YES → .cached
  NO ↓

Should it be shared only while someone holds a reference?
  YES → .shared
  NO ↓

Should all objects in one resolution chain share the same instance?
  YES → .graph
```

### Applying Scopes

```swift
var userManager: Factory<UserManager> {
    self { UserManager() }.singleton
}

var sessionService: Factory<SessionService> {
    self { SessionService() }.cached
}
```

### Custom Scopes

Define domain-specific scopes for clarity:

```swift
extension Scope {
    static let session = Cached()
}

var sessionData: Factory<SessionData> {
    self { SessionData() }.scope(.session)
}

// Reset just this scope on logout
Scope.session.reset()
```

### Time-To-Live

Cache with automatic expiration:

```swift
var config: Factory<RemoteConfig> {
    self { RemoteConfig.fetch() }.cached.timeToLive(300) // 5 minutes
}
```

### Graph Scope — Use With Care

`.graph` caches an instance only within a single resolution cycle. This is powerful for ensuring related objects share the same instance during construction, but has subtleties:

- Each `@Injected` property wrapper triggers its own resolution cycle — two `@Injected` properties in the same class will get *different* graph-scoped instances.
- Graph scope works best when dependencies are wired through constructor injection inside the container, so they share a single resolution chain.

---

## Context-Based Registration

Contexts let you swap implementations based on runtime environment without `#if` flags scattered through your code:

```swift
var apiService: Factory<APIServiceType> {
    self { ProductionAPIService() }
        .onTest { MockAPIService() }
        .onPreview { StubAPIService() }
        .onSimulator { MockAPIService() }
}
```

### Available Contexts

| Modifier | Fires when | DEBUG-only? |
|----------|-----------|-------------|
| `.onTest { }` | Running in XCTest | Yes |
| `.onPreview { }` | SwiftUI Preview | Yes |
| `.onDebug { }` | DEBUG build config | Yes |
| `.onSimulator { }` | iOS Simulator | No |
| `.onDevice { }` | Physical device | No |
| `.onArg("key") { }` | Launch argument present | No |

### Context Priority (highest wins)

1. `.onArg` / `.onArgs`
2. `.onPreview`
3. `.onTest`
4. `.onSimulator` / `.onDevice`
5. `.onDebug`
6. Registered override (`.register { }`)
7. Original factory closure

### Runtime Arguments

```swift
FactoryContext.setArg("premium", forKey: "userTier")
// Later:
FactoryContext.removeArg(forKey: "userTier")
```

---

## SwiftUI Integration

### View Models

```swift
// Pre-iOS 17: ObservableObject
@InjectedObject(\.contentViewModel) var viewModel

// iOS 17+: @Observable
@InjectedObservable(\.contentViewModel) var viewModel
```

When using `@Observable` types with other `@Injected` properties, mark them `@ObservationIgnored`:

```swift
@Observable class MyViewModel {
    @ObservationIgnored
    @Injected(\.networkService) var network
}
```

### @MainActor Factories

SwiftUI view models often need `@MainActor`. Apply it to both the factory property and its closure:

```swift
extension Container {
    @MainActor var contentViewModel: Factory<ContentViewModel> {
        self { ContentViewModel() }
    }
}
```

### SwiftUI Previews

```swift
// Single factory override
#Preview {
    Container.shared.apiService.preview { MockAPIService() }
    ContentView()
}

// Bulk registration
#Preview {
    Container.preview {
        $0.apiService.register { MockAPIService() }
        $0.userService.register { MockUserService() }
    }
    MainView()
}
```

---

## The `.once()` Modifier

Factory definitions are computed properties — they execute every time someone resolves. This means internal `.register` or `.context` calls re-apply on each resolution, potentially overriding external registrations (the "Factory Wins" problem).

`.once()` ensures preceding modifiers apply only on the first instantiation:

```swift
var service: Factory<ServiceType> {
    self { DefaultService() }
        .onTest { MockService() }
        .once()  // .onTest won't override a manual .register() call
}
```

---

## Parameter Factories

When a dependency needs runtime data:

```swift
extension Container {
    var userProfile: ParameterFactory<Int, UserProfile> {
        self { userId in UserProfile(id: userId) }
    }
}

// Resolution
let profile = Container.shared.userProfile(42)
```

### Caching Per Parameter

```swift
var userProfile: ParameterFactory<Int, UserProfile> {
    self { userId in UserProfile(id: userId) }
        .scopeOnParameters  // cache separately for each userId
        .cached
}
```

---

## Decorators

Run code after every resolution (logging, metrics, relationship setup):

```swift
var parentChild: Factory<ParentChildService> {
    self { ParentChildService() }
        .decorator { instance in
            instance.child.parent = instance  // wire back-reference
        }
}
```

---

## Common Anti-Patterns & Fixes

### 1. Circular Dependencies

**Symptom:** Fatal error in DEBUG: `circular dependency chain - A > B > C > A`

**Fix:** Use `@LazyInjected` to break the cycle, or better yet, extract the shared logic into a third type:

```swift
// Before (circular): A needs B, B needs A
// After: extract shared concern into C, both A and B depend on C
```

The circular dependency detector defaults to `dependencyChainTestMax = 10`. You can adjust it, but fixing the design is better.

### 2. Scope Mismatch

**Problem:** A `.unique`-scoped factory depends on a `.cached` factory — you get a stale reference inside a fresh object.

**Fix:** Ensure parent scopes are equal to or broader than child scopes. If `A` is `.unique`, anything it injects should also be `.unique` or resolved lazily.

### 3. Overusing Singletons

**Problem:** Everything is `.singleton`, making testing hard and state unpredictable.

**Fix:** Default to `.unique`. Use `.singleton` only for truly app-lifetime, stateless services (e.g., analytics manager, network client). Use `.cached` with explicit reset for session-scoped state.

### 4. Service Locator Everywhere

**Problem:** Sprinkling `Container.shared.service()` calls throughout business logic.

**Fix:** Use constructor injection via the container. Reserve property wrappers for top-level composition roots (views, view models).

### 5. Ignoring "The Factory Wins"

**Problem:** A test registers a mock, but the factory's internal `.register` call overrides it on next resolution.

**Fix:** Add `.once()` to the factory definition, or move context registrations to `autoRegister()`.

### 6. Missing Reset in Tests

**Problem:** Test pollution — one test's registration leaks into the next.

**Fix:** Always call `Container.shared.reset()` in `setUp()`. Or use `push()`/`pop()` for fine-grained state management. Or use `ContainerTrait` with Swift Testing.

---

## Refactoring Checklist

When reviewing or improving Factory-based code, check for:

- [ ] **Protocols over concrete types** — `Factory<MyServiceType>` not `Factory<MyService>`
- [ ] **Appropriate scopes** — not everything needs `.singleton`; default to `.unique`
- [ ] **Constructor injection in containers** — wire deps through `self.otherFactory()` rather than resolving inside the class
- [ ] **No Container.shared in business logic** — keep resolution at the composition root
- [ ] **Contexts instead of #if DEBUG** — use `.onTest`, `.onPreview` instead of compile-time flags
- [ ] **Custom scopes for domain concepts** — `.scope(.session)` is clearer than `.cached` with manual reset
- [ ] **`.once()` where needed** — if the factory has internal registrations that shouldn't override external ones
- [ ] **Tests reset containers** — `setUp()` calls `.reset()`, or uses `ContainerTrait`
- [ ] **@MainActor on SwiftUI factories** — both property and closure need it
- [ ] **@ObservationIgnored on @Injected in @Observable classes**
- [ ] **FactoryKit import** — `import FactoryKit` instead of `import Factory` (as of 2.5.0)

---

## Debugging

Enable trace logging to see the full resolution tree:

```swift
Container.shared.manager.trace = true

// Custom logger
Container.shared.manager.logger = { message in
    os_log(.debug, "Factory: %{public}@", message)
}
```

Trace output shows depth, factory path, type, and `N:` (new) vs `C:` (cached) prefix with memory addresses.

---

## AutoRegistering

For one-time setup when a container is first accessed:

```swift
extension Container: AutoRegistering {
    func autoRegister() {
        // Cross-module registrations, feature flags, etc.
        #if DEBUG
        apiService.onArg("mockMode") { MockAPIService() }
        #endif
    }
}
```

---

## Reference Files

Consult these for deeper detail:

- **`references/api-reference.md`** — Full API surface: every public type, method, and modifier. Read when you need exact signatures or want to verify an API exists.
- **`references/testing-patterns.md`** — Testing recipes: XCTest reset patterns, Swift Testing `ContainerTrait`, parallel test isolation, mock registration, preview helpers. Read when writing or fixing tests.
- **`references/migration-guide.md`** — Factory 1.x to 2.0 migration: syntax changes, conceptual shifts, and step-by-step conversion. Read when upgrading legacy Factory code.
