# GitHub Discussions Configuration
#
# Philosophy:
# - Discussions for IDEAS and QUESTIONS (exploratory, no commitment)
# - Issues for BUGS and TRACKED WORK (actionable, goes in backlog)
#
# This separation keeps the issue tracker clean for actual work while
# providing space for community engagement and exploration.

resource "github_repository_discussion_category" "ideas" {
  repository = github_repository.llm_config.name
  name       = "Ideas"
  slug       = "ideas"
  description = "Share ideas for new commands, skills, agents, or improvements. No commitment to implement - just exploring possibilities."
}

resource "github_repository_discussion_category" "questions" {
  repository = github_repository.llm_config.name
  name       = "Questions"
  slug       = "questions"
  description = "Ask questions about using the configs, setup, or LLM workflows. Community support and knowledge sharing."
}

resource "github_repository_discussion_category" "show_and_tell" {
  repository = github_repository.llm_config.name
  name       = "Show and Tell"
  slug       = "show-and-tell"
  description = "Share your custom commands, skills, or interesting LLM workflows using these configs."
}

resource "github_repository_discussion_category" "general" {
  repository = github_repository.llm_config.name
  name       = "General"
  slug       = "general"
  description = "General discussion about LLM configuration, team practices, and related topics."
}

# Note: Announcements category is created automatically by GitHub
# We can reference it but don't need to create it

# Future: If we want to convert discussions to issues programmatically,
# we can use GitHub Actions with the discussion ID and issue creation API
