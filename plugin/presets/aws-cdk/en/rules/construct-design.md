# Construct Design Standards

> **Purpose**: Define Construct Props interface design, implementation patterns, secure default configurations, and JSDoc comment standards.

> Consult first when Claude generates CDK Construct code

---

## 0. Quick Reference Card

### Props Design

| Rule | ✅ Correct | ❌ Incorrect |
|------|-----------|-------------|
| readonly modifier | `readonly vpcCidr: string` | `vpcCidr: string` |
| Optional parameters | `readonly timeout?: number` | `readonly timeout: number \| undefined` |
| Default values | Set during destructuring | Set in Props interface |
| Interface naming | `{Construct}Props` | `{Construct}Options` |

### Construct Template

```typescript
export interface {Construct}Props {
  readonly requiredProp: string;
  readonly optionalProp?: number;
}

/**
 * {Description} Construct - One-line purpose statement.
 * @remarks Default configuration: xxx, xxx
 */
export class {Construct} extends Construct {
  public readonly resource: ResourceType;

  constructor(scope: Construct, id: string, props: {Construct}Props) {
    super(scope, id);
    const { requiredProp, optionalProp = 100 } = props;
    // Create resources...
  }

  /** Grant method for authorization */
  public grantXxx(grantee: iam.IGrantable): iam.Grant { ... }
}
```

### Secure Default Configurations

> For security requirements and rationale, see [security.md](security.md). This section only lists required configuration items in code templates.

| Resource | Required Configuration |
|----------|----------------------|
| S3 | `encryption: S3_MANAGED`, `blockPublicAccess: BLOCK_ALL`, `enforceSSL: true`, `versioned: true` |
| RDS | `storageEncrypted: true`, `deletionProtection: true`, `iamAuthentication: true`, `vpcSubnets: PRIVATE_ISOLATED` |
| Lambda | `tracing: ACTIVE`, `timeout: 30s`, explicit LogGroup |
| API Gateway | Access logs, throttling, WAF |

### Export Pattern

```typescript
// lib/constructs/{name}/index.ts
export { {Construct} } from './{name}.construct';
export type { {Construct}Props } from './{name}.construct';

// lib/constructs/index.ts (barrel export)
export * from './vpc';
export * from './aurora';
```

---

## 1. Props Interface Design

### Basic Rules

```typescript
// ✅ readonly + optional parameters
export interface VpcConstructProps {
  readonly vpcCidr: string;
  readonly maxAzs?: number;        // Optional, set default during destructuring
  readonly enableNatGateway?: boolean;
}

// Stack Props inheritance
export interface NetworkStackProps extends cdk.StackProps {
  readonly vpcCidr: string;
}
```

### Nested Configuration

```typescript
export interface AutoScalingConfig {
  readonly minCapacity: number;
  readonly maxCapacity: number;
  readonly targetCpuUtilization?: number;
}

export interface EcsServiceConstructProps {
  readonly vpc: ec2.IVpc;
  readonly autoScaling?: AutoScalingConfig;
}
```

---

## 2. Construct Implementation Patterns

### Core Structure

```typescript
export class VpcConstruct extends Construct {
  public readonly vpc: ec2.Vpc;  // Expose main resource

  constructor(scope: Construct, id: string, props: VpcConstructProps) {
    super(scope, id);

    // 1. Destructure + defaults
    const { vpcCidr, maxAzs = 3, enableNatGateway = true } = props;

    // 2. Create resources
    this.vpc = new ec2.Vpc(this, 'Vpc', { ... });
  }
}
```

### Exposed Properties Rules

```typescript
// Expose properties for external use
public readonly cluster: rds.DatabaseCluster;
public readonly clusterEndpoint: rds.Endpoint;
public readonly secret: secretsmanager.ISecret;

// Provide Grant methods
public grantDataApiAccess(grantee: iam.IGrantable): iam.Grant {
  return this.cluster.grantDataApiAccess(grantee);
}
```

---

## 3. Secure Default Configurations

> **Responsibility boundary**: This section provides security configuration **code templates**. For security rationale, IAM least privilege, CDK Nag rules, etc., see [security.md](security.md)

### S3 Bucket

```typescript
this.bucket = new s3.Bucket(this, 'Bucket', {
  encryption: s3.BucketEncryption.S3_MANAGED,
  blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
  enforceSSL: true,
  versioned: true,
  removalPolicy: props.removalPolicy ?? cdk.RemovalPolicy.RETAIN,
});
```

### RDS/Aurora

```typescript
this.cluster = new rds.DatabaseCluster(this, 'Cluster', {
  storageEncrypted: true,
  deletionProtection: props.deletionProtection ?? true,
  iamAuthentication: true,
  vpc: props.vpc,
  vpcSubnets: { subnetType: ec2.SubnetType.PRIVATE_ISOLATED },
});
```

### Lambda

```typescript
this.function = new lambda.Function(this, 'Function', {
  tracing: lambda.Tracing.ACTIVE,
  timeout: props.timeout ?? cdk.Duration.seconds(30),
  memorySize: props.memorySize ?? 256,
});
```

---

## 4. JSDoc Comments

### Construct Comments

```typescript
/**
 * API Gateway Construct - Creates a REST API entry point.
 * @remarks Enables access logs and WAF protection by default.
 */
export class ApiGatewayConstruct extends Construct { ... }
```

### Props Comments

```typescript
export interface ApiGatewayConstructProps {
  /** Deployment stage name (dev, staging, prod) */
  readonly stageName: string;
  /** API request throttling rate limit @default 1000 */
  readonly throttlingRateLimit?: number;
  /** Whether to enable WAF protection @default true */
  readonly enableWaf?: boolean;
}
```

---

## Related Documents

- [architecture.md](architecture.md) - Construct layering rules
- [security.md](security.md) - Detailed security configuration standards
- [testing.md](testing.md) - Construct testing standards
