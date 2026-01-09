---
name: testing
description: Testing strategy, patterns, and best practices for unit, integration, and e2e tests
---

# Testing Skill

Use this skill when writing tests, reviewing test coverage, or designing test strategies.

## Test Types

### Unit Tests
- Test individual functions/methods in isolation.
- Mock external dependencies (databases, APIs, filesystem).
- Fast execution (milliseconds per test).
- High volume (many tests covering many cases).

### Integration Tests
- Test interactions between components.
- Use real dependencies or realistic fakes.
- Test API contracts, database queries, external services.
- Moderate execution time.

### End-to-End (E2E) Tests
- Test complete user workflows.
- Run against a real or near-real environment.
- Slowest to execute, most brittle.
- Use sparingly for critical paths.

## Test Pyramid

```
      /\
     /  \     E2E (few)
    /----\
   /      \   Integration (some)
  /--------\
 /          \ Unit (many)
/------------\
```

Aim for many unit tests, fewer integration tests, and minimal E2E tests.

## Test Naming

Tests should clearly describe what they test and the expected outcome.

### Pattern
```
test_<unit>_<scenario>_<expected_result>
```

### Examples
```python
# Python (pytest)
def test_login_with_valid_credentials_returns_token():
def test_login_with_invalid_password_raises_auth_error():
def test_calculate_total_with_empty_cart_returns_zero():
```

```typescript
// TypeScript (vitest/jest)
describe('LoginForm', () => {
  it('submits successfully with valid credentials', () => {});
  it('displays error message with invalid password', () => {});
});
```

```go
// Go
func TestLogin_ValidCredentials_ReturnsToken(t *testing.T) {}
func TestLogin_InvalidPassword_ReturnsError(t *testing.T) {}
```

## Test Structure (AAA Pattern)

Every test should follow Arrange-Act-Assert:

```python
def test_add_item_to_cart_increases_total():
    # Arrange - set up preconditions
    cart = Cart()
    item = Item(price=10.00)
    
    # Act - perform the action
    cart.add(item)
    
    # Assert - verify the outcome
    assert cart.total == 10.00
```

## What to Test

### Always Test
- Happy path (expected inputs produce expected outputs)
- Edge cases (empty, null, zero, max values)
- Error conditions (invalid inputs, failures)
- Boundary conditions (off-by-one, limits)

### Edge Cases Checklist
- Empty collections ([], {}, "")
- Null/None/undefined values
- Zero and negative numbers
- Maximum values (MAX_INT, very long strings)
- Unicode and special characters
- Whitespace-only strings
- Single-element collections
- Duplicate values

### Don't Test
- Third-party library internals
- Language features (operators, built-ins)
- Private implementation details (test behavior, not implementation)
- Trivial code (simple getters/setters)

## Mocking Strategy

### When to Mock
- External services (APIs, databases, message queues)
- Time-dependent code (use frozen time)
- Randomness (use seeded generators)
- Filesystem operations (in unit tests)
- Expensive operations

### When NOT to Mock
- The unit under test
- Simple data structures
- Pure functions with no side effects

### Mock Principles
- Mock at the boundary, not deep in the stack
- Verify mock interactions when behavior matters
- Prefer fakes over mocks when possible
- Reset mocks between tests

## Test Quality Checklist

- [ ] Tests are independent (no shared state, order doesn't matter)
- [ ] Tests are deterministic (same result every run)
- [ ] Tests are fast (slow tests get skipped)
- [ ] Tests are readable (clear names, simple assertions)
- [ ] Tests document behavior (readable as specifications)
- [ ] Tests fail for the right reason (not false positives)
- [ ] Tests cover edge cases, not just happy paths

## Framework Patterns

### Python (pytest)
```python
import pytest

@pytest.fixture
def client():
    """Create test client."""
    return TestClient(app)

def test_get_user_returns_user(client):
    response = client.get("/users/1")
    assert response.status_code == 200
    assert response.json()["id"] == 1

@pytest.mark.parametrize("input,expected", [
    (0, 0),
    (1, 1),
    (5, 120),
])
def test_factorial(input, expected):
    assert factorial(input) == expected
```

### TypeScript (vitest)
```typescript
import { describe, it, expect, vi } from 'vitest';

describe('UserService', () => {
  it('fetches user by id', async () => {
    const mockFetch = vi.fn().mockResolvedValue({ id: 1, name: 'Test' });
    const service = new UserService(mockFetch);
    
    const user = await service.getUser(1);
    
    expect(user.name).toBe('Test');
    expect(mockFetch).toHaveBeenCalledWith('/users/1');
  });
});
```

### Go
```go
func TestGetUser(t *testing.T) {
    t.Run("returns user for valid ID", func(t *testing.T) {
        repo := &MockUserRepo{
            users: map[int]User{1: {ID: 1, Name: "Test"}},
        }
        service := NewUserService(repo)
        
        user, err := service.GetUser(1)
        
        if err != nil {
            t.Fatalf("unexpected error: %v", err)
        }
        if user.Name != "Test" {
            t.Errorf("got %q, want %q", user.Name, "Test")
        }
    })
}
```

## Coverage Guidelines

- Aim for meaningful coverage, not 100%
- Focus on critical paths and complex logic
- Low coverage in a file indicates undertested code
- High coverage doesn't guarantee quality tests
- Uncovered code should be a discussion point in review

## Avoiding Flaky Tests

Flaky tests erode trust in the test suite. Prevent them:

### Don't Use Sleep for Timing
```python
# Bad - arbitrary sleep
time.sleep(2)
assert task.is_complete

# Good - poll with timeout
for _ in range(20):
    if task.is_complete:
        break
    time.sleep(0.1)
else:
    pytest.fail("Task did not complete in time")
```

### Freeze Time for Time-Dependent Tests
```python
# Python (freezegun)
from freezegun import freeze_time

@freeze_time("2024-01-15 10:00:00")
def test_expiration():
    token = create_token(expires_in=3600)
    assert token.expires_at == datetime(2024, 1, 15, 11, 0, 0)
```

```typescript
// TypeScript (vitest)
import { vi } from 'vitest';

beforeEach(() => {
  vi.useFakeTimers();
  vi.setSystemTime(new Date('2024-01-15T10:00:00Z'));
});

afterEach(() => {
  vi.useRealTimers();
});
```

### Use Fixed Seeds for Randomness
```python
# Bad - random data each run
def test_shuffle():
    result = shuffle([1, 2, 3])
    assert len(result) == 3

# Good - seeded random for reproducibility
def test_shuffle():
    random.seed(42)
    result = shuffle([1, 2, 3])
    assert result == [2, 3, 1]
```

### Isolate Test Data
- Use unique identifiers per test to avoid collisions
- Clean up test data after each test
- Use database transactions that rollback
- Don't rely on test execution order

## Async Testing Patterns

### Python (pytest-asyncio)
```python
import pytest

@pytest.mark.asyncio
async def test_async_fetch():
    result = await fetch_user(1)
    assert result.id == 1

@pytest.fixture
async def async_client():
    async with AsyncClient(app) as client:
        yield client

@pytest.mark.asyncio
async def test_api_endpoint(async_client):
    response = await async_client.get("/users/1")
    assert response.status_code == 200
```

### TypeScript (vitest)
```typescript
it('handles async operations', async () => {
  await expect(fetchUser(1)).resolves.toEqual({ id: 1 });
  await expect(fetchUser(-1)).rejects.toThrow('Not found');
});

it('waits for UI updates', async () => {
  render(<UserProfile userId="1" />);
  
  // Wait for async content
  expect(await screen.findByText('Alice')).toBeInTheDocument();
});
```
