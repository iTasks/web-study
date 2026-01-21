# Multi-AZ VPC with Terraform

This Terraform configuration creates a production-ready VPC with public and private subnets across multiple availability zones.

## Architecture

```
VPC (10.0.0.0/16)
├── Public Subnets (2 AZs)
│   ├── 10.0.0.0/24 (AZ-1)
│   └── 10.0.1.0/24 (AZ-2)
├── Private Subnets (2 AZs)
│   ├── 10.0.10.0/24 (AZ-1)
│   └── 10.0.11.0/24 (AZ-2)
├── Internet Gateway
└── NAT Gateways (1 per AZ)
```

## Features

- Multi-AZ deployment for high availability
- Public subnets with internet gateway
- Private subnets with NAT gateways
- Remote state in S3 with locking
- Environment-based configuration
- Proper route table associations

## Prerequisites

1. AWS account with appropriate permissions
2. S3 bucket for Terraform state
3. DynamoDB table for state locking
4. Terraform installed (>= 1.0)

## Usage

### Initialize

```bash
terraform init
```

### Plan

```bash
# Development environment
terraform plan -var="environment=dev"

# Production environment
terraform plan -var="environment=prod" -var="vpc_cidr=10.1.0.0/16"
```

### Apply

```bash
terraform apply -var="environment=dev"
```

### Destroy

```bash
terraform destroy -var="environment=dev"
```

## Variables

- `aws_region` - AWS region (default: us-east-1)
- `environment` - Environment name (default: dev)
- `vpc_cidr` - VPC CIDR block (default: 10.0.0.0/16)

## Outputs

- `vpc_id` - VPC ID
- `public_subnet_ids` - List of public subnet IDs
- `private_subnet_ids` - List of private subnet IDs
- `nat_gateway_ids` - List of NAT gateway IDs

## Cost Estimate

- **NAT Gateways**: ~$0.045/hour each (~$65/month for 2)
- **VPC**: Free
- **Subnets**: Free
- **Route Tables**: Free
- **Internet Gateway**: Free

## Customization

For production:
1. Update backend configuration with your S3 bucket
2. Adjust CIDR blocks for your network design
3. Consider adding VPC Flow Logs
4. Add additional subnet tiers if needed
5. Implement VPC peering if required

## Best Practices

✅ Multi-AZ for high availability
✅ Separate public/private subnets
✅ NAT gateway per AZ
✅ Remote state management
✅ Resource tagging
✅ DNS support enabled
