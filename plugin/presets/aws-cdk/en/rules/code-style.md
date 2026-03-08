# Code Style Standards

> **Purpose**: Concrete CDK code style practices — code examples, ESLint configuration, and file organization.

---

## 0. Quick Reference Card

### Naming Conventions

| Element | Style | Example |
|---------|-------|---------|
| Stack class | `PascalCase` + `Stack` suffix | `NetworkStack`, `ComputeStack` |
| Construct class | `PascalCase` + descriptive name | `SecureBucket`, `MonitoredApi` |
| Props interface | Class name + `Props` suffix | `NetworkStackProps`, `SecureBucketProps` |
| Construct ID | `PascalCase` descriptive | `'DataBucket'`, `'ApiHandler'` |
| Functions/Variables | `camelCase` | `getEnvironmentConfig`, `vpcCidr` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_AZS`, `DEFAULT_TIMEOUT` |
| Files | `kebab-case.ts` | `network-stack.ts`, `secure-bucket.ts` |
| Directories | `kebab-case` | `stacks/`, `constructs/`, `config/` |

### Construct ID Naming Convention

- **PascalCase**: Describe resource purpose, e.g., `'DataBucket'`, `'ApiHandler'`
- **Prohibited**: Meaningless names (`'bucket1'`), non-PascalCase (`'my-function'`)

### TypeScript Coding Principles

| Rule | Requirement |
|------|-------------|
| Props definition | Use `interface` (extensible), fields use `readonly` |
| Strict mode | `strict: true` |
| Avoid any | Use specific types or `unknown` |
| Enum alternative | Use `as const` objects or union types, avoid `enum` |
| Boolean naming | Use `enable`/`is`/`has` prefix |

### Import Ordering Principle

1. AWS CDK core (`aws-cdk-lib`, `constructs`)
2. AWS CDK modules (`aws-cdk-lib/aws-*`)
3. Third-party libraries
4. Internal project modules
5. Type imports (`import type`, separate line)

### Import Ordering Example

```typescript
// 1. AWS CDK core
import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';

// 2. AWS CDK modules
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as s3 from 'aws-cdk-lib/aws-s3';

// 3. Third-party libraries
import { NagSuppressions } from 'cdk-nag';

// 4. Internal project modules
import { SecureBucket } from '../constructs/secure-bucket';
import { getEnvironmentConfig } from '../config/environments';

// 5. Type imports (separate line)
import type { EnvironmentConfig } from '../config/environments';
```

---

## 1. Naming Conventions

### 1.1 Stack & Construct Naming

```typescript
// ✅ Stack: describe responsibility + Stack suffix
export class NetworkStack extends cdk.Stack { }
export class ComputeStack extends cdk.Stack { }

// ✅ Construct: describe capability, no Construct suffix
export class SecureBucket extends Construct { }
export class MonitoredApi extends Construct { }

// ❌ Wrong naming
export class MyStack extends cdk.Stack { }       // meaningless name
export class BucketConstruct extends Construct { } // redundant suffix
```

### 1.2 Construct ID Naming

```typescript
// ✅ PascalCase, descriptive
const bucket = new s3.Bucket(this, 'DataBucket', { ... });
const fn = new lambda.Function(this, 'ApiHandler', { ... });

// ❌ Wrong
const bucket = new s3.Bucket(this, 'bucket1', { ... });      // not descriptive
const fn = new lambda.Function(this, 'my-function', { ... }); // not PascalCase
```

### 1.3 Props Interface Naming

```typescript
// ✅ Props fields use readonly
export interface ComputeStackProps extends cdk.StackProps {
  readonly vpc: ec2.IVpc;                    // required dependency
  readonly instanceType?: ec2.InstanceType;  // optional config, use ?
  readonly enableMonitoring?: boolean;       // booleans use enable/is/has prefix
}
```

### 1.4 Boolean Naming

| Prefix | Usage | Example |
|--------|-------|---------|
| `enable` | Feature toggle | `enableMonitoring`, `enableEncryption` |
| `is` | State check | `isProduction`, `isPublic` |
| `has` | Ownership check | `hasNatGateway`, `hasCustomDomain` |

---

## 2. TypeScript Standards

### 2.1 Strict Mode (Required)

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}
```

### 2.2 Interface vs Type Decision

| Scenario | Choice |
|----------|--------|
| Props definition | `interface` (extensible) |
| Union types | `type` |
| Mapped types, utility types | `type` |
| Environment configuration | `interface` |

### 2.3 Avoid enum, Use as const

```typescript
// ✅ Correct: as const object
export const STAGE = {
  DEV: 'dev',
  STAGING: 'staging',
  PROD: 'prod',
} as const;
export type Stage = typeof STAGE[keyof typeof STAGE];

// ❌ Avoid: TypeScript enum
enum Stage { DEV = 'dev', STAGING = 'staging', PROD = 'prod' }
```

---

## 3. ESLint Configuration

### 3.1 Recommended Configuration

```javascript
// eslint.config.mjs
import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.strictTypeChecked,
  {
    rules: {
      '@typescript-eslint/no-floating-promises': 'error',
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/explicit-function-return-type': ['error', {
        allowExpressions: true,
      }],
    },
  },
);
```

### 3.2 CDK-Specific Rules

| Rule | Setting | Reason |
|------|---------|--------|
| `no-new` | `off` | CDK uses `new` to create resources and register them to scope |
| `no-explicit-any` | `error` | Ensure type safety in infrastructure code |
| `no-floating-promises` | `error` | Avoid missed async operations |

---

## 4. File Organization

### 4.1 File Naming

| Type | Convention | Example |
|------|-----------|---------|
| Stack file | `{responsibility}-stack.ts` | `network-stack.ts` |
| Construct file | `{capability}.ts` | `secure-bucket.ts` |
| Test file | `{source-file}.test.ts` | `network-stack.test.ts` |
| Config file | `{purpose}.ts` | `environments.ts` |

### 4.2 One Export Per File

```typescript
// ✅ Each file exports one main Stack/Construct
// network-stack.ts
export class NetworkStack extends cdk.Stack { }

// ❌ Avoid multiple Stacks in the same file
export class NetworkStack extends cdk.Stack { }
export class ComputeStack extends cdk.Stack { }
```

### 4.3 Props and Class in Same File

```typescript
// network-stack.ts
export interface NetworkStackProps extends cdk.StackProps {
  readonly vpcCidr: string;
}

export class NetworkStack extends cdk.Stack {
  public readonly vpc: ec2.IVpc;

  constructor(scope: Construct, id: string, props: NetworkStackProps) {
    super(scope, id, props);
    // ...
  }
}
```

---

## Related Documents

| Document | Description |
|----------|-------------|
| [tech-stack.md](tech-stack.md) | TypeScript and toolchain version requirements (SSoT) |
| [architecture.md](architecture.md) | Construct layering and Stack composition patterns |
| [project-structure.md](project-structure.md) | Directory structure standards |
| [testing.md](testing.md) | Testing standards |
