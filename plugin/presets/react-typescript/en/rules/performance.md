> **Purpose**: Performance optimization standards - Code splitting, memoization, list optimization, bundle optimization

# Performance Standards

---

## 0. Quick Reference Card

### Optimization Decision Flow

```
Performance issue?
    ↓
Measure first (React DevTools Profiler / Lighthouse)
    ↓
Identify bottleneck
    ↓
Apply corresponding optimization strategy
    ↓
Measure again to verify
```

### Common Optimizations Quick Reference

| Problem | Solution |
|---------|----------|
| Slow initial load | Code splitting / lazy loading |
| Component re-renders | React.memo / useMemo / useCallback |
| List jank | Virtual list (react-window) |
| Slow image loading | Lazy loading / WebP / compression |
| Slow state updates | Fine-grained state / Selectors |

### Memoization Decision

```
Need memo/useMemo/useCallback?
    ↓
Props passed to a memo'd child component? ──Yes──► useCallback/useMemo
    │
   No
    ↓
Expensive computation (sorting/filtering large arrays)? ──Yes──► useMemo
    │
   No
    ↓
❌ Not needed (premature optimization)
```


---

## 1. Code Splitting

### 1.1 Route-Level Splitting (Mandatory)

```typescript
// app/routes/index.tsx
import { lazy, Suspense } from 'react';
import { Routes, Route } from 'react-router-dom';

const LoginPage = lazy(() => import('@/pages/login'));
const DashboardPage = lazy(() => import('@/pages/dashboard'));

export function AppRoutes() {
  return (
    <Suspense fallback={<Spinner fullScreen />}>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/" element={<DashboardPage />} />
      </Routes>
    </Suspense>
  );
}
```

### 1.2 Other Splitting Rules

| Scenario | Approach |
|----------|----------|
| Large components (editors, charts) | `lazy(() => import('./RichTextEditor'))` + `<Suspense>` |
| Preloading | Trigger `import('@/pages/detail')` on mouse hover for preloading |

---

## 2. Memoization

### ✅/❌ Examples

```typescript
// ✅ Needed - Passing to a memo'd child component
function Parent() {
  const handleClick = useCallback(() => { /* ... */ }, []);
  const config = useMemo(() => ({ theme: 'dark' }), []);
  return <MemoizedChild onClick={handleClick} config={config} />;
}

// ✅ Needed - Expensive computation
function List({ items, filter }: Props) {
  const filtered = useMemo(
    () => items.filter(i => i.status === filter).sort((a, b) => a.name.localeCompare(b.name)),
    [items, filter]
  );
  return <ul>{filtered.map(/* ... */)}</ul>;
}

// ❌ Not needed - Simple computation, not passed to children
function Simple({ a, b }: Props) {
  const sum = a + b; // No need for useMemo
  const handleChange = (e: ChangeEvent) => { /* ... */ }; // No need for useCallback
  return <input onChange={handleChange} />;
}
```

---

## 3. List Optimization

### Rules

| Rule | Description |
|------|-------------|
| Virtual list threshold | >100 items use `react-window` (`FixedSizeList` + `AutoSizer`) |
| Keys must be stable and unique | ✅ `key={item.id}` / ❌ `key={index}` (when list changes) |

---

## 4. State Optimization

```typescript
// ❌ Wrong - Large object state (any field change causes re-render)
const [state, setState] = useState({
  user: null, settings: {}, notifications: [], sidebarOpen: true,
});

// ✅ Correct - Split state
const [user, setUser] = useState(null);
const [sidebarOpen, setSidebarOpen] = useState(true);
```

> See state-management.md Section 2.2 for Zustand Selector optimization

---

## 5. Image Optimization

```tsx
// Native lazy loading (recommended)
<img src={imageUrl} loading="lazy" alt="Description" />

// Responsive images
<img
  src="/image.jpg"
  srcSet="/image-320.jpg 320w, /image-640.jpg 640w"
  sizes="(max-width: 320px) 280px, 600px"
  alt="Description"
  loading="lazy"
/>
```

---

## 6. Performance Metric Targets

| Metric | Target | Description |
|--------|--------|-------------|
| LCP | < 2.5s | Largest Contentful Paint |
| INP | < 200ms | Interaction to Next Paint (replaced FID, became official Core Web Vitals metric 2024.03) |
| CLS | < 0.1 | Cumulative Layout Shift |
| FCP | < 1.8s | First Contentful Paint |
| TTI | < 3.8s | Time to Interactive |

---

## 7. Bundle Optimization

### Tree Shaking

```typescript
// ✅ Correct - Named imports (tree shakeable)
import { debounce } from 'lodash-es';

// ❌ Wrong - Default import of entire library
import _ from 'lodash';
```

**Analysis Tools**: `rollup-plugin-visualizer` for bundle composition visualization
