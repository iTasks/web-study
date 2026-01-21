# Level 1: Fundamentals - Examples

This directory contains hands-on examples for foundational DevOps and AWS concepts.

## 📁 Available Examples

### Linux Basics (`linux-basics/examples/`)
Practical shell scripts demonstrating Linux fundamentals:
- **01-file-operations.sh** - File and directory management
- **02-text-processing.sh** - grep, sed, awk for log analysis
- **03-system-info.sh** - System information gathering
- **04-backup-script.sh** - Automated backup with retention

**Quick Start:**
```bash
cd linux-basics/examples
chmod +x *.sh
./01-file-operations.sh
```

### Docker Introduction (`docker-intro/examples/`)
Containerization examples from basics to multi-container apps:
- **01-simple-webapp/** - Flask app with Dockerfile
- **03-docker-compose/** - Multi-container application stack

**Quick Start:**
```bash
cd docker-intro/examples/01-simple-webapp
docker build -t flask-app:1.0 .
docker run -p 5000:5000 flask-app:1.0
```

### Git & GitHub (`git-github/examples/`)
Version control workflows and best practices:
- **01-basic-workflow/** - Complete Git workflow guide
- Feature branching, PR process, and collaboration

**Quick Start:**
```bash
cd git-github/examples/01-basic-workflow
# Follow the README for step-by-step workflow
```

### Networking Basics (`networking-basics/examples/`)
Network diagnostics and troubleshooting:
- **network-diagnostics.sh** - Comprehensive network testing tool

**Quick Start:**
```bash
cd networking-basics/examples
chmod +x network-diagnostics.sh
./network-diagnostics.sh
```

### AWS Basics (`aws-basics/examples/`)
Infrastructure as Code with AWS:
- **01-ec2-terraform/** - EC2 instance provisioning with Terraform

**Quick Start:**
```bash
cd aws-basics/examples/01-ec2-terraform
terraform init
terraform plan
terraform apply
# Don't forget: terraform destroy
```

## 🎯 Learning Path

1. **Week 1**: Start with Linux basics scripts
2. **Week 2**: Practice Git workflows
3. **Week 3**: Build and run Docker containers
4. **Week 4**: Deploy to AWS with Terraform

## 💡 Tips for Success

- **Execute Every Example**: Learning by doing is essential
- **Modify and Experiment**: Change parameters and see what happens
- **Read the Code**: Understand each line before running
- **Clean Up**: Always destroy cloud resources after practice
- **Take Notes**: Document what you learn

## ⚠️ Important Notes

### For AWS Examples
- **Costs**: Most examples use Free Tier eligible resources
- **Cleanup**: Always run `terraform destroy` to avoid charges
- **Credentials**: Never commit AWS credentials to Git
- **Billing Alerts**: Set up alerts at $5, $10, $25

### For Docker Examples
- **Resources**: Ensure Docker has adequate RAM (4GB+)
- **Cleanup**: Remove unused images and containers regularly
- **Networks**: Examples create custom networks - clean up after

## 📚 Additional Resources

- [Linux Command Line Cheat Sheet](https://cheatography.com/davechild/cheat-sheets/linux-command-line/)
- [Docker Documentation](https://docs.docker.com/)
- [Git Documentation](https://git-scm.com/doc)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [Terraform Tutorials](https://learn.hashicorp.com/terraform)

## 🆘 Troubleshooting

### Common Issues

**Linux Scripts**
- Permission denied → `chmod +x script.sh`
- Command not found → Check if tool is installed

**Docker**
- Permission denied → Add user to docker group
- Port conflicts → Change port mapping or stop conflicting service

**AWS/Terraform**
- Authentication errors → Run `aws configure`
- Resource conflicts → Use unique names or change region

**Git**
- Merge conflicts → Learn to resolve manually
- Push rejected → Pull latest changes first

## ✅ Completion Checklist

Before moving to Level 2, ensure you can:
- [ ] Write and execute shell scripts
- [ ] Use Git for version control
- [ ] Build and run Docker containers
- [ ] Create Dockerfiles
- [ ] Use Docker Compose
- [ ] Provision AWS resources with Terraform
- [ ] Understand basic networking concepts

---

**Ready for more?** Once you've mastered these fundamentals, proceed to [Level 2: Intermediate](/devops-aws/02-intermediate/)
