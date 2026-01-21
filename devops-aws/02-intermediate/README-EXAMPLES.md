# Level 2: Intermediate Examples

This directory contains practical examples for intermediate DevOps and AWS concepts.

## Available Examples

### CI/CD Pipelines
- **github-actions-cicd.yml** - Complete CI/CD pipeline with GitHub Actions
  - Multi-stage build and test
  - Docker image building and pushing
  - Automated deployment to staging/production
  - Integration with Slack notifications

### Terraform IaC
Check `/terraform-iac/examples/` for:
- VPC with public/private subnets
- Auto-scaling groups with load balancers
- RDS database with backup configuration
- Modular infrastructure design

### Kubernetes Basics
- **deployment-with-hpa.yaml** - Kubernetes deployment with autoscaling
  - Horizontal Pod Autoscaler (HPA)
  - Resource limits and requests
  - Health checks (liveness/readiness probes)
  - LoadBalancer service

### AWS Core Services
Check `/aws-core-services/examples/` for:
- VPC networking examples
- Application Load Balancer configuration
- RDS Multi-AZ deployment
- Auto Scaling Groups

## Usage

Each example includes:
- Complete, working configurations
- Detailed README with setup instructions
- Best practices and learning points
- Cost estimates where applicable

## Prerequisites

- AWS account with appropriate permissions
- kubectl configured for Kubernetes examples
- Terraform installed for IaC examples
- GitHub account for CI/CD examples

## Getting Started

1. Choose an example that matches your learning goal
2. Read the README in each example directory
3. Follow the setup instructions
4. Experiment and modify to deepen understanding
5. Always clean up resources to avoid unnecessary costs
