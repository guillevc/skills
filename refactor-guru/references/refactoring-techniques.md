# Refactoring Techniques Catalog

Complete catalog of 66 refactoring techniques, organized by category.
Read sections selectively based on the smell you're addressing.

For the most commonly used techniques, detailed step-by-step instructions are at the end
of this file in [Key Techniques — How to Refactor](#key-techniques--how-to-refactor).

## Table of Contents

1. [Composing Methods](#composing-methods)
2. [Moving Features between Objects](#moving-features-between-objects)
3. [Organizing Data](#organizing-data)
4. [Simplifying Conditional Expressions](#simplifying-conditional-expressions)
5. [Simplifying Method Calls](#simplifying-method-calls)
6. [Dealing with Generalization](#dealing-with-generalization)

---

## Composing Methods

These techniques streamline methods, remove code duplication, and pave the way for future improvements.

| Technique | What it does | Use when |
|-----------|-------------|----------|
| **Extract Method** | Pull a code fragment into a named method | A block of code can be grouped together and named |
| **Inline Method** | Replace a method call with the method's body | The method body is as clear as the method name |
| **Extract Variable** | Give a meaningful name to an expression | An expression is complex or repeated |
| **Inline Temp** | Replace a temp variable with the expression itself | The temp adds nothing; it's assigned once and used once |
| **Replace Temp with Query** | Turn a temp variable into a method call | A temp holds the result of an expression that could be a method |
| **Split Temporary Variable** | Use separate variables for separate assignments | A temp is assigned more than once for different purposes |
| **Remove Assignments to Parameters** | Use a local variable instead of reassigning a parameter | A parameter is being reassigned inside a method |
| **Replace Method with Method Object** | Turn a method into its own class | A method has so many local variables that extraction is impossible |
| **Substitute Algorithm** | Replace the body of a method with a better algorithm | An algorithm can be replaced with a clearer or more efficient one |

---

## Moving Features between Objects

These techniques move functionality between classes and create new classes to distribute responsibilities.

| Technique | What it does | Use when |
|-----------|-------------|----------|
| **Move Method** | Move a method to the class that uses it most | A method is used more by another class than its own |
| **Move Field** | Move a field to the class that uses it most | A field is used more by another class than its own |
| **Extract Class** | Create a new class from a subset of fields/methods | A class does too many things |
| **Inline Class** | Merge a class into the class that uses it | A class does too little to justify its existence |
| **Hide Delegate** | Create a method on a server to hide the delegate | A client calls a delegate through the server's field |
| **Remove Middle Man** | Let the client call the delegate directly | A class has too many delegating methods |
| **Introduce Foreign Method** | Add a utility method to the client when you can't modify a library class | A library class is missing a method you need |
| **Introduce Local Extension** | Create a subclass or wrapper to extend a library class | You need several methods added to a library class |

---

## Organizing Data

These techniques help with data handling, replace primitives with rich class functionality, and untangle class associations.

| Technique | What it does | Use when |
|-----------|-------------|----------|
| **Self Encapsulate Field** | Access a field through getter/setter even within the class | Direct field access is causing issues in subclasses |
| **Replace Data Value with Object** | Wrap a primitive field in its own class | A data field has behavior or validation attached |
| **Change Value to Reference** | Turn a value object into a reference object | Many identical instances should be a single shared instance |
| **Change Reference to Value** | Turn a reference object into a value object | A reference object is too small/simple to justify lifecycle management |
| **Replace Array with Object** | Replace an array with an object that has named fields | An array contains elements with different meanings |
| **Duplicate Observed Data** | Copy domain data to a separate domain object | Domain data is mixed into a UI class |
| **Change Unidirectional to Bidirectional** | Add back-reference between two classes | Two classes need to refer to each other |
| **Change Bidirectional to Unidirectional** | Remove one direction of an association | One class no longer needs to know about the other |
| **Replace Magic Number with Symbolic Constant** | Replace a literal with a named constant | A number has special meaning |
| **Encapsulate Field** | Make a public field private and add accessors | A field is public |
| **Encapsulate Collection** | Return a read-only view and provide add/remove methods | A getter returns a raw collection |
| **Replace Type Code with Class** | Replace a type code with a class | A field has a code that doesn't affect behavior |
| **Replace Type Code with Subclasses** | Replace a type code with subclasses | A type code affects behavior and doesn't change at runtime |
| **Replace Type Code with State/Strategy** | Replace a type code with a State/Strategy pattern | A type code affects behavior and can change at runtime |
| **Replace Subclass with Fields** | Replace subclasses with fields in the parent | Subclasses differ only in constant values |

---

## Simplifying Conditional Expressions

These techniques simplify conditional logic.

| Technique | What it does | Use when |
|-----------|-------------|----------|
| **Decompose Conditional** | Extract condition, then-branch, and else-branch into named methods | A conditional is complex or hard to read |
| **Consolidate Conditional Expression** | Combine conditionals that lead to the same result | Multiple conditions produce the same outcome |
| **Consolidate Duplicate Conditional Fragments** | Move identical code outside the conditional | The same code appears in all branches |
| **Remove Control Flag** | Replace a control flag with break/return/continue | A boolean variable acts as a control flag in a loop |
| **Replace Nested Conditional with Guard Clauses** | Convert nested ifs into early returns | The normal flow is lost in nesting |
| **Replace Conditional with Polymorphism** | Move each branch into an overriding method on a subclass | A conditional dispatches on type |
| **Introduce Null Object** | Replace null checks with a null object that provides default behavior | Code is littered with null checks for the same object |
| **Introduce Assertion** | Add an assertion to document an assumption | A section of code assumes something about the program state |

---

## Simplifying Method Calls

These techniques make method calls simpler and easier to understand.

| Technique | What it does | Use when |
|-----------|-------------|----------|
| **Rename Method** | Give the method a name that reveals its purpose | The name doesn't communicate what the method does |
| **Add Parameter** | Add a parameter the method needs | A method needs data it doesn't currently receive |
| **Remove Parameter** | Remove a parameter that isn't used | A parameter is unused |
| **Separate Query from Modifier** | Split a method that returns a value AND changes state | A method has side effects and a return value |
| **Parameterize Method** | Combine similar methods that differ by a value | Methods do the same thing with different hardcoded values |
| **Replace Parameter with Explicit Methods** | Create a separate method for each parameter value | A method behaves differently based on a parameter value |
| **Preserve Whole Object** | Pass the whole object instead of individual fields | Several values are pulled from the same object to pass as parameters |
| **Replace Parameter with Method Call** | The receiver can get the value itself | A parameter can be obtained by calling a method |
| **Introduce Parameter Object** | Bundle related parameters into an object | The same group of parameters appears in multiple methods |
| **Remove Setting Method** | Drop the setter for a field | A field should be set at creation time and never changed |
| **Hide Method** | Reduce a method's visibility | A method isn't used outside its class |
| **Replace Constructor with Factory Method** | Use a factory method instead of a constructor | The constructor does more than just setting fields |
| **Replace Error Code with Exception** | Throw an exception instead of returning a special error code | A method returns a special value to indicate an error |
| **Replace Exception with Test** | Check the condition before calling the method | An exception is thrown for a condition you can check in advance |

---

## Dealing with Generalization

These techniques deal with class hierarchies, abstraction, and inheritance.

| Technique | What it does | Use when |
|-----------|-------------|----------|
| **Pull Up Field** | Move a field from subclasses to the superclass | Multiple subclasses have the same field |
| **Pull Up Method** | Move a method from subclasses to the superclass | Multiple subclasses have the same method |
| **Pull Up Constructor Body** | Move common constructor logic to the superclass | Subclass constructors have near-identical code |
| **Push Down Method** | Move a method from superclass to a specific subclass | A method is only relevant to one subclass |
| **Push Down Field** | Move a field from superclass to a specific subclass | A field is only used by one subclass |
| **Extract Subclass** | Create a subclass for a subset of features | A class has features used only in certain cases |
| **Extract Superclass** | Create a superclass from common features of two classes | Two classes have shared fields and methods |
| **Extract Interface** | Define an interface for the shared subset of methods | Multiple classes share the same method signatures |
| **Collapse Hierarchy** | Merge a subclass into its parent | A subclass is barely different from its superclass |
| **Form Template Method** | Restructure methods with similar steps into a Template Method | Subclass methods have the same structure but differ in details |
| **Replace Inheritance with Delegation** | Use composition instead of inheritance | A subclass only uses a portion of its parent's interface |
| **Replace Delegation with Inheritance** | Inherit instead of delegating | A class delegates everything to another class and the relationship is truly "is-a" |

---

## Key Techniques — How to Refactor

Detailed step-by-step instructions for the most commonly used refactoring techniques.

### Extract Method

The single most important refactoring. Used to fix Long Method, Duplicate Code, Feature Envy,
Switch Statements, Message Chains, Comments, and Data Class.

**Steps:**
1. Create a new method named to make its purpose self-evident (name it after *what* it does,
   not *how*).
2. Copy the relevant code fragment to the new method. Delete it from the old location and
   replace with a call.
3. If variables are declared inside the fragment and not used outside, leave them as local
   variables in the new method.
4. If variables are declared *before* the extracted code and used *inside* it, pass them as
   parameters. If there are too many, consider Replace Temp with Query to eliminate some.
5. If a local variable changes in the extracted code and the changed value is needed later in
   the main method, return it from the new method.

**Pros:** More readable code (the name communicates intent). Less code duplication (the method
can be reused). Isolates independent parts, reducing error likelihood.

---

### Move Method

The primary fix for Feature Envy and Shotgun Surgery. Also addresses Switch Statements,
Parallel Inheritance Hierarchies, Message Chains, Inappropriate Intimacy, and Data Class.

**Steps:**
1. Verify all features used by the method in its current class. Consider moving them too.
   If a feature is used *only* by this method, move it along. If used by other methods too,
   consider moving those as well. Moving a cluster is simpler than untangling references.
2. Check that the method is not declared in superclasses/subclasses. If it is, you may need
   to implement polymorphism in the recipient class.
3. Declare the new method in the recipient class. Give it an appropriate name for its new home
   (it may make sense to rename it).
4. Decide how the old class will refer to the recipient class — existing field, method parameter,
   or create a new field.
5. Move the code. If the old method can be deleted entirely (no other callers), do so and
   replace all references with calls to the new location.

**Payoff:** Better cohesion — method lives with the data it uses. Reduced coupling between classes.

---

### Extract Class

The primary fix for Large Class, Divergent Change, and Data Clumps. Also addresses Duplicate
Code, Primitive Obsession, Temporary Field, and Inappropriate Intimacy.

**Steps:**
1. Create a new class to contain the relevant functionality. Name it after the responsibility
   you're extracting.
2. Create a relationship between the old class and the new one. Prefer unidirectional (old → new)
   for simplicity and reuse. Use bidirectional only if necessary.
3. Use Move Field and Move Method for each piece you're relocating. **Start with private
   methods** to reduce error risk. Move a little at a time and test after each move.
4. After moving, review both classes. Rename the old class if its responsibilities have changed
   significantly. Check if bidirectional relationships can be simplified to unidirectional.
5. Decide on accessibility: make the new class private (managed via old class fields, hidden
   from clients) or public (direct client access), depending on whether direct access is safe.

**Pros:** Maintains Single Responsibility Principle. Code becomes more obvious and understandable.
Single-responsibility classes are more reliable and tolerant of changes — changing a class for
one of its ten responsibilities risks breaking the other nine.

**Cons:** If you overdo it, you'll need Inline Class to undo the over-splitting.

---

### Inline Class

The fix for Lazy Class, Shotgun Surgery, and Speculative Generality. The reverse of Extract Class.

**Steps:**
1. In the recipient class, create the public fields and methods present in the donor class.
   Methods should initially refer to the equivalent donor class methods.
2. Replace all references to the donor class with references to the recipient class's fields
   and methods.
3. Test. If everything works, use Move Method and Move Field to completely transplant all
   functionality. Continue until the donor class is empty.
4. Delete the empty donor class.

---

### Hide Delegate

Fixes Message Chains and Inappropriate Intimacy.

**Steps:**
1. For each method of the delegate class called by the client, create a method in the server
   class that delegates the call.
2. Change client code to call the server class methods instead.
3. If changes free the client from needing the delegate class, remove the access method to the
   delegate from the server class.

**Pros:** Hides delegation from the client. The less the client knows about object relationships,
the easier it is to make changes.

**Cons:** If you need excessive delegating methods, the server class risks becoming an unneeded
Middle Man. Balance with Remove Middle Man.

---

### Replace Conditional with Polymorphism

The fundamental fix for Switch Statements. Converts conditionals into a clean class hierarchy.

**Steps:**
1. If the conditional is in a method that does other things too, use Extract Method to isolate it.
2. Create subclasses for each branch of the conditional (if they don't already exist). Use
   Replace Type Code with Subclasses or Replace Type Code with State/Strategy.
3. In each subclass, override the method that contains the conditional and move the relevant
   branch code into it.
4. Delete the branch from the conditional. Repeat for each branch.
5. Delete the conditional entirely — the method in the base class can become abstract or contain
   default behavior.

**Prerequisite:** You need an inheritance hierarchy or can create one. This technique transforms
procedural type-checking code into proper OO design.
