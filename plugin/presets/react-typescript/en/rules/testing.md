> **Purpose**: Testing standards - TDD workflow, test layering, coverage requirements

# Testing Standards

---

## 0. Quick Reference Card

### Commands

> See [CLAUDE.md](../CLAUDE.md) Section: Testing for test commands

### Naming

| Element | Pattern | Example |
|---------|---------|---------|
| Test file | `{Component}.test.tsx` | `Button.test.tsx` |
| Test suite | `describe('{Component}')` | `describe('Button')` |
| Test case | `it('should {behavior}')` | `it('should render children')` |
| E2E file | `{feature}.spec.ts` | `auth.spec.ts` |

### Layering

| Layer | Coverage | Mock | Tools |
|-------|----------|------|-------|
| Unit | Hook/Component/Utility | External dependencies | Vitest + Testing Library |
| Integration | Page/API integration | External services | Vitest + MSW |
| E2E | User flows | None | Playwright |

### Pitfalls

- ❌ Testing implementation details → ✅ Test behavior
- ❌ `getByTestId` first → ✅ Accessibility queries first
- ❌ Synchronous expectations for async → ✅ `waitFor` / `findBy`


---

## 1. Test File Location

```
# Unit tests - Co-located with components
shared/ui/Button/
├── Button.tsx
└── Button.test.tsx

# E2E tests - Separate directory
tests/
├── e2e/auth.spec.ts
└── fixtures/users.json
```

---

## 2. Component Testing

### 2.1 Basic Template

```typescript
// Button.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';

describe('Button', () => {
  it('should render children', () => {
    render(<Button>Click</Button>);
    expect(screen.getByRole('button', { name: 'Click' })).toBeInTheDocument();
  });

  it('should call onClick', async () => {
    const handleClick = vi.fn();
    const user = userEvent.setup();
    render(<Button onClick={handleClick}>Click</Button>);
    await user.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

### 2.2 Query Priority

```typescript
// ✅ Recommended (by priority)
screen.getByRole('button', { name: 'Submit' });  // 1. Role
screen.getByLabelText('Username');                // 2. Label
screen.getByPlaceholderText('Enter here');        // 3. Placeholder
screen.getByText('Welcome');                      // 4. Text
// ❌ Last resort
screen.getByTestId('custom-element');
```

### 2.3 Async Testing

```typescript
it('should load data', async () => {
  render(<AsyncComponent />);
  expect(await screen.findByText('Loading complete')).toBeInTheDocument();
});
```

---

## 3. Hook Testing

```typescript
import { renderHook, act } from '@testing-library/react';
import { vi, beforeEach, afterEach } from 'vitest';

describe('useDebounce', () => {
  beforeEach(() => vi.useFakeTimers());
  afterEach(() => vi.useRealTimers());

  it('should debounce value', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, 500),
      { initialProps: { value: 'hello' } }
    );
    rerender({ value: 'world' });
    expect(result.current).toBe('hello');
    act(() => vi.advanceTimersByTime(500));
    expect(result.current).toBe('world');
  });
});
```

---

## 4. API Mock (MSW)

### 4.1 Configuration

```typescript
// tests/mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/v1/tasks', () => HttpResponse.json([{ id: '1', name: 'Task 1' }])),
  http.post('/api/v1/auth/login', async ({ request }) => {
    const body = await request.json();
    return body.email === 'test@example.com'
      ? HttpResponse.json({ token: 'fake-token' })
      : HttpResponse.json({ message: 'Error' }, { status: 401 });
  }),
];

// tests/mocks/server.ts
import { setupServer } from 'msw/node';
export const server = setupServer(...handlers);

// tests/setup.ts
beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### 4.2 Integration Testing

```typescript
// Test wrapper
function renderWithProviders(ui: React.ReactElement) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(<QueryClientProvider client={queryClient}>{ui}</QueryClientProvider>);
}

describe('LoginForm', () => {
  it('should handle error', async () => {
    server.use(http.post('/api/v1/auth/login', () => HttpResponse.json({ message: 'Error' }, { status: 401 })));
    const user = userEvent.setup();
    renderWithProviders(<LoginForm onSuccess={vi.fn()} />);
    await user.type(screen.getByLabelText('Email'), 'wrong@example.com');
    await user.type(screen.getByLabelText('Password'), 'wrongpass');
    await user.click(screen.getByRole('button', { name: 'Login' }));
    await waitFor(() => expect(screen.getByText(/Error/)).toBeInTheDocument());
  });
});
```

---

## 5. E2E Testing (Playwright)

### 5.1 Basic Template

```typescript
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('should login', async ({ page }) => {
    await page.goto('/login');
    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: 'Login' }).click();
    await expect(page).toHaveURL('/');
  });
});
```

### 5.2 Page Object Pattern

```typescript
export class LoginPage {
  constructor(private page: Page) {}
  readonly emailInput = () => this.page.getByLabel('Email');
  readonly passwordInput = () => this.page.getByLabel('Password');
  readonly submitButton = () => this.page.getByRole('button', { name: 'Login' });

  async goto() { await this.page.goto('/login'); }
  async login(email: string, password: string) {
    await this.emailInput().fill(email);
    await this.passwordInput().fill(password);
    await this.submitButton().click();
  }
}
```

---

## 6. Test Configuration

> Vitest and Playwright configuration files are located at the project root (`vitest.config.ts`, `playwright.config.ts`). Refer to official documentation for specific configuration options.

---

## 7. Coverage Requirements

| Layer | Minimum | Target |
|-------|---------|--------|
| Hooks | 90% | 95% |
| Components | {{COVERAGE_MIN}}% | 85% |
| Utils | 95% | 100% |
| **Overall** | **{{COVERAGE_MIN}}%** | **85%** |
