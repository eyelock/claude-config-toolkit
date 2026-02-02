terraform {
  required_version = ">= 1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = var.github_organization
  # Token should be set via GITHUB_TOKEN environment variable
}

# Main repository configuration
resource "github_repository" "llm_config" {
  name        = var.repository_name
  description = var.repository_description

  # Repository settings
  visibility = var.repository_visibility

  # Features
  has_issues      = true
  has_discussions = true
  has_projects    = false  # Using Linear/external project management
  has_wiki        = false  # Using docs/ directory instead

  # Advanced features
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  allow_auto_merge       = true
  delete_branch_on_merge = true

  # Default branch
  default_branch = "main"

  # Template repository
  is_template = var.is_template_repository

  # Topics for discoverability
  topics = var.repository_topics

  # Security
  vulnerability_alerts   = true
  archive_on_destroy     = true
  allow_update_branch    = true
}

# Branch protection for main
resource "github_branch_protection" "main" {
  repository_id = github_repository.llm_config.node_id
  pattern       = "main"

  # Require pull request reviews
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = false
    required_approving_review_count = 1
  }

  # Require status checks
  required_status_checks {
    strict = true
    # Add specific checks as needed
    # contexts = ["ci/build", "ci/lint", "ci/test"]
  }

  # Additional protections
  enforce_admins         = false  # Allow admins to bypass for hotfixes
  require_signed_commits = false

  # Prevent force pushes and deletions
  allows_force_pushes = false
  allows_deletions    = false
}

# Repository labels for issue/PR categorization
resource "github_issue_label" "type_bug" {
  repository  = github_repository.llm_config.name
  name        = "type: bug"
  color       = "d73a4a"
  description = "Something isn't working"
}

resource "github_issue_label" "type_feature" {
  repository  = github_repository.llm_config.name
  name        = "type: feature"
  color       = "a2eeef"
  description = "New feature or request"
}

resource "github_issue_label" "type_documentation" {
  repository  = github_repository.llm_config.name
  name        = "type: documentation"
  color       = "0075ca"
  description = "Improvements or additions to documentation"
}

resource "github_issue_label" "type_config" {
  repository  = github_repository.llm_config.name
  name        = "type: config"
  color       = "fbca04"
  description = "Command, skill, or agent configuration"
}

resource "github_issue_label" "priority_high" {
  repository  = github_repository.llm_config.name
  name        = "priority: high"
  color       = "d93f0b"
  description = "High priority"
}

resource "github_issue_label" "priority_medium" {
  repository  = github_repository.llm_config.name
  name        = "priority: medium"
  color       = "fbca04"
  description = "Medium priority"
}

resource "github_issue_label" "priority_low" {
  repository  = github_repository.llm_config.name
  name        = "priority: low"
  color       = "0e8a16"
  description = "Low priority"
}

resource "github_issue_label" "status_in_progress" {
  repository  = github_repository.llm_config.name
  name        = "status: in progress"
  color       = "c5def5"
  description = "Work is in progress"
}

resource "github_issue_label" "status_blocked" {
  repository  = github_repository.llm_config.name
  name        = "status: blocked"
  color       = "b60205"
  description = "Blocked by dependency or decision"
}

resource "github_issue_label" "scope_command" {
  repository  = github_repository.llm_config.name
  name        = "scope: command"
  color       = "bfdadc"
  description = "Related to commands"
}

resource "github_issue_label" "scope_skill" {
  repository  = github_repository.llm_config.name
  name        = "scope: skill"
  color       = "bfdadc"
  description = "Related to skills"
}

resource "github_issue_label" "scope_agent" {
  repository  = github_repository.llm_config.name
  name        = "scope: agent"
  color       = "bfdadc"
  description = "Related to agents"
}

resource "github_issue_label" "scope_infrastructure" {
  repository  = github_repository.llm_config.name
  name        = "scope: infrastructure"
  color       = "bfdadc"
  description = "Related to infrastructure or tooling"
}
