# Deployment Standards

> **Purpose**: Define deployment execution standards, including environment matrix, CI/CD Pipeline, deployment flow, and blue-green deployment strategy.

> Consult this document first when Claude performs deployment-related operations

> **Responsibility boundary**: This document focuses on **deployment execution** (environment matrix, CI/CD, deployment flow). For the **architectural design** of environment configuration (CDK Context structure), see [architecture.md §4](architecture.md#4-environment-configuration)

---

## 0. Quick Reference Card

### Deployment Commands

For the complete CDK commands, see [CLAUDE.md §CDK Commands](../CLAUDE.md#cdk-commands)

```bash
# Deploy to specific environment
pnpm cdk deploy --context env=prod --all

# View changes then deploy
pnpm cdk diff && pnpm cdk deploy
```

### Environment Matrix

| Environment | Purpose | Deployment Method | Approval |
|-------------|---------|-------------------|----------|
| dev | Development and testing | Manual | None |
| staging | Pre-release | CI/CD | Automatic |
| prod | Production | CI/CD | Manual approval |

---

## 1. Environment Configuration

For environment configuration architecture, see [architecture.md §4](architecture.md#4-environment-configuration)

### RemovalPolicy Strategy

| Environment | S3/Logs | RDS |
|-------------|---------|-----|
| Dev | DESTROY | DESTROY |
| Staging | DESTROY | SNAPSHOT |
| Prod | RETAIN | SNAPSHOT |

```typescript
export function getRemovalPolicy(envName: string): cdk.RemovalPolicy {
  return envName === 'dev' ? cdk.RemovalPolicy.DESTROY
       : envName === 'staging' ? cdk.RemovalPolicy.SNAPSHOT
       : cdk.RemovalPolicy.RETAIN;
}
```

---

## 2. CI/CD Pipeline

### GitHub Actions (Key Configuration)

```yaml
# .github/workflows/cdk-deploy.yml
name: CDK Deploy

on:
  push:
    branches: [main]
    paths: ['infra/**']
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        options: [dev, staging, prod]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - run: pnpm install && pnpm test:coverage
      - run: pnpm cdk synth --context env=${{ inputs.environment || 'dev' }}

  deploy-dev:
    needs: test
    environment: dev
    steps:
      - run: pnpm cdk deploy --all --context env=dev --require-approval never

  deploy-prod:
    needs: deploy-staging
    environment:
      name: prod  # Requires manual approval
    steps:
      - run: pnpm cdk deploy --all --context env=prod --require-approval never
```

### CDK Pipeline (AWS Native)

```typescript
const pipeline = new CodePipeline(this, 'Pipeline', {
  synth: new ShellStep('Synth', {
    input: CodePipelineSource.gitHub('owner/repo', 'main'),
    commands: ['cd infra', 'pnpm install', 'pnpm test', 'pnpm cdk synth'],
  }),
});

// Prod stage requires manual approval
pipeline.addStage(prodStage, {
  pre: [new pipelines.ManualApprovalStep('Approve')],
});
```

---

## 3. Deployment Flow

### Manual Deployment

```bash
echo $AWS_PROFILE                                    # 1. Confirm environment
pnpm cdk synth --context env=dev && pnpm cdk diff   # 2. Synthesize and review
pnpm test                                            # 3. Run tests
pnpm cdk deploy --all --context env=dev             # 4. Deploy
aws cloudformation describe-stacks --stack-name X   # 5. Verify
```

### Deployment Order

NetworkStack → SecurityStack → DatabaseStack → ComputeStack → ApiStack → MonitoringStack

### Rollback Strategy

```bash
# Rollback to previous version
pnpm cdk deploy --all --context env=dev --rollback

# Emergency: Destroy and rebuild
pnpm cdk destroy ComputeStack-dev && pnpm cdk deploy ComputeStack-dev
```

---

## 4. Blue-Green Deployment (ECS)

Use CodeDeploy for blue-green deployment with canary release and automatic rollback support:

```typescript
new codedeploy.EcsDeploymentGroup(this, 'DeploymentGroup', {
  service: ecsService,
  blueGreenDeploymentConfig: {
    blueTargetGroup, greenTargetGroup, listener, testListener,
  },
  deploymentConfig: codedeploy.EcsDeploymentConfig.LINEAR_10PERCENT_EVERY_1MINUTES,
  autoRollback: { failedDeployment: true, stoppedDeployment: true },
});
```

---

## 5. Secure Deployment

For security standards, see [security.md](security.md)

### Pre-deployment Checks

```bash
pnpm test test/compliance/  # CDK Nag checks
git secrets --scan          # Sensitive information scan
pnpm audit                  # Dependency vulnerability check
```

---

## Related Documents

| Document | Description |
|----------|-------------|
| [architecture.md](architecture.md) | Stack dependencies, environment configuration |
| [security.md](security.md) | Deployment security, IAM permissions |
| [cost-optimization.md](cost-optimization.md) | Environment cost management |
