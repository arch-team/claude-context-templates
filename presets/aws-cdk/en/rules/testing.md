# Testing Standards

> **Purpose**: Define TDD workflow, coverage requirements, Fine-grained Assertions, and CDK Nag compliance testing standards.

> Consult this document first when Claude generates CDK test code

This project fully adopts Test-Driven Development (TDD).

---

## 0. Quick Reference Card

### TDD Core Cycle

```
1. Red: Write a failing test first
2. Green: Write the minimum code to make the test pass
3. Refactor: Refactor code while keeping tests passing
```

**Test integrity principle**: Never fabricate results to make tests pass. Test failure = code has a problem; fix the code.

### Coverage Requirements

| Layer | Minimum Coverage | Target Coverage |
|-------|-----------------|----------------|
| Constructs | 90% | 95% |
| Stacks | 85% | 90% |
| **Overall** | **85%** | **90%** |

### Commands

```bash
pnpm test                              # Run all tests
pnpm test:coverage                     # Tests + coverage
pnpm test -- -u                        # Update snapshots
pnpm test test/snapshot/main.test.ts   # Run specific test
```

### Test Types

| Type | Purpose | Tools |
|------|---------|-------|
| **Fine-grained** | Verify specific resource properties | CDK Assertions |
| **Snapshot** | Detect unintended changes | Jest Snapshot |
| **Compliance** | Security compliance checks | CDK Nag |

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

### Best Practices

| ✅ Do | ❌ Avoid |
|-------|---------|
| Test business configuration and security properties | Testing CDK internal implementation |
| Create stack independently in beforeEach | Sharing global stack state |
| Verify critical security properties | Only verifying resource existence |

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
      env: { account: '123456789012', region: 'ap-northeast-1' },  // Placeholder account for testing
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

- [project-structure.md](project-structure.md) - Test file locations
- [construct-design.md](construct-design.md) - Construct design patterns
