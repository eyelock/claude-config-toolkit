# Repository Information
output "repository_url" {
  description = "URL of the created repository"
  value       = github_repository.llm_config.html_url
}

output "repository_ssh_clone_url" {
  description = "SSH clone URL"
  value       = github_repository.llm_config.ssh_clone_url
}

output "repository_https_clone_url" {
  description = "HTTPS clone URL"
  value       = github_repository.llm_config.http_clone_url
}

output "repository_full_name" {
  description = "Full name of the repository (owner/repo)"
  value       = github_repository.llm_config.full_name
}

# Discussions
output "discussions_url" {
  description = "URL to GitHub Discussions"
  value       = "${github_repository.llm_config.html_url}/discussions"
}

output "discussion_categories" {
  description = "Created discussion categories"
  value = {
    ideas        = github_repository_discussion_category.ideas.slug
    questions    = github_repository_discussion_category.questions.slug
    show_and_tell = github_repository_discussion_category.show_and_tell.slug
    general      = github_repository_discussion_category.general.slug
  }
}

# Setup Instructions
output "next_steps" {
  description = "Next steps after Terraform apply"
  value = <<-EOT

    Repository created successfully!

    Next steps:
    1. Clone the repository:
       git clone ${github_repository.llm_config.ssh_clone_url}

    2. Add GitHub templates (not managed by Terraform):
       - Copy .github/ISSUE_TEMPLATE/ from this directory
       - Copy .github/PULL_REQUEST_TEMPLATE.md from this directory
       - Commit and push

    3. Initialize with content:
       - Add your first command/skill/agent
       - Update README.md with team-specific info
       - Tag your first release (v0.1.0)

    4. Team setup:
       - Share setup instructions from README.md
       - Have team members run config/setup.sh
       - Test submodule workflow

    5. Discussions are enabled at:
       ${github_repository.llm_config.html_url}/discussions

       Categories created:
       - Ideas: Share new ideas (no commitment)
       - Questions: Ask for help
       - Show and Tell: Share your work
       - General: Everything else

    Remember: Use Discussions for exploration, Issues for tracked work!
  EOT
}
