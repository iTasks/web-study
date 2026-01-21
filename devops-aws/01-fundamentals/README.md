# Level 1: Fundamentals

## Overview

Welcome to Level 1 of the DevOps and AWS Management learning path! This level is designed for complete beginners and covers the foundational skills you need before diving into advanced DevOps practices.

**Duration**: 4 weeks (40-60 hours)
**Difficulty**: Beginner
**Prerequisites**: None - just basic computer skills and enthusiasm to learn!

## What You'll Learn

By the end of this level, you will:
- Navigate and manage Linux systems confidently
- Use Git for version control and collaborate on GitHub
- Understand basic networking concepts
- Create and manage Docker containers
- Set up and use core AWS services
- Deploy a simple web application to the cloud

## Module Structure

### Week 1: [Linux Basics](linux-basics/)
Learn the command line and shell scripting fundamentals.

**Key Topics**:
- Linux file system and navigation
- File operations and permissions
- Text processing and manipulation
- Process management
- Shell scripting basics

**Time**: 10-15 hours

---

### Week 2: [Git and GitHub](git-github/)
Master version control and collaborative development.

**Key Topics**:
- Git fundamentals and workflows
- Branching and merging
- GitHub collaboration
- Pull requests and code reviews
- Best practices

**Time**: 10-15 hours

---

### Week 3: [Networking Basics](networking-basics/) and [Docker Introduction](docker-intro/)
Understand networking fundamentals and containerization.

**Key Topics**:
- TCP/IP, DNS, and HTTP
- Networking tools and debugging
- Container concepts
- Docker basics and Dockerfile
- Container management

**Time**: 10-15 hours

---

### Week 4: [AWS Basics](aws-basics/)
Get started with cloud computing and AWS.

**Key Topics**:
- Cloud computing concepts
- AWS account setup
- IAM and security
- EC2 and compute services
- S3 and storage

**Time**: 10-15 hours

---

## Learning Path

```
Week 1: Linux Basics
   ↓
Week 2: Git & GitHub
   ↓
Week 3: Networking & Docker
   ↓
Week 4: AWS Basics
   ↓
Capstone Project
```

## Hands-On Projects

Each week includes practical exercises and mini-projects:

1. **Week 1**: Write shell scripts to automate system tasks
2. **Week 2**: Collaborate on a GitHub repository with branching and PRs
3. **Week 3**: Containerize a web application with Docker
4. **Week 4**: Deploy an application to AWS EC2

## Capstone Project

**Project**: Deploy a Containerized Web Application to AWS

Combine everything you've learned to:
1. Create a simple web application
2. Write a Dockerfile to containerize it
3. Use Git to version control your code
4. Deploy the container to an AWS EC2 instance
5. Make the application accessible via the internet

**Deliverables**:
- GitHub repository with your application code
- Dockerfile for the application
- Documentation on how to deploy
- Running application on AWS

## Prerequisites

### Software to Install
- Linux environment (Ubuntu recommended, or WSL2 for Windows)
- Text editor (VS Code, vim, or nano)
- Web browser
- Terminal emulator

### Accounts to Create
- GitHub account (free)
- AWS account (with Free Tier)

### Hardware Requirements
- Modern computer (Windows, macOS, or Linux)
- At least 8GB RAM
- 20GB free disk space
- Stable internet connection

## Study Tips

### For Success
1. **Hands-On First**: Don't just read - practice every command and example
2. **Take Notes**: Document what you learn in your own words
3. **Break It Down**: If something is confusing, break it into smaller parts
4. **Ask Questions**: Use community forums, Stack Overflow, and documentation
5. **Build Daily Habits**: 30 minutes daily is better than 5 hours once a week

### Common Pitfalls to Avoid
- ❌ Skipping hands-on exercises
- ❌ Not understanding why, just memorizing commands
- ❌ Rushing through content without practice
- ❌ Being afraid to break things (you have VMs for a reason!)
- ❌ Not asking for help when stuck

### Time Management
- Allocate 2-3 hours per session for focused learning
- Take regular breaks (Pomodoro technique: 25 min work, 5 min break)
- Review previous week's content before starting new material
- Dedicate weekend time for longer projects

## Assessment Checklist

Before moving to Level 2, ensure you can:

### Linux Skills
- [ ] Navigate the file system using cd, ls, pwd
- [ ] Create, copy, move, and delete files and directories
- [ ] Understand and modify file permissions
- [ ] Use grep, sed, and awk for text processing
- [ ] Write basic shell scripts with loops and conditionals
- [ ] Manage processes (start, stop, monitor)

### Git Skills
- [ ] Initialize and clone repositories
- [ ] Make commits with meaningful messages
- [ ] Create and merge branches
- [ ] Resolve merge conflicts
- [ ] Create and review pull requests on GitHub
- [ ] Use .gitignore effectively

### Networking Skills
- [ ] Explain TCP/IP and DNS concepts
- [ ] Use ping, curl, and netstat commands
- [ ] Understand HTTP requests and responses
- [ ] Debug basic network issues

### Docker Skills
- [ ] Explain what containers are and why they're useful
- [ ] Run containers from Docker Hub
- [ ] Create Dockerfiles
- [ ] Build and tag Docker images
- [ ] Manage containers (start, stop, remove)
- [ ] Use Docker volumes for data persistence

### AWS Skills
- [ ] Set up an AWS account and understand Free Tier
- [ ] Create and manage IAM users and policies
- [ ] Launch and connect to EC2 instances
- [ ] Create and manage S3 buckets
- [ ] Configure AWS CLI
- [ ] Understand basic AWS billing

## Resources

### Official Documentation
- [Linux Man Pages](https://man7.org/linux/man-pages/)
- [Git Documentation](https://git-scm.com/doc)
- [Docker Documentation](https://docs.docker.com/)
- [AWS Documentation](https://docs.aws.amazon.com/)

### Free Courses
- [Linux Journey](https://linuxjourney.com/)
- [GitHub Learning Lab](https://lab.github.com/)
- [Docker for Beginners](https://docker-curriculum.com/)
- [AWS Free Digital Training](https://aws.amazon.com/training/digital/)

### Books
- "The Linux Command Line" by William Shotts (free online)
- "Pro Git" by Scott Chacon (free online)
- "Docker Deep Dive" by Nigel Poulton

### Communities
- [r/linux](https://reddit.com/r/linux)
- [r/devops](https://reddit.com/r/devops)
- [r/aws](https://reddit.com/r/aws)
- [Docker Community Slack](https://www.docker.com/docker-community)

## Cost Considerations

### Expected Costs (with careful management)
- **Linux**: Free (Ubuntu)
- **Git/GitHub**: Free
- **Docker**: Free
- **AWS**: $0-$10/month (using Free Tier)

### Cost-Saving Tips
1. Always shut down EC2 instances when not in use
2. Use t2.micro or t3.micro instances (Free Tier eligible)
3. Set up billing alerts at $5 threshold
4. Delete unused resources immediately
5. Use AWS Free Tier dashboard to monitor usage

## Troubleshooting

### Common Issues

**Linux**:
- Permission denied → Use `sudo` or check file permissions
- Command not found → Install the required package or check PATH

**Git**:
- Merge conflicts → Learn to resolve them manually, don't panic!
- Detached HEAD → Checkout a branch before making commits

**Docker**:
- Permission denied → Add your user to the docker group
- Port already in use → Stop the conflicting container or use a different port

**AWS**:
- Access denied → Check IAM permissions
- Can't SSH to EC2 → Verify security group rules and key pair

## Next Steps

After completing Level 1, you'll be ready for:
- **Level 2: Intermediate** - CI/CD, Kubernetes, and Infrastructure as Code
- **AWS Certified Cloud Practitioner** exam preparation
- Contributing to open-source projects

---

**Ready to start?** Begin with [Week 1: Linux Basics](linux-basics/)! 🚀
