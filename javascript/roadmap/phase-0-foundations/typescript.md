# TypeScript

[← Back to Phase 0](README.md) | [Roadmap](../README.md)

## Why TypeScript is Mandatory

As a .NET/Python engineer you live in strongly typed environments. TypeScript gives you:

- Compile-time safety in JavaScript (mirrors C# type system)
- First-class IDE support (IntelliSense, refactoring, go-to-definition)
- Self-documenting APIs (interfaces serve as contracts)
- Generics for reusable, type-safe utilities
- Better collaboration at scale — types are documentation

> TypeScript compiles to plain JavaScript. Zero runtime overhead.

---

## Setup

```bash
npm install -D typescript
npx tsc --init        # generates tsconfig.json

# Recommended tsconfig.json flags
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,          // enables all strict checks — always enable
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "skipLibCheck": true,
    "esModuleInterop": true
  }
}
```

---

## Interfaces

Define the shape of objects — equivalent to C# interfaces or Python dataclass/Protocol.

```typescript
interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'editor' | 'viewer';  // literal union
  createdAt: Date;
  deletedAt?: Date;                       // optional property
}

// Extending interfaces (composition)
interface AdminUser extends User {
  permissions: string[];
  department: string;
}

// Interface vs type alias — use interface for objects, type for unions/tuples
```

---

## Type Aliases

```typescript
// Union types
type Status = 'idle' | 'loading' | 'success' | 'error';
type ID = string | number;

// Tuple types (fixed-length arrays)
type Coordinate = [lat: number, lng: number];
type HookResult = [value: string, setValue: (v: string) => void];

// Function types
type Predicate<T> = (item: T) => boolean;
type AsyncFetcher<T> = (id: string) => Promise<T>;

// Discriminated unions (powerful pattern for state machines)
type RequestState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };
```

---

## Generics

```typescript
// Generic function — mirrors C# generics
function first<T>(arr: T[]): T | undefined {
  return arr[0];
}

// Generic interface — data container / repository pattern
interface Repository<T extends { id: string }> {
  findById(id: string): Promise<T | null>;
  findAll(filter?: Partial<T>): Promise<T[]>;
  save(entity: T): Promise<T>;
  delete(id: string): Promise<void>;
}

// Generic React component
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  keyExtractor: (item: T) => string;
}

function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <ul>
      {items.map((item, i) => (
        <li key={keyExtractor(item)}>{renderItem(item, i)}</li>
      ))}
    </ul>
  );
}
```

---

## Utility Types

TypeScript ships built-in utilities that map well to common backend patterns:

```typescript
interface Product {
  id: string;
  name: string;
  price: number;
  description: string;
  stock: number;
}

// Partial — all fields optional (useful for PATCH endpoints)
type ProductPatch = Partial<Product>;

// Required — all fields required (opposite of Partial)
type FullProduct = Required<Product>;

// Pick — select subset of fields (like SQL SELECT)
type ProductSummary = Pick<Product, 'id' | 'name' | 'price'>;

// Omit — exclude fields (like excluding PK from a DTO)
type CreateProductDto = Omit<Product, 'id'>;

// Readonly — immutable version (good for config objects)
type ProductConfig = Readonly<Product>;

// Record — typed map / dictionary
type ProductMap = Record<string, Product>;
type StatusMessages = Record<Status, string>;

// ReturnType — infer return type of a function
type UserDto = ReturnType<typeof mapUserToDto>;

// Awaited — unwrap Promise type
type UserData = Awaited<ReturnType<typeof fetchUser>>;
```

---

## Enums

```typescript
// Numeric enum
enum Direction {
  Up = 0,
  Down = 1,
  Left = 2,
  Right = 3,
}

// String enum (preferred — serializes cleanly to JSON)
enum Environment {
  Development = 'development',
  Staging = 'staging',
  Production = 'production',
}

// Const enum — inlined at compile time (zero runtime cost)
const enum HttpMethod {
  GET = 'GET',
  POST = 'POST',
  PUT = 'PUT',
  DELETE = 'DELETE',
}
```

---

## Type Guards

```typescript
// typeof guard
function process(value: string | number) {
  if (typeof value === 'string') {
    return value.toUpperCase();
  }
  return value.toFixed(2);
}

// instanceof guard
function handleError(error: unknown) {
  if (error instanceof ApiError) {
    return error.statusCode;
  }
  if (error instanceof Error) {
    return 500;
  }
  throw error;
}

// Custom type guard (user-defined predicate)
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'email' in obj
  );
}

// Discriminated union narrowing (exhaustiveness checking)
function handleState<T>(state: RequestState<T>): T | null {
  switch (state.status) {
    case 'idle':
    case 'loading':
      return null;
    case 'success':
      return state.data;   // TypeScript knows data exists here
    case 'error':
      throw state.error;   // TypeScript knows error exists here
  }
}
```

---

## Declaration Merging & Module Augmentation

```typescript
// Extending third-party types (e.g., add custom property to Express Request)
declare global {
  namespace Express {
    interface Request {
      user?: AuthenticatedUser;
      requestId: string;
    }
  }
}

// Augmenting environment variables (Vite/Next.js)
interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  readonly VITE_AUTH_DOMAIN: string;
}
```

---

## Strict Mode Gotchas

```typescript
// With strict: true, these patterns require attention:

// 1. Strict null checks — no implicit null/undefined
let user: User;         // error: used before assigned
let user: User | null = null;  // correct

// 2. No implicit any
function process(data) { ... }          // error
function process(data: unknown) { ... } // correct

// 3. strictFunctionTypes — parameter contravariance
// 4. strictPropertyInitialization — class fields must be initialized

class UserService {
  private readonly db: Database;    // error without constructor init

  constructor(db: Database) {
    this.db = db;                   // correct
  }
}
```

---

## Practice Exercises

1. Model your existing .NET DTOs/entities as TypeScript interfaces
2. Create a generic `Result<T, E>` type (Rust-style error handling)
3. Build a typed API client with proper request/response types
4. Implement a type-safe event emitter with generic event maps
5. Write utility types: `DeepPartial<T>`, `NonNullable<T>`, `Flatten<T[]>`

---

## Resources

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [TypeScript Playground](https://www.typescriptlang.org/play)
- [Total TypeScript](https://www.totaltypescript.com/) — advanced patterns
- [Type Challenges](https://github.com/type-challenges/type-challenges) — exercises

---

→ [Phase 0 Overview](README.md) | [Phase 1 – React Core](../phase-1-react-core/README.md)
