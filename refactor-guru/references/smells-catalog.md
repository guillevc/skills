# Code Smells Catalog

Complete catalog of code smells from refactoring.guru, organized by category.
Each smell includes symptoms, why it develops, why it matters, and the specific refactoring techniques to fix it.

## Table of Contents

1. [Bloaters](#bloaters)
2. [Object-Orientation Abusers](#object-orientation-abusers)
3. [Change Preventers](#change-preventers)
4. [Dispensables](#dispensables)
5. [Couplers](#couplers)

---

## Bloaters

Things that have grown too large to work with. They accumulate over time as the program evolves,
especially when nobody makes an effort to eradicate them.

### Long Method

**Symptoms:** A method contains too many lines of code. Generally, any method longer than ten
lines should make you start asking questions.

**Why it develops:** Like the Hotel California, something is always being added but nothing is
ever taken out. Since it's easier to write code than to read it, this smell goes unnoticed until
the method becomes an oversized beast. It's often harder mentally to create a new method than to
add to an existing one: "But it's just two lines, there's no use creating a whole method just
for that..." And then another line is added, and then yet another.

**Why it matters:** The longer a method or function is, the harder it becomes to understand and
maintain. Long methods are the perfect hiding place for unwanted duplicate code. Classes with
short methods live longest.

**Refactoring techniques:**
- **Extract Method** — If you feel the need to comment on something inside a method, take that
  code and put it in a new method. Even a single line can be worth extracting if it needs explanation.
- **Replace Temp with Query** — If temporary variables prevent extraction, turn them into methods.
- **Introduce Parameter Object** / **Preserve Whole Object** — If many parameters contribute to length.
- **Replace Method with Method Object** — When local variables are so intertwined that extraction
  is impossible, move the whole method into its own class.
- **Decompose Conditional** — Conditional operators and loops are good clues that code can be
  extracted. For conditionals, extract condition, then-branch, and else-branch into named methods.

---

### Large Class

**Symptoms:** A class contains many fields/methods/lines of code.

**Why it develops:** Classes usually start small. But over time, they get bloated as the program
grows. Programmers usually find it mentally less taxing to place a new feature in an existing
class than to create a new class for it.

**Why it matters:** Large classes have many reasons to change (violating SRP). They're hard to
understand because you need to keep track of many moving parts. Splitting them often avoids
duplication of code and functionality.

**Refactoring techniques:**
- **Extract Class** — When part of the behavior can be spun off into a separate component.
  Identify clusters of related fields and methods.
- **Extract Subclass** — When part of the behavior is only used in specific cases or can be
  implemented in different ways.
- **Extract Interface** — When clients use only a subset of the class's behavior and you need
  a list of the operations they can use.
- **Duplicate Observed Data** — When a class is responsible for the graphical interface, move
  some data and behavior to a separate domain object.

---

### Primitive Obsession

**Symptoms:** Use of primitives instead of small objects for simple tasks (such as currency,
ranges, special strings for phone numbers). Use of constants for coding information (such as
`USER_ADMIN_ROLE = 1`). Use of string constants as field names for use in data arrays.

**Why it develops:** "Just a field for storing some data!" the programmer says. Creating a
primitive field is so much easier than making a whole new class. Then another field is needed,
added the same way. The class becomes huge and unwieldy. Primitives are also used to "simulate"
types — instead of a separate data type, you have a set of numbers or strings forming the list
of allowable values, given easy-to-understand names via constants spread wide and far.

**Why it matters:** Primitives carry no domain meaning, no validation, and no behavior. Logic
that should live with the concept gets scattered across the codebase. You end up with validation
code duplicated everywhere a phone number appears. Code becomes more flexible when you use
objects instead of primitives.

**Refactoring techniques:**
- **Replace Data Value with Object** — Wrap the primitive in a class with domain behavior.
- **Introduce Parameter Object** — When groups of primitives travel together.
- **Preserve Whole Object** — Pass the domain object instead of its primitive parts.
- **Replace Type Code with Class** — When a string/int represents a fixed set of types.
- **Replace Type Code with Subclasses** — When the type code influences behavior (fixed at creation).
- **Replace Type Code with State/Strategy** — When the type code influences behavior and changes at runtime.
- **Replace Array with Object** — When arrays hold heterogeneous data with different meanings per element.

---

### Long Parameter List

**Symptoms:** More than 3-4 parameters for a method.

**Why it develops:** Often results from trying to make methods more flexible, or from extracting
methods that need data from many sources. It can also happen when an algorithm is moved from an
object that held the data into a separate method that now needs everything passed in.

**Why it matters:** Long parameter lists are hard to read, hard to call correctly (was it
`create(name, email, age, role)` or `create(name, age, email, role)`?), and often signal that
the method is doing too much or that related data should be grouped.

**Refactoring techniques:**
- **Replace Parameter with Method Call** — If a parameter can be obtained by calling another method
  the receiver already has access to.
- **Preserve Whole Object** — If several parameters come from the same object, pass the object.
- **Introduce Parameter Object** — If several parameters naturally belong together and travel as a group.

---

### Data Clumps

**Symptoms:** The same group of variables appears together repeatedly — as parameters to multiple
methods, as fields in multiple classes, or as local variables in multiple methods. Database
connection parameters (host, port, user, password) are a classic example.

**Why it matters:** Data that travels together usually represents a concept that deserves its own
class. Until you extract it, related validation and behavior has no home and gets duplicated.
A good litmus test: delete one of the data values. If the others don't make sense without it,
it's a clump that should be an object.

**Refactoring techniques:**
- **Extract Class** — Create a class for the clump.
- **Introduce Parameter Object** — Bundle the parameters.
- **Preserve Whole Object** — Pass the object instead of its parts.

---

## Object-Orientation Abusers

Incomplete or incorrect application of object-oriented programming principles.

### Switch Statements

**Symptoms:** A complex `switch` operator or sequence of `if` statements. The same switch
structure often appears scattered in multiple places throughout the code.

**Why it develops:** Relatively rare use of `switch` and `case` is a hallmark of well-designed
OO code. When you see `switch`, think polymorphism. The problem is that code for a single
`switch` can be scattered in different places, and when a new condition is added, you have to
find all the switch code and modify it.

**Why it matters:** Every time you add a new type/case, you must find and update every switch.
This is error-prone and violates the Open/Closed Principle. The logic for each type is scattered
across multiple switches instead of being cohesive in one place.

**Refactoring techniques:**
- **Extract Method + Move Method** — Isolate the switch, then move it to the class it dispatches on.
- **Replace Type Code with Subclasses** — If the type code is fixed at creation time.
- **Replace Type Code with State/Strategy** — If the type code can change at runtime.
- **Replace Conditional with Polymorphism** — The fundamental fix: let each type define its own behavior.
- **Replace Parameter with Explicit Methods** — When there aren't too many conditions and they all
  call the same method with different parameters; polymorphism would be superfluous here.
- **Introduce Null Object** — When one branch handles the "null/default" case.

**GoF pattern connections:** Strategy (when selecting algorithms), State (when behavior changes
with state), Factory Method (when creating different objects based on type).

---

### Temporary Field

**Symptoms:** Temporary fields get their values only under certain circumstances. Outside of
these circumstances, they're empty or null.

**Why it develops:** Often created for use in an algorithm that requires a large amount of
inputs. Instead of creating a large number of parameters in the method, the programmer decides
to create fields for this data in the class. These fields are used only in the algorithm and
go unused the rest of the time.

**Why it matters:** You expect data in object fields but for some reason they're almost always
empty. This kind of code is tough to understand — you can't tell the object's state without
tracing the execution path. Code that reads the field must always check if it's populated.

**Refactoring techniques:**
- **Extract Class** — Move the temporary field and the code that uses it into a separate class.
  This creates a method object, achieving the same result as Replace Method with Method Object.
- **Introduce Null Object** — Replace null checks with a null object that provides default behavior.

---

### Refused Bequest

**Symptoms:** A subclass uses only some of the methods/properties inherited from its parents.
The unneeded methods may go unused, or worse, be redefined to throw exceptions or do nothing.

**Why it develops:** Someone was motivated to create inheritance between classes only by the
desire to reuse code in a superclass. But the superclass and subclass are completely different —
they don't actually have an "is-a" relationship.

**Why it matters:** The inheritance hierarchy confuses developers who expect subclasses to honor
the parent's contract (Liskov Substitution Principle). You shouldn't wonder why the `Dog` class
inherits from the `Chair` class (even though they both have 4 legs).

**Refactoring techniques:**
- **Replace Inheritance with Delegation** — If inheritance makes no sense. Use composition instead;
  the former subclass holds a reference and delegates only what it needs.
- **Extract Superclass** — If inheritance is appropriate but the parent is too broad, extract all
  fields and methods needed by the subclass from the parent into a new superclass, and set both
  classes to inherit from it.

---

### Alternative Classes with Different Interfaces

**Symptoms:** Two classes perform the same function but have different method names or signatures.
Often discovered when you realize two pieces of code do the same thing but can't be used
interchangeably.

**Why it matters:** Duplication of purpose. Clients can't treat these classes polymorphically.
You lose the ability to swap implementations.

**Refactoring techniques:**
- **Rename Method** — Align method names across classes.
- **Move Method** — Consolidate behavior into one class.
- **Add Parameter** / **Parameterize Method** — Align method signatures.
- **Extract Superclass** — Create a shared interface or superclass.

**GoF pattern connection:** Adapter (when you can't change one of the interfaces).

---

## Change Preventers

Code structures that make changes ripple across the codebase. If you need to change something
in one place in your code, you have to make many changes in other places too.

**Note:** Divergent Change and Shotgun Surgery are opposites. Divergent Change = many changes
to a single class. Shotgun Surgery = one change to many classes.

### Divergent Change

**Symptoms:** You find yourself having to change many unrelated methods when you make changes
to a class. For example, when adding a new product type you have to change the methods for
finding, displaying, AND ordering products — all in the same class.

**Why it develops:** Often due to poor program structure or "copypasta programming."

**Why it matters:** This is an SRP violation — the class has multiple axes of change. Each
change risks breaking unrelated functionality. Different team members may conflict on the same file.

**Refactoring techniques:**
- **Extract Class** — Split the class by responsibility. Each resulting class has one reason to change.
- **Extract Superclass** / **Extract Subclass** — When the divergence follows an inheritance pattern.

---

### Shotgun Surgery

**Symptoms:** Making any modifications requires that you make many small changes to many
different classes.

**Why it develops:** A single responsibility has been split up among a large number of classes.
This can happen after overzealous application of Divergent Change fixes — you split too aggressively.

**Why it matters:** The opposite of Divergent Change. One responsibility is spread too thin.
Changes are error-prone because it's easy to miss a file. Related logic is scattered.

**Refactoring techniques:**
- **Move Method** / **Move Field** — Consolidate scattered pieces into one class.
- **Inline Class** — If a class is too thin and its logic belongs with its collaborator.
  If moving code leaves original classes almost empty, get rid of them.

---

### Parallel Inheritance Hierarchies

**Symptoms:** Whenever you create a subclass of one class, you need to create a subclass of
another class. The hierarchies mirror each other.

**Why it matters:** This is a special case of Shotgun Surgery. Every new type requires two
(or more) new classes, and forgetting one breaks the system.

**Refactoring techniques:**
- **Move Method** / **Move Field** — Collapse the hierarchies by moving behavior from one to the other.

**GoF pattern connection:** Bridge (when the two hierarchies represent independent dimensions).

---

## Dispensables

Things that could be removed to make the code cleaner. A dispensable is something pointless and
unneeded whose absence would make the code cleaner, more efficient, and easier to understand.

### Duplicate Code

**Symptoms:** Two or more code fragments look almost identical.

**Why it develops:** Duplication usually occurs when multiple programmers work on different parts
of the same program simultaneously, unaware that similar code already exists. There's also more
subtle duplication, when specific parts of code look different but actually perform the same job.
Sometimes duplication is purposeful — rushing to meet deadlines with copy-paste, or simply too
lazy to de-clutter.

**Why it matters:** Merging duplicate code simplifies structure and makes it shorter.
Simplification + shortness = code that's easier to simplify and cheaper to support. Bugs fixed
in one copy may be missed in the other.

**Refactoring techniques:**
- **Extract Method** — For duplication within the same class.
- **Pull Up Field** / **Pull Up Constructor Body** — For duplication across sibling subclasses.
- **Form Template Method** — When methods in subclasses share structure but differ in steps.
- **Substitute Algorithm** — When two methods do the same thing differently; select the best
  algorithm and replace the other.
- **Extract Superclass** / **Extract Class** — When duplication spans unrelated classes. If it's
  difficult or impossible to create a superclass, use Extract Class in one class and use the
  new component in the other.
- **Consolidate Conditional Expression** — For a large number of conditional expressions performing
  the same code (differing only in conditions).
- **Consolidate Duplicate Conditional Fragments** — When the same code appears in all branches.

**GoF pattern connection:** Template Method (when the duplication follows a shared algorithm structure).

---

### Lazy Class

**Symptoms:** A class doesn't do enough to justify its existence. May have been created for a
planned feature that never materialized, or gradually lost responsibility through refactoring.

**Why it matters:** Understanding and maintaining classes always costs time and money. If a class
doesn't earn your attention, it should be deleted.

**Refactoring techniques:**
- **Inline Class** — Merge it into the class that uses it.
- **Collapse Hierarchy** — If a subclass is barely different from its parent.

---

### Data Class

**Symptoms:** A class contains only fields and crude methods for accessing them (getters and
setters). These are simply containers for data used by other classes. They don't contain any
additional functionality and can't independently operate on the data they own.

**Why it develops:** It's normal when a newly created class contains only a few public fields
(and maybe a handful of getters/setters). But the true power of objects is that they can
contain behavior types or operations on their data.

**Why it matters:** Data classes are a sign that behavior is misplaced. The classes that
manipulate the data have Feature Envy for it. Operations on particular data end up haphazardly
scattered throughout the code instead of gathered in a single place.

**Refactoring techniques:**
- **Encapsulate Field** / **Encapsulate Collection** — Control access to the data first.
- **Move Method** / **Extract Method** — Review client code that uses the class. Find
  functionality that would be better located in the data class itself, then migrate it.
- **Remove Setting Method** — After the class has well-thought-out methods, get rid of old data
  access methods that give overly broad access.
- **Hide Method** — Reduce the public surface.

---

### Dead Code

**Symptoms:** Variables, parameters, fields, methods, or classes that are never used. Often
left behind after feature changes or incomplete removals.

**Why it matters:** Dead code misleads readers into thinking it's relevant. It adds to
compilation time, cognitive load, and maintenance burden.

**Refactoring techniques:**
- **Delete it.** Use your IDE or compiler to verify it's unused, then remove it.
- **Inline Class** / **Collapse Hierarchy** — When entire classes are dead.
- **Remove Parameter** — When parameters are unused.

---

### Speculative Generality

**Symptoms:** Abstract classes, interfaces, parameters, or delegation structures that exist "in
case we need them someday" but currently serve no purpose. Unused class, method, field, or
parameter added "for future use."

**Why it matters:** Premature abstraction adds complexity without current benefit. It makes code
harder to understand and navigate. YAGNI — You Aren't Gonna Need It.

**Refactoring techniques:**
- **Collapse Hierarchy** — Remove unnecessary abstract classes.
- **Inline Class** — Merge unnecessary delegation.
- **Inline Method** — Remove unnecessary indirection.
- **Remove Parameter** — Remove unused parameters.

---

### Comments (as Deodorant)

**Symptoms:** A method is filled with explanatory comments. The comments exist because the code
itself is unclear.

**Why it matters:** Comments that explain "what" go stale when code changes. The real fix is
making the code self-explanatory. If you feel the need to comment on something inside a method,
you should take that code and put it in a new method. If the method has a descriptive name,
nobody will need to look at the code to see what it does.

(Comments explaining "why" — business rules, non-obvious constraints — are valuable and not a smell.)

**Refactoring techniques:**
- **Extract Variable** — Name an expression to explain what it represents.
- **Extract Method** — Name a block of code to explain what it does.
- **Rename Method** — If a method name doesn't communicate its purpose.
- **Introduce Assertion** — Replace a comment about expectations with a runtime assertion.

---

## Couplers

Smells related to excessive coupling between classes, or what happens if coupling is replaced
by excessive delegation.

### Feature Envy

**Symptoms:** A method accesses the data of another object more than its own data.

**Why it develops:** This smell may occur after fields are moved to a data class. If so, you
may want to move the operations on data to that class as well.

**Why it matters:** The behavior is in the wrong place. Things that change at the same time
should be kept in the same place. Usually data and the functions that use it are changed together.
Less code duplication results when data handling is in a central place. Better organization when
methods for handling data are next to the actual data.

**Refactoring techniques:**
- **Move Method** — Move the method to the class whose data it uses.
- **Extract Method** — If only part of a method has Feature Envy, extract that part and move it.
- If a method uses functions from several other classes, determine which class contains most of
  the data used, then place the method in that class. Alternatively, split the method into parts
  that can live in different classes.

---

### Inappropriate Intimacy

**Symptoms:** One class uses the internal fields and methods of another class. Good classes
should know as little about each other as possible.

**Why it develops:** Keep a close eye on classes that spend too much time together. Such classes
are easier to maintain and reuse when they know less about each other.

**Why it matters:** Changes to one class break the other. Neither class can be understood,
tested, or reused independently. This is tight coupling at its worst.

**Refactoring techniques:**
- **Move Method + Move Field** — The simplest solution: relocate parts to the class where they're
  used (only if the first class truly doesn't need them).
- **Extract Class + Hide Delegate** — Make the code relations "official" through a new intermediate class.
- **Change Bidirectional Association to Unidirectional** — If the classes are mutually interdependent.
- **Replace Delegation with Inheritance** — If the "intimacy" is between a subclass and its superclass.

**GoF pattern connection:** Mediator (when a central coordinator would decouple the classes).

---

### Message Chains

**Symptoms:** A client asks object A for object B, then asks B for object C, then asks C for D:
`a.getB().getC().getD().doSomething()`. The client is coupled to the entire chain.

**Why it matters:** If any intermediate class in the chain changes its structure, the client
breaks. The client knows too much about the object graph. These chains mean the client is
coupled to navigation along the class structure.

**Refactoring techniques:**
- **Hide Delegate** — Have the first object expose the needed behavior directly.
- **Extract Method + Move Method** — Move the chain-traversing logic to the object that should own it.

---

### Middle Man

**Symptoms:** A class delegates almost everything to another class. Its methods are all
one-liners that forward to a delegate. If you remove it, nothing breaks.

**Why it matters:** The class adds indirection without adding value. Clients navigate through
it unnecessarily. This is often the result of over-applying Hide Delegate — every time a class
needed to talk to the delegate, a forwarding method was added, until the original class became
a shell.

**Refactoring techniques:**
- **Remove Middle Man** — Let clients talk to the delegate directly.

---

## Other

### Incomplete Library Class

**Symptoms:** A third-party library doesn't provide a method you need, and you can't modify it.
Libraries stop meeting user needs over time, and the only solution — changing the library — is
often impossible since the library is read-only.

**Refactoring techniques:**
- **Introduce Foreign Method** — Add the method to a utility class in your code (for just a few methods).
- **Introduce Local Extension** — Create a subclass or wrapper that adds the missing behavior
  (when you need several methods added).

**GoF pattern connection:** Adapter (wrapping the library to add the needed interface), Decorator
(adding behavior dynamically).
