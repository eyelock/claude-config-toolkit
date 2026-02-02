# Terraform Infrastructure for LLM Config Repository

This directory contains Terraform configuration to set up a GitHub repository with best practices for sharing LLM configurations across a team.

## What This Creates

- **GitHub Repository** with proper settings (issues, discussions, branch protection)
- **Discussion Categories** for community engagement (Ideas, Questions, Show and Tell, General)
- **Issue Labels** for categorization (type, priority, status, scope)
- **Branch Protection** for main branch (optional, configurable)

## Philosophy: Discussions vs Issues

**Use Discussions for:**
- 💡 **Ideas** - Exploring possibilities, no commitment to implement
- ❓ **Questions** - Getting help, learning, knowledge sharing
- 🎉 **Show and Tell** - Sharing what you built
- 💬 **General** - Everything else

**Use Issues for:**
- 🐛 **Bugs** - Something is broken and needs fixing
- ✨ **Features** - Committed work, going in the backlog
- 📋 **Tracked Work** - Anything that needs project management

This keeps your issue tracker clean for actual work while providing space for exploration.

## Prerequisites

1. **GitHub Token** with repository management permissions:
   ```bash
   export GITHUB_TOKEN="ghp_your_token_here"
   ```

2. **Terraform** installed (>= 1.0):
   ```bash
   brew install terraform  # macOS
   # or download from https://www.terraform.io/downloads
   ```

## Setup

### 1. Configure Variables

Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your team's settings:
```hcl
github_organization = "your-org"
repository_name     = "llm-config"
team_name          = "MyTeam"
```

### 2. Initialize Terraform

```bash
terraform init
```

This downloads the GitHub provider.

### 3. Preview Changes

```bash
terraform plan
```

Review what will be created. You should see:
- 1 repository
- 4 discussion categories
- ~10 issue labels
- 1 branch protection rule (if enabled)

### 4. Apply Configuration

```bash
terraform apply
```

Type `yes` to confirm.

### 5. Add GitHub Templates

Terraform doesn't manage file contents, so manually add these:

```bash
# From your new repository
cd path/to/your-new-repo

# Copy templates from this directory
cp -r ../claude-config/.github .

# Commit and push
git add .github/
git commit -m "Add issue and PR templates"
git push
```

## What's NOT Managed by Terraform

These need to be added manually:

1. **Issue Templates** (`.github/ISSUE_TEMPLATE/*.md`)
2. **PR Template** (`.github/PULL_REQUEST_TEMPLATE.md`)
3. **Repository Content** (actual commands, skills, agents)
4. **Team Members** (add via GitHub UI or separate Terraform resources)

## Outputs

After `terraform apply`, you'll see:

```
repository_url              = "https://github.com/myorg/llm-config"
repository_ssh_clone_url    = "git@github.com:your-org/llm-config.git"
discussions_url             = "https://github.com/myorg/llm-config/discussions"
discussion_categories       = { ... }
next_steps                  = "..." (setup instructions)
```

## Customization

### Add More Labels

Edit `main.tf` and add:
```hcl
resource "github_issue_label" "custom" {
  repository  = github_repository.llm_config.name
  name        = "custom-label"
  color       = "hex-color"
  description = "Description"
}
```

### Add Team Access

If using GitHub Teams:
```hcl
resource "github_team_repository" "team_access" {
  team_id    = data.github_team.my_team.id
  repository = github_repository.llm_config.name
  permission = "push"  # or "pull", "maintain", "admin"
}
```

### Modify Branch Protection

Edit `variables.tf` or your `terraform.tfvars`:
```hcl
enable_branch_protection      = true
enable_required_reviews       = true
required_approving_review_count = 2  # Require 2 approvals
```

## Managing State

### Remote State (Recommended for Teams)

For team usage, store Terraform state remotely:

```hcl
# Add to main.tf
terraform {
  backend "s3" {
    bucket = "your-terraform-state"
    key    = "llm-config/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### Local State (Simple, Single User)

By default, state is stored in `terraform.tfstate` (gitignored).

**⚠️ Warning:** If you lose this file, Terraform can't manage your resources anymore!

Backup options:
```bash
# Backup state
cp terraform.tfstate terraform.tfstate.backup

# Or use git (carefully!)
# Make sure terraform.tfstate is NOT in .gitignore if doing this
git add -f terraform.tfstate
git commit -m "Backup Terraform state"
```

## Destroying Resources

To remove everything Terraform created:

```bash
terraform destroy
```

**⚠️ Warning:** This will delete your repository! Make sure you have backups.

## Troubleshooting

### "Resource already exists"

If the repository already exists:
```bash
# Import existing repository
terraform import github_repository.llm_config your-org/llm-config

# Then apply
terraform apply
```

### "Unauthorized" errors

Check your GitHub token:
```bash
# Verify token is set
echo $GITHUB_TOKEN

# Verify token has correct permissions
gh auth status
```

### "Discussion categories not showing up"

GitHub has a delay (sometimes minutes) before discussion categories appear in the UI. Wait a bit and refresh.

## Files in This Directory

```
terraform/
├── main.tf                    # Repository, labels, branch protection
├── discussions.tf             # Discussion category configuration
├── variables.tf               # Input variable definitions
├── outputs.tf                 # Output values after apply
├── terraform.tfvars.example   # Example configuration
├── README.md                  # This file
└── .gitignore                 # Ignore state files and secrets
```

## Next Steps After Terraform Apply

1. **Clone your new repository**
2. **Add GitHub templates** (.github/ISSUE_TEMPLATE/, etc.)
3. **Initialize with content** (first command, skill, or agent)
4. **Tag your first release** (v0.1.0)
5. **Share with team** (send README.md and setup.sh instructions)

## Self-Documenting Infrastructure

This Terraform configuration IS the documentation for your GitHub setup. Instead of maintaining a separate "how we set up our repo" document, the Terraform code shows exactly:

- What features are enabled
- What labels exist
- What branch protections are in place
- What discussion categories are available

To understand your setup, just read the `.tf` files!

## See Also

- [Terraform GitHub Provider Docs](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [GitHub Discussions API](https://docs.github.com/en/graphql/guides/using-the-graphql-api-for-discussions)
- Main project README: `../README.md`
- Setup script: `../config/setup.sh`
