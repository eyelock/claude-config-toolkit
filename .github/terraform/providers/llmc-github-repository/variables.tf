# GitHub Organization/Owner
variable "github_organization" {
  description = "GitHub organization or user account that owns the repository"
  type        = string
  # Set via terraform.tfvars or TF_VAR_github_organization
}

# Repository Configuration
variable "repository_name" {
  description = "Name of the GitHub repository"
  type        = string
  default     = "llm-config"
}

variable "repository_description" {
  description = "Description of the repository"
  type        = string
  default     = "Team-shared LLM configurations (commands, skills, agents) for Claude Code and compatible tools"
}

variable "repository_visibility" {
  description = "Repository visibility: public, private, or internal"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "internal"], var.repository_visibility)
    error_message = "Repository visibility must be 'public', 'private', or 'internal'."
  }
}

variable "is_template_repository" {
  description = "Whether this repository is a template for other teams to fork"
  type        = bool
  default     = false
}

variable "repository_topics" {
  description = "Topics for repository discoverability"
  type        = list(string)
  default = [
    "llm",
    "claude-code",
    "ai-configuration",
    "developer-tools",
    "prompt-engineering",
    "team-configuration"
  ]
}

# Team Configuration
variable "team_name" {
  description = "Name of the team using these configs (for display purposes)"
  type        = string
  default     = "MyTeam"
}

# Feature Flags
variable "enable_branch_protection" {
  description = "Enable branch protection rules for main branch"
  type        = bool
  default     = true
}

variable "enable_required_reviews" {
  description = "Require pull request reviews before merging"
  type        = bool
  default     = true
}

variable "required_approving_review_count" {
  description = "Number of required approving reviews"
  type        = number
  default     = 1

  validation {
    condition     = var.required_approving_review_count >= 0 && var.required_approving_review_count <= 6
    error_message = "Required approving review count must be between 0 and 6."
  }
}
