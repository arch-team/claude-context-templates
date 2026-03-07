> **Purpose**: State management standards - React Query (server), Zustand (client), form state

# State Management Standards

---

## 0. Quick Reference Card

### State Type Decision

| Data Type | Recommended Solution | Examples |
|-----------|---------------------|----------|
| Server data | React Query | User list, task details |
| Global UI state | Zustand | Theme, sidebar expanded state |
| User session | Zustand (in-memory) | Login state, token (never persist sensitive data) |
| Form state | React Hook Form | Login form, settings form |
| Component local state | useState | Dropdown toggle |
| Complex component state | useReducer | Multi-step wizard |

### Decision Flow

```
Data from API? ──Yes──► React Query (TanStack Query)
      │
     No
      ↓
Needs cross-component sharing? ──Yes──► Zustand Store
      │                    ↓
     No              Needs persistence? ──Yes──► Zustand + persist (⚠️ Never persist tokens or sensitive data)
      ↓
Complex component state? ──Yes──► useReducer
      │
     No
      ↓
useState
```

### File Location Quick Reference

| State Type | Location |
|-----------|----------|
| Feature-related API | `features/{feature}/api/queries.ts` |
| Feature Store | `features/{feature}/model/store.ts` |
| Global Store | `shared/store/{store}.ts` |
| Entity types | `entities/{entity}/model/types.ts` |


---

## 1. React Query (Server State)

### 1.1 Basic Configuration

```typescript
// app/providers/QueryProvider.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,  // 5 minutes
      gcTime: 1000 * 60 * 30,    // 30 minutes
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

export function QueryProvider({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
}
```

### 1.2 Query Keys Convention

```typescript
// features/tasks/api/queries.ts - Key Factory pattern
export const taskKeys = {
  all: ['tasks'] as const,
  lists: () => [...taskKeys.all, 'list'] as const,
  list: (filters: TaskFilters) => [...taskKeys.lists(), filters] as const,
  details: () => [...taskKeys.all, 'detail'] as const,
  detail: (id: string) => [...taskKeys.details(), id] as const,
};
```

### 1.3 Query/Mutation Template

```typescript
// List query
export function useTasks(filters?: TaskFilters) {
  return useQuery({
    queryKey: taskKeys.list(filters ?? {}),
    queryFn: async () => {
      const { data } = await apiClient.get<Task[]>('/api/v1/tasks', { params: filters });
      return data;
    },
  });
}

// Mutation + cache invalidation
export function useCreateTask() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (dto: CreateTaskDTO) => apiClient.post<Task>('/api/v1/tasks', dto).then(r => r.data),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: taskKeys.lists() }),
  });
}

// Detail query follows same pattern, key point: enabled: !!id to prevent empty requests
// Update/delete mutation key points:
// - onSuccess: invalidateQueries to invalidate list
// - onSuccess: setQueryData to update detail cache
// - onSuccess: removeQueries to delete cache
```

### 1.4 Optimistic Update Pattern

> Pattern: `onMutate`(cancelQueries → save old data → setQueryData) → `onError`(rollback) → `onSettled`(invalidateQueries)

---

## 2. Zustand (Client State)

### 2.1 Store Template (Auth Example - In-Memory Storage)

> **Security Note**: Tokens and sensitive data **must never** be stored in localStorage (XSS can read it).
> Prefer httpOnly Cookie (requires backend support) or in-memory storage. See [security.md](security.md) Section 3.

```typescript
// features/auth/model/store.ts
import { create } from 'zustand';

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  setUser: (user: User | null) => void;
  setToken: (token: string | null) => void;
  logout: () => void;
}

// Token only saved in memory; page refresh requires re-authentication (more secure)
export const useAuthStore = create<AuthState>()((set) => ({
  user: null,
  token: null,
  isAuthenticated: false,
  setUser: (user) => set({ user, isAuthenticated: !!user }),
  setToken: (token) => set({ token }),
  logout: () => set({ user: null, token: null, isAuthenticated: false }),
}));
```

**When persisting non-sensitive state**: Use `persist` middleware, but **never persist tokens**

```typescript
import { persist, createJSONStorage } from 'zustand/middleware';

export const useUIStore = create<UIState>()(
  persist(
    (set) => ({ /* non-sensitive state */ }),
    {
      name: 'ui-storage',
      storage: createJSONStorage(() => localStorage),
    }
  )
);
```

### 2.2 Selector Hooks (Performance Critical)

```typescript
// Fine-grained selectors - avoid unnecessary re-renders
export const useAuth = () =>
  useAuthStore((state) => ({
    user: state.user,
    isAuthenticated: state.isAuthenticated,
  }));

export const useAuthToken = () => useAuthStore((state) => state.token);

export const useAuthActions = () =>
  useAuthStore((state) => ({
    setUser: state.setUser,
    setToken: state.setToken,
    logout: state.logout,
  }));
```

---

## 3. React Hook Form (Form State)

```typescript
// features/auth/ui/LoginForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const loginSchema = z.object({
  email: z.string().email('Please enter a valid email'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

type LoginFormData = z.infer<typeof loginSchema>;

export function LoginForm() {
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => { /* call mutation */ };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <label htmlFor="email">Email</label>
      <input
        id="email"
        {...register('email')}
        aria-invalid={!!errors.email}
        aria-describedby={errors.email ? 'email-error' : undefined}
      />
      {errors.email && (
        <span id="email-error" role="alert">{errors.email.message}</span>
      )}

      <label htmlFor="password">Password</label>
      <input
        id="password"
        type="password"
        {...register('password')}
        aria-invalid={!!errors.password}
        aria-describedby={errors.password ? 'password-error' : undefined}
      />
      {errors.password && (
        <span id="password-error" role="alert">{errors.password.message}</span>
      )}

      <button type="submit" disabled={isSubmitting}>Login</button>
    </form>
  );
}
```

---

## 4. Best Practices

```typescript
// ❌ Wrong - Put everything in global state
const useStore = create((set) => ({
  modalOpen: false,        // Should be component state
  formData: {},            // Should use React Hook Form
  users: [],               // Should use React Query
}));

// ✅ Correct - Only put truly shared global state in Zustand
const useUIStore = create((set) => ({
  sidebarOpen: true,       // Genuinely needs cross-component sharing
  theme: 'light',          // Genuinely needs cross-component sharing
}));
```
