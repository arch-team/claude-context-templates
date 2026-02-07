# CDK Architecture Standards

> **Purpose**: Define CDK Construct layering (L1/L2/L3), Stack composition patterns, and cross-Stack communication standards.

> Consult this document first when Claude generates CDK code

**Architecture pattern**: CDK Construct layering (L1 → L2 → L3)

---

## 0. Quick Reference Card

### Construct Layers

| Layer | Description | Source | Example |
|-------|-------------|--------|---------|
| **L1** | Direct CloudFormation mapping | `Cfn*` prefix | `CfnBucket` |
| **L2** | High-level abstraction + sensible defaults | `aws-*` modules | `s3.Bucket` |
| **L3** | Business composition, multi-resource orchestration | Custom Construct | `VpcConstruct` |

**Rule**: Prefer L2 → Use L3 when composition is needed → Use L1 only when L2 doesn't support the feature

### Dependency Direction

```
App → Stack A → L3 → L2 → L1
         ↓
      Stack B (depends on A's outputs)
```

**Core rules**:
- Stacks communicate via Props or Outputs
- Within a Construct, higher layers call lower layers
- Circular dependencies are prohibited

### Stack Composition Patterns

| Pattern | Use Case | Example |
|---------|----------|---------|
| By resource type | Different lifecycles | NetworkStack, DatabaseStack |
| By environment | Multi-environment deployment | dev-Stack, prod-Stack |
| By service | Microservices architecture | AuthStack, ApiStack |

### Stack Responsibility Division

| Stack | Included Resources |
|-------|-------------------|
| NetworkStack | VPC, Subnets, NAT |
| SecurityStack | Security Groups, WAF, KMS |
| DatabaseStack | RDS, DynamoDB, ElastiCache |
| ComputeStack | EKS, ECS, Lambda, EC2 |
| ApiStack | API Gateway, ALB |
| MonitoringStack | CloudWatch, SNS, Alarms |

---

## 1. Construct Layer Usage

### L2 First (Recommended)

```typescript
// ✅ L2: Sensible defaults + Grant methods
const bucket = new s3.Bucket(this, 'DataBucket', {
  versioned: true,
  encryption: s3.BucketEncryption.S3_MANAGED,
});
bucket.grantRead(fn);  // Grant method for authorization
```

### L3 Custom Construct

See [construct-design.md](construct-design.md) - Construct Design Standards

---

## 2. Stack Design

### Stack Props Pattern

```typescript
export interface ComputeStackProps extends cdk.StackProps {
  readonly vpc: ec2.IVpc;           // Required dependency
  readonly instanceType?: ec2.InstanceType;  // Optional configuration
}

export class ComputeStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: ComputeStackProps) {
    super(scope, id, props);
    const { vpc, instanceType = ec2.InstanceType.of(T3, SMALL) } = props;
  }
}
```

### Inter-Stack Dependencies

```typescript
// bin/app.ts
const networkStack = new NetworkStack(app, `Network-${env}`);
const computeStack = new ComputeStack(app, `Compute-${env}`, {
  vpc: networkStack.vpc,  // Props passing
});
computeStack.addDependency(networkStack);  // Explicit dependency
```

---

## 3. Cross-Stack Communication

### Decision Matrix

| Method | Use Case | Pros | Cons |
|--------|----------|------|------|
| **Props passing** (preferred) | Inter-Stack dependencies within the same App | Type-safe, refactor-friendly | Same App only |
| **SSM Parameter** | Cross-App/cross-team shared configuration | Decoupled deployment, runtime lookup | Synthesis-time delay, requires naming management |
| **CfnOutput** | Legacy system integration | CloudFormation native | Create/delete order coupling, difficult to modify export values |

> **Rule**: Prefer Props passing → Use SSM for cross-App → Use CfnOutput only for legacy integration

### Method 1: Props Passing (Preferred)

```typescript
const computeStack = new ComputeStack(app, 'Compute', { vpc: networkStack.vpc });
```

### Method 2: SSM Parameter (Cross-App Scenarios)

```typescript
// Write (Network Stack)
new ssm.StringParameter(this, 'VpcId', { parameterName: '/infra/vpc-id', stringValue: this.vpc.vpcId });

// Read (Compute Stack)
const vpcId = ssm.StringParameter.valueFromLookup(this, '/infra/vpc-id');
```

### Method 3: CfnOutput + Fn.importValue (Not recommended for new code)

> `Fn.importValue` creates hard coupling between Stacks: the exporting Stack cannot modify or delete the export value unless all importing Stacks remove their references first.

```typescript
// Export
new cdk.CfnOutput(this, 'VpcId', { value: this.vpc.vpcId, exportName: 'NetworkVpcId' });

// Import
const vpcId = cdk.Fn.importValue('NetworkVpcId');
```

---

## 4. Environment Configuration

> **Responsibility boundary**: This section focuses on the **architectural design** of environment configuration (how to organize configuration structure). For actual deployment processes, environment matrices, and CI/CD configuration, see [deployment.md](deployment.md)

### CDK Context Pattern

```typescript
// lib/config/environments.ts
export interface EnvironmentConfig {
  readonly account: string;
  readonly region: string;
  readonly vpcCidr: string;
}

export function getEnvironmentConfig(app: cdk.App, envName: string): EnvironmentConfig {
  const config = app.node.tryGetContext('environments')?.[envName];
  if (!config) throw new Error(`Environment configuration not found: ${envName}`);
  return config;
}
```

### Using Configuration

```typescript
// bin/app.ts
const envName = app.node.tryGetContext('env') || 'dev';
const envConfig = getEnvironmentConfig(app, envName);

new NetworkStack(app, `Network-${envName}`, {
  env: { account: envConfig.account, region: envConfig.region },
  vpcCidr: envConfig.vpcCidr,
});
```

---

## Related Documents

- [project-structure.md](project-structure.md) - Directory structure standards
- [construct-design.md](construct-design.md) - Construct design standards
- [security.md](security.md) - Security standards
- [testing.md](testing.md) - Testing standards
