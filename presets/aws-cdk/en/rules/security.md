# Security Standards

> **Purpose**: Define IAM least privilege, secrets management, network security, data encryption, and CDK Nag compliance standards.

> Consult this document first when Claude generates CDK code

CDK security standards based on the AWS Well-Architected Framework Security Pillar.

> **Responsibility boundary**: This document focuses on security **rationale and compliance requirements** (why to write it this way). For security configuration **code templates**, see [construct-design.md §3](construct-design.md#3-secure-default-configurations)

---

## 0. Quick Reference Card

### Security Rules Cheat Sheet

| Rule | Prohibited | Correct |
|------|-----------|---------|
| IAM permissions | `PolicyStatement({ actions: ['*'] })` | `bucket.grantRead(role)` |
| Secrets management | Hardcoded in code | Secrets Manager |
| S3 access | Public access | `BlockPublicAccess.BLOCK_ALL` |
| RDS | Public subnet | `PRIVATE_ISOLATED` subnet |
| Transit encryption | HTTP | HTTPS + TLS 1.2+ |

### Grant Method Quick Reference

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

// ❌ Prohibited - Overly broad policy
lambdaFn.addToRolePolicy(new iam.PolicyStatement({ actions: ['s3:*'], resources: ['*'] }));
```

### 1.2 Fine-grained Permission Control

- ✅ Restrict resource scope: `bucket.grantRead(lambdaFn, 'data/*')`
- ✅ Add condition constraints: `conditions: { StringEquals: { ... } }`
- ❌ Prohibited Admin permissions: `AdministratorAccess`

> For detailed code templates, see [construct-design.md §2](construct-design.md#2-construct-implementation-patterns)

---

## 2. Secrets Management

### 2.1 Storage Strategy

- **Sensitive credentials**: Secrets Manager (database passwords, API keys, etc.)
- **Non-sensitive configuration**: SSM Parameter Store (API URLs, config items, etc.)
- ❌ **Prohibited**: Hardcoded secrets `environment: { API_KEY: 'sk-xxx' }`

### 2.2 Usage Pattern

```typescript
// ✅ Read from Secrets Manager
const secret = secretsmanager.Secret.fromSecretNameV2(this, 'ApiKey', 'prod/api-key');
environment: { API_KEY_SECRET_ARN: secret.secretArn }
secret.grantRead(fn);

// ❌ Prohibited - Hardcoded
environment: { API_KEY: 'sk-1234567890abcdef' }
```

---

## 3. Network Security

### 3.1 VPC Layered Subnets

| Subnet Type | Purpose | Example Resources |
|-------------|---------|-------------------|
| `PUBLIC` | Public entry | ALB, NAT Gateway |
| `PRIVATE_WITH_EGRESS` | Application layer | ECS, Lambda |
| `PRIVATE_ISOLATED` | Data layer | RDS, ElastiCache |

**Key rules**:
- ✅ Databases must be in `PRIVATE_ISOLATED`
- ❌ RDS in `PUBLIC` subnet is prohibited

```typescript
// Database in isolated subnet
const database = new rds.DatabaseCluster(this, 'Database', {
  vpc,
  vpcSubnets: { subnetType: ec2.SubnetType.PRIVATE_ISOLATED },
});
```

### 3.2 Security Groups

- ✅ Minimum open ports + `allowAllOutbound: false`
- ✅ Allow only necessary inbound sources and ports
- ❌ Prohibited: `allowAllOutbound: true` (default) for data layer

### 3.3 VPC Endpoints

Use VPC Endpoints to reduce traffic leakage risk and avoid sensitive data traversing the public internet:
- Gateway Endpoints: S3, DynamoDB (free)
- Interface Endpoints: Secrets Manager, CloudWatch, etc. (as needed)

> For complete code templates and environment strategies, see [cost-optimization.md §3](cost-optimization.md#3-network-optimization)

---

## 4. Data Encryption

### 4.1 S3 Encryption

- ✅ `encryption: S3_MANAGED` or `KMS`
- ✅ `enforceSSL: true` + `blockPublicAccess: BLOCK_ALL`
- Sensitive data: CMK + `enableKeyRotation: true`

> For code templates, see [construct-design.md §3](construct-design.md#3-secure-default-configurations)

### 4.2 RDS Encryption

- ✅ `storageEncrypted: true`
- Use custom KMS key for sensitive data

> For code templates, see [construct-design.md §3](construct-design.md#3-secure-default-configurations)

### 4.3 Transit Encryption

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

> **Granularity principle**: Prefer `addResourceSuppressions` (resource-level precision) → Use `addStackSuppressions` (Stack-level) only when truly needed. Stack-level suppression may cause subsequently added resources to be inadvertently skipped.

```typescript
// ✅ Preferred - Resource-level suppression (precise, safe)
NagSuppressions.addResourceSuppressions(bucket, [
  { id: 'AwsSolutions-S1', reason: 'This Bucket is used for CloudTrail logs and does not require access logging' },
]);

// ⚠️ Use with caution - Stack-level suppression (broad impact, requires additional justification)
NagSuppressions.addStackSuppressions(stack, [
  { id: 'AwsSolutions-IAM4', reason: 'Using AWS managed policies is best practice for this use case' },
]);
```

### 5.3 Common Rules

| Rule ID | Description | Fix Method |
|---------|-------------|-----------|
| AwsSolutions-S1 | S3 Bucket should enable access logging | Add `serverAccessLogsBucket` |
| AwsSolutions-S2 | S3 Bucket should block public access | Add `blockPublicAccess` |
| AwsSolutions-IAM4 | Should not use AWS managed policies | Use Grant methods |
| AwsSolutions-IAM5 | IAM policy should not use wildcards | Restrict resources |
| AwsSolutions-RDS10 | RDS should enable deletion protection | Add `deletionProtection: true` |
| AwsSolutions-ELB2 | ALB should enable access logging | Add `accessLogsBucket` |

---

## 6. Audit Monitoring

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
