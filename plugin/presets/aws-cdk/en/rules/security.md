# Security Standards

> **Purpose**: Concrete CDK security practices — code templates, Grant method reference, and configuration examples.

> For security configuration **code templates**, see [construct-design.md §3](construct-design.md#3-secure-default-configurations)

---

## 0. Quick Reference Card

### IAM Least Privilege Principle

- **Grant methods first**: Use CDK L2 Construct Grant methods to automatically create least-privilege policies
- **No wildcards**: `actions: ['*']` or `resources: ['*']` are prohibited
- **No Admin permissions**: Do not use `AdministratorAccess`
- **Fine-grained resource scope**: Restrict to specific resource paths (e.g., `bucket.grantRead(fn, 'data/*')`)

### Secrets Management Principle

| Type | Storage Method |
|------|---------------|
| Sensitive credentials (passwords, API keys) | Secrets Manager |
| Non-sensitive configuration (URLs, config items) | SSM Parameter Store |
| **Prohibited** | Hardcoded in source code |

### Network Security Layering Principle

| Subnet Type | Purpose | Example Resources |
|-------------|---------|-------------------|
| `PUBLIC` | Public entry point | ALB, NAT Gateway |
| `PRIVATE_WITH_EGRESS` | Application layer | ECS, Lambda |
| `PRIVATE_ISOLATED` | Data layer | RDS, ElastiCache |

**Key rule**: Databases must be placed in `PRIVATE_ISOLATED`; RDS in `PUBLIC` subnets is prohibited.

### Data Encryption Principle

- **At-rest encryption**: S3 uses `S3_MANAGED` or `KMS`, RDS enables `storageEncrypted`
- **In-transit encryption**: HTTPS + TLS 1.2+, HTTP auto-redirects to HTTPS
- **Sensitive data**: Use CMK + `enableKeyRotation: true`

### CDK Nag Compliance Principle

- **Must enable**: All Stacks should apply `AwsSolutionsChecks`
- **Suppression granularity**: Prefer resource-level `addResourceSuppressions` → Use Stack-level only when truly necessary
- **Suppressions must include reason**: Every suppression rule must provide a `reason` field

### Grant Methods Quick Reference

| Resource | Grant Methods |
|----------|-------------|
| S3 | `grantRead()`, `grantWrite()`, `grantReadWrite()`, `grantDelete()` |
| DynamoDB | `grantReadData()`, `grantWriteData()`, `grantReadWriteData()` |
| Lambda | `grantInvoke()`, `grantInvokeUrl()` |
| KMS | `grantEncrypt()`, `grantDecrypt()`, `grantEncryptDecrypt()` |
| SNS | `grantPublish()`, `grantSubscribe()` |
| SQS | `grantSendMessages()`, `grantConsumeMessages()` |
| Secrets | `grantRead()`, `grantWrite()` |

---

## 1. IAM Least Privilege

### 1.1 Use Grant Methods

```typescript
// ✅ Grant methods automatically create least-privilege policies
bucket.grantRead(lambdaFn);

// ❌ Prohibited - overly broad policy
lambdaFn.addToRolePolicy(new iam.PolicyStatement({ actions: ['s3:*'], resources: ['*'] }));
```

### 1.2 Fine-grained Permission Control

- ✅ Restrict resource scope: `bucket.grantRead(lambdaFn, 'data/*')`
- ✅ Add condition constraints: `conditions: { StringEquals: { ... } }`
- ❌ Prohibited Admin permissions: `AdministratorAccess`

> Detailed code templates at [construct-design.md §2](construct-design.md#2-construct-implementation-patterns)

---

## 2. Secrets Management

### 2.1 Storage Strategy

- **Sensitive credentials**: Secrets Manager (database passwords, API keys, etc.)
- **Non-sensitive configuration**: SSM Parameter Store (API URLs, config items, etc.)
- ❌ **Prohibited**: Hardcoded secrets `environment: { API_KEY: 'sk-xxx' }`

### 2.2 Usage Patterns

```typescript
// ✅ Read from Secrets Manager
const secret = secretsmanager.Secret.fromSecretNameV2(this, 'ApiKey', 'prod/api-key');
environment: { API_KEY_SECRET_ARN: secret.secretArn }
secret.grantRead(fn);

// ❌ Prohibited - hardcoded
environment: { API_KEY: 'sk-1234567890abcdef' }
```

---

## 3. Network Security

### 3.1 VPC Layered Subnets

| Subnet Type | Purpose | Example Resources |
|-------------|---------|-------------------|
| `PUBLIC` | Public entry point | ALB, NAT Gateway |
| `PRIVATE_WITH_EGRESS` | Application layer | ECS, Lambda |
| `PRIVATE_ISOLATED` | Data layer | RDS, ElastiCache |

**Key rules**:
- ✅ Databases must be placed in `PRIVATE_ISOLATED`
- ❌ RDS in `PUBLIC` subnets is prohibited

```typescript
// Place database in isolated subnet
const database = new rds.DatabaseCluster(this, 'Database', {
  vpc,
  vpcSubnets: { subnetType: ec2.SubnetType.PRIVATE_ISOLATED },
});
```

### 3.2 Security Groups

- ✅ Minimal open ports + `allowAllOutbound: false`
- ✅ Allow only necessary inbound sources and ports
- ❌ Prohibit `allowAllOutbound: true` (default) for data layer

### 3.3 VPC Endpoints

Use VPC Endpoints to reduce data exfiltration risk and avoid sensitive data traversing the public internet:
- Gateway Endpoints: S3, DynamoDB (free)
- Interface Endpoints: Secrets Manager, CloudWatch, etc. (as needed)

> Full code templates and environment strategies at [cost-optimization.md §3](cost-optimization.md#3-network-optimization)

---

## 4. Data Encryption

### 4.1 S3 Encryption

- ✅ `encryption: S3_MANAGED` or `KMS`
- ✅ `enforceSSL: true` + `blockPublicAccess: BLOCK_ALL`
- Sensitive data: CMK + `enableKeyRotation: true`

> Code templates at [construct-design.md §3](construct-design.md#3-secure-default-configurations)

### 4.2 RDS Encryption

- ✅ `storageEncrypted: true`
- Sensitive data uses custom KMS keys

> Code templates at [construct-design.md §3](construct-design.md#3-secure-default-configurations)

### 4.3 Transport Encryption

```typescript
// ALB: HTTPS + TLS 1.2 + HTTP→HTTPS redirect
lb.addListener('Https', { port: 443, certificates: [cert], sslPolicy: elbv2.SslPolicy.TLS12 });
lb.addListener('Http', { port: 80, defaultAction: elbv2.ListenerAction.redirect({ protocol: 'HTTPS', port: '443', permanent: true }) });
```

---

## 5. CDK Nag

### 5.1 Enable CDK Nag

```typescript
// bin/app.ts
import { Aspects } from 'aws-cdk-lib';
import { AwsSolutionsChecks, NagSuppressions } from 'cdk-nag';

Aspects.of(app).add(new AwsSolutionsChecks({ verbose: true }));
```

### 5.2 Suppression Rules

> **Granularity principle**: Prefer `addResourceSuppressions` (resource-level) → Use `addStackSuppressions` (Stack-level) only when truly necessary. Stack-level suppressions may cause newly added resources to inadvertently skip checks.

```typescript
// ✅ Preferred - Resource-level suppression (precise, safe)
NagSuppressions.addResourceSuppressions(bucket, [
  { id: 'AwsSolutions-S1', reason: 'This bucket is used for CloudTrail logs and does not require access logging' },
]);

// ⚠️ Use with caution - Stack-level suppression (broad impact, requires additional justification)
NagSuppressions.addStackSuppressions(stack, [
  { id: 'AwsSolutions-IAM4', reason: 'Using AWS managed policies is best practice for this use case' },
]);
```

### 5.3 Common Rules

| Rule ID | Description | Fix |
|---------|-------------|-----|
| AwsSolutions-S1 | S3 Bucket should enable access logging | Add `serverAccessLogsBucket` |
| AwsSolutions-S2 | S3 Bucket should block public access | Add `blockPublicAccess` |
| AwsSolutions-IAM4 | Should not use AWS managed policies | Use Grant methods |
| AwsSolutions-IAM5 | IAM policies should not use wildcards | Restrict resources |
| AwsSolutions-RDS10 | RDS should enable deletion protection | Add `deletionProtection: true` |
| AwsSolutions-ELB2 | ALB should enable access logging | Add `accessLogsBucket` |

---

## 6. Audit & Monitoring

```typescript
// CloudTrail + Config Rules
const trail = new cloudtrail.Trail(this, 'Trail', {
  bucket: logBucket,
  isMultiRegionTrail: true,
  enableFileValidation: true,
});

new config.ManagedRule(this, 'S3Public', {
  identifier: config.ManagedRuleIdentifiers.S3_BUCKET_PUBLIC_READ_PROHIBITED,
});
new config.ManagedRule(this, 'RdsEncrypt', {
  identifier: config.ManagedRuleIdentifiers.RDS_STORAGE_ENCRYPTED,
});
```

---

## Related Documents

| Document | Description |
|----------|-------------|
| [construct-design.md](construct-design.md) | Secure default configuration code templates |
| [testing.md](testing.md) | CDK Nag testing |
| [AWS Well-Architected - Security](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/) | External reference |
