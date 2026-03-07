# Project Configuration - {{PROJECT_NAME}} Infrastructure

> **Purpose**: Project-specific configuration for {{PROJECT_NAME}}, including Stack list, environment configuration, Construct list, and cost tags.

> **Positioning**: This file supplements CLAUDE.md with **project-specific business configuration**.
> **Principle**: Common standards go in `rules/`, project-specific information goes here.
> For architecture standards, see [rules/architecture.md](rules/architecture.md)

---

## Project Information

| Configuration | Value |
|---------------|-------|
| **Project name** | {{PROJECT_SLUG}}-infra |
| **Project description** | TODO: Fill in project description |
| **Architecture pattern** | CDK Construct layering (L1 → L2 → L3) |
| **Tech stack versions** | See [tech-stack.md](rules/tech-stack.md) |
| **Source root path** | `lib` |

---

## Stack List

Stack design standards at [architecture.md §2.1](rules/architecture.md#21-stack-responsibilities)

**Project Stacks**:

| Stack | Dependencies |
|-------|-------------|
| `NetworkStack` | - |
| `SecurityStack` | NetworkStack |
| `DatabaseStack` | NetworkStack, SecurityStack |
| `ComputeStack` | NetworkStack, SecurityStack |
| `ApiStack` | ComputeStack |
| `MonitoringStack` | All Stacks |

> TODO: Adjust Stack list based on actual project requirements

---

## Environment Configuration

> **Design principle**: Use CDK Context to manage configuration for different environments.

### Environment Definitions

| Environment | AWS Account | Region | Purpose |
|-------------|------------|--------|---------|
| `dev` | TODO | TODO | Development testing |
| `staging` | TODO | TODO | Pre-release validation |
| `prod` | TODO | TODO | Production |

### CDK Context Configuration

Detailed configuration structure at [deployment.md §1.1](rules/deployment.md#11-cdk-context)

**Project configuration values**: See environment table above

---

## Construct List

> **Location convention**: Custom Constructs go under `lib/constructs/`.

| Construct | Responsibility | Composed Resources |
|-----------|---------------|-------------------|
| TODO | TODO | TODO |

> TODO: Fill in Construct list based on actual project requirements

---

## Naming Conventions

**Project prefix**: `{{PROJECT_SLUG}}`
**Stack naming**: `{{PROJECT_SLUG}}-{Resource}Stack-{env}`

---

## Architecture Compliance Rules

> **Detailed rules**: See [rules/security.md](rules/security.md) and [rules/architecture.md](rules/architecture.md)

### CDK Nag Checks

```typescript
// bin/app.ts
import { Aspects } from 'aws-cdk-lib';
import { AwsSolutionsChecks } from 'cdk-nag';

// Apply AWS Solutions checks
Aspects.of(app).add(new AwsSolutionsChecks({ verbose: true }));
```

### Violation Detection

| Violation Type | Rule | Severity |
|---------------|------|----------|
| Public S3 Bucket | AwsSolutions-S3 | Blocking |
| Overly broad IAM permissions | AwsSolutions-IAM4 | Blocking |
| Unencrypted storage | AwsSolutions-RDS10 | Warning |
| Missing access logs | AwsSolutions-ELB2 | Warning |

---

## Cost Tags

> **Principle**: All resources must include cost tags for cost allocation.

```typescript
// Required tags
const requiredTags = {
  Project: '{{PROJECT_SLUG}}',
  Environment: env,
  ManagedBy: 'cdk',
  CostCenter: 'TODO: Fill in cost center',
};

// Apply tags
Tags.of(app).add('Project', '{{PROJECT_SLUG}}');
Tags.of(app).add('Environment', env);
```

---

## PR Review Checklist

Full checklist at [rules/checklist.md](rules/checklist.md)
