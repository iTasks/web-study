# Git and GitHub

## Introduction

Git is a distributed version control system that tracks changes in your code over time. GitHub is a web-based platform that hosts Git repositories and provides collaboration features. Together, they are essential tools for modern software development and DevOps practices.

## Learning Objectives

By the end of this module, you will:
- Understand version control concepts
- Use Git for managing code changes
- Collaborate effectively using GitHub
- Implement branching strategies
- Handle merge conflicts
- Follow Git best practices

## Prerequisites

- Basic command line knowledge
- Text editor
- GitHub account (create at https://github.com)

## Setup

### Install Git

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install git
```

**macOS**:
```bash
brew install git
```

**Windows**:
Download from https://git-scm.com/download/win

**Verify Installation**:
```bash
git --version
```

### Configure Git
```bash
# Set your identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default editor
git config --global core.editor "nano"  # or vim, code, etc.

# Set default branch name
git config --global init.defaultBranch main

# View configuration
git config --list
```

### Set Up SSH for GitHub
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Start SSH agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub: Settings → SSH and GPG keys → New SSH key
# Test connection
ssh -T git@github.com
```

## Core Git Concepts

### The Three States
1. **Working Directory**: Where you modify files
2. **Staging Area (Index)**: Files ready to be committed
3. **Repository (.git directory)**: Committed snapshots

```
Working Directory  →  Staging Area  →  Repository
     (add)                (commit)
```

### Basic Workflow

```bash
# Initialize a new repository
git init my-project
cd my-project

# Check status
git status

# Create a file
echo "# My Project" > README.md

# Stage the file
git add README.md

# Commit the change
git commit -m "Initial commit"

# View commit history
git log
git log --oneline
git log --graph --oneline --all
```

## Essential Git Commands

### Working with Files

```bash
# Stage files
git add file.txt              # Stage specific file
git add .                     # Stage all changes
git add *.js                  # Stage by pattern
git add -p                    # Interactive staging

# Unstage files
git reset HEAD file.txt       # Unstage but keep changes
git restore --staged file.txt # Unstage (newer syntax)

# Discard changes
git checkout -- file.txt      # Discard changes (old syntax)
git restore file.txt          # Discard changes (new syntax)

# Remove files
git rm file.txt               # Remove and stage
git rm --cached file.txt      # Remove from Git, keep locally

# Move/Rename files
git mv oldname.txt newname.txt
```

### Viewing Changes

```bash
# See unstaged changes
git diff

# See staged changes
git diff --staged
git diff --cached

# Compare commits
git diff commit1 commit2

# Show specific commit
git show commit-hash
git show HEAD
git show HEAD~1               # Previous commit
```

### Commit History

```bash
# View logs
git log
git log --oneline
git log --graph --decorate --all
git log -n 5                  # Last 5 commits
git log --since="2 weeks ago"
git log --author="Your Name"
git log -- file.txt           # Commits affecting specific file

# Search commits
git log --grep="bug fix"
git log -S "function_name"    # Pickaxe search
```

## Branching and Merging

### Branch Operations

```bash
# Create branch
git branch feature-login
git branch -a                 # List all branches

# Switch branch
git checkout feature-login    # Old syntax
git switch feature-login      # New syntax

# Create and switch
git checkout -b feature-signup
git switch -c feature-signup

# Rename branch
git branch -m old-name new-name

# Delete branch
git branch -d feature-login   # Safe delete
git branch -D feature-login   # Force delete

# View branch info
git branch -v                 # Show last commit
git branch --merged           # Merged branches
git branch --no-merged        # Unmerged branches
```

### Merging Strategies

```bash
# Fast-forward merge (if possible)
git checkout main
git merge feature-branch

# No fast-forward (always create merge commit)
git merge --no-ff feature-branch

# Squash merge (combine all commits)
git merge --squash feature-branch
git commit -m "Add feature"

# Abort merge
git merge --abort
```

### Handling Merge Conflicts

```bash
# When conflict occurs:
# 1. Git marks conflicts in files
# 2. Open conflicted files and resolve

# Conflict markers look like:
<<<<<<< HEAD
Your current changes
=======
Incoming changes
>>>>>>> feature-branch

# After resolving:
git add resolved-file.txt
git commit -m "Merge feature-branch"

# Or use merge tool
git mergetool
```

**Hands-On Lab 1**: Branching Practice
```bash
# Initialize repository
mkdir git-practice && cd git-practice
git init

# Create main branch content
echo "# Website" > README.md
git add README.md
git commit -m "Initial commit"

# Create feature branch
git switch -c add-homepage
echo "<h1>Homepage</h1>" > index.html
git add index.html
git commit -m "Add homepage"

# Switch back and create another branch
git switch main
git switch -c add-about
echo "<h1>About</h1>" > about.html
git add about.html
git commit -m "Add about page"

# Merge both branches
git switch main
git merge add-homepage
git merge add-about

# View history
git log --graph --oneline --all
```

## Remote Repositories

### Working with GitHub

```bash
# Clone repository
git clone git@github.com:username/repo.git
git clone https://github.com/username/repo.git

# View remotes
git remote -v

# Add remote
git remote add origin git@github.com:username/repo.git

# Remove remote
git remote remove origin

# Rename remote
git remote rename origin upstream
```

### Push and Pull

```bash
# Push to remote
git push origin main
git push -u origin main       # Set upstream and push
git push --all                # Push all branches
git push --tags               # Push tags

# Pull from remote
git pull origin main          # Fetch and merge
git pull --rebase origin main # Fetch and rebase

# Fetch without merging
git fetch origin
git fetch --all
```

### Tracking Branches

```bash
# Create tracking branch
git checkout -b feature origin/feature
git switch -c feature origin/feature

# Set upstream for existing branch
git branch --set-upstream-to=origin/main main
git push -u origin main

# View tracking information
git branch -vv
```

## GitHub Workflows

### Forking and Pull Requests

```bash
# 1. Fork repository on GitHub
# 2. Clone your fork
git clone git@github.com:your-username/repo.git
cd repo

# 3. Add upstream remote
git remote add upstream git@github.com:original-owner/repo.git

# 4. Create feature branch
git switch -c my-feature

# 5. Make changes and commit
# ... make changes ...
git add .
git commit -m "Add new feature"

# 6. Push to your fork
git push origin my-feature

# 7. Create pull request on GitHub

# 8. Keep your fork updated
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

### Collaborative Workflows

**GitHub Flow** (simple, for continuous deployment):
```
main (production-ready)
  ↓
feature branch → pull request → code review → merge to main → deploy
```

**Git Flow** (more structured, for release-based):
```
main (production)
develop (integration)
  ↓
feature branches → develop → release branch → main
hotfix branches → main + develop
```

## Advanced Git Operations

### Rebasing

```bash
# Rebase feature branch onto main
git checkout feature
git rebase main

# Interactive rebase (edit history)
git rebase -i HEAD~3          # Last 3 commits
# Pick, reword, edit, squash, fixup, drop commits

# Abort rebase
git rebase --abort

# Continue after resolving conflicts
git rebase --continue
```

### Stashing

```bash
# Save current changes temporarily
git stash
git stash save "Work in progress"

# List stashes
git stash list

# Apply stash
git stash apply               # Keep stash
git stash pop                 # Apply and remove

# Apply specific stash
git stash apply stash@{1}

# Delete stash
git stash drop stash@{0}
git stash clear               # Remove all
```

### Tagging

```bash
# Create lightweight tag
git tag v1.0.0

# Create annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Tag specific commit
git tag v0.9.0 commit-hash

# List tags
git tag
git tag -l "v1.*"

# Push tags
git push origin v1.0.0
git push origin --tags

# Delete tag
git tag -d v1.0.0
git push origin --delete v1.0.0
```

### Cherry-Pick

```bash
# Apply specific commit to current branch
git cherry-pick commit-hash

# Cherry-pick multiple commits
git cherry-pick commit1 commit2

# Cherry-pick without committing
git cherry-pick -n commit-hash
```

## Best Practices

### Commit Messages

**Good commit message format**:
```
Short summary (50 chars or less)

More detailed explanation if needed (wrapped at 72 chars).
Explain what and why, not how.

- Bullet points are okay
- Use present tense: "Add feature" not "Added feature"
- Reference issues: "Fixes #123"
```

**Examples**:
```bash
# Good
git commit -m "Add user authentication feature"
git commit -m "Fix memory leak in data processing"
git commit -m "Update dependencies to latest versions"

# Bad
git commit -m "fix"
git commit -m "changes"
git commit -m "asdfasdf"
```

### .gitignore

Create `.gitignore` to exclude files:

```gitignore
# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp

# Dependencies
node_modules/
vendor/

# Build outputs
dist/
build/
*.o
*.exe

# Environment files
.env
.env.local

# Logs
*.log
logs/

# Temporary files
tmp/
temp/
```

### Git Workflow Best Practices

1. **Commit Often**: Small, focused commits
2. **Write Meaningful Messages**: Clear and descriptive
3. **Branch for Features**: Keep main stable
4. **Pull Before Push**: Stay synchronized
5. **Review Before Committing**: Use `git diff`
6. **Don't Commit Secrets**: Use .gitignore and environment variables
7. **Test Before Merging**: Ensure code works
8. **Keep History Clean**: Use rebase when appropriate

## Troubleshooting

### Common Issues

**Undo last commit (keep changes)**:
```bash
git reset --soft HEAD~1
```

**Undo last commit (discard changes)**:
```bash
git reset --hard HEAD~1
```

**Amend last commit**:
```bash
git commit --amend -m "New message"
git commit --amend --no-edit  # Keep message
```

**Recover deleted branch**:
```bash
git reflog
git checkout -b recovered-branch commit-hash
```

**Clean untracked files**:
```bash
git clean -n                  # Dry run
git clean -f                  # Remove files
git clean -fd                 # Remove files and directories
```

**Fix diverged branches**:
```bash
# Option 1: Merge
git pull origin main

# Option 2: Rebase
git pull --rebase origin main
```

## Hands-On Projects

### Project 1: Personal Portfolio Repository
1. Create a new repository for your portfolio
2. Initialize with README, .gitignore
3. Create branches for different features
4. Make commits as you develop
5. Use tags for versions
6. Push to GitHub

### Project 2: Contribute to Open Source
1. Find a beginner-friendly project on GitHub
2. Fork the repository
3. Create a feature branch
4. Make your contribution
5. Submit a pull request
6. Respond to code review feedback

### Project 3: Team Collaboration Simulation
1. Create a repository with a partner
2. Both clone and create feature branches
3. Intentionally create merge conflicts
4. Practice resolving conflicts
5. Use pull requests for code review

## Assessment Checklist

Before moving forward, ensure you can:

- [ ] Initialize a Git repository
- [ ] Make commits with meaningful messages
- [ ] Create and switch between branches
- [ ] Merge branches successfully
- [ ] Resolve merge conflicts
- [ ] Clone a repository from GitHub
- [ ] Push and pull changes
- [ ] Create pull requests
- [ ] Review and comment on pull requests
- [ ] Use .gitignore effectively
- [ ] Understand Git workflow strategies
- [ ] Stash and apply changes
- [ ] Create and push tags
- [ ] Undo commits and changes safely

## Additional Resources

- [Pro Git Book](https://git-scm.com/book/en/v2) (Free online)
- [GitHub Learning Lab](https://lab.github.com/)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [Visualizing Git](https://git-school.github.io/visualizing-git/)
- [Oh Shit, Git!?!](https://ohshitgit.com/) - Common mistakes and fixes

## Next Steps

Once you're comfortable with Git and GitHub, move on to:
- [Networking Basics](../networking-basics/) - Understanding network fundamentals
- [Docker Introduction](../docker-intro/) - Containerization basics

---

**Remember**: Git has a learning curve, but it becomes second nature with practice. Don't be afraid to experiment in a test repository!
