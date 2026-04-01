# Test Doubles Taxonomy — Detailed Guide

Multi-language examples and framework-specific patterns for each test double type.
Read sections selectively based on the user's language and needs.

## Table of Contents

1. [Dummy Objects](#dummy-objects)
2. [Fakes](#fakes)
3. [Stubs](#stubs)
4. [Spies](#spies)
5. [Mocks](#mocks)
6. [Framework Mapping](#framework-mapping)
7. [Verification Strategies Deep Dive](#verification-strategies-deep-dive)
8. [When to Use Real Objects Instead](#when-to-use-real-objects-instead)

---

## Dummy Objects

**Definition:** Objects passed around but never actually used. They exist only to satisfy a
parameter list or constructor signature.

**When to use:**
- A constructor requires a dependency that the specific test path never touches
- Interface is broader than what the test exercises

### Examples

**Python:**
```python
# The logger is required by __init__ but this test never triggers logging
def test_calculate_total():
    calculator = PriceCalculator(logger=None)
    assert calculator.total([10, 20, 30]) == 60
```

**TypeScript:**
```typescript
// Payment gateway required but this test only checks validation
const dummy: PaymentGateway = {} as PaymentGateway;
const service = new OrderValidator(dummy);
expect(service.validate(order)).toBe(true);
```

**Java:**
```java
// Mailer is a constructor dependency but not used in this code path
var service = new ReportGenerator(null /* mailer */);
assertEquals("Q4 Report", service.generateTitle(q4Data));
```

**Go:**
```go
// nilLogger satisfies the Logger interface, does nothing
type nilLogger struct{}
func (n nilLogger) Log(msg string) {}

func TestCalculation(t *testing.T) {
    calc := NewCalculator(nilLogger{})
    if calc.Add(2, 3) != 5 { t.Fatal("expected 5") }
}
```

**Ruby:**
```ruby
# double() creates a dummy that will error if anything is called on it
calculator = PriceCalculator.new(logger: double("unused logger"))
expect(calculator.total([10, 20])).to eq(30)
```

**Swift:**
```swift
// Protocol conformance that should never be called
struct DummyAnalytics: AnalyticsTracker {
    func track(_ event: String) { fatalError("Dummy — should not be called") }
}

func testCalculation() {
    let calc = Calculator(analytics: DummyAnalytics())
    XCTAssertEqual(calc.add(2, 3), 5)
}
```

**C#:**
```csharp
// null is the simplest dummy when the dep isn't touched
var service = new ReportGenerator(mailer: null!);
Assert.Equal("Q4 Report", service.GenerateTitle(q4Data));
```

**Gotcha:** If your dummy starts needing return values, it's become a stub — promote it
consciously rather than adding ad-hoc returns to a dummy.

---

## Fakes

**Definition:** Objects with working implementations that take shortcuts making them unsuitable
for production. They have real business logic, just simplified.

**When to use:**
- The real collaborator is slow (database, network, filesystem)
- Multiple tests need consistent stateful behavior from the same collaborator
- Stubs would require increasingly elaborate canned responses to simulate stateful interactions

### Examples

**Python:**
```python
class InMemoryUserRepository:
    def __init__(self):
        self._users = {}

    def save(self, user):
        self._users[user.id] = user

    def find_by_id(self, user_id):
        return self._users.get(user_id)

    def find_active(self):
        return [u for u in self._users.values() if u.is_active]

# Test uses it like the real thing — state verification on the SUT
def test_deactivate_user():
    repo = InMemoryUserRepository()
    repo.save(User(id="1", is_active=True))
    service = UserService(repo)

    service.deactivate("1")

    user = repo.find_by_id("1")
    assert not user.is_active  # verify state, not interactions
```

**TypeScript:**
```typescript
class InMemoryOrderStore implements OrderStore {
  private orders = new Map<string, Order>();

  save(order: Order): void { this.orders.set(order.id, order); }
  findById(id: string): Order | undefined { return this.orders.get(id); }
  findByStatus(status: string): Order[] {
    return [...this.orders.values()].filter(o => o.status === status);
  }
}
```

**Java:**
```java
public class InMemoryProductCatalog implements ProductCatalog {
    private final Map<String, Product> products = new HashMap<>();

    @Override public void add(Product p) { products.put(p.getId(), p); }
    @Override public Optional<Product> findById(String id) {
        return Optional.ofNullable(products.get(id));
    }
    @Override public List<Product> search(String query) {
        return products.values().stream()
            .filter(p -> p.getName().toLowerCase().contains(query.toLowerCase()))
            .collect(Collectors.toList());
    }
}
```

**Go:**
```go
type InMemoryStore struct {
    items map[string]Item
}

func NewInMemoryStore() *InMemoryStore {
    return &InMemoryStore{items: make(map[string]Item)}
}

func (s *InMemoryStore) Save(item Item) error {
    s.items[item.ID] = item
    return nil
}

func (s *InMemoryStore) FindByID(id string) (Item, error) {
    item, ok := s.items[id]
    if !ok { return Item{}, ErrNotFound }
    return item, nil
}
```

**Gotchas:**
- Fakes have real logic, so they can have bugs — write a few tests for the fake itself
- Fakes can drift from the real implementation over time. Contract tests (run the same tests
  against both the fake and the real implementation) catch this drift early.

---

## Stubs

**Definition:** Provide canned answers to calls made during the test. Usually don't respond
to anything outside what's programmed for the specific test.

**When to use:**
- The SUT needs specific input data from a collaborator to exercise a code path
- You want to test how the SUT handles specific conditions (errors, empty results, edge cases)
- **State verification**: you'll assert on what the SUT produced, not what it called

### Examples

**Python:**
```python
# Hand-written stub
class StubWeatherService:
    def get_temperature(self, city):
        return 35.0  # always hot — testing the heat warning path

def test_issues_heat_warning():
    advisor = WeatherAdvisor(weather=StubWeatherService())
    assert advisor.get_advisory("Phoenix") == "Heat warning: stay hydrated"

# Framework stub (unittest.mock)
from unittest.mock import Mock
weather = Mock()
weather.get_temperature.return_value = 35.0
advisor = WeatherAdvisor(weather=weather)
assert advisor.get_advisory("Phoenix") == "Heat warning: stay hydrated"
```

**TypeScript:**
```typescript
// Hand-written stub
const stubPricing: PricingService = {
  getPrice: () => 99.99,
  getDiscount: () => 0.1,
};

// Framework stub (jest)
const stubPricing = { getPrice: jest.fn().mockReturnValue(99.99) };
```

**Java:**
```java
// Mockito stub — when().thenReturn() is the stub pattern
var pricingService = mock(PricingService.class);
when(pricingService.getPrice("SKU-1")).thenReturn(new BigDecimal("99.99"));

var cart = new ShoppingCart(pricingService);
cart.addItem("SKU-1", 2);
// State verification — checking the cart, not the mock
assertEquals(new BigDecimal("199.98"), cart.getTotal());
```

**Go:**
```go
type stubExchangeRate struct{}

func (s stubExchangeRate) GetRate(from, to string) (float64, error) {
    return 1.25, nil // always return fixed rate
}

func TestConvertCurrency(t *testing.T) {
    converter := NewConverter(stubExchangeRate{})
    result := converter.Convert(100, "USD", "EUR")
    if result != 125.0 { t.Fatalf("expected 125.0, got %f", result) }
}
```

**Gotcha:** If you find yourself calling `verify()` on a stub, you've turned it into a mock.
That's a conscious choice — make it intentionally, not accidentally.

---

## Spies

**Definition:** Stubs that also record information about how they were called. You inspect the
recorded data in your test assertions.

**When to use:**
- You need to verify a side effect happened (email sent, event published, audit logged)
- You prefer to assert AFTER execution rather than setting expectations BEFORE
- The interaction is the behavior you care about — not just an implementation detail

### Examples

**Python:**
```python
# Hand-written spy
class SpyEmailSender:
    def __init__(self):
        self.sent = []

    def send(self, to, subject, body):
        self.sent.append({"to": to, "subject": subject, "body": body})

def test_sends_welcome_email():
    spy = SpyEmailSender()
    service = RegistrationService(email_sender=spy)

    service.register("alice@example.com")

    assert len(spy.sent) == 1
    assert spy.sent[0]["to"] == "alice@example.com"
    assert "Welcome" in spy.sent[0]["subject"]
```

**TypeScript:**
```typescript
// jest.fn() is naturally a spy — it records all calls
const sendEmail = jest.fn();
const service = new RegistrationService({ sendEmail });

await service.register("alice@example.com");

expect(sendEmail).toHaveBeenCalledTimes(1);
expect(sendEmail).toHaveBeenCalledWith(
  "alice@example.com",
  expect.stringContaining("Welcome")
);
```

**Java:**
```java
// Mockito's verify() turns a mock into a spy pattern
var notifier = mock(Notifier.class);
var service = new OrderService(notifier);

service.placeOrder(order);

// Behavior verification — but asserted AFTER execution, not before
verify(notifier).notify(eq("order-placed"), argThat(msg ->
    msg.contains(order.getId())
));
```

**Go:**
```go
type spyAuditLog struct {
    entries []AuditEntry
}

func (s *spyAuditLog) Record(entry AuditEntry) {
    s.entries = append(s.entries, entry)
}

func TestAuditLogOnTransfer(t *testing.T) {
    spy := &spyAuditLog{}
    service := NewTransferService(spy)

    service.Transfer("A", "B", 100)

    if len(spy.entries) != 1 { t.Fatal("expected 1 audit entry") }
    if spy.entries[0].Action != "transfer" { t.Fatal("wrong action") }
}
```

**Gotcha:** Spies couple tests to implementation, just like mocks. Use them only when the
interaction is the behavior you care about — not as a default verification strategy.

---

## Mocks

**Definition:** Objects pre-programmed with expectations which form a specification of the
calls they are expected to receive. Verification happens automatically.

**When to use:**
- You need strict interaction protocols (must call X before Y, must not call Z)
- Outside-in TDD where you're designing the collaborator's interface through the test
- The exact sequence and arguments of calls is the specification you're testing

### Examples

**Python:**
```python
from unittest.mock import Mock, call

gateway = Mock()
# Expectations set BEFORE execution
gateway.connect.return_value = True
gateway.send.return_value = {"status": "ok"}

client = ApiClient(gateway)
client.submit(payload)

# Verification — order matters
gateway.assert_has_calls([
    call.connect(),
    call.send(payload),
    call.disconnect()
])
```

**Java (JMock-style — closest to Fowler's original examples):**
```java
// Expectations set up BEFORE execution
context.checking(new Expectations() {{
    oneOf(warehouse).hasInventory("Talisker", 50); will(returnValue(true));
    oneOf(warehouse).remove("Talisker", 50);
}});

order.fill(warehouse);
context.assertIsSatisfied(); // auto-verification
```

**Go (gomock):**
```go
ctrl := gomock.NewController(t)
mockRepo := NewMockRepository(ctrl)

// Expectations — strict
gomock.InOrder(
    mockRepo.EXPECT().BeginTx().Return(tx, nil),
    mockRepo.EXPECT().Save(gomock.Any()).Return(nil),
    mockRepo.EXPECT().CommitTx(tx).Return(nil),
)

service := NewService(mockRepo)
service.Process(item) // gomock auto-verifies on ctrl.Finish()
```

**Gotcha:** Mocks create the tightest coupling between tests and implementation. If you can
verify the same thing through state, prefer that. Mocks are most valuable during interface
design (outside-in TDD) and for strict protocol verification.

---

## Framework Mapping

Most frameworks use the word "mock" generically, but the actual test double type depends on
how you use it. This table maps common framework constructs to their typical Meszaros type:

| Framework construct           | Default type | Becomes... when you...                        |
|-------------------------------|-------------|-----------------------------------------------|
| Jest `jest.fn()`              | Spy         | Stub (`.mockReturnValue`), Mock (strict setup) |
| Mockito `mock(T.class)`      | Stub        | Spy/Mock (`.verify()`), Spy (`.spy()`)         |
| Python `Mock()`              | Spy         | Stub (`.return_value`), Mock (`.assert_called`) |
| Python `MagicMock()`         | Spy         | Same as Mock, with magic methods               |
| Go `gomock`                  | Mock        | Strict expectations by default                 |
| RSpec `double()`             | Configurable| Stub (`allow`), Mock (`expect`)                |
| Sinon `sinon.stub()`         | Stub        | Spy (`.calledWith`), Mock (`.expects()`)       |
| Sinon `sinon.spy()`          | Spy         | Pure recording, wraps real or standalone        |
| Sinon `sinon.mock()`         | Mock        | Expectations-based                             |
| Moq `Mock<T>()`              | Stub        | Mock (`MockBehavior.Strict`), Spy (`.Verify`)  |
| NSubstitute `Substitute.For` | Stub/Spy    | Records by default, verify optional            |
| Mockery (PHP) `mock()`       | Stub        | Mock (`shouldReceive`), Spy (`shouldHaveReceived`) |
| OCMock `OCMockObject`        | Stub/Mock   | Stub (`stub`), Mock (`expect`)                 |

The key insight: these frameworks give you a Swiss Army knife. The Meszaros taxonomy tells
you which blade to open. Classify by usage pattern, not framework vocabulary.

---

## Verification Strategies Deep Dive

### State Verification

Check the SUT's output or resulting state after exercising the method:

```
1. Setup — create SUT and collaborators (stubs/fakes for inputs)
2. Exercise — call the method being tested
3. Verify — assert on the SUT's return value, properties, or observable state
4. Teardown — clean up (if needed)
```

**Strengths:**
- Tests survive refactoring — they don't care about internal method calls
- Tests express WHAT the system does, not HOW it does it
- Easy to understand: input → output

**Weaknesses:**
- Some behaviors have no observable state change (side effects only)
- Complex state setup for deeply nested object graphs
- May need query methods that exist solely for test observation

### Behavior Verification

Check that the SUT made the right calls to its collaborators:

```
1. Setup — create SUT with mocks/spies
2. Set expectations — define expected calls (mocks) or just provide canned responses (spies)
3. Exercise — call the method being tested
4. Verify — check that expected interactions occurred (automatic for mocks, manual for spies)
```

**Strengths:**
- Perfect for verifying side effects (notifications, events, external calls)
- No need for query methods on collaborators
- Guides interface design in outside-in TDD

**Weaknesses:**
- Tests coupled to implementation — refactoring breaks tests
- Tests describe HOW, not WHAT — harder to understand intent
- Risk of "testing the choreography" rather than the behavior

### Hybrid Approach (often the best choice)

Use stubs for input dependencies + a spy for the one critical side effect:

```python
def test_order_processing():
    # Stub for input — we need it to return data
    inventory = StubInventory(available=True)
    # Spy for side effect — sending confirmation is the important behavior
    email_spy = SpyEmailSender()

    service = OrderService(inventory=inventory, email=email_spy)
    result = service.place_order(order)

    # State verification on the SUT
    assert result.status == "confirmed"
    # Behavior verification only for the side effect
    assert email_spy.sent_to == order.customer_email
```

---

## When to Use Real Objects Instead

Not every dependency needs a test double. Use the real thing when:

- **Fast and deterministic** — value objects, pure functions, simple collections
- **Same module** — collaborators within the same bounded context, when you want integration
  confidence
- **Simpler than the double** — if creating a double requires more code than using the real
  object, the double adds complexity without benefit
- **The interaction matters** — if the test specifically validates integration between two
  components, doubles defeat the purpose

This aligns with the classical TDD philosophy: use real objects by default, introduce doubles
only when a collaborator makes testing difficult (slow, nondeterministic, not yet built, or
produces side effects you don't want in tests).
