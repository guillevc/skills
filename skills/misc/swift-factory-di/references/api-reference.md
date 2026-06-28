# Factory API Reference (v2.5.3)

## Table of Contents

1. [Factory\<T\>](#factoryt)
2. [ParameterFactory\<P,T\>](#parameterfactorypt)
3. [Containers](#containers)
4. [ContainerManager](#containermanager)
5. [Scopes](#scopes)
6. [Property Wrappers](#property-wrappers)
7. [Modifiers (FactoryModifying)](#modifiers)
8. [Contexts](#contexts)
9. [Reset Options](#reset-options)
10. [Resolving Protocol](#resolving-protocol)
11. [AutoRegistering](#autoregistering)
12. [ContainerTrait (Swift Testing)](#containertrait)
13. [Type Aliases](#type-aliases)

---

## Factory\<T\>

The core type for managing dependency creation and resolution.

```swift
public struct Factory<T>: FactoryModifying {
    /// Create a factory with a container and closure
    public init(_ container: ManagedContainer, key: StaticString = #function,
                _ factory: @escaping VoidFactoryType<T>)

    /// Resolve the dependency (callAsFunction)
    public func callAsFunction() -> T

    /// Resolve the dependency (explicit)
    public func resolve() -> T

    /// Override the factory closure
    @discardableResult
    public func register(factory: @escaping VoidFactoryType<T>) -> Self

    /// Reset this factory's registration and/or scope cache
    @discardableResult
    public func reset(_ options: FactoryResetOptions = .all) -> Self
}
```

**Shorthand syntax** via `ManagedContainer`:
```swift
// These are equivalent:
var service: Factory<MyType> { Factory(self) { MyType() } }
var service: Factory<MyType> { self { MyType() } }
```

---

## ParameterFactory\<P,T\>

Factory that accepts runtime parameters at resolution time.

```swift
public struct ParameterFactory<P, T>: FactoryModifying {
    public init(_ container: ManagedContainer, key: StaticString = #function,
                _ factory: @escaping ParameterFactoryType<P, T>)

    public func callAsFunction(_ parameters: P) -> T
    public func resolve(_ parameters: P) -> T

    @discardableResult
    public func register(factory: @escaping ParameterFactoryType<P, T>) -> Self

    @discardableResult
    public func reset(_ options: FactoryResetOptions = .all) -> Self
}
```

**Extra modifier:**
- `.scopeOnParameters` — caches a separate instance per unique parameter value (parameter must be `Hashable`).

---

## Containers

### ManagedContainer (Protocol)

Base protocol for all containers.

```swift
public protocol ManagedContainer: AnyObject, Sendable {
    var manager: ContainerManager { get }
}
```

Provides the `callAsFunction` sugar for defining factories:
```swift
func callAsFunction<T>(key: StaticString = #function,
                       _ factory: @escaping VoidFactoryType<T>) -> Factory<T>
func callAsFunction<P,T>(key: StaticString = #function,
                         _ factory: @escaping ParameterFactoryType<P,T>) -> ParameterFactory<P,T>
```

### SharedContainer (Protocol)

Container with a static shared instance.

```swift
public protocol SharedContainer: ManagedContainer {
    static var shared: Self { get }
}
```

Extension methods:
```swift
// Reset the shared container
static func reset(options: FactoryResetOptions = .all)

// Promised factory (initially nil, fatal in DEBUG if unregistered)
func promised<T>(key: StaticString = #function) -> Factory<T?>

// Preview helper — register overrides for SwiftUI previews
static func preview(_ transform: (Self) -> Void)
```

### Container (Default)

The built-in default container with `@TaskLocal` isolation for parallel test support.

```swift
public final class Container: SharedContainer {
    @TaskLocal public static var shared = Container()
    public let manager: ContainerManager = ContainerManager()
    public init() {}
}
```

---

## ContainerManager

Manages registrations, scope caches, and debugging for a container.

```swift
public final class ContainerManager {
    /// Default scope applied to all factories in this container (nil = .unique)
    public var defaultScope: Scope?

    /// Max depth before circular dependency detection fires (0 = disabled)
    public var dependencyChainTestMax: Int  // default: 10

    /// Whether promised() types trigger fatalError in DEBUG when unregistered
    public var promiseTriggersError: Bool  // default: true

    /// Enable resolution trace logging
    public var trace: Bool

    /// Custom log output function
    public var logger: (String) -> Void

    /// Reset registrations, caches, or both
    public func reset(options: FactoryResetOptions = .all)

    /// Reset a specific scope's cache
    public func reset(scope: Scope)

    /// Check if registrations/caches are empty
    public func isEmpty(_ options: FactoryResetOptions) -> Bool

    /// Save current state (for test isolation)
    public func push()

    /// Restore previously saved state
    public func pop()
}
```

---

## Scopes

Control instance lifetime. All scope types are subclasses of `Scope`.

```swift
public class Scope {
    /// New instance every resolution (default)
    public static let unique = Unique()

    /// Cached until explicitly reset
    public static let cached = Cached()

    /// Cached for app lifetime (per container, per TaskLocal)
    public static let singleton = Singleton()

    /// Shared while any strong reference exists (weak cache)
    public static let shared = Shared()

    /// Cached within a single resolution cycle
    public static let graph = Graph()

    /// Reset all instances in this scope
    public func reset()
}
```

### Custom Scopes

```swift
extension Scope {
    static let session = Cached()   // Behaves like .cached but independently resettable
    static let request = Graph()    // Behaves like .graph
}
```

---

## Property Wrappers

### @Injected

Resolves immediately at initialization.

```swift
@propertyWrapper public struct Injected<T> {
    public init(_ keyPath: KeyPath<Container, Factory<T>>)
    public init<C: SharedContainer>(_ keyPath: KeyPath<C, Factory<T>>)
    public var wrappedValue: T { get }
}
```

### @LazyInjected

Defers resolution until first access.

```swift
@propertyWrapper public struct LazyInjected<T> {
    public init(_ keyPath: KeyPath<Container, Factory<T>>)
    public init<C: SharedContainer>(_ keyPath: KeyPath<C, Factory<T>>)
    public var wrappedValue: T { get mutating set }
    public var projectedValue: Self { get }

    // Projected value methods:
    public func resolvedOrNil() -> T?
    public mutating func resolve()
    public var factory: Factory<T> { get }
}
```

### @WeakLazyInjected

Weak reference, lazy resolution. Instance may be released and re-resolved.

```swift
@propertyWrapper public struct WeakLazyInjected<T> {
    public init(_ keyPath: KeyPath<Container, Factory<T>>)
    public var wrappedValue: T? { get }
}
```

### @DynamicInjected

Re-resolves on every access.

```swift
@propertyWrapper public struct DynamicInjected<T> {
    public init(_ keyPath: KeyPath<Container, Factory<T>>)
    public var wrappedValue: T { get }
}
```

### @InjectedObject

SwiftUI `ObservableObject` injection (wraps `@StateObject` internally).

```swift
@propertyWrapper public struct InjectedObject<T: ObservableObject>: DynamicProperty {
    public init(_ keyPath: KeyPath<Container, Factory<T>>)
    public init<C: SharedContainer>(_ keyPath: KeyPath<C, Factory<T>>)
    public var wrappedValue: T { get }
    public var projectedValue: ObservedObject<T>.Wrapper { get }
}
```

### @InjectedObservable

Swift Observation framework injection (iOS 17+, wraps `@State` internally).

```swift
@propertyWrapper public struct InjectedObservable<T: Observable & AnyObject>: DynamicProperty {
    public init(_ keyPath: KeyPath<Container, Factory<T>>)
    public var wrappedValue: T { get }
}
```

### @InjectedType

Optional type-based injection.

```swift
@propertyWrapper public struct InjectedType<T> {
    public init()
    public var wrappedValue: T? { get }
}
```

---

## Modifiers

All modifiers are available on `Factory<T>` and `ParameterFactory<P,T>` via the `FactoryModifying` protocol. They return `Self` for chaining.

### Scope Modifiers

```swift
.unique          // Scope.unique
.cached          // Scope.cached
.singleton       // Scope.singleton
.shared          // Scope.shared
.graph           // Scope.graph
.scope(_ scope: Scope)  // Custom scope
```

### Lifecycle Modifiers

```swift
.timeToLive(_ seconds: TimeInterval)  // Auto-expire cached instances
.once()           // Preceding modifiers apply only on first instantiation
```

### Context Modifiers

```swift
.context(_ types: FactoryContextType..., factory:)
.onPreview(factory:)    // SwiftUI Preview
.onTest(factory:)       // XCTest
.onDebug(factory:)      // DEBUG builds
.onSimulator(factory:)  // iOS Simulator
.onDevice(factory:)     // Physical device
.onArg(_ arg: String, factory:)      // Launch argument
.onArgs(_ args: [String], factory:)  // Multiple launch arguments
```

### Registration Modifiers

```swift
.register(factory:)   // Override the factory closure
.reset(_ options:)     // Reset registration and/or cache
```

### Decorator

```swift
.decorator(_ decorator: @escaping (T) -> Void)  // Post-resolution hook
```

### Preview Helper

```swift
.preview(factory:)   // Convenience for SwiftUI #Preview blocks
```

### ParameterFactory-Only

```swift
.scopeOnParameters   // Cache per unique parameter value
```

---

## Contexts

```swift
public enum FactoryContextType: Equatable {
    case arg(String)        // Launch argument present
    case args([String])     // All listed arguments present
    case preview            // SwiftUI Preview mode
    case test               // XCTest environment
    case debug              // DEBUG configuration
    case simulator          // iOS Simulator
    case device             // Physical device
}
```

### FactoryContext

Runtime context inspection and manipulation:

```swift
public struct FactoryContext {
    public static var current: FactoryContext

    public var isPreview: Bool    // read-only
    public var isTest: Bool       // read-only
    public var isDebug: Bool      // read-only
    public var isSimulator: Bool  // read-only
    public var isDevice: Bool     // read-only

    public static func setArg(_ value: String, forKey key: String)
    public static func removeArg(forKey key: String)
}
```

---

## Reset Options

```swift
public enum FactoryResetOptions {
    case all           // Registrations + scope caches + contexts
    case registration  // Only registered overrides
    case scope         // Only scope caches
    case context       // Only context overrides
    case none          // No-op
}
```

---

## Resolving Protocol

Type-based (rather than keypath-based) registration and resolution:

```swift
public protocol Resolving: ManagedContainer {
    @discardableResult
    func register<T>(_ type: T.Type, factory: @escaping @Sendable () -> T) -> Factory<T>

    func factory<T>(_ type: T.Type) -> Factory<T>?

    func resolve<T>(_ type: T.Type) -> T?
}
```

Usage:
```swift
extension Container: Resolving {}

Container.shared.register(NetworkService.self) { URLSessionService() }
let service: NetworkService? = Container.shared.resolve(NetworkService.self)
```

---

## AutoRegistering

One-time container setup hook, called before the first resolution:

```swift
public protocol AutoRegistering {
    func autoRegister()
}

extension Container: AutoRegistering {
    public func autoRegister() {
        // Register cross-module dependencies, feature flags, etc.
    }
}
```

---

## ContainerTrait

Swift Testing support for parallel test isolation (in `FactoryTesting` module):

```swift
import FactoryTesting

public struct ContainerTrait<C: SharedContainer>: TestTrait, SuiteTrait, TestScoping {
    public init(shared: TaskLocal<C>,
                container: @autoclosure @escaping @Sendable () -> C)

    /// Apply a transform to the container before the test runs
    public func callAsFunction(transform: @escaping (C) async -> Void) -> Self
}
```

Usage:
```swift
extension Trait where Self == ContainerTrait<Container> {
    static var container: Self {
        ContainerTrait(shared: Container.$shared, container: Container())
    }
}

@Suite(.container)
struct MyTests {
    @Test func example() {
        Container.shared.service.register { MockService() }
        // Isolated — won't affect other tests
    }

    @Test(.container { $0.service.register { SpecialMock() } })
    func withSetup() { ... }
}
```

---

## Type Aliases

```swift
public typealias VoidFactoryType<T> = @Sendable () -> T
public typealias ParameterFactoryType<P, T> = @Sendable (P) -> T
```

---

## Platform Requirements

- Swift 5.9+
- iOS 13+ / macOS 10.15+ / tvOS 13+ / watchOS 8+ / visionOS 1+
- Full Swift 6 strict concurrency support
