# GoF Design Patterns Catalog

All 23 Gang of Four patterns with problem descriptions, when to use, how they map to code
smells, and how they relate to each other. Read the relevant section when a pattern might
apply to a refactoring.

## Table of Contents

1. [Creational Patterns](#creational-patterns) (5)
2. [Structural Patterns](#structural-patterns) (7)
3. [Behavioral Patterns](#behavioral-patterns) (11)
4. [Pattern Relationships](#pattern-relationships)
5. [Pattern-Smell Quick Reference](#patternsmell-quick-reference)

---

## Creational Patterns

Deal with object creation mechanisms.

### Factory Method

**Also known as:** Virtual Constructor

**Intent:** Define an interface for creating objects, but let subclasses decide which class to instantiate.

**Problem it solves:** Code that uses `new ConcreteClass()` everywhere becomes impossible to
extend — adding a new type means finding and changing every creation point. Your logistics app
handles Trucks, but when Ships are added, the code is so coupled to Truck that adding new
transport types requires changes throughout.

**When to use:**
- You don't know the exact types of objects your code needs to create
- You want to let users extend the types your framework creates
- You want to reuse existing objects instead of rebuilding them (object pooling)

**Smell connection:** Replaces switch statements that create different objects based on a type code.

**Relations:** Many designs start with Factory Method and evolve toward Abstract Factory,
Prototype, or Builder. **Factory Method is a specialization of Template Method** — a factory
method may serve as a step in a large template method. Prototype isn't based on inheritance
(no inheritance drawbacks), but requires complicated initialization of cloned objects; Factory
Method is based on inheritance but needs no initialization step.

---

### Abstract Factory

**Intent:** Produce families of related objects without specifying their concrete classes.

**Problem it solves:** When you have multiple related objects (e.g., Button + Checkbox + Dialog)
that must be consistent with each other, and you need to support multiple families (e.g., Windows
vs macOS).

**When to use:**
- Code must work with various families of related products
- Products within a family must be used together consistently
- You want to add new families without changing existing code

**Smell connection:** Addresses Parallel Inheritance Hierarchies when the hierarchies represent
product families.

**Relations:** Abstract Factory classes are often based on a set of Factory Methods. Can serve as
an alternative to Facade when you only want to hide how subsystem objects are created. Abstract
Factories, Builders, and Prototypes can all be implemented as Singletons.

---

### Builder

**Intent:** Construct complex objects step by step, separating construction from representation.

**Problem it solves:** Telescoping constructors with many optional parameters. A constructor
like `new House(walls, doors, windows, garage, pool, garden, statues)` is unreadable. Or an
explosion of subclasses for every possible configuration.

**When to use:**
- Objects require extensive, multi-step configuration
- You need different representations of the same construction process
- Building composite/recursive structures (e.g., building a tree of UI components)

**Smell connection:** Addresses Long Parameter List and Primitive Obsession in constructors.

**Relations:** Many designs start with Factory Method and evolve toward Builder (more flexible,
more complicated). Builder focuses on step-by-step construction; Abstract Factory specializes
in creating families of related objects (returns product immediately). **Builder can be used
when creating complex Composite trees** (construction steps work recursively). Builder can
combine with Bridge: the director plays the role of the abstraction, builders act as implementations.

---

### Prototype

**Intent:** Copy existing objects without depending on their classes.

**Problem it solves:** When cloning an object is non-trivial because it has private fields or
complex internal state, and you don't want to couple your code to its concrete class.

**When to use:**
- Your code shouldn't depend on the concrete classes of objects it needs to copy
- You want to reduce the number of subclasses that differ only in initialization

**Smell connection:** Rarely a direct smell fix; more of an optimization for object creation.

**Relations:** Prototype isn't based on inheritance (avoids its drawbacks), but requires
complicated initialization. Factory Method is based on inheritance but has no initialization
step. Prototype can help save copies of Commands into history. Heavy use of Composite and
Decorator can benefit from Prototype (clone complex structures instead of rebuilding).

---

### Singleton

**Intent:** Ensure a class has only one instance with a global access point.

**Problem it solves:** Controlled access to a shared resource (database connection, file system,
configuration).

**When to use:**
- Exactly one instance of a class must exist
- That instance must be accessible from a well-known point

**Caution:** Singleton is itself a smell when overused. It creates global state, hides
dependencies, makes testing harder, and violates SRP (it manages both its own logic and its
lifecycle). Use sparingly — dependency injection is usually better.

**Relations:** Facade can often be transformed into a Singleton. Abstract Factories, Builders,
and Prototypes can all be implemented as Singletons.

---

## Structural Patterns

How to assemble objects into larger structures.

### Adapter

**Also known as:** Wrapper

**Intent:** Allow objects with incompatible interfaces to collaborate.

**Problem it solves:** Your stock market app downloads data in XML, but a smart analytics
library only works with JSON. You can't change the library. Changing your code to output JSON
would be fragile.

**Two implementations:** Object adapter (composition — works in all languages) and Class adapter
(multiple inheritance — only C++ and similar).

**When to use:**
- You need to use an existing class whose interface doesn't match what you need
- You want to create a reusable class that cooperates with unrelated/unforeseen classes

**Smell connection:** Directly addresses Alternative Classes with Different Interfaces.
Also useful for Incomplete Library Class.

**Relations:** Bridge is designed up-front; Adapter is used with existing apps to make
incompatible classes work together. Adapter provides a completely different interface;
Decorator keeps/extends the same interface and supports recursive composition. Facade defines
a new interface for a subsystem; Adapter makes an existing interface usable. **Adapter wraps
one object; Facade works with an entire subsystem.** Bridge, State, Strategy, and Adapter have
very similar structures — all based on composition/delegation, but solve different problems.

---

### Bridge

**Intent:** Split a large class into two separate hierarchies — abstraction and implementation —
that can vary independently.

**Problem it solves:** A class hierarchy that grows exponentially because it tries to combine
multiple independent dimensions (e.g., Shape x Color, Platform x Feature).

**When to use:**
- A monolithic class has several orthogonal dimensions of variation
- You need to switch implementations at runtime
- You want to extend a class in multiple independent dimensions

**Smell connection:** Addresses Parallel Inheritance Hierarchies and can help with Large Class.

**Relations:** Bridge is designed up-front (develop independently); Adapter makes existing
incompatible things work together. Bridge, State, Strategy, and Adapter have similar structures
but different intents. Builder can combine with Bridge: director = abstraction, builders =
implementations.

---

### Composite

**Also known as:** Object Tree

**Intent:** Compose objects into tree structures and treat individual objects and compositions
uniformly.

**Problem it solves:** When your model naturally forms a tree (products in boxes in bigger boxes)
and you need to determine the total price, but you'd need to know all classes, nesting levels,
and details beforehand.

**When to use:**
- The core model is a tree structure
- Clients should treat simple and complex elements uniformly

**Smell connection:** Not a direct smell fix, but can simplify code that has complex conditionals
distinguishing between "container" and "leaf" objects.

**Relations:** Builder can create complex Composite trees. Chain of Responsibility is often used
with Composite — a leaf can pass requests through parents to root. Iterators can traverse
Composite trees. Visitor can execute operations over an entire Composite tree. **Composite and
Decorator have similar structure diagrams** — both rely on recursive composition. A Decorator is
like a Composite but with only one child. Decorator adds responsibilities; Composite "sums up"
children's results. They can cooperate: use Decorator to extend behavior of a specific object
in a Composite tree. Shared leaf nodes can be implemented as Flyweights.

---

### Decorator

**Also known as:** Wrapper

**Intent:** Attach new behaviors to objects by wrapping them, without modifying their class.

**Problem it solves:** Subclass explosion when combining optional behaviors. If you have 4
optional behaviors, inheritance requires 16 subclasses; Decorator requires 4 wrappers. A
notification library that starts with email-only and needs SMS, Facebook, Slack — and combinations.

**Key insight:** Inheritance is static (can't alter behavior at runtime) and single-parent.
Composition/aggregation allows substituting the linked helper object, changing behavior at runtime.

**When to use:**
- You need to add behaviors at runtime
- Inheritance is impractical (final classes, too many combinations)
- You want to combine behaviors by stacking wrappers

**Smell connection:** Addresses Large Class when the class is large because it holds many
optional behaviors. Also addresses Incomplete Library Class (wrap and extend).

**Relations:** Adapter provides a different interface; Decorator keeps/extends the same
interface and supports recursive composition. Chain of Responsibility and Decorator have
very similar class structures (recursive composition), but CoR handlers execute arbitrary
operations independently, while Decorators can't break the flow. **Decorator changes the skin;
Strategy changes the guts.** Decorator and Proxy have similar structures but different intents
(Proxy manages lifecycle; Decorator composition is client-controlled).

---

### Facade

**Intent:** Provide a simplified interface to a complex subsystem.

**Problem it solves:** Your code must work with a broad set of objects from a sophisticated
library/framework. You'd need to initialize all objects, track dependencies, and execute methods
in correct order. Business logic becomes tightly coupled to 3rd-party implementation details.

**Real-world analogy:** When you call a shop to place a phone order, the operator is your
facade to all services and departments.

**When to use:**
- You need a limited, simple interface to a complex subsystem
- You want to layer your subsystem with defined entry points

**Smell connection:** Can simplify Message Chains and address Inappropriate Intimacy
(clients no longer need to know subsystem internals).

**Relations:** **Facade and Mediator have similar jobs** — both organize collaboration between
tightly coupled classes. Facade defines a simplified interface without new functionality
(subsystem is unaware of it; objects communicate directly). Mediator centralizes communication;
components only know the mediator, not each other. Abstract Factory can serve as an alternative
to Facade when you only want to hide how subsystem objects are created. Facade is similar to
Proxy (both buffer complex entities), but Proxy has the same interface as its service object.
Facade can often be transformed into a Singleton.

---

### Flyweight

**Intent:** Share common state between many objects to reduce memory usage.

**Problem it solves:** Creating millions of similar objects consumes too much RAM.

**When to use:**
- Your application creates a huge number of similar objects
- Objects contain duplicated state that can be shared
- Object identity isn't important (they're interchangeable)

**Smell connection:** Not a direct smell fix; it's a performance optimization pattern.

**Relations:** Flyweight shows how to make lots of little objects; Facade shows how to make a
single object representing an entire subsystem. Shared Composite leaf nodes can be implemented
as Flyweights.

---

### Proxy

**Intent:** Provide a substitute for another object to control access.

**Problem it solves:** You need lazy initialization, access control, logging, caching, or
remote access without modifying the real object.

**When to use:**
- Lazy initialization (virtual proxy)
- Access control (protection proxy)
- Local caching of remote service results (caching proxy)
- Logging, monitoring (logging proxy)

**Smell connection:** Not typically a smell fix, but can address Inappropriate Intimacy
by controlling how classes interact.

**Relations:** With Adapter: different interface. With Decorator: enhanced interface. With Proxy:
same interface. Facade is similar to Proxy (both buffer complex entities). Decorator and Proxy
have similar structures but different intents.

---

## Behavioral Patterns

How objects communicate and divide responsibilities.

### Chain of Responsibility

**Intent:** Pass requests along a chain of handlers, each deciding whether to process or forward.

**Problem it solves:** Hardcoded sequential checks — a Long Method full of if/else chains
where each block checks a condition and takes an action.

**When to use:**
- Multiple handlers may process a request, and the handler isn't known in advance
- The processing order should be configurable
- The set of handlers changes dynamically

**Smell connection:** Can address Long Method when it's a chain of condition-action blocks.

**Relations:** Chain of Responsibility, Command, Mediator, and Observer address various ways
of connecting senders and receivers: CoR passes sequentially until handled; Command establishes
unidirectional connections; Mediator eliminates direct connections; Observer lets receivers
dynamically subscribe/unsubscribe. CoR handlers can be implemented as Commands. Often used
with Composite (leaf passes request up through parents). Chain of Responsibility and Decorator
have similar structures (recursive composition), but CoR handlers can stop the chain.

---

### Command

**Also known as:** Action, Transaction

**Intent:** Encapsulate a request as an object, allowing parameterization, queuing, logging, and undo.

**Problem it solves:** Tight coupling between the invoker of an operation and the object that
performs it. A text editor needs copy/paste invocable from toolbar, context menu, and Ctrl+C.

**When to use:**
- You need to parameterize objects with operations
- You need to queue, schedule, or log operations
- You need undo/redo support

**Smell connection:** Can decouple classes with Inappropriate Intimacy when one class directly
invokes complex operations on another.

**Relations:** **Command and Memento work together for undo** — commands perform operations,
mementos save state before execution. **Command vs Strategy** — both parameterize with an
action, but Command converts any operation into an object (defer, queue, history, remote);
Strategy describes different ways of doing the same thing. CoR handlers can be implemented as
Commands. Prototype can help save copies of Commands into history. Visitor can be seen as a
powerful version of Command.

---

### Iterator

**Intent:** Traverse a collection without exposing its internal structure.

**Problem it solves:** Different collections (arrays, trees, graphs) need different traversal
code. Clients shouldn't care about the collection type.

**When to use:**
- You need to traverse complex data structures uniformly
- You need to support multiple traversal algorithms
- You want to hide collection implementation details

**Smell connection:** Addresses Message Chains when traversing complex data structures.

**Relations:** Can traverse Composite trees. Factory Method can be used with Iterator to let
collection subclasses return different types of iterators. Memento can be used alongside
Iterator to capture current traversal state and roll back if necessary.

---

### Mediator

**Also known as:** Intermediary, Controller

**Intent:** Reduce chaotic dependencies by forcing objects to communicate through a central coordinator.

**Problem it solves:** A web of direct dependencies between components makes them impossible to
reuse or modify independently. A dialog with form controls that all interact with each other.

**Real-world analogy:** Air traffic control tower — pilots don't talk to each other directly
about landing priorities; all communication goes through the tower.

**When to use:**
- Many components are tightly coupled
- Components need to communicate but shouldn't know about each other
- You want to reuse components in different contexts

**Smell connection:** Directly addresses Inappropriate Intimacy and can simplify Feature Envy
when multiple classes are envying each other.

**Relations:** **Facade and Mediator have similar jobs.** Facade simplifies a subsystem interface
(subsystem unaware). Mediator centralizes communication (components know the mediator, not each
other). **Mediator vs Observer is often elusive.** A popular Mediator implementation uses Observer
(mediator as publisher, components as subscribers). You can also implement Mediator without
Observer (permanently link all components to the same mediator). Chain of Responsibility,
Command, Mediator, and Observer address various ways of connecting senders and receivers.

---

### Memento

**Intent:** Capture and restore an object's state without violating encapsulation.

**Problem it solves:** Implementing undo/snapshot when the object's fields are private.

**When to use:**
- You need to create snapshots for undo/restore
- Direct access to internal state would violate encapsulation

**Smell connection:** Not a typical smell fix; more of a feature pattern.

**Relations:** Command and Memento work together for undo. Can be used alongside Iterator
to capture traversal state.

---

### Observer

**Also known as:** Event-Subscriber, Listener

**Intent:** Define a subscription mechanism for event notification.

**Problem it solves:** Objects need to react to changes in another object, but you don't want
tight coupling or constant polling. A Customer wants to know when a Store has a product —
visiting daily is wasteful; sending emails to all customers is spam.

**When to use:**
- Changes to one object should notify others, and you don't know which others in advance
- Objects should observe temporarily or conditionally

**Smell connection:** Can decouple classes with Inappropriate Intimacy or Feature Envy
when one class watches another's state.

**Relations:** Chain of Responsibility, Command, Mediator, and Observer address various ways of
connecting senders and receivers. **Mediator vs Observer:** Mediator eliminates mutual
dependencies (components depend on single mediator). Observer establishes dynamic one-way
connections. When all components become publishers with dynamic connections, there's no
centralized mediator — just a distributed set of observers.

---

### State

**Intent:** Let an object change its behavior when its internal state changes, appearing as if
it changed its class.

**Problem it solves:** Large conditionals (switch/if-else) that check the object's state to
decide what to do. A `Document` that behaves differently in Draft, Moderation, and Published
states — the `publish` method needs different logic per state.

**When to use:**
- An object behaves differently depending on its current state
- There are many states, and state-specific code changes frequently
- Conditional logic based on state has become unwieldy
- A lot of duplicate code across similar states and transitions of a condition-based state machine

**Smell connection:** Directly addresses Switch Statements when the switch is on the object's
state. Also addresses Temporary Field (state-dependent fields move into state objects).

**Key difference from Strategy:** In State, particular states may be aware of each other and
initiate transitions from one state to another. In Strategy, strategies almost never know about
each other.

**Relations:** Bridge, State, Strategy, and Adapter have very similar structures — all based on
composition/delegation, but solve different problems. **State can be considered an extension of
Strategy.** Both change context behavior by delegating to helper objects. Strategy makes objects
completely independent. State doesn't restrict dependencies between concrete states, letting
them alter the context's state at will.

---

### Strategy

**Intent:** Define a family of interchangeable algorithms.

**Problem it solves:** A class contains multiple variations of an algorithm (e.g., different
routing, pricing, or sorting strategies) implemented as conditionals. A navigation app that
needs road, walking, transit, and cycling routes — each algorithm bloats the main navigator.

**When to use:**
- You need to switch algorithms at runtime
- Multiple classes differ only in their algorithm
- You want to replace complex conditionals with pluggable behavior

**Smell connection:** Directly addresses Switch Statements when the switch selects an algorithm.
Also addresses Large Class when the class is large because it holds multiple algorithm variants.

**Relations:** Bridge, State, Strategy, and Adapter have similar structures but different intents.
**Command vs Strategy:** both parameterize with an action, but Command is about deferring/queuing/
undoing; Strategy is about swapping algorithms. **Decorator changes the skin; Strategy changes
the guts.** **Template Method uses inheritance (static, class level); Strategy uses composition
(dynamic, object level, switchable at runtime).** State can be considered an extension of Strategy.

---

### Template Method

**Intent:** Define the skeleton of an algorithm in a superclass, letting subclasses override
specific steps without changing the algorithm's structure.

**Problem it solves:** Multiple classes implement nearly identical algorithms with minor
variations, leading to Duplicate Code. A data mining app processes DOC, CSV, and PDF — format
handling differs, but data processing and analysis are almost identical.

**When to use:**
- Subclass methods follow the same overall structure but differ in specific steps
- You want to enforce an algorithm's structure while allowing customization of steps
- You want clients to extend only particular steps, not the whole algorithm

**Smell connection:** Directly addresses Duplicate Code when the duplication follows a shared
algorithm structure across sibling classes.

**Relations:** **Factory Method is a specialization of Template Method.** A factory method may
serve as a step in a large template method. **Template Method is based on inheritance (static);
Strategy is based on composition (dynamic, switchable at runtime).** Template Method lets you
alter parts by extending in subclasses. Strategy lets you alter behavior by supplying different
strategy objects.

---

### Visitor

**Intent:** Separate algorithms from the objects they operate on.

**Problem it solves:** You need to add new operations to a class hierarchy without modifying
the classes themselves.

**When to use:**
- You need to perform operations across a complex object structure (e.g., AST, document tree)
- You want to keep related behavior together instead of spreading it across element classes
- The element classes rarely change, but operations change frequently

**Smell connection:** Can address Feature Envy when external code keeps reaching into an object
hierarchy. Moves the operation into a dedicated Visitor instead.

**Relations:** Visitor can execute operations over an entire Composite tree. Visitor can be seen
as a powerful version of Command — executing operations over various objects of different classes.

---

## Pattern Relationships

Patterns connect to each other in systematic ways. Understanding these relationships helps you
pick the right pattern and recognize when one pattern naturally evolves into another.

### Evolution paths

- Many designs **start with Factory Method** (simpler) and evolve toward Abstract Factory,
  Prototype, or Builder (more flexible, more complicated).
- **Composition over inheritance:** When inheritance becomes awkward, Bridge/Strategy/State
  (composition-based) usually replace Template Method/Factory Method (inheritance-based).

### Similar structures, different intents

These groups share nearly identical class diagrams but solve different problems:

- **Bridge, State, Strategy, Adapter** — All based on composition/delegation.
- **Composite, Decorator** — Both rely on recursive composition. Decorator has one child and adds
  behavior; Composite sums up children's results.
- **Chain of Responsibility, Decorator** — Recursive composition, but CoR handlers can stop the chain.
- **Decorator, Proxy** — Similar structures, but Proxy manages lifecycle while Decorator is client-controlled.

### Connecting senders and receivers

Four patterns address this in different ways:
- **Chain of Responsibility** — passes request sequentially until one handler processes it
- **Command** — establishes unidirectional sender→receiver connections
- **Mediator** — eliminates direct connections between senders and receivers
- **Observer** — lets receivers dynamically subscribe/unsubscribe to notifications

### Common cooperations

- **Command + Memento** — undo (commands perform operations, mementos save state before)
- **Builder + Composite** — builder constructs complex composite trees recursively
- **Composite + Iterator + Visitor** — traverse and operate on tree structures
- **Facade + Singleton** — facade often needs exactly one instance
- **Abstract Factory + Factory Method** — abstract factories are often built on factory methods

---

## Pattern-Smell Quick Reference

| Smell | Potential Pattern | Condition |
|-------|-------------------|-----------|
| Switch Statements (on type) | Strategy | Switch selects algorithm behavior |
| Switch Statements (on state) | State | Switch checks object's current state |
| Switch Statements (on creation) | Factory Method | Switch creates different objects |
| Parallel Inheritance Hierarchies | Bridge | Hierarchies represent independent dimensions |
| Parallel Inheritance Hierarchies | Abstract Factory | Hierarchies represent product families |
| Duplicate Code (algorithm structure) | Template Method | Methods share structure, differ in steps |
| Long Method (chain of checks) | Chain of Responsibility | Method is sequential condition-action |
| Large Class (multiple behaviors) | Strategy | Class holds algorithm variants |
| Large Class (optional behaviors) | Decorator | Class is large because of combinable options |
| Large Class (complex subsystem) | Facade | Class is a monolith exposing too much |
| Message Chains | Facade / Mediator | Chain traverses a complex object graph |
| Inappropriate Intimacy | Mediator | Two classes need decoupling via coordinator |
| Inappropriate Intimacy | Observer | One class watches another's state |
| Alternative Classes Different Interfaces | Adapter | Can't modify one or both interfaces |
| Temporary Field | State | Fields are state-dependent |
| Temporary Field | Null Object | Fields are often null |
| Long Parameter List | Builder | Constructor has too many optional params |
| Incomplete Library Class | Adapter / Decorator | Need to extend library behavior |
| Data Class + Feature Envy | Move behavior in (not a pattern) | Behavior belongs with the data |
| Refused Bequest | Replace Inheritance with Delegation (not a pattern) | Inheritance is wrong relationship |
