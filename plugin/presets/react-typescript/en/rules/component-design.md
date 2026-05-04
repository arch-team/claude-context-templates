> **Purpose**: Component design standards - Component types, props design, compound component patterns
>
> **Related**: [architecture.md](architecture.md) (FSD layer definitions) | [state-management.md](state-management.md) (component state selection) | [checklist.md](checklist.md) (PR Review checklist)

# Component Design Standards

---

## 0. Quick Reference Card

### Component Type Quick Reference

| Type | Responsibility | Examples | Location |
|------|---------------|----------|----------|
| **Presentational** | Pure UI rendering, stateless | `Button`, `Card`, `Avatar` | `shared/ui/` |
| **Container** | Business logic, data fetching | `TaskList`, `LoginForm` | `features/*/ui/` |
| **Compound** | Multi-component composition, shared state | `Tabs`, `Dropdown`, `Dialog` | `shared/ui/` |

### Component Decision Flow

```
Need to create a component?
    ↓
Contains business logic? ──Yes──► features/{feature}/ui/
    │
   No
    ↓
Is a reusable base component? ──Yes──► shared/ui/
    │
   No
    ↓
Composes multiple features? ──Yes──► widgets/{widget}/ui/
    │
   No
    ↓
Entity base display? ──Yes──► entities/{entity}/ui/
```

### Props Design Quick Reference

| Rule | ✅ Correct | ❌ Wrong |
|------|-----------|---------|
| Use interface | `interface ButtonProps {}` | `type ButtonProps = {}` |
| children type | `children: React.ReactNode` | `children: any` |
| Event naming | `onClick`, `onSubmit` | `click`, `handleClick` |
| Optional properties | `disabled?: boolean` | `disabled: boolean \| undefined` |
| Default values | Destructuring defaults | Defaults in Props definition |


---

## 1. Component Types

### 1.1 Presentational Components

**Key Patterns**: `forwardRef` + `displayName` + Extend native attributes + variant/size

```typescript
// shared/ui/Button/Button.tsx
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  children: React.ReactNode;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'primary', size = 'md', loading, children, className, disabled, ...props }, ref) => (
    <button
      ref={ref}
      className={cn(/* variant + size + state styles */, className)}
      disabled={disabled || loading}
      {...props}
    >
      {loading && <Spinner />}
      {children}
    </button>
  )
);
Button.displayName = 'Button';
```

### 1.2 Container Components

**Key Patterns**: React Query data fetching + loading/error/empty state handling

```typescript
// features/tasks/ui/TaskList.tsx
interface TaskListProps {
  onSelect?: (id: string) => void;
}

export function TaskList({ onSelect }: TaskListProps) {
  const { data: tasks, isLoading, error } = useTasks();

  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!tasks?.length) return <EmptyState />;

  return (
    <div className="grid gap-4">
      {tasks.map((task) => (
        <TaskCard key={task.id} task={task} onClick={() => onSelect?.(task.id)} />
      ))}
    </div>
  );
}
```

### 1.3 Compound Components

**Key Patterns**: Context for shared state + `Object.assign` for combined export

```typescript
// shared/ui/Tabs/Tabs.tsx - structural skeleton
// 1. Context
const TabsContext = createContext<TabsContextValue | null>(null);

// 2. Root component provides Context
function TabsRoot({ defaultValue, children, onChange }: TabsProps) {
  const [activeTab, setActiveTab] = useState(defaultValue);
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      {children}
    </TabsContext.Provider>
  );
}

// 3. Child components consume Context (TabList, Tab, TabPanel each implement)

// 4. Combined export
export const Tabs = Object.assign(TabsRoot, { List: TabList, Tab, Panel: TabPanel });
```

**Usage**:

```tsx
<Tabs defaultValue="tab1" onChange={handleChange}>
  <Tabs.List>
    <Tabs.Tab value="tab1">Tab One</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel value="tab1">Content One</Tabs.Panel>
</Tabs>
```

---

## 2. Advanced Props Patterns

### 2.1 Extending Native Attributes

```typescript
interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

export function Input({ label, error, className, ...props }: InputProps) {
  return (
    <div>
      {label && <label>{label}</label>}
      <input className={cn('...', className)} {...props} />
      {error && <span className="text-red-500">{error}</span>}
    </div>
  );
}
```

**Ref Forwarding**: Use `forwardRef` when ref is needed, and set `displayName` (see Section 1.1)

### 2.2 Generic Components

```typescript
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  keyExtractor: (item: T) => string;
  emptyMessage?: string;
}

export function List<T>({ items, renderItem, keyExtractor, emptyMessage = 'No data' }: ListProps<T>) {
  if (!items.length) return <div>{emptyMessage}</div>;
  return <ul>{items.map((item, i) => <li key={keyExtractor(item)}>{renderItem(item, i)}</li>)}</ul>;
}
```

---

## 3. Custom Hook Return Values

| Scenario | Return Type | Example |
|----------|------------|---------|
| Multiple values | Object | `{ user, isAuthenticated, login, logout }` |
| Similar to useState | Tuple | `[state, toggle]` |
| Single value | Direct return | `debouncedValue` |

---

## 4. Component File Structure

### Single Component

```
Button/
├── index.ts              # export { Button } from './Button';
├── Button.tsx            # Component implementation
├── Button.test.tsx       # Unit test
└── Button.types.ts       # Type definitions (when complex)
```

### Compound Component

```
Tabs/
├── index.ts              # Export Tabs and sub-components
├── Tabs.tsx              # Main component + Context
├── TabList.tsx           # Sub-component
├── Tab.tsx               # Sub-component
├── TabPanel.tsx          # Sub-component
├── Tabs.context.ts       # Context (optional separation)
├── Tabs.types.ts         # Type definitions
└── Tabs.test.tsx         # Tests
```
