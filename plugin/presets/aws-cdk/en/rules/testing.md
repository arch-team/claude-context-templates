# Testing Standards

> **Purpose**: Concrete CDK testing practices — code templates, API usage, and command reference.

> Consult this document first when Claude generates CDK test code

---

## 0. Quick Reference Card

### CDK Testing Strategy

#### Test Priority

1. **Fine-grained Assertions** — Verify specific resource properties (preferred)
2. **Snapshot Tests** — Detect unexpected changes (supplementary)
3. **CDK Nag Compliance** — Security compliance checks (mandatory)

#### Coverage Standards

| Level | Minimum Coverage | Target Coverage |
|-------|-----------------|-----------------|
| Constructs | 90% | 95% |
| Stacks | {{COVERAGE_MIN}}% | 90% |
| **Overall** | **{{COVERAGE_MIN}}%** | **90%** |

### Universal Testing Principles

> For TDD core cycle and test integrity principles, see `rules/principles/testing.md`

### CDK Testing Philosophy

| ✅ Do | ❌ Avoid |
|-------|---------|
| Test business configuration and security properties | Test CDK internal implementation |
| Create stack independently in beforeEach | Share global stack state |
| Verify critical security properties | Only verify resource existence |

### Test Types

| Type | Purpose | Tool |
|------|---------|------|
| **Fine-grained** | Verify specific resource properties | CDK Assertions |
| **Snapshot** | Detect unexpected changes | Jest Snapshot |
| **Compliance** | Security compliance checks | CDK Nag |

### Commands

```bash
pnpm test                              # Run all tests
pnpm test:coverage                     # Tests + coverage
pnpm test -- -u                        # Update snapshots
pnpm test test/snapshot/main.test.ts   # Run specific test
```

### CDK Assertions API

```typescript
// Resource assertions
template.hasResourceProperties('AWS::S3::Bucket', { ... });
template.resourceCountIs('AWS::Lambda::Function', 2);
template.hasOutput('VpcId', { ... });

// Match matchers
Match.objectLike({ ... })    // Partial match
Match.exact({ ... })         // Exact match
Match.anyValue()             // Any value
Match.absent()               // Property does not exist
Match.arrayWith([...])       // Array contains
```

---

## 1. Fine-grained Assertions

### Test Template

```typescript
import * as cdk from 'aws-cdk-lib';
import { Template, Match } from 'aws-cdk-lib/assertions';
import { VpcConstruct } from './vpc.construct';

describe('VpcConstruct', () => {
  let template: Template;

  beforeEach(() => {
    const app = new cdk.App();
    const stack = new cdk.Stack(app, 'TestStack');
    new VpcConstruct(stack, 'TestVpc', { vpcCidr: '10.0.0.0/16' });
    template = Template.fromStack(stack);
  });

  it('should create VPC with correct CIDR', () => {
    template.hasResourceProperties('AWS::EC2::VPC', {
      CidrBlock: '10.0.0.0/16',
      EnableDnsHostnames: true,
    });
  });

  it('should create NAT Gateway when enabled', () => {
    template.resourceCountIs('AWS::EC2::NatGateway', 2);
  });
});
```

### Security Property Verification

```typescript
// S3 security configuration
template.hasResourceProperties('AWS::S3::Bucket', {
  PublicAccessBlockConfiguration: {
    BlockPublicAcls: true,
    BlockPublicPolicy: true,
  },
});

// RDS security configuration
template.hasResourceProperties('AWS::RDS::DBCluster', {
  StorageEncrypted: true,
  DeletionProtection: true,
  PubliclyAccessible: Match.absent(),
});

// IAM policy verification
template.hasResourceProperties('AWS::IAM::Policy', {
  PolicyDocument: {
    Statement: Match.arrayWith([
      Match.objectLike({ Action: Match.arrayWith(['s3:GetObject*']), Effect: 'Allow' }),
    ]),
  },
});
```

---

## 2. Snapshot Tests

```typescript
// test/snapshot/main.test.ts
describe('Snapshot Tests', () => {
  it('NetworkStack matches snapshot', () => {
    const app = new cdk.App();
    const stack = new NetworkStack(app, 'TestStack', {
      env: { account: '123456789012', region: 'ap-northeast-1' },  // Test placeholder account
      vpcCidr: '10.0.0.0/16',
    });

    expect(Template.fromStack(stack).toJSON()).toMatchSnapshot();
  });
});
```

---

## 3. CDK Nag Compliance Tests

```typescript
// test/compliance/cdk-nag.test.ts
import { Aspects } from 'aws-cdk-lib';
import { AwsSolutionsChecks } from 'cdk-nag';

describe('CDK Nag Compliance', () => {
  it('should pass AWS Solutions checks', () => {
    const app = new cdk.App();
    const stack = new NetworkStack(app, 'TestStack', { ... });

    Aspects.of(stack).add(new AwsSolutionsChecks({ verbose: true }));

    const messages = app.synth().getStackArtifact(stack.artifactId).messages;
    const errors = messages.filter((m) => m.level === 'error');

    expect(errors).toHaveLength(0);
  });
});
```

---

## Related Documents

- [architecture.md](architecture.md) - Architecture standards
- [checklist.md](checklist.md) - PR Review checklist
- [code-style.md](code-style.md) - Code style standards
- [construct-design.md](construct-design.md) - Construct design patterns
- [project-structure.md](project-structure.md) - Test file locations
- [security.md](security.md) - Security standards
- [tech-stack.md](tech-stack.md) - Test framework version constraints
