---
name: typescript
description: TypeScript and React/TSX coding conventions and patterns
---

# TypeScript Skill

Use this skill when working with TypeScript or TSX code.

## Required Practices

These rules must always be followed:

### No `any` Type
```typescript
// Bad - loses all type safety
function process(data: any): any {
  return data.value;
}

const result: any = fetchData();

// Good - use proper types
function process(data: { value: string }): string {
  return data.value;
}

// Good - use unknown when type is truly unknown
function parseJson(input: string): unknown {
  return JSON.parse(input);
}

// Good - use generics for flexible types
function first<T>(items: T[]): T | undefined {
  return items[0];
}
```

### Named Exports Only (No Default Exports)
```typescript
// Bad - default exports
export default function Button() { ... }
export default class UserService { ... }

// Good - named exports
export function Button() { ... }
export class UserService { ... }

// Good - multiple exports from a file
export { Button, ButtonProps };
export { UserService, UserRepository };
```

Why: Named exports provide better refactoring support, clearer imports, and prevent naming inconsistencies.

```typescript
// With named exports, the import must match
import { Button } from './Button';  // Clear what you're importing

// With default exports, you can use any name
import Btn from './Button';  // Confusing - is this really Button?
```

### Functional Components with Hooks
```tsx
// Bad - class components
class UserProfile extends React.Component<Props, State> {
  state = { loading: true };
  
  componentDidMount() {
    this.fetchUser();
  }
  
  render() {
    return <div>{this.state.user?.name}</div>;
  }
}

// Good - functional component with hooks
export function UserProfile({ userId }: UserProfileProps) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchUser(userId).then(setUser).finally(() => setLoading(false));
  }, [userId]);

  if (loading) return <Spinner />;
  return <div>{user?.name}</div>;
}
```

## Type Patterns

### Interface vs Type
```typescript
// Use interface for object shapes (extendable)
interface User {
  id: string;
  name: string;
  email: string;
}

interface AdminUser extends User {
  permissions: string[];
}

// Use type for unions, primitives, and complex types
type Status = 'pending' | 'active' | 'inactive';
type UserId = string;
type UserOrNull = User | null;
type Callback = (user: User) => void;
```

### Props Types
```tsx
// Define props interface with component
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

export function Button({ 
  label, 
  onClick, 
  variant = 'primary',
  disabled = false,
}: ButtonProps) {
  return (
    <button 
      className={`btn-${variant}`}
      onClick={onClick}
      disabled={disabled}
    >
      {label}
    </button>
  );
}
```

### Children Props
```tsx
import { ReactNode } from 'react';

interface CardProps {
  title: string;
  children: ReactNode;
}

export function Card({ title, children }: CardProps) {
  return (
    <div className="card">
      <h2>{title}</h2>
      {children}
    </div>
  );
}
```

### Generic Components
```tsx
interface ListProps<T> {
  items: T[];
  renderItem: (item: T) => ReactNode;
  keyExtractor: (item: T) => string;
}

export function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <ul>
      {items.map((item) => (
        <li key={keyExtractor(item)}>{renderItem(item)}</li>
      ))}
    </ul>
  );
}

// Usage
<List
  items={users}
  renderItem={(user) => <span>{user.name}</span>}
  keyExtractor={(user) => user.id}
/>
```

## React Patterns

### Custom Hooks
```tsx
// Extract reusable logic into custom hooks
export function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    setLoading(true);
    setError(null);
    
    fetchUser(userId)
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [userId]);

  return { user, loading, error };
}

// Usage
export function UserProfile({ userId }: { userId: string }) {
  const { user, loading, error } = useUser(userId);
  
  if (loading) return <Spinner />;
  if (error) return <Error message={error.message} />;
  if (!user) return <NotFound />;
  
  return <div>{user.name}</div>;
}
```

### Event Handlers
```tsx
interface FormProps {
  onSubmit: (data: FormData) => void;
}

export function LoginForm({ onSubmit }: FormProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    onSubmit({ email, password });
  };

  const handleEmailChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setEmail(e.target.value);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input type="email" value={email} onChange={handleEmailChange} />
      <input 
        type="password" 
        value={password} 
        onChange={(e) => setPassword(e.target.value)} 
      />
      <button type="submit">Login</button>
    </form>
  );
}
```

### Conditional Rendering
```tsx
export function UserStatus({ user }: { user: User | null }) {
  // Early return for null case
  if (!user) {
    return <GuestBanner />;
  }

  // Ternary for simple conditions
  return (
    <div>
      <span>{user.isAdmin ? 'Admin' : 'User'}</span>
      
      {/* Logical AND for optional elements */}
      {user.unreadCount > 0 && (
        <Badge count={user.unreadCount} />
      )}
    </div>
  );
}
```

## Utility Types

```typescript
// Partial - all properties optional
type UserUpdate = Partial<User>;

// Required - all properties required
type CompleteUser = Required<User>;

// Pick - select specific properties
type UserPreview = Pick<User, 'id' | 'name'>;

// Omit - exclude specific properties
type UserWithoutId = Omit<User, 'id'>;

// Record - key-value map
type UserRoles = Record<string, 'admin' | 'user' | 'guest'>;

// ReturnType - infer return type
type FetchResult = ReturnType<typeof fetchUser>;

// Parameters - infer parameter types
type FetchParams = Parameters<typeof fetchUser>;
```

## Error Handling

```typescript
// Define error types
interface ApiError {
  code: string;
  message: string;
  field?: string;
}

// Type guard for errors
function isApiError(error: unknown): error is ApiError {
  return (
    typeof error === 'object' &&
    error !== null &&
    'code' in error &&
    'message' in error
  );
}

// Usage
try {
  await createUser(data);
} catch (error) {
  if (isApiError(error)) {
    showFieldError(error.field, error.message);
  } else {
    showGenericError('An unexpected error occurred');
  }
}
```

## File Organization

```
src/
├── components/
│   ├── Button/
│   │   ├── Button.tsx        # Component
│   │   ├── Button.test.tsx   # Tests
│   │   └── index.ts          # Re-export
│   └── index.ts              # Barrel export
├── hooks/
│   ├── useUser.ts
│   └── index.ts
├── services/
│   ├── api.ts
│   └── userService.ts
├── types/
│   ├── user.ts
│   └── index.ts
└── utils/
    ├── format.ts
    └── validate.ts
```

### Barrel Exports
```typescript
// components/Button/index.ts
export { Button } from './Button';
export type { ButtonProps } from './Button';

// components/index.ts
export { Button } from './Button';
export { Card } from './Card';
export { Modal } from './Modal';
```

## Style Reference

For additional TypeScript conventions, refer to:
- Google TypeScript Style Guide: https://google.github.io/styleguide/tsguide.html
- React TypeScript Cheatsheet: https://react-typescript-cheatsheet.netlify.app/

## Strict TypeScript Config

Always enable strict mode in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true
  }
}
```

These catch bugs at compile time that would otherwise surface at runtime.

## Discriminated Unions

Use discriminated unions for type-safe branching:

```typescript
// Result type for operations that can fail
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

function handleResult(result: Result<User>) {
  if (result.success) {
    console.log(result.data.name);  // TypeScript knows data exists
  } else {
    console.error(result.error);    // TypeScript knows error exists
  }
}

// API response states
type ApiState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: string };

function renderState(state: ApiState<User>) {
  switch (state.status) {
    case 'idle': return null;
    case 'loading': return <Spinner />;
    case 'success': return <UserCard user={state.data} />;
    case 'error': return <Error message={state.error} />;
  }
}
```

## Exhaustive Switch Statements

Ensure all cases are handled at compile time:

```typescript
type Status = 'pending' | 'active' | 'cancelled';

function getLabel(status: Status): string {
  switch (status) {
    case 'pending': return 'Pending';
    case 'active': return 'Active';
    case 'cancelled': return 'Cancelled';
    default:
      // Compile error if a case is missing
      const _exhaustive: never = status;
      return _exhaustive;
  }
}
```

## Runtime Validation with Zod

Use Zod for validating external data (API responses, form input):

```typescript
import { z } from 'zod';

// Define schema
const UserSchema = z.object({
  id: z.number(),
  email: z.string().email(),
  name: z.string().min(1).max(100),
  role: z.enum(['admin', 'user', 'guest']),
  createdAt: z.string().datetime(),
});

// Infer TypeScript type from schema
type User = z.infer<typeof UserSchema>;

// Validate at runtime
function parseUser(data: unknown): User {
  return UserSchema.parse(data);  // Throws ZodError if invalid
}

// Safe parsing (no throw)
function tryParseUser(data: unknown): User | null {
  const result = UserSchema.safeParse(data);
  return result.success ? result.data : null;
}

// Validate API response
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  const data = await response.json();
  return UserSchema.parse(data);  // Validated!
}
```

## Const Assertions

Use `as const` for literal types:

```typescript
// Array of literal types
const ROLES = ['admin', 'user', 'guest'] as const;
type Role = typeof ROLES[number];  // 'admin' | 'user' | 'guest'

// Object with literal values
const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  NOT_FOUND: 404,
} as const;

type StatusCode = typeof HTTP_STATUS[keyof typeof HTTP_STATUS];  // 200 | 201 | 400 | 404

// Config objects
const CONFIG = {
  apiUrl: '/api',
  timeout: 5000,
  retries: 3,
} as const;
// CONFIG.timeout is type 5000, not number
```

## Data Fetching with React Query

Use TanStack Query for server state:

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Query hook
export function useUser(id: string) {
  return useQuery({
    queryKey: ['user', id],
    queryFn: () => fetchUser(id),
    staleTime: 5 * 60 * 1000,  // 5 minutes
  });
}

// Mutation hook
export function useUpdateUser() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: updateUser,
    onSuccess: (data, variables) => {
      // Invalidate and refetch
      queryClient.invalidateQueries({ queryKey: ['user', variables.id] });
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}

// Usage in component
export function UserProfile({ id }: { id: string }) {
  const { data: user, isLoading, error } = useUser(id);
  const updateUser = useUpdateUser();

  if (isLoading) return <Spinner />;
  if (error) return <Error message={error.message} />;
  if (!user) return <NotFound />;

  return (
    <form onSubmit={(e) => {
      e.preventDefault();
      updateUser.mutate({ id, name: newName });
    }}>
      {/* form content */}
    </form>
  );
}
```
