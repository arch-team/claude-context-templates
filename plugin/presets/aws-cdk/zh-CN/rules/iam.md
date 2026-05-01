# IAM 权限规范

> **职责**: AWS CDK 项目中 IAM Role / Policy / PolicyStatement 的设计准则、反模式和检测方法。

> **职责边界**: 本文档关注**身份与权限**。通用安全实践（Secrets Manager、VPC 隔离、加密）详见 [security.md](security.md)。CI/CD 部署角色见 [deployment.md §部署角色](deployment.md)。

---

## 0. 速查卡片

### Grant 方法决策树

```
需要授权？
├─ L2 Construct 提供 grant_* 方法？
│   └─ ✅ 使用 grant_*()              # 优先（CDK 自动最小权限）
├─ 跨账户授权？
│   └─ ✅ 使用 PolicyStatement + Condition(aws:SourceAccount)
├─ Service Role (Lambda/ECS/CodeBuild)?
│   └─ ✅ 使用 ServicePrincipal + 精细 PolicyStatement
└─ 人类用户 / 跨角色？
    └─ ✅ 使用 iam.Group + iam.User（禁止创建长期 AccessKey）
```

### 最小权限 4 步法

1. **Action**: 精确枚举（禁止 `*`）
2. **Resource**: 限定 ARN（禁止 `*` 除非明确是 `iam:PassRole` 等特殊场景）
3. **Condition**: 加 `aws:SourceAccount` / `aws:SourceArn` / `aws:PrincipalOrgID`
4. **Effect**: 默认 Allow，敏感操作补 Deny 护栏

### 禁用清单

| 禁止项 | 替代方案 |
|-------|---------|
| `AdministratorAccess` | 按角色职能拆分，自定义托管策略 |
| `actions: ['*']` | 精确枚举（用 `iam list-actions` 查询） |
| `resources: ['*']` | 限定 ARN（至少到服务级 `arn:aws:s3:::bucket-name/*`） |
| `PowerUserAccess` | 拆分为只读 + 明确的写入子集 |
| 长期 IAM User AccessKey | IAM Role + STS AssumeRole / IAM Identity Center |
| 硬编码 AccountId | 使用 `Stack.of(this).account` |

---

## 1. 核心原则

### 1.1 Grant 方法优先

CDK L2 Construct 自动生成最小权限策略，**优先使用** `grant_*()` 方法：

```typescript
// ✅ 推荐：Grant 方法
const bucket = new s3.Bucket(this, 'Data');
const fn = new lambda.Function(this, 'Handler', { ... });
bucket.grantRead(fn);                          // s3:GetObject + s3:ListBucket
bucket.grantReadWrite(fn, 'uploads/*');        // 限定前缀
table.grantReadWriteData(fn);                  // DynamoDB 数据权限

// ❌ 避免：手写 PolicyStatement
fn.addToRolePolicy(new iam.PolicyStatement({
  actions: ['s3:*'],                           // 过宽
  resources: [bucket.bucketArn, `${bucket.bucketArn}/*`]
}));
```

### 1.2 AssumeRolePolicy 必加 Condition

Service Role 创建时，`AssumeRolePolicy` 必须限制来源：

```typescript
// ✅ 推荐：限定来源账户
new iam.Role(this, 'CrossAccountRole', {
  assumedBy: new iam.PrincipalWithConditions(
    new iam.AccountPrincipal('123456789012'),
    { StringEquals: { 'sts:ExternalId': externalId } }
  ),
});

// ✅ 服务角色：限定 SourceAccount
new iam.Role(this, 'LambdaRole', {
  assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com', {
    conditions: {
      StringEquals: { 'aws:SourceAccount': Stack.of(this).account }
    }
  }),
});

// ❌ 避免：无 Condition 的 ServicePrincipal
assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com')  // 混淆代理风险
```

### 1.3 显式 Deny 作为护栏

即使不授予某权限，对敏感操作添加 **显式 Deny** 作为第二道防线：

```typescript
// ✅ 禁止删除特定 Bucket 的 Deny 护栏
role.addToPolicy(new iam.PolicyStatement({
  effect: iam.Effect.DENY,
  actions: ['s3:DeleteBucket'],
  resources: [productionBucket.bucketArn],
}));
```

> IAM 策略评估顺序：显式 Deny > 显式 Allow > 隐式 Deny

### 1.4 资源级 vs 服务级权限

| 场景 | Resource 写法 |
|------|--------------|
| 单一 Bucket 全部对象 | `arn:aws:s3:::my-bucket/*` |
| 单一对象前缀 | `arn:aws:s3:::my-bucket/data/*` |
| 所有 DynamoDB 索引 | `table.tableArn + '/index/*'` |
| 只允许 `iam:PassRole` 给特定服务 | `Condition: iam:PassedToService` |
| 仅自己账户的资源 | `Condition: aws:ResourceAccount` |

---

## 2. CDK 最佳实践

### 2.1 ManagedPolicy vs InlinePolicy

| 类型 | 适用场景 | 限制 |
|------|---------|------|
| **AWS Managed Policy** | ❌ 避免（权限过宽） | 不可自定义 |
| **Customer Managed Policy** | ✅ 跨多个 Role 复用 | 单账户 5000 个策略 |
| **Inline Policy** | ✅ Role 专属权限 | Role 总大小 10KB |

```typescript
// ✅ 推荐：Customer Managed Policy（可复用）
const s3ReadPolicy = new iam.ManagedPolicy(this, 'S3Read', {
  statements: [new iam.PolicyStatement({
    actions: ['s3:GetObject', 's3:ListBucket'],
    resources: [bucket.bucketArn, `${bucket.bucketArn}/*`],
  })],
});
fn.role?.addManagedPolicy(s3ReadPolicy);

// ⚠️ 仅在 Role 专属时用 Inline
fn.addToRolePolicy(new iam.PolicyStatement({ ... }));
```

### 2.2 `iam:PassRole` 必须 Condition

授予用户 / Service Role `iam:PassRole` 是常见提权漏洞：

```typescript
// ❌ 危险：可将任意 Role 传给任意服务
{ actions: ['iam:PassRole'], resources: ['*'] }

// ✅ 安全：限定目标服务 + 目标 Role
{
  actions: ['iam:PassRole'],
  resources: [taskExecutionRole.roleArn],
  conditions: {
    StringEquals: { 'iam:PassedToService': 'ecs-tasks.amazonaws.com' }
  }
}
```

### 2.3 跨账户授权模式

```typescript
// 信任方（提供资源）
bucket.addToResourcePolicy(new iam.PolicyStatement({
  principals: [new iam.AccountPrincipal('111122223333')],
  actions: ['s3:GetObject'],
  resources: [`${bucket.bucketArn}/*`],
  conditions: {
    StringEquals: { 'aws:PrincipalOrgID': 'o-xxxxxx' }  // 限定组织
  }
}));

// 受托方（访问资源）: AssumeRole + ExternalId
```

### 2.4 禁用长期凭证

```typescript
// ❌ 禁止：创建 IAM User 并生成 AccessKey
const user = new iam.User(this, 'ServiceUser');
const key = new iam.AccessKey(this, 'Key', { user });  // 长期凭证 = 泄露风险

// ✅ 推荐：服务用 Role + STS，人用 IAM Identity Center
```

---

## 3. 常见反模式

| 反模式 | 问题 | 修复 |
|-------|------|------|
| `actions: ['s3:*']` | 过宽 | 精确枚举 Get/Put/List |
| `resources: ['*']` + 非通配 Action | 越权 | 限定到具体 ARN |
| ServicePrincipal 无 Condition | 混淆代理攻击 | 加 `aws:SourceAccount` |
| `iam:PassRole` + `resources: *` | 提权 | 限定目标 Role 和 Service |
| 授予 `iam:*` | 可自我提权 | 拆分为具体 Action |
| `AdministratorAccess` 托管策略 | 超级权限 | 自定义按职责的策略 |
| 忘记 Deny Policy | 无护栏 | 对敏感操作加显式 Deny |
| 根账号创建资源 | 单点风险 | 启用 Organizations + 按账号隔离 |
| 长期 AccessKey 存放在仓库 | 凭证泄露 | 改用 OIDC + GitHub Actions |
| 未启用 MFA Delete | 误删风险 | `versioned: true, mfaDelete: true` |

---

## 4. 检测与审计

### 4.1 cdk-nag 规则（强制启用）

```typescript
// bin/app.ts
import { AwsSolutionsChecks } from 'cdk-nag';
cdk.Aspects.of(app).add(new AwsSolutionsChecks({ verbose: true }));
```

**IAM 相关关键规则**：

| 规则 ID | 说明 | 处理 |
|--------|------|------|
| `AwsSolutions-IAM4` | 使用 AWS Managed Policy | 替换为 Customer Managed Policy |
| `AwsSolutions-IAM5` | 使用通配符权限 | 限定 Resource/Action |
| `AwsSolutions-SMG4` | Secrets Manager 未启用自动轮换 | 启用 `rotation` |

**抑制规则需书面理由**：

```typescript
NagSuppressions.addResourceSuppressions(role, [{
  id: 'AwsSolutions-IAM5',
  reason: '必须使用 s3:* 因为 CloudTrail 需要动态创建对象键',
  appliesTo: ['Resource::<BucketArn>/*'],
}]);
```

### 4.2 自动化检查命令

```bash
# cdk-nag（合成时检查）
pnpm cdk synth

# checkov（静态扫描）
checkov -d cdk.out --framework cloudformation

# IAM Access Analyzer（部署后）
aws accessanalyzer list-findings --analyzer-arn <arn>

# Prowler（全面审计）
prowler aws -c iam
```

### 4.3 CI/CD Pipeline IAM Role

部署用的 CI Role 应满足：

- 使用 **OIDC** 而非长期 AccessKey（GitHub Actions → AWS OIDC Provider）
- AssumeRole 限定 GitHub 仓库：
  ```typescript
  conditions: {
    StringEquals: {
      'token.actions.githubusercontent.com:sub':
        'repo:my-org/my-repo:ref:refs/heads/main'
    }
  }
  ```
- 部署 Role 仅授予 `cloudformation:*` + 精细的资源级权限（而非 `PowerUserAccess`）

详细的 CI/CD IAM 配置见 [deployment.md](deployment.md)。

---

## 5. PR Review 检查清单（IAM 专项）

- [ ] 无 `actions: ['*']` 和无限定的 `resources: ['*']`
- [ ] 所有 ServicePrincipal 带 `aws:SourceAccount` Condition
- [ ] `iam:PassRole` 带 `iam:PassedToService` Condition
- [ ] 无 AWS Managed Policy（`AdministratorAccess` / `PowerUserAccess`）
- [ ] Grant 方法优先于手写 PolicyStatement
- [ ] 敏感操作有显式 Deny 护栏
- [ ] 无新增 IAM User / AccessKey
- [ ] cdk-nag 通过或有书面抑制理由
- [ ] 跨账户授权带 ExternalId / PrincipalOrgID

---

## 6. 相关文档

- [security.md](security.md) - 通用安全实践（Secrets、VPC、加密）
- [construct-design.md §3](construct-design.md) - 安全默认配置的代码模板
- [deployment.md](deployment.md) - CI/CD Pipeline IAM Role 配置
- [architecture.md](architecture.md) - 环境隔离与账号边界
