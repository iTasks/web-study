# AWS Basics

## Introduction

Amazon Web Services (AWS) is the world's most comprehensive and widely adopted cloud platform, offering over 200 fully featured services. This module introduces you to cloud computing concepts and core AWS services that form the foundation of modern cloud infrastructure.

## Learning Objectives

By the end of this module, you will:
- Understand cloud computing models and benefits
- Set up and secure an AWS account
- Navigate the AWS Management Console
- Use AWS CLI for automation
- Work with core AWS services (EC2, S3, IAM, VPC)
- Deploy a simple web application on AWS
- Understand AWS pricing and cost management

## Cloud Computing Fundamentals

### What is Cloud Computing?

Cloud computing is the on-demand delivery of IT resources over the Internet with pay-as-you-go pricing.

**Benefits**:
- ✅ No upfront infrastructure costs
- ✅ Pay only for what you use
- ✅ Scale instantly (up or down)
- ✅ Global reach in minutes
- ✅ Focus on your application, not infrastructure

### Service Models

| Model | Description | Examples | You Manage |
|-------|-------------|----------|------------|
| **IaaS** | Infrastructure as a Service | EC2, VPC | OS, Runtime, App |
| **PaaS** | Platform as a Service | Elastic Beanstalk, RDS | Just your app |
| **SaaS** | Software as a Service | Gmail, Salesforce | Just your data |

### Deployment Models

- **Public Cloud**: AWS, Azure, GCP (resources shared)
- **Private Cloud**: On-premises (dedicated resources)
- **Hybrid Cloud**: Combination of public and private

## AWS Account Setup

### Creating Your Account

1. Go to https://aws.amazon.com/
2. Click "Create an AWS Account"
3. Provide email and account name
4. Enter payment information (required, but Free Tier available)
5. Verify your identity (phone)
6. Choose support plan (Basic - Free)

### Free Tier

AWS Free Tier includes:
- **EC2**: 750 hours/month of t2.micro or t3.micro instances
- **S3**: 5GB storage, 20,000 GET requests, 2,000 PUT requests
- **RDS**: 750 hours/month of db.t2.micro instance
- **Lambda**: 1 million requests/month
- Many other services (see https://aws.amazon.com/free/)

**Important**: Set up billing alerts immediately!

### Security Best Practices for Root Account

```
1. Enable MFA (Multi-Factor Authentication)
   - Security Credentials → MFA → Activate MFA
   - Use Google Authenticator or Authy

2. Never use root account for daily tasks
   - Create IAM users instead

3. Delete root access keys if they exist
   - Security Credentials → Access keys

4. Use a strong, unique password
```

## AWS IAM (Identity and Access Management)

IAM controls who can do what in your AWS account.

### Core Concepts

- **User**: Individual person or application
- **Group**: Collection of users
- **Role**: Set of permissions for AWS services
- **Policy**: JSON document defining permissions

### Creating IAM Users

**Via Console**:
1. Navigate to IAM service
2. Users → Add users
3. Set user name and access type
4. Set permissions (attach policies)
5. Review and create
6. Download credentials

**Via AWS CLI**:
```bash
# Create user
aws iam create-user --user-name devops-user

# Create access key
aws iam create-access-key --user-name devops-user

# Attach policy
aws iam attach-user-policy \
    --user-name devops-user \
    --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

### IAM Best Practices

```
✅ Enable MFA for all users
✅ Use groups to assign permissions
✅ Grant least privilege
✅ Use roles for applications
✅ Rotate credentials regularly
✅ Enable CloudTrail for audit logs
❌ Don't share credentials
❌ Don't embed access keys in code
```

**Hands-On Lab 1**: Create IAM User
```bash
# 1. Create user via console
# 2. Create group "Developers"
# 3. Attach "PowerUserAccess" policy to group
# 4. Add user to group
# 5. Enable MFA
# 6. Create access key for CLI access
```

## AWS CLI Setup

### Installation

**Linux**:
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

**macOS**:
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
aws --version
```

### Configuration

```bash
# Configure AWS CLI
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Default output format (json)

# Test configuration
aws sts get-caller-identity

# View configuration
cat ~/.aws/config
cat ~/.aws/credentials

# Use profiles for multiple accounts
aws configure --profile project1
aws s3 ls --profile project1
```

## Amazon EC2 (Elastic Compute Cloud)

EC2 provides resizable compute capacity in the cloud.

### Key Concepts

- **Instance**: Virtual server
- **AMI (Amazon Machine Image)**: Template for instances
- **Instance Type**: Hardware configuration (t2.micro, m5.large, etc.)
- **Security Group**: Virtual firewall
- **Key Pair**: SSH credentials

### Launching an EC2 Instance

**Via Console**:
```
1. Navigate to EC2 → Launch Instance
2. Choose AMI (e.g., Amazon Linux 2)
3. Choose instance type (t2.micro for Free Tier)
4. Configure instance details
5. Add storage (8GB default)
6. Add tags (Name: MyWebServer)
7. Configure security group
   - Allow SSH (port 22) from your IP
   - Allow HTTP (port 80) from anywhere
8. Review and launch
9. Create/select key pair
10. Download .pem file
```

**Via AWS CLI**:
```bash
# Create key pair
aws ec2 create-key-pair \
    --key-name MyKeyPair \
    --query 'KeyMaterial' \
    --output text > MyKeyPair.pem
chmod 400 MyKeyPair.pem

# Create security group
aws ec2 create-security-group \
    --group-name MySecurityGroup \
    --description "My security group"

# Add SSH rule
aws ec2 authorize-security-group-ingress \
    --group-name MySecurityGroup \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

# Launch instance
aws ec2 run-instances \
    --image-id ami-0c55b159cbfafe1f0 \
    --count 1 \
    --instance-type t2.micro \
    --key-name MyKeyPair \
    --security-groups MySecurityGroup \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyWebServer}]'
```

### Connecting to EC2

```bash
# Get instance public IP
aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=MyWebServer" \
    --query 'Reservations[0].Instances[0].PublicIpAddress'

# Connect via SSH
ssh -i MyKeyPair.pem ec2-user@<PUBLIC-IP>

# Once connected
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>Hello from AWS!</h1>" | sudo tee /var/www/html/index.html
```

**Hands-On Lab 2**: Deploy Web Server on EC2
```bash
# 1. Launch t2.micro instance
# 2. Configure security group (SSH, HTTP)
# 3. Connect via SSH
# 4. Install and configure web server
# 5. Access via browser
# 6. Stop instance when done (save costs)
```

### EC2 Instance States

```
pending → running → stopping → stopped → terminated
           ↓
        rebooting
```

### Managing EC2 Instances

```bash
# List instances
aws ec2 describe-instances

# Stop instance
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Start instance
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Reboot instance
aws ec2 reboot-instances --instance-ids i-1234567890abcdef0

# Terminate instance
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0
```

## Amazon S3 (Simple Storage Service)

S3 is object storage built to store and retrieve any amount of data.

### Key Concepts

- **Bucket**: Container for objects (globally unique name)
- **Object**: File and metadata
- **Key**: Unique identifier for an object
- **Region**: Geographic location

### Working with S3

**Create Bucket**:
```bash
# Via CLI
aws s3 mb s3://my-unique-bucket-name-12345

# Via high-level commands
aws s3 ls                           # List buckets
```

**Upload Files**:
```bash
# Upload single file
aws s3 cp file.txt s3://my-bucket/

# Upload directory
aws s3 cp ./mydir s3://my-bucket/mydir --recursive

# Sync directory
aws s3 sync ./local-dir s3://my-bucket/remote-dir
```

**Download Files**:
```bash
# Download single file
aws s3 cp s3://my-bucket/file.txt ./

# Download directory
aws s3 cp s3://my-bucket/mydir ./mydir --recursive

# Sync directory
aws s3 sync s3://my-bucket/remote-dir ./local-dir
```

**Manage Files**:
```bash
# List objects
aws s3 ls s3://my-bucket/
aws s3 ls s3://my-bucket/ --recursive

# Delete file
aws s3 rm s3://my-bucket/file.txt

# Delete directory
aws s3 rm s3://my-bucket/mydir --recursive

# Move file
aws s3 mv s3://my-bucket/old.txt s3://my-bucket/new.txt
```

**Delete Bucket**:
```bash
# Empty bucket first
aws s3 rm s3://my-bucket --recursive

# Delete bucket
aws s3 rb s3://my-bucket
```

### S3 Storage Classes

| Class | Use Case | Retrieval Time |
|-------|----------|----------------|
| **Standard** | Frequently accessed | Immediate |
| **Intelligent-Tiering** | Unknown access patterns | Automatic |
| **Standard-IA** | Infrequent access | Immediate |
| **Glacier** | Archive | Minutes to hours |
| **Glacier Deep Archive** | Long-term archive | Hours |

**Hands-On Lab 3**: Static Website Hosting
```bash
# Create bucket
aws s3 mb s3://my-website-bucket-12345

# Create index.html
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>My S3 Website</title></head>
<body>
    <h1>Hello from S3!</h1>
    <p>This is hosted on Amazon S3.</p>
</body>
</html>
EOF

# Upload with public-read ACL
aws s3 cp index.html s3://my-website-bucket-12345/ --acl public-read

# Enable static website hosting
aws s3 website s3://my-website-bucket-12345/ \
    --index-document index.html

# Access: http://my-website-bucket-12345.s3-website-us-east-1.amazonaws.com
```

## Amazon VPC (Virtual Private Cloud)

VPC is your isolated virtual network in AWS.

### Key Components

- **VPC**: Virtual network
- **Subnet**: Segment of VPC IP range
- **Internet Gateway**: Connect to internet
- **Route Table**: Traffic routing rules
- **Security Group**: Instance-level firewall
- **NACL**: Subnet-level firewall

### Default VPC

- Every AWS account has a default VPC in each region
- Has internet gateway attached
- Has public subnets
- Suitable for getting started

```bash
# Describe your default VPC
aws ec2 describe-vpcs --filters "Name=isDefault,Values=true"

# List subnets
aws ec2 describe-subnets
```

## AWS Regions and Availability Zones

### Regions

AWS has data centers globally grouped into Regions:
- us-east-1 (N. Virginia)
- us-west-2 (Oregon)
- eu-west-1 (Ireland)
- ap-southeast-1 (Singapore)
- And many more...

### Availability Zones (AZs)

Each Region has multiple isolated AZs (typically 3-6):
- us-east-1a, us-east-1b, us-east-1c, etc.
- Physically separated for fault tolerance
- Low-latency connections between AZs

```bash
# List regions
aws ec2 describe-regions

# List availability zones
aws ec2 describe-availability-zones --region us-east-1
```

## Cost Management

### Understanding AWS Pricing

- **Pay-as-you-go**: No upfront costs
- **Save when you reserve**: Reserved instances
- **Pay less as you grow**: Volume discounts
- **Stop paying when you stop using**: No termination fees

### Setting Up Billing Alerts

```bash
# 1. Enable billing alerts
# AWS Console → Billing → Billing Preferences
# ✓ Receive Billing Alerts

# 2. Create CloudWatch alarm via console
# CloudWatch → Alarms → Create Alarm
# - Metric: Billing → Total Estimated Charge
# - Condition: > $5
# - Notification: Create SNS topic with email
```

### Cost Optimization Tips

```
✅ Use Free Tier services
✅ Stop instances when not in use
✅ Delete unused resources (EBS volumes, snapshots)
✅ Use t2.micro/t3.micro for testing
✅ Set up auto-shutdown for development instances
✅ Use Spot Instances for non-critical workloads
✅ Monitor with Cost Explorer
✅ Clean up regularly
```

## Hands-On Capstone Project

Deploy a complete web application on AWS:

### Project Requirements
1. Launch EC2 instance with web server
2. Store static files in S3
3. Configure security groups properly
4. Set up IAM user with minimal permissions
5. Implement cost monitoring

### Implementation Steps

```bash
# 1. Create IAM user for project
aws iam create-user --user-name webapp-user

# 2. Create S3 bucket for static files
aws s3 mb s3://my-webapp-assets-12345

# 3. Launch EC2 instance
aws ec2 run-instances \
    --image-id ami-0c55b159cbfafe1f0 \
    --instance-type t2.micro \
    --key-name MyKeyPair \
    --security-groups WebServerSG \
    --user-data file://user-data.sh \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=WebApp}]'

# 4. user-data.sh (bootstrap script)
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
aws s3 cp s3://my-webapp-assets-12345/index.html /var/www/html/

# 5. Upload website files to S3
aws s3 sync ./website s3://my-webapp-assets-12345/

# 6. Configure security group
aws ec2 authorize-security-group-ingress \
    --group-name WebServerSG \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0
```

## Assessment Checklist

Before moving to Level 2, ensure you can:

- [ ] Create and secure an AWS account
- [ ] Set up billing alerts
- [ ] Create IAM users, groups, and policies
- [ ] Configure AWS CLI with credentials
- [ ] Launch and connect to EC2 instances
- [ ] Manage EC2 instance states
- [ ] Create and manage S3 buckets
- [ ] Upload and download files to/from S3
- [ ] Understand VPC basics
- [ ] Use AWS CLI for common tasks
- [ ] Monitor AWS costs
- [ ] Clean up resources to avoid charges

## Additional Resources

- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS Documentation](https://docs.aws.amazon.com/)
- [AWS Getting Started](https://aws.amazon.com/getting-started/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS Training and Certification](https://aws.amazon.com/training/)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/)

## Next Steps

After mastering AWS basics:
- **Complete the Level 1 Capstone Project**
- **Prepare for AWS Certified Cloud Practitioner**
- **Move to Level 2: Intermediate** (CI/CD, Kubernetes, IaC)

---

**Important Reminders**:
- Always stop/terminate resources when not in use
- Monitor your AWS billing dashboard regularly
- Never commit AWS credentials to version control
- Use IAM roles for applications, not access keys

Happy cloud computing! ☁️
