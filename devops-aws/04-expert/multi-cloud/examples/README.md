# Multi-Cloud Terraform Module

[← Back to Level 4: Expert](../../README.md) | [DevOps & AWS](../../../README.md) | [Main README](../../../../README.md)

This example demonstrates a cloud-agnostic approach to deploying infrastructure.

## Supported Clouds

- AWS
- Google Cloud Platform (GCP)
- Microsoft Azure

## Variables

```hcl
variable "cloud_provider" {
  description = "Cloud provider (aws, gcp, azure)"
  type        = string
}

variable "region" {
  description = "Cloud region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
```

## Usage

### AWS
```hcl
module "infrastructure" {
  source = "./multi-cloud-module"
  
  cloud_provider = "aws"
  region         = "us-east-1"
  environment    = "production"
}
```

### GCP
```hcl
module "infrastructure" {
  source = "./multi-cloud-module"
  
  cloud_provider = "gcp"
  region         = "us-central1"
  environment    = "production"
}
```

### Azure
```hcl
module "infrastructure" {
  source = "./multi-cloud-module"
  
  cloud_provider = "azure"
  region         = "eastus"
  environment    = "production"
}
```

## Benefits

- **Avoid Vendor Lock-in**: Easy to switch providers
- **Multi-Region**: Deploy across multiple clouds
- **Consistency**: Same interface for all clouds
- **Flexibility**: Choose best cloud for each workload
