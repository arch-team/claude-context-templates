> **职责**: 代码风格规范 - CDK TypeScript 命名约定、Construct 类设计、导入排序

# CDK 代码风格规范 (Code Style Standards)

---

## 0. 速查卡片

### 命名速查

| 元素 | 样式 | 示例 |
|------|------|------|
| Stack 类 | `PascalCase` + `Stack` 后缀 | `NetworkStack`, `ComputeStack` |
| Construct 类 | `PascalCase` + 描述性名称 | `SecureBucket`, `MonitoredApi` |
| Props 接口 | 类名 + `Props` 后缀 | `NetworkStackProps`, `SecureBucketProps` |
| Construct ID | `PascalCase` 描述性 | `'DataBucket'`, `'ApiHandler'` |
| 函数/变量 | `camelCase` | `getEnvironmentConfig`, `vpcCidr` |
| 常量 | `UPPER_SNAKE_CASE` | `MAX_AZS`, `DEFAULT_TIMEOUT` |
| 类型/接口 | `PascalCase` | `EnvironmentConfig`, `DeploymentStage` |
| 文件 (Stack) | `kebab-case.ts` | `network-stack.ts`, `compute-stack.ts` |
| 文件 (Construct) | `kebab-case.ts` | `secure-bucket.ts`, `monitored-api.ts` |
| 目录 | `kebab-case` | `stacks/`, `constructs/`, `config/` |

### TypeScript 速查

| 规则 | ✅ 正确 | ❌ 错误 |
|------|--------|--------|
| Props 定义 | `interface ComputeStackProps extends StackProps {}` | `type ComputeStackProps = {}` |
| Props 字段 | `readonly vpc: ec2.IVpc` | `vpc: ec2.IVpc` (缺少 readonly) |
| 避免 any | 具体类型 / `unknown` | `any` |
| 严格模式 | `strict: true` | `strict: false` |
| 枚举替代 | `as const` 对象或联合类型 | `enum` |

### 导入排序

```typescript
// 1. AWS CDK 核心
import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';

// 2. AWS CDK 模块
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as s3 from 'aws-cdk-lib/aws-s3';

// 3. 第三方库
import { NagSuppressions } from 'cdk-nag';

// 4. 项目内部模块
import { SecureBucket } from '../constructs/secure-bucket';
import { getEnvironmentConfig } from '../config/environments';

// 5. 类型导入 (单独行)
import type { EnvironmentConfig } from '../config/environments';
```

---

## 1. 命名规范

### 1.1 Stack 与 Construct 命名

```typescript
// ✅ Stack: 描述职责 + Stack 后缀
export class NetworkStack extends cdk.Stack { }
export class ComputeStack extends cdk.Stack { }

// ✅ Construct: 描述能力，不加 Construct 后缀
export class SecureBucket extends Construct { }
export class MonitoredApi extends Construct { }

// ❌ 错误命名
export class MyStack extends cdk.Stack { }       // 无意义名称
export class BucketConstruct extends Construct { } // 冗余后缀
```

### 1.2 Construct ID 命名

```typescript
// ✅ PascalCase，描述性
const bucket = new s3.Bucket(this, 'DataBucket', { ... });
const fn = new lambda.Function(this, 'ApiHandler', { ... });

// ❌ 错误
const bucket = new s3.Bucket(this, 'bucket1', { ... });      // 不描述用途
const fn = new lambda.Function(this, 'my-function', { ... }); // 不是 PascalCase
```

### 1.3 Props 接口命名

```typescript
// ✅ Props 字段用 readonly
export interface ComputeStackProps extends cdk.StackProps {
  readonly vpc: ec2.IVpc;                    // 必需依赖
  readonly instanceType?: ec2.InstanceType;  // 可选配置，加 ?
  readonly enableMonitoring?: boolean;       // 布尔值用 enable/is/has 前缀
}
```

### 1.4 布尔值命名

| 前缀 | 用途 | 示例 |
|------|------|------|
| `enable` | 功能开关 | `enableMonitoring`, `enableEncryption` |
| `is` | 状态判断 | `isProduction`, `isPublic` |
| `has` | 所有权判断 | `hasNatGateway`, `hasCustomDomain` |

---

## 2. TypeScript 规范

### 2.1 严格模式 (必须)

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

### 2.2 Interface vs Type 决策

| 场景 | 选择 |
|------|------|
| Props 定义 | `interface` (可扩展) |
| 联合类型 | `type` |
| 映射类型、工具类型 | `type` |
| 环境配置 | `interface` |

### 2.3 避免 enum，使用 as const

```typescript
// ✅ 正确: as const 对象
export const STAGE = {
  DEV: 'dev',
  STAGING: 'staging',
  PROD: 'prod',
} as const;
export type Stage = typeof STAGE[keyof typeof STAGE];

// ❌ 避免: TypeScript enum
enum Stage { DEV = 'dev', STAGING = 'staging', PROD = 'prod' }
```

---

## 3. ESLint 配置

### 3.1 推荐配置

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

### 3.2 CDK 特定规则

| 规则 | 设置 | 原因 |
|------|------|------|
| `no-new` | `off` | CDK 使用 `new` 创建资源并注册到 scope |
| `no-explicit-any` | `error` | 确保基础设施代码类型安全 |
| `no-floating-promises` | `error` | 避免异步操作遗漏 |

---

## 4. 文件组织

### 4.1 文件命名

| 类型 | 命名规范 | 示例 |
|------|---------|------|
| Stack 文件 | `{职责}-stack.ts` | `network-stack.ts` |
| Construct 文件 | `{能力}.ts` | `secure-bucket.ts` |
| 测试文件 | `{源文件}.test.ts` | `network-stack.test.ts` |
| 配置文件 | `{用途}.ts` | `environments.ts` |

### 4.2 单文件单导出

```typescript
// ✅ 每个文件导出一个主要 Stack/Construct
// network-stack.ts
export class NetworkStack extends cdk.Stack { }

// ❌ 避免多个 Stack 放在同一文件
export class NetworkStack extends cdk.Stack { }
export class ComputeStack extends cdk.Stack { }
```

### 4.3 Props 与类放在同一文件

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

## 相关文档

| 文档 | 说明 |
|------|------|
| [tech-stack.md](tech-stack.md) | TypeScript 和工具链版本要求 (SSoT) |
| [architecture.md](architecture.md) | Construct 分层和 Stack 组合模式 |
| [project-structure.md](project-structure.md) | 目录结构规范 |
| [testing.md](testing.md) | 测试规范 |
