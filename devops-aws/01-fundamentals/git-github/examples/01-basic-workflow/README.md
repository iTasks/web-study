# Simple Git Workflow Example

[← Back to Git and GitHub](../../README.md) | [Level 1: Fundamentals](../../../README.md) | [DevOps & AWS](../../../../README.md)

This is a practice repository to learn basic Git workflows.

## Git Workflow Steps

### 1. Clone Repository
```bash
git clone https://github.com/username/repo.git
cd repo
```

### 2. Create a Feature Branch
```bash
git checkout -b feature/add-new-page
```

### 3. Make Changes
```bash
# Create or edit files
echo "# New Page" > new-page.md

# Check status
git status
```

### 4. Stage and Commit
```bash
# Stage specific file
git add new-page.md

# Or stage all changes
git add .

# Commit with message
git commit -m "Add new page with introduction"
```

### 5. Push to Remote
```bash
git push origin feature/add-new-page
```

### 6. Create Pull Request
- Go to GitHub repository
- Click "Compare & pull request"
- Fill in PR description
- Request reviewers
- Submit PR

### 7. After PR Approval
```bash
# Switch to main branch
git checkout main

# Pull latest changes
git pull origin main

# Delete feature branch (optional)
git branch -d feature/add-new-page
```

## Common Commands Reference

### Branch Management
```bash
git branch                    # List branches
git branch -a                 # List all branches (including remote)
git checkout -b new-branch    # Create and switch to new branch
git branch -d branch-name     # Delete branch
```

### Viewing History
```bash
git log                       # View commit history
git log --oneline            # Condensed log
git log --graph              # Visual graph
git diff                     # Show changes
```

### Undoing Changes
```bash
git checkout -- file.txt     # Discard changes in file
git reset HEAD file.txt      # Unstage file
git revert <commit>          # Revert a commit
git reset --hard HEAD~1      # Remove last commit (dangerous!)
```

### Remote Operations
```bash
git remote -v                # List remotes
git fetch origin             # Fetch from remote
git pull origin main         # Pull and merge
git push origin main         # Push to remote
```

## Best Practices

1. **Commit Often**: Small, frequent commits are better
2. **Write Good Messages**: Be descriptive
3. **Use Branches**: Never work directly on main
4. **Pull Before Push**: Always sync before pushing
5. **Review Before Commit**: Check `git status` and `git diff`

## Common Workflows

### Feature Development
1. Create feature branch
2. Make changes
3. Commit frequently
4. Push to remote
5. Create PR
6. Address review comments
7. Merge to main

### Bug Fix
1. Create hotfix branch from main
2. Fix the bug
3. Test thoroughly
4. Create PR
5. Fast-track review
6. Merge and deploy

### Collaboration
1. Fork repository (if not a collaborator)
2. Clone your fork
3. Create feature branch
4. Make changes
5. Push to your fork
6. Create PR to original repo
