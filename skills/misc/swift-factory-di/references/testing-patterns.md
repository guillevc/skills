# Factory Testing Patterns (v2.5.3)

## Table of Contents

1. [XCTest Basics](#xctest-basics)
2. [Mock Registration](#mock-registration)
3. [Container Reset](#container-reset)
4. [Push/Pop State](#pushpop-state)
5. [Swift Testing with ContainerTrait](#swift-testing-with-containertrait)
6. [XCTest Parallel Isolation](#xctest-parallel-isolation)
7. [Testing Injected Properties](#testing-injected-properties)
8. [Context-Based Mocking](#context-based-mocking)
9. [SwiftUI Preview Helpers](#swiftui-preview-helpers)
10. [Debugging Tests](#debugging-tests)
11. [Common Testing Mistakes](#common-testing-mistakes)

---

## XCTest Basics

The fundamental pattern: reset the container in `setUp()`, register mocks before exercising code.

```swift
final class MyViewModelTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Container.shared.reset()  // Clean slate for every test
    }

    func testFetchUsers() {
        // Arrange: register mock
        Container.shared.networkService.register { MockNetworkService() }

        // Act: create SUT (it will resolve the mock)
        let viewModel = Container.shared.myViewModel()

        // Assert
        XCTAssertEqual(viewModel.users.count, 3)
    }
}
```

---

## Mock Registration

### Single Factory Override

```swift
Container.shared.myService.register { MockService() }
```

### Reset a Single Factory

```swift
Container.shared.myService.reset()            // Registration + cache
Container.shared.myService.reset(.registration) // Just the override
Container.shared.myService.reset(.scope)       // Just the cached instance
```

### Parameterized Mocks

```swift
Container.shared.userService.register { userId in
    MockUser(id: userId, name: "Test User \(userId)")
}
```

---

## Container Reset

### Reset Options

```swift
Container.shared.reset()                        // Everything
Container.shared.reset(options: .all)            // Same as above
Container.shared.reset(options: .registration)   // Only overrides
Container.shared.reset(options: .scope)          // Only cached instances
Container.shared.reset(options: .context)        // Only context overrides
```

### Reset a Specific Scope

```swift
Scope.cached.reset()                              // All cached instances globally
Scope.singleton.reset()                           // All singletons globally
Container.shared.manager.reset(scope: .session)   // Custom scope
```

### Verify Clean State

```swift
XCTAssertTrue(Container.shared.manager.isEmpty(.all))
```

---

## Push/Pop State

For tests that need temporary overrides within a test, then restore:

```swift
func testMultipleScenarios() {
    // Save current state
    Container.shared.manager.push()

    // Override for this scenario
    Container.shared.myService.register { MockServiceA() }
    let result1 = Container.shared.myViewModel().text()
    XCTAssertEqual(result1, "A")

    // Restore and push again
    Container.shared.manager.pop()
    Container.shared.manager.push()

    Container.shared.myService.register { MockServiceB() }
    let result2 = Container.shared.myViewModel().text()
    XCTAssertEqual(result2, "B")

    // Final restore
    Container.shared.manager.pop()
}
```

Push/pop is stackable — you can nest multiple levels.

---

## Swift Testing with ContainerTrait

The recommended approach for Swift Testing framework. Provides automatic per-test container isolation via `@TaskLocal`.

### Setup

```swift
import FactoryTesting
import Testing

extension Trait where Self == ContainerTrait<Container> {
    static var container: Self {
        ContainerTrait(shared: Container.$shared, container: Container())
    }
}
```

### Usage — Suite-Level

```swift
@Suite(.container)
struct UserServiceTests {
    @Test func fetchUsers() {
        Container.shared.networkService.register { MockNetworkService() }
        let service = Container.shared.userService()
        #expect(service.users.count == 3)
    }

    @Test func fetchEmpty() {
        Container.shared.networkService.register { EmptyMockNetwork() }
        let service = Container.shared.userService()
        #expect(service.users.isEmpty)
    }
}
```

Each test gets its own container — no leakage between tests, safe for parallel execution.

### Usage — Per-Test with Setup

```swift
@Test(.container {
    $0.networkService.register { MockNetworkService() }
    $0.authService.register { MockAuthService() }
})
func testAuthenticatedFetch() {
    let viewModel = Container.shared.myViewModel()
    #expect(viewModel.isAuthenticated)
}
```

### Custom Container Trait

```swift
extension Trait where Self == ContainerTrait<AuthContainer> {
    static var authContainer: Self {
        ContainerTrait(shared: AuthContainer.$shared, container: AuthContainer())
    }
}

@Suite(.authContainer)
struct AuthTests { ... }
```

---

## XCTest Parallel Isolation

For XCTest (not Swift Testing), use `Container.$shared.withValue` for task-local isolation:

```swift
func testParallelA() {
    let container = Container()
    Container.$shared.withValue(container) {
        Container.shared.service.register { MockA() }
        let sut = MyViewModel()
        XCTAssertEqual(sut.service.value, "A")
    }
}

func testParallelB() {
    let container = Container()
    Container.$shared.withValue(container) {
        Container.shared.service.register { MockB() }
        let sut = MyViewModel()
        XCTAssertEqual(sut.service.value, "B")
    }
}
```

---

## Testing Injected Properties

### @Injected

Resolved at init — register mocks *before* creating the object:

```swift
Container.shared.networkService.register { MockNetworkService() }
let viewModel = MyViewModel()  // @Injected resolves here
```

### @LazyInjected

Resolved on first access — you can register mocks after creating the object but before accessing the property:

```swift
let viewModel = MyViewModel()
Container.shared.networkService.register { MockNetworkService() }
let _ = viewModel.service  // Resolved now with mock
```

Check resolution state:
```swift
XCTAssertNil(viewModel.$service.resolvedOrNil())
let _ = viewModel.service
XCTAssertNotNil(viewModel.$service.resolvedOrNil())
```

### @WeakLazyInjected

Returns `nil` if no strong reference exists elsewhere:

```swift
var holder: MyService? = Container.shared.myService()
let viewModel = MyViewModel()  // @WeakLazyInjected
XCTAssertNotNil(viewModel.service)  // Shared instance exists

holder = nil  // Release the strong reference
XCTAssertNil(viewModel.service)     // Weak reference is gone
```

---

## Context-Based Mocking

### Automatic Test Context

Factory auto-detects XCTest — `.onTest` registrations activate automatically:

```swift
extension Container {
    var apiService: Factory<APIServiceType> {
        self { ProductionAPIService() }
            .onTest { MockAPIService() }  // Auto-used in tests
    }
}
```

### Launch Arguments for UI Tests

```swift
// In UI test:
let app = XCUIApplication()
app.launchArguments.append("mockNetwork")
app.launch()

// In app's container:
extension Container {
    var networkService: Factory<NetworkServiceType> {
        self { RealNetworkService() }
            .onArg("mockNetwork") { MockNetworkService() }
    }
}
```

### Runtime Context Switching

```swift
func testPremiumFeature() {
    FactoryContext.setArg("premium", forKey: "userTier")
    defer { FactoryContext.removeArg(forKey: "userTier") }

    let viewModel = Container.shared.featureViewModel()
    XCTAssertTrue(viewModel.isPremium)
}
```

---

## SwiftUI Preview Helpers

### Single Factory Preview

```swift
#Preview {
    Container.shared.apiService.preview { MockAPIService() }
    ContentView()
}
```

### Bulk Container Preview

```swift
#Preview {
    Container.preview {
        $0.apiService.register { MockAPIService() }
        $0.userService.register { MockUserService() }
        $0.analyticsService.register { NoOpAnalytics() }
    }
    MainView()
}
```

### Custom Container Preview

```swift
#Preview {
    AuthContainer.preview {
        $0.authService.register { MockAuthService(loggedIn: true) }
    }
    ProfileView()
}
```

---

## Debugging Tests

### Trace Resolution

```swift
override func setUp() {
    super.setUp()
    Container.shared.reset()
    Container.shared.manager.trace = true  // See what resolves
}
```

Output shows the resolution tree:
```
0: Container.networkService = N:URLSessionNetworkService 0x600001234560
1:  Container.authService = C:MockAuthService 0x600001234570
```

`N:` = new instance, `C:` = cached instance.

### Custom Test Logger

```swift
Container.shared.manager.logger = { message in
    print("[TEST-FACTORY] \(message)")
}
```

---

## Common Testing Mistakes

### 1. Forgetting to Reset

```swift
// BAD: previous test's mock leaks
func testA() { Container.shared.service.register { MockA() } }
func testB() { /* Still using MockA! */ }

// GOOD: reset in setUp
override func setUp() {
    super.setUp()
    Container.shared.reset()
}
```

### 2. Registering After @Injected Init

```swift
// BAD: @Injected resolves at init, mock comes too late
let viewModel = MyViewModel()
Container.shared.service.register { MockService() }

// GOOD: register before creating the object
Container.shared.service.register { MockService() }
let viewModel = MyViewModel()
```

### 3. Not Using .once() with Context Overrides

```swift
// If the factory has .onTest internally, your manual .register may be overridden
// Add .once() to the factory definition to fix this
var service: Factory<ServiceType> {
    self { RealService() }
        .onTest { TestService() }
        .once()  // Allows manual .register to take precedence
}
```

### 4. Testing Singletons Without Reset

```swift
// BAD: singleton persists across tests
func testA() {
    let s1 = Container.shared.singletonService()
    s1.value = 42
}
func testB() {
    let s2 = Container.shared.singletonService()
    // s2.value is still 42!
}

// GOOD: reset clears singletons too
override func setUp() {
    super.setUp()
    Container.shared.reset()  // Clears all scope caches including singletons
}
```

### 5. Mixing XCTest and Async Without Isolation

```swift
// BAD: async tests may interleave without isolation
func testAsync() async {
    Container.shared.service.register { MockService() }
    // Another test could override this before you use it
}

// GOOD: use ContainerTrait or $shared.withValue for isolation
```
