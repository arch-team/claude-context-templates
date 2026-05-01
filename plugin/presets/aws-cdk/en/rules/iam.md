# IAM Permissions

> **Responsibility**: Design guidelines, anti-patterns, and detection methods for IAM Role / Policy / PolicyStatement in AWS CDK projects.

> **Scope boundary**: This doc covers **identity and permissions**. For general security practices (Secrets Manager, VPC isolation, encryption), see [security.md](security.md). For CI/CD deployment roles, see [deployment.md](deployment.md).

---

## 0. Quick Reference

### Grant Method Decision Tree

```
Need authorization?
├─ Does L2 Construct provide a grant_* method?
│   └─ ✅ Use grant_*()                 # Preferred (CDK auto least-privilege)
├─ Cross-account authorization?
│   └─ ✅ PolicyStatement + Condition(aws:SourceAccount)
├─ Service Role (Lambda/ECS/CodeBuild)?
│   └─ ✅ ServicePrincipal + granular PolicyStatement
└─ Human users / cross-role?
    └─ ✅ iam.Group + iam.User (no long-lived AccessKey)
```

### Least Privilege in 4 Steps

1. **Action**: Enumerate precisely (no `*`)
2. **Resource**: Scope to ARN (no `*` except special cases like `iam:PassRole`)
3. **Condition**: Add `aws:SourceAccount` / `aws:SourceArn` / `aws:PrincipalOrgID`
4. **Effect**: Default Allow; add explicit Deny guardrails for sensitive actions

### Forbidden List

| Forbidden | Alternative |
|-----------|-------------|
| `AdministratorAccess` | Split by role duties, custom managed policies |
| `actions: ['*']` | Enumerate precisely (use `iam list-actions`) |
| `resources: ['*']` | Scope to ARN (at least service-level `arn:aws:s3:::bucket-name/*`) |
| `PowerUserAccess` | Split into read-only + explicit write subset |
| Long-lived IAM User AccessKey | IAM Role + STS AssumeRole / IAM Identity Center |
| Hardcoded AccountId | Use `Stack.of(this).account` |

---

## 1. Core Principles

### 1.1 Prefer Grant Methods

CDK L2 Constructs auto-generate least-privilege policies. **Prefer** `grant_*()` methods:

```typescript
// ✅ Recommended: Grant methods
const bucket = new s3.Bucket(this, 'Data');
const fn = new lambda.Function(this, 'Handler', { ... });
bucket.grantRead(fn);                          // s3:GetObject + s3:ListBucket
bucket.grantReadWrite(fn, 'uploads/*');        // Scoped to prefix
table.grantReadWriteData(fn);                  // DynamoDB data permissions

// ❌ Avoid: hand-written PolicyStatement
fn.addToRolePolicy(new iam.PolicyStatement({
  actions: ['s3:*'],                           // Too broad
  resources: [bucket.bucketArn, `${bucket.bucketArn}/*`]
}));
```

### 1.2 AssumeRolePolicy Must Have Condition

Service Roles must restrict the source:

```typescript
// ✅ Recommended: Restrict source account
new iam.Role(this, 'CrossAccountRole', {
  assumedBy: new iam.PrincipalWithConditions(
    new iam.AccountPrincipal('123456789012'),
    { StringEquals: { 'sts:ExternalId': externalId } }
  ),
});

// ✅ Service role with SourceAccount condition
new iam.Role(this, 'LambdaRole', {
  assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com', {
    conditions: {
      StringEquals: { 'aws:SourceAccount': Stack.of(this).account }
    }
  }),
});

// ❌ Avoid: ServicePrincipal without conditions
assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com')  // Confused deputy risk
```

### 1.3 Explicit Deny as Guardrail

Even if a permission isn't granted, add **explicit Deny** as a second line of defense:

```typescript
// ✅ Deny guardrail for production bucket deletion
role.addToPolicy(new iam.PolicyStatement({
  effect: iam.Effect.DENY,
  actions: ['s3:DeleteBucket'],
  resources: [productionBucket.bucketArn],
}));
```

> IAM evaluation order: Explicit Deny > Explicit Allow > Implicit Deny

### 1.4 Resource-level vs Service-level

| Scenario | Resource syntax |
|----------|----------------|
| All objects in one bucket | `arn:aws:s3:::my-bucket/*` |
| Single prefix | `arn:aws:s3:::my-bucket/data/*` |
| All DynamoDB indexes | `table.tableArn + '/index/*'` |
| `iam:PassRole` to specific service | `Condition: iam:PassedToService` |
| Only own account's resources | `Condition: aws:ResourceAccount` |

---

## 2. CDK Best Practices

### 2.1 ManagedPolicy vs InlinePolicy

| Type | Use case | Limit |
|------|----------|-------|
| **AWS Managed Policy** | ❌ Avoid (too permissive) | Not customizable |
| **Customer Managed Policy** | ✅ Shared across multiple Roles | 5000 policies per account |
| **Inline Policy** | ✅ Role-specific permissions | Role total 10KB |

```typescript
// ✅ Recommended: Customer Managed Policy (reusable)
const s3ReadPolicy = new iam.ManagedPolicy(this, 'S3Read', {
  statements: [new iam.PolicyStatement({
    actions: ['s3:GetObject', 's3:ListBucket'],
    resources: [bucket.bucketArn, `${bucket.bucketArn}/*`],
  })],
});
fn.role?.addManagedPolicy(s3ReadPolicy);

// ⚠️ Use Inline only when Role-specific
fn.addToRolePolicy(new iam.PolicyStatement({ ... }));
```

### 2.2 `iam:PassRole` Requires Conditions

Granting `iam:PassRole` is a common privilege-escalation vector:

```typescript
// ❌ Dangerous: Can pass any Role to any service
{ actions: ['iam:PassRole'], resources: ['*'] }

// ✅ Safe: Restrict target service and target Role
{
  actions: ['iam:PassRole'],
  resources: [taskExecutionRole.roleArn],
  conditions: {
    StringEquals: { 'iam:PassedToService': 'ecs-tasks.amazonaws.com' }
  }
}
```

### 2.3 Cross-account Authorization Pattern

```typescript
// Trusting side (resource owner)
bucket.addToResourcePolicy(new iam.PolicyStatement({
  principals: [new iam.AccountPrincipal('111122223333')],
  actions: ['s3:GetObject'],
  resources: [`${bucket.bucketArn}/*`],
  conditions: {
    StringEquals: { 'aws:PrincipalOrgID': 'o-xxxxxx' }  // Restrict to org
  }
}));

// Trusted side: AssumeRole + ExternalId
```

### 2.4 No Long-lived Credentials

```typescript
// ❌ Forbidden: Create IAM User with AccessKey
const user = new iam.User(this, 'ServiceUser');
const key = new iam.AccessKey(this, 'Key', { user });  // Long-lived = leak risk

// ✅ Recommended: Services use Role + STS, humans use IAM Identity Center
```

---

## 3. Common Anti-patterns

| Anti-pattern | Issue | Fix |
|-------------|-------|-----|
| `actions: ['s3:*']` | Too broad | Enumerate Get/Put/List |
| `resources: ['*']` + non-wildcard Action | Over-permission | Scope to specific ARN |
| ServicePrincipal without Condition | Confused deputy | Add `aws:SourceAccount` |
| `iam:PassRole` + `resources: *` | Privilege escalation | Restrict target Role and Service |
| Granting `iam:*` | Self-escalation | Split into specific Actions |
| `AdministratorAccess` managed policy | Superpower | Custom policy by duty |
| Missing Deny Policy | No guardrail | Add explicit Deny for sensitive actions |
| Creating resources with root account | Single point of risk | Enable Organizations + account isolation |
| Long-lived AccessKey in repo | Credential leak | Use OIDC + GitHub Actions |
| MFA Delete disabled | Accidental deletion | `versioned: true, mfaDelete: true` |

---

## 4. Detection and Audit

### 4.1 cdk-nag Rules (Enforce)

```typescript
// bin/app.ts
import { AwsSolutionsChecks } from 'cdk-nag';
cdk.Aspects.of(app).add(new AwsSolutionsChecks({ verbose: true }));
```

**Key IAM rules**:

| Rule ID | Description | Action |
|---------|-------------|--------|
| `AwsSolutions-IAM4` | Uses AWS Managed Policy | Replace with Customer Managed Policy |
| `AwsSolutions-IAM5` | Uses wildcard permissions | Scope Resource/Action |
| `AwsSolutions-SMG4` | Secrets Manager auto-rotation disabled | Enable `rotation` |

**Suppressions require written justification**:

```typescript
NagSuppressions.addResourceSuppressions(role, [{
  id: 'AwsSolutions-IAM5',
  reason: 's3:* required because CloudTrail dynamically creates object keys',
  appliesTo: ['Resource::<BucketArn>/*'],
}]);
```

### 4.2 Automated Checks

```bash
# cdk-nag (synthesis-time)
pnpm cdk synth

# checkov (static scan)
checkov -d cdk.out --framework cloudformation

# IAM Access Analyzer (post-deployment)
aws accessanalyzer list-findings --analyzer-arn <arn>

# Prowler (comprehensive audit)
prowler aws -c iam
```

### 4.3 CI/CD Pipeline IAM Role

The CI Role for deployment should:

- Use **OIDC** instead of long-lived AccessKey (GitHub Actions → AWS OIDC Provider)
- Restrict AssumeRole to specific GitHub repo:
  ```typescript
  conditions: {
    StringEquals: {
      'token.actions.githubusercontent.com:sub':
        'repo:my-org/my-repo:ref:refs/heads/main'
    }
  }
  ```
- Grant only `cloudformation:*` + granular resource-level permissions (not `PowerUserAccess`)

For detailed CI/CD IAM configuration, see [deployment.md](deployment.md).

---

## 5. PR Review Checklist (IAM-specific)

- [ ] No `actions: ['*']` or unscoped `resources: ['*']`
- [ ] All ServicePrincipals have `aws:SourceAccount` Condition
- [ ] `iam:PassRole` has `iam:PassedToService` Condition
- [ ] No AWS Managed Policies (`AdministratorAccess` / `PowerUserAccess`)
- [ ] Grant methods preferred over hand-written PolicyStatement
- [ ] Sensitive actions have explicit Deny guardrails
- [ ] No new IAM User / AccessKey
- [ ] cdk-nag passes or has written suppression justification
- [ ] Cross-account authorization has ExternalId / PrincipalOrgID

---

## 6. Related Documents

- [security.md](security.md) - General security (Secrets, VPC, encryption)
- [construct-design.md §3](construct-design.md) - Code templates for secure defaults
- [deployment.md](deployment.md) - CI/CD Pipeline IAM Role config
- [architecture.md](architecture.md) - Environment isolation and account boundaries
