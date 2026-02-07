# Cost Optimization Standards

> **Purpose**: Define resource selection, environment resource matrix, storage optimization, network optimization, and cost monitoring strategies.

> Consult this document first when Claude designs CDK infrastructure

---

## 0. Quick Reference Card

### Environment Resource Matrix

| Resource | Dev | Staging | Prod |
|----------|-----|---------|------|
| EC2/ECS | t3.small, On-Demand | t3.medium, On-Demand | t3.large, Reserved |
| RDS | db.t3.small, Single-AZ | db.t3.medium, Multi-AZ | db.r6g.large, Multi-AZ, Reserved |
| NAT Gateway | 1 | 2 | 3 (per AZ) |
| Lambda | Default | Default | ARM + optimized memory |

### Required Tags

```typescript
// bin/app.ts - Apply to all resources
const requiredTags = { Project: '{{PROJECT_SLUG}}', Environment: envName, CostCenter: '<!-- TODO: Please fill in the cost center -->', ManagedBy: 'cdk' };
Object.entries(requiredTags).forEach(([k, v]) => cdk.Tags.of(app).add(k, v));

// Prod additional tags
if (envName === 'prod') cdk.Tags.of(app).add('Criticality', 'high');
```

---

## 1. Compute Optimization

### Dev Scheduled Scaling (Required)

```typescript
// Dev: Scale down to 0 during non-working hours
if (envName === 'dev') {
  scaling.scaleOnSchedule('Down', { schedule: cron({ hour: '20' }), minCapacity: 0 });
  scaling.scaleOnSchedule('Up',   { schedule: cron({ hour: '8' }),  minCapacity: 1 });
}
```

### Lambda Optimization

```typescript
architecture: lambda.Architecture.ARM_64,  // ~20% cost savings
memorySize: envConfig.lambdaMemory ?? 256, // Use Power Tuning to determine optimal value
```

---

## 2. Storage Optimization

### S3 Lifecycle (Required)

```typescript
lifecycleRules: [
  { transitions: [
      { storageClass: s3.StorageClass.INFREQUENT_ACCESS, transitionAfter: cdk.Duration.days(30) },
      { storageClass: s3.StorageClass.GLACIER, transitionAfter: cdk.Duration.days(90) },
  ]},
  { noncurrentVersionExpiration: cdk.Duration.days(30) },
  { abortIncompleteMultipartUploadAfter: cdk.Duration.days(7) },
],
```

### EBS: gp3 Over gp2

```typescript
volumeType: ec2.EbsDeviceVolumeType.GP3,  // Customizable IOPS/throughput, lower cost
```

---

## 3. Network Optimization

### NAT Gateway Strategy

| Environment | NAT Configuration | Cost Reference |
|-------------|------------------|---------------|
| Dev | 1 or NAT Instance | ~$4/month (Instance) vs ~$30/month (Gateway) |
| Prod | One per AZ | High availability |

### VPC Endpoints (Reduce NAT Traffic)

```typescript
// Gateway Endpoints (free)
vpc.addGatewayEndpoint('S3', { service: ec2.GatewayVpcEndpointAwsService.S3 });
vpc.addGatewayEndpoint('DynamoDB', { service: ec2.GatewayVpcEndpointAwsService.DYNAMODB });

// Interface Endpoints (Prod as needed)
if (envName === 'prod') {
  vpc.addInterfaceEndpoint('SecretsManager', { service: ec2.InterfaceVpcEndpointAwsService.SECRETS_MANAGER });
}
```

---

## 4. Resource Cleanup

### CloudWatch Logs Retention

```typescript
retention: envName === 'prod' ? logs.RetentionDays.ONE_YEAR : logs.RetentionDays.ONE_WEEK,
```

> For RemovalPolicy strategy, see deployment.md §1

---

## 5. Cost Monitoring

### Budget Alerts

```typescript
new budgets.CfnBudget(this, 'Budget', {
  budget: {
    budgetLimit: { amount: envName === 'prod' ? 1000 : 100, unit: 'USD' },
    budgetType: 'COST',
    timeUnit: 'MONTHLY',
  },
  notificationsWithSubscribers: [{
    notification: { threshold: 80, thresholdType: 'PERCENTAGE', comparisonOperator: 'GREATER_THAN', notificationType: 'ACTUAL' },
    subscribers: [{ address: '<!-- TODO: Please fill in the alert email -->', subscriptionType: 'EMAIL' }],
  }],
});
```

Enable cost allocation tags in the Billing Console: `Project`, `Environment`, `CostCenter`

---

## 6. Audit Checklist

**Monthly**: Unused EBS volumes | Unassociated Elastic IPs | Idle LBs | RI utilization | S3 storage classes

**Quarterly**: RI/Savings Plans renewal | Instance type evaluation | Spot opportunities | Cross-region transfer
