# Fossil + Git maintaining:
You can safely run both Git and Fossil together for the same Java project.

This is actually a very good migration strategy:

* keep Git compatibility
* gradually adopt Fossil
* sync both histories
* avoid breaking CI/CD or team workflows

The best approach is:

# Recommended Architecture

```text id="7jsv6o"
Java Project Working Tree
        │
 ┌──────┴──────┐
 │             │
Git Repo    Fossil Repo
 │             │
GitHub      Fossil Server
```

One working directory.
Two VCS systems.

---

# Important Reality

Git and Fossil use:

* different DAG/history models
* different metadata systems
* different hashes

So:

> there is NO perfect bidirectional native sync.

But you can safely:

* mirror commits
* keep same working tree
* automate dual commits

---

# BEST PRACTICAL METHOD

## Method 1 (Recommended)

## Keep Git Main + Fossil Mirror

This is safest.

You:

* continue using Git normally
* create Fossil mirror
* auto-sync changes into Fossil

Advantages:

* zero disruption
* GitHub/GitLab still work
* Fossil gets archival/history benefits

---

# Step-by-Step Setup

# 1. Existing Git Java Project

Example:

```bash id="l8vf2y"
my-java-app/
 ├── .git/
 ├── pom.xml
 ├── src/
```

---

# 2. Create Fossil Repository

Outside project:

```bash id="k07r7f"
mkdir fossil-repos

fossil init fossil-repos/my-java-app.fossil
```

---

# 3. Open Fossil Inside Existing Git Project

Go into project:

```bash id="jlwm6i"
cd my-java-app
```

Open Fossil:

```bash id="l1ws8r"
fossil open ../fossil-repos/my-java-app.fossil
```

Now project contains:

```text id="h6t0mz"
.git/
.fslckout
```

This is OK.

Git and Fossil can coexist safely.

---

# 4. Import Existing Git History (Optional but Recommended)

Fossil supports Git import.

Run:

```bash id="nhn9qe"
fossil import --git .git
```

or:

```bash id="0m3l8o"
git fast-export --all | fossil import --git
```

This imports:

* branches
* commits
* tags

into Fossil history.

VERY useful.

---

# 5. Ignore Fossil Metadata in Git

Add:

```gitignore id="j9r9b2"
.fslckout
_fossil_
```

---

# 6. Ignore Git Metadata in Fossil

Run:

```bash id="y5m0j3"
fossil settings ignore-glob ".git,.gitignore,target,node_modules"
```

For Maven:

```bash id="9f8h7m"
fossil settings ignore-glob "*.class,target,.idea,.git"
```

---

# Daily Workflow Options

# OPTION A — Manual Dual Commit (Safest)

## Git

```bash id="h8b2d0"
git add .
git commit -m "feature"
git push
```

## Fossil

```bash id="77l2t4"
fossil addremove
fossil commit -m "feature"
fossil sync
```

Very reliable.

---

# OPTION B — Auto Dual Commit Script

Create:

```bash id="xq9x33"
commit.sh
```

Example:

```bash id="jjlwm4"
#!/bin/bash

MSG="$1"

git add .
git commit -m "$MSG"
git push

fossil addremove
fossil commit -m "$MSG"
fossil sync
```

Usage:

```bash id="8t8v1s"
./commit.sh "added kafka processing"
```

This is usually the best balance.

---

# OPTION C — Git Hook → Fossil Sync

Advanced approach.

Use Git post-commit hook.

Create:

```bash id="3l0t4u"
.git/hooks/post-commit
```

Example:

```bash id="u2wwyt"
#!/bin/bash

MSG=$(git log -1 --pretty=%B)

fossil addremove
fossil commit -m "$MSG"
fossil sync
```

Make executable:

```bash id="5dvlh7"
chmod +x .git/hooks/post-commit
```

Now every Git commit also commits to Fossil.

---

# Important Caveats

# 1. Hashes Will Differ

Git:

```text id="q2csy8"
SHA-1/SHA-256
```

Fossil:

```text id="r9lq7d"
Own artifact hash system
```

Cannot match exactly.

---

# 2. Rebase Is Dangerous

Avoid aggressive Git rebasing after Fossil import.

Prefer:

* merge workflow
* stable history

because Fossil is more history-preserving.

---

# 3. Git Submodules ≠ Fossil

If project uses:

```text id="v1n6gh"
git submodule
```

migration becomes harder.

Fossil has different concepts.

---

# 4. LFS Needs Special Care

If using:
Git Large File Storage

then:

* import may fail
* large binaries behave differently

---

# BEST ENTERPRISE STRATEGY

For enterprise Java systems:

## Keep:

* GitHub/GitLab
* CI/CD
* PR workflow

## Add:

* Fossil archival mirror
* Fossil wiki
* Fossil tickets
* Fossil documentation

This works extremely well.

---

# Powerful Use Case for You

Considering your backend/distributed systems background, Fossil is excellent for:

* internal OMS systems
* FIX/FAST protocol projects
* long-lived enterprise tooling
* regulated audit environments
* self-hosted infra

Especially because:

* single SQLite repo
* built-in timeline
* integrated docs/tickets

---

# Recommended Java Workflow

For Maven:

```text id="nq52up"
Git:
- collaboration
- CI/CD
- GitHub

Fossil:
- archival
- docs
- timeline
- tickets
- internal hosting
```

This hybrid model is usually ideal.

---

# Useful Fossil Commands

## Web UI

```bash id="4fv0u8"
fossil ui
```

## Sync

```bash id="0mz0v4"
fossil sync
```

## Timeline

```bash id="8a8mrt"
fossil timeline
```

## Add/remove files

```bash id="u1bh2f"
fossil addremove
```

---

# My Strong Recommendation

Do NOT replace Git entirely initially.

Instead:

1. import Git history into Fossil
2. run both together
3. automate dual commits
4. slowly adopt Fossil features
5. keep Git ecosystem compatibility

That gives:

* zero operational risk
* full migration flexibility
* easy rollback
* best of both worlds.
