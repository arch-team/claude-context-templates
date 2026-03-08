# Accessibility Standards

> **Purpose**: Accessibility standards - POUR principles, WCAG standards, ARIA guidelines, form patterns, focus management code

---

## POUR Principles

| Principle | Description | Example |
|-----------|-------------|---------|
| **Perceivable** | Information can be perceived by users | Images have alt, videos have captions |
| **Operable** | Interface can be operated by users | Keyboard accessible, no time limits |
| **Understandable** | Content can be understood by users | Clear labels, consistent navigation |
| **Robust** | Compatible with assistive technologies | Semantic HTML, ARIA |

---

## WCAG 2.1 AA Compliance Standards

### Visual Standards

| Rule | Requirement |
|------|-------------|
| Text contrast | >= 4.5:1 (normal text), >= 3:1 (large text) |
| Not color-only | Use color + icon + text combination to distinguish states |
| Focus styles | Never remove `outline: none`; `:focus-visible` must remain visible |

### Semantic Standards

| Scenario | Correct | Wrong |
|----------|---------|-------|
| Page structure | `<header>`, `<main>`, `<footer>` | `<div class="header">` |
| Navigation | `<nav>` | `<div class="nav">` |
| Actions | `<button onClick={}>` | `<div onClick={}>` |
| Page navigation | `<a href="">`, `<Link to="">` | `<a href="#" onClick={}>` |

---

## ARIA Usage Guidelines

| Attribute | Purpose | Example |
|-----------|---------|---------|
| `aria-label` | Provides a label for an element | `<button aria-label="Close">x</button>` |
| `aria-labelledby` | References another element as label | `<div aria-labelledby="title-id">` |
| `aria-describedby` | References descriptive text | `<input aria-describedby="error-id">` |
| `aria-hidden` | Hides from accessibility tree | `<span aria-hidden="true">icon</span>` |
| `aria-expanded` | Expand/collapse state | `<button aria-expanded="true">` |
| `aria-current` | Current item marker | `<a aria-current="page">` |
| `aria-invalid` | Invalid input state | `<input aria-invalid="true">` |
| `aria-required` | Required field | `<input aria-required="true">` |

---

## Keyboard Navigation Requirements

| Scenario | Requirement |
|----------|-------------|
| Modal opens | Focus moves to first interactive element inside the modal |
| Modal closes | Focus returns to the trigger element |
| Focus trap | Tab cycles within modal, does not escape to background |
| Skip link | Provide a "Skip to main content" link at the top of the page |
| Focus styles | Never remove `outline`; `:focus-visible` must remain visible |

---

## Alt Text Rules

| Image Type | Alt Handling | Example |
|------------|-------------|---------|
| Meaningful image | Descriptive text | `alt="User avatar: default icon"` |
| Decorative image | Empty alt | `alt=""` |
| Functional image | Describe function | `alt="Search"` |
| SVG icon | `aria-hidden` or `role="img"` | `<svg aria-hidden="true">` |

---

## 1. Form Accessibility

### 2.1 Label Association

```tsx
// ✅ Explicit association
<label htmlFor="email">Email</label>
<input id="email" type="email" />

// ✅ Use aria-label when no visible label
<input type="search" aria-label="Search" placeholder="Search..." />

// ❌ Wrong - placeholder is not a label
<input type="email" placeholder="Email" />
```

### 2.2 Error Message Key Pattern

Error messages must use the following three ARIA attribute combination:

```tsx
<input
  id={id}
  aria-invalid={!!error}              // Mark invalid state
  aria-describedby={error ? errorId : undefined}  // Associate error message
/>
{error && (
  <span id={errorId} role="alert">    // role="alert" auto-notifies screen readers
    {error}
  </span>
)}
```

### 2.3 Required Fields

```tsx
<label htmlFor="name">
  Name
  <span aria-hidden="true" className="text-red-500">*</span>
</label>
<input id="name" required aria-required="true" />
```

---

## 2. ARIA Patterns

### 3.1 Icon Buttons

```tsx
// ✅ Correct - aria-label describes the function
<button aria-label="Close dialog" onClick={onClose}>
  <CloseIcon aria-hidden="true" />
</button>

// ❌ Wrong - no label
<button onClick={onClose}>
  <CloseIcon />
</button>
```

### 3.2 Custom Component ARIA Attributes

| Component | Required Attributes | Optional Attributes |
|-----------|-------------------|-------------------|
| **Dropdown** | `role="listbox"`, `aria-expanded`, `aria-labelledby` | `aria-activedescendant` |
| **Option** | `role="option"`, `aria-selected` | - |
| **Tab** | `role="tab"`, `aria-selected`, `aria-controls` | `tabIndex` |
| **TabPanel** | `role="tabpanel"`, `aria-labelledby` | `hidden` |
| **TabList** | `role="tablist"`, `aria-label` | - |
| **Dialog** | `role="dialog"`, `aria-modal`, `aria-labelledby` | `aria-describedby` |

---

## 3. Keyboard Navigation Implementation

### Focus Management Rules

| Scenario | Requirement |
|----------|-------------|
| Modal opens | Focus moves to first interactive element inside the modal |
| Modal closes | Focus returns to the trigger element |
| Focus trap | Tab cycles within modal, does not escape to background (use `@headlessui/react` FocusTrap) |
| Skip link | Provide a "Skip to main content" link at the top of the page, `<main id="main-content" tabIndex={-1}>` |
| Focus styles | Never remove `outline: none`; `:focus-visible` must remain visible |

---

## 4. Visual Accessibility Implementation

### Color Rules

| Rule | Requirement |
|------|-------------|
| Text contrast | >= 4.5:1 (normal text), >= 3:1 (large text) |
| Not color-only | Use color + icon + text combination to distinguish states |

```tsx
// ✅ Correct - color + icon + text
<span>{status === 'active' ? '● Active' : '○ Inactive'}</span>

// ❌ Wrong - color only to distinguish
<span className={status === 'active' ? 'text-green-500' : 'text-red-500'}>Status</span>
```

### Focus Styles

```css
/* Ensure focus is visible */
:focus-visible {
  outline: 2px solid #2563eb;
  outline-offset: 2px;
}

/* ❌ Never remove focus styles */
/* :focus { outline: none; } */
```
