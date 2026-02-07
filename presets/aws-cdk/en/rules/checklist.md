# PR Review Checklist

> **Purpose**: Single Source of Truth (SSoT) for the PR Review checklist, covering architecture, design, security, testing, deployment, and cost check items.

---

## Layering & Architecture

- [ ] Custom Constructs are placed in `lib/constructs/`
- [ ] Stacks are placed in `lib/stacks/`
- [ ] New Stacks are added to the Stack list in project-config.md
- [ ] No direct cross-Stack resource references
- [ ] Construct dependency direction is correct (L3 → L2 → L1)

See [architecture.md](architecture.md)

---

## Construct Design

- [ ] Props use `readonly` modifier
- [ ] Optional parameters have sensible defaults
- [ ] Necessary public properties are exposed
- [ ] JSDoc comments are present

See [construct-design.md](construct-design.md)

---

## Security

- [ ] Grant methods are used instead of manual IAM policies
- [ ] Sensitive information is stored in Secrets Manager
- [ ] S3 Buckets block public access
- [ ] RDS is in private subnets and encrypted
- [ ] CDK Nag checks pass
- [ ] No `actions: ['*']` or `resources: ['*']`

See [security.md](security.md)

---

## Testing

- [ ] Each Construct has corresponding tests
- [ ] Critical properties have fine-grained assertions
- [ ] Snapshot tests detect unintended changes
- [ ] Coverage meets requirements (>=85%)

See [testing.md](testing.md)

---

## Deployment

- [ ] Environment configuration uses CDK Context
- [ ] Appropriate RemovalPolicy is set
- [ ] `cdk diff` confirms changes
- [ ] Rollback plan is in place

See [deployment.md](deployment.md)

---

## Cost

- [ ] All resources have cost tags
- [ ] Dev environment uses minimum specs
- [ ] S3 has lifecycle rules

See [cost-optimization.md](cost-optimization.md)

---

## Project Structure

- [ ] Tests and source code are in corresponding directories
- [ ] No hardcoded accounts or regions
- [ ] cdk.context.json is not committed

See [project-structure.md](project-structure.md)

---

## Pre-commit One-click Validation

For the complete validation command, see [CLAUDE.md §PR Review Checklist](../CLAUDE.md#pr-review-checklist)
