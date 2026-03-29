# Factory Migration Guide

## Table of Contents

1. [Factory 1.x to 2.0](#factory-1x-to-20)
2. [Factory 2.4.x to 2.5.x (FactoryKit)](#factory-24x-to-25x-factorykit)

---

## Factory 1.x to 2.0

Factory 2.0 moved from static namespace-based containers to instance-based containers. This is the most significant API change in the library's history.

### Conceptual Shift

| Concept | 1.x | 2.0 |
|---------|-----|-----|
| Container role | Static namespace | Actual object instance |
| Factory storage | Static vars | Computed properties |
| Resolution | Via static reference | Via instance or shared |
| Injection keypath | Static property ref | Instance keypath |
| Container isolation | Not possible | Full support |

### Syntax Changes

#### Factory Definitions

```swift
// 1.x — static stored property with closure
extension Container {
    static var myService = Factory<MyServiceType> { MyService() }
}

// 2.0 — computed property returning Factory
extension Container {
    var myService: Factory<MyServiceType> {
        self { MyService() }
    }
}
```

#### Scoped Factories

```swift
// 1.x
static var myService = Factory<MyServiceType>(scope: .singleton) { MyService() }

// 2.0
var myService: Factory<MyServiceType> {
    self { MyService() }.singleton
}
```

#### Property Wrapper Injection

```swift
// 1.x — reference to static property
@Injected(Container.myService) var service

// 2.0 — keypath to instance property
@Injected(\.myService) var service
```

#### Constructor Injection

```swift
// 1.x
static var viewModel = Factory {
    MyViewModel(service: Container.myService())
}

// 2.0
var viewModel: Factory<MyViewModel> {
    self { MyViewModel(service: self.myService()) }
}
```

#### Registration Overrides

```swift
// 1.x
Container.myService.register { MockService() }

// 2.0
Container.shared.myService.register { MockService() }
```

#### Container Reset

```swift
// 1.x
Container.Registrations.reset()
Container.Scope.reset()

// 2.0
Container.shared.reset()
Container.shared.reset(options: .registration)
Container.shared.reset(options: .scope)
```

### Migration Steps

1. **Change factory definitions** from `static var` to computed `var` properties
2. **Update closures** from `Factory<T> { }` to `self { }`
3. **Update @Injected** from `(Container.prop)` to `(\.prop)`
4. **Update registrations** to use `.shared` — `Container.shared.service.register { }`
5. **Update resets** to use `Container.shared.reset()`
6. **Update constructor injection** to use `self.otherFactory()` inside closures
7. **Search for `Container.` references** — most need `.shared` inserted

### What You Gain

- **Container instances** — pass containers as dependencies, create isolated containers for tests
- **Parallel test support** — `@TaskLocal` on `shared` enables per-task isolation
- **Custom containers** — define `SharedContainer` conforming types per module
- **Push/pop state** — snapshot and restore container state in tests
- **SwiftUI alignment** — computed properties match SwiftUI's declaration style

---

## Factory 2.4.x to 2.5.x (FactoryKit)

### Import Name Change

As of 2.5.0, the recommended import is `FactoryKit` instead of `Factory`:

```swift
// Before
import Factory

// After
import FactoryKit
```

**Why:** The `Factory` module name conflicts with SPM's own internal naming in some configurations, causing XCFramework build issues. `FactoryKit` resolves this.

**Backward compatibility:** `import Factory` still works but may cause issues in certain SPM/XCFramework setups.

### New Features in 2.5.x

#### Preview Helpers (2.5.1)

```swift
// Per-factory preview
Container.shared.service.preview { MockService() }

// Container-level preview
Container.preview {
    $0.service1.register { Mock1() }
    $0.service2.register { Mock2() }
}
```

#### scopeOnParameters (2.5.0)

Cache `ParameterFactory` instances per unique parameter value:

```swift
var userProfile: ParameterFactory<Int, UserProfile> {
    self { UserProfile(id: $0) }
        .scopeOnParameters
        .cached
}

// userId 1 cached separately from userId 2
let profile1 = container.userProfile(1)  // Creates
let profile1b = container.userProfile(1) // Cached
let profile2 = container.userProfile(2)  // Creates (different param)
```

#### FactoryTesting Module (2.5.0)

Separate module for Swift Testing support:

```swift
import FactoryTesting

// ContainerTrait for test isolation
@Suite(.container)
struct MyTests { ... }
```

### Migration Steps (2.4 to 2.5)

1. **Change imports** from `import Factory` to `import FactoryKit`
2. **Add `FactoryTesting`** dependency if using Swift Testing framework
3. **Adopt `ContainerTrait`** for parallel test isolation (optional but recommended)
4. **Adopt preview helpers** for cleaner SwiftUI preview code (optional)
