# DevOps and AWS Management - Zero to Expert

## Purpose

This directory provides a comprehensive learning path for DevOps practices and AWS cloud management, taking you from absolute beginner to expert level. The content is structured progressively, with hands-on examples, best practices, and real-world scenarios.

## Why DevOps and AWS?

DevOps combines software development (Dev) and IT operations (Ops) to shorten the development lifecycle and provide continuous delivery with high software quality. AWS (Amazon Web Services) is the world's most comprehensive and broadly adopted cloud platform, making it essential for modern DevOps practices.

## Learning Path Structure

This course is organized into four progressive levels:

### 📚 Level 1: Fundamentals (Weeks 1-4)
**Target**: Complete beginners with no prior DevOps or cloud experience

Topics covered:
- Linux command line and shell scripting
- Version control with Git and GitHub
- Basic networking concepts
- Introduction to cloud computing
- Docker containers basics
- AWS account setup and core concepts

**Location**: `01-fundamentals/`

### 🔧 Level 2: Intermediate (Weeks 5-10)
**Target**: Those with basic understanding seeking practical skills

Topics covered:
- CI/CD pipelines (Jenkins, GitHub Actions, GitLab CI)
- Infrastructure as Code with Terraform
- Kubernetes fundamentals
- AWS core services (EC2, S3, RDS, VPC)
- Configuration management (Ansible)
- Container orchestration basics

**Location**: `02-intermediate/`

### 🚀 Level 3: Advanced (Weeks 11-18)
**Target**: Practitioners ready for production-grade implementations

Topics covered:
- Advanced Kubernetes (Helm, operators, service mesh)
- AWS advanced services (ECS, EKS, Lambda, Step Functions, CloudFormation)
- Monitoring and observability (Prometheus, Grafana, CloudWatch)
- Security and compliance (IAM, secrets management, security scanning)
- High availability and disaster recovery
- Cost optimization and resource management

**Location**: `03-advanced/`

### 🏆 Level 4: Expert (Weeks 19-24)
**Target**: Senior practitioners and architects

Topics covered:
- Multi-cloud and hybrid cloud architectures
- Advanced networking (Transit Gateway, PrivateLink, service mesh)
- GitOps and advanced deployment strategies
- Platform engineering and internal developer platforms
- Chaos engineering and resilience testing
- Enterprise DevOps transformation
- Advanced AWS architectures (Well-Architected Framework)

**Location**: `04-expert/`

## Quick Start

### Prerequisites
- Computer with Linux, macOS, or Windows (with WSL2)
- Internet connection
- Text editor or IDE (VS Code recommended)
- Willingness to learn and experiment!

### Getting Started
1. Start with the [Study Plan](STUDY-PLAN.md) to understand the learning roadmap
2. Follow the levels sequentially: `01-fundamentals/` → `02-intermediate/` → `03-advanced/` → `04-expert/`
3. Complete hands-on labs and projects in each section
4. Build your own projects to reinforce learning

### Setting Up Your Environment

#### For AWS Practice
1. Create a free AWS account at https://aws.amazon.com/free/
2. Set up AWS CLI and configure credentials
3. **Important**: Use AWS Free Tier to minimize costs
4. Set up billing alerts to avoid unexpected charges

#### For Local Development
```bash
# Install essential tools
# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

## Project Structure

```
devops-aws/
├── README.md                          # This file
├── STUDY-PLAN.md                      # Detailed 24-week curriculum
├── 01-fundamentals/                   # Level 1: Beginner content
│   ├── README.md
│   ├── EXAMPLES.md                    # ⭐ Examples overview
│   ├── linux-basics/
│   │   └── examples/                  # Shell scripts and automation
│   ├── git-github/
│   │   └── examples/                  # Git workflows
│   ├── networking-basics/
│   │   └── examples/                  # Network diagnostics
│   ├── docker-intro/
│   │   └── examples/                  # Dockerfiles and apps
│   └── aws-basics/
│       └── examples/                  # Terraform EC2 example
├── 02-intermediate/                   # Level 2: Intermediate content
│   ├── README.md
│   ├── README-EXAMPLES.md             # ⭐ Examples overview
│   ├── ci-cd-pipelines/
│   │   └── examples/                  # GitHub Actions workflows
│   ├── kubernetes-basics/
│   │   └── examples/                  # K8s deployments
│   ├── terraform-iac/
│   │   └── examples/                  # Infrastructure templates
│   ├── aws-core-services/
│   │   └── examples/                  # VPC, RDS, ALB configs
│   └── configuration-management/
├── 03-advanced/                       # Level 3: Advanced content
│   ├── README.md
│   ├── README-EXAMPLES.md             # ⭐ Examples overview
│   ├── kubernetes-advanced/
│   │   └── examples/                  # Helm charts, operators
│   ├── aws-advanced-services/
│   │   └── examples/                  # Lambda, ECS, EKS
│   ├── monitoring-observability/
│   │   └── examples/                  # Prometheus, Grafana
│   ├── security-compliance/
│   │   └── examples/                  # IAM policies, security
│   └── high-availability/
│       └── examples/                  # Multi-AZ architectures
└── 04-expert/                         # Level 4: Expert content
    ├── README.md
    ├── README-EXAMPLES.md             # ⭐ Examples overview
    ├── multi-cloud/
    │   └── examples/                  # Multi-cloud templates
    ├── advanced-networking/
    │   └── examples/                  # Service mesh configs
    ├── gitops/
    │   └── examples/                  # ArgoCD applications
    ├── platform-engineering/
    │   └── examples/                  # Golden path templates
    ├── chaos-engineering/
    │   └── examples/                  # Chaos experiments
    └── enterprise-devops/
        └── examples/                  # Enterprise architectures
```

## Learning Approach

### Hands-On First
Every concept includes practical examples and labs. Learning is most effective when you practice.

**📂 Examples Available**: Each level now includes comprehensive examples:
- **Level 1**: Shell scripts, Dockerfiles, Terraform templates, Git workflows
- **Level 2**: CI/CD pipelines, Kubernetes manifests, IaC configurations
- **Level 3**: Helm charts, Lambda functions, monitoring stacks, security configs
- **Level 4**: GitOps apps, chaos experiments, multi-cloud templates

See the `examples/` directory in each module or check the `EXAMPLES.md` file in each level.

### Build Real Projects
Each level includes capstone projects that simulate real-world scenarios:
- **Fundamentals**: Deploy a simple web application
- **Intermediate**: Build a complete CI/CD pipeline
- **Advanced**: Design and implement a microservices platform
- **Expert**: Architect a multi-region, highly available system

### Community and Resources
- AWS Free Tier: https://aws.amazon.com/free/
- AWS Documentation: https://docs.aws.amazon.com/
- Kubernetes Documentation: https://kubernetes.io/docs/
- DevOps Roadmap: https://roadmap.sh/devops
- AWS Well-Architected Framework: https://aws.amazon.com/architecture/well-architected/

## Certification Paths

After completing this course, you'll be prepared for:
- **AWS Certified Cloud Practitioner** (after Level 1)
- **AWS Certified Solutions Architect - Associate** (after Level 2)
- **AWS Certified DevOps Engineer - Professional** (after Level 3)
- **AWS Certified Solutions Architect - Professional** (after Level 4)
- **Certified Kubernetes Administrator (CKA)** (after Level 2-3)
- **Certified Kubernetes Application Developer (CKAD)** (after Level 2-3)

## Cost Management

**Important**: Cloud resources cost money. Follow these practices:
- Always use the AWS Free Tier when possible
- Destroy resources after practice sessions
- Set up billing alerts
- Use `terraform destroy` or cleanup scripts
- Never commit AWS credentials to Git

## Contributing

Contributions are welcome! Please ensure:
1. Examples are tested and working
2. Documentation is clear and comprehensive
3. Code follows best practices
4. Sensitive information is never committed

## Support

- Check the README in each level for specific guidance
- Review the STUDY-PLAN.md for the learning sequence
- Refer to official documentation for detailed information

## License

This educational content is provided for learning purposes. Cloud service usage is subject to provider terms.

---

**Ready to begin?** Start with [STUDY-PLAN.md](STUDY-PLAN.md) or jump straight into [01-fundamentals/](01-fundamentals/)!
