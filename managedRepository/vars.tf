variable "project_name" {
  description = "The Project/Partner associated with the repository"
  default     = "WeNeedAName"
}

variable "project_description" {
  description = "The general description of the repository"
  default     = "Default Repo description from terraform module"
}

# "Local" teams are built/defined by this template and granted associated
#    privileges.
# "External" teams already exist and are granted associated privileges.

variable "admin_teams_local" {
  description = "Github Team that has admin privileges, local to this module"
  type        = "list"
  default     = []                                                            # List of users to add to team on creation
}

variable "admin_teams_external" {
  description = "Github Team that has admin privileges, already existing"
  type        = "list"
  default     = []
} # List of already existing teams

variable "pull_teams_local" {
  description = "Github Team that has pull privileges, local to this module"
  type        = "list"
  default     = []                                                           # List of users to add to team on creation
}

variable "pull_teams_external" {
  description = "Github Team that has pull privileges, already existing"
  type        = "list"
  default     = []
} # List of already existing teams

variable "push_teams_local" {
  description = "Github Team that has push privileges, local to this module"
  type        = "list"
  default     = []                                                           # List of users to add to team on creation
}

variable "push_teams_external" {
  description = "Github Team that has push privileges, already existing"
  type        = "list"
  default     = []
} # List of already existing teams

variable "external_collaborators_push" {
  description = "Map of non-enthought Github users with push privileges"
  type        = "list"
  default     = []                                                       # List of users to add to team on creation
}

variable "external_collaborators_pull" {
  description = "Map of non-enthought Github users with pull privileges"
  type        = "list"
  default     = []
} # List of already existing teams

variable "topics" {
  description = "Topics for tagging in the repository"
  default     = []
}

variable branch_protection {
  description = "Do we enable branch protection on this branch?"
  default     = true
}

variable "branch_enforce_admins" {
  description = "Value to set for enforce_admins on branch protection"
  default     = false
}

variable "branch_dismiss_stale_reviews" {
  description = "Value to set for dismiss_stale_reviews on branch protection"
  default     = false
}

variable "branch_strict_status_checks" {
  description = "The value to set for strict_status_checks in branch protection"
  default     = false
}

variable "ci_options" {
  description = "List of enabled ci apps"

  default = [
    "Travis CI - Pull Request",
    "continuous-integration/appveyor/pr",
  ]
}

# Repository Config Booleans
variable "repo_private" {
  description = "Set This boolean on the repository?"
  default     = true
}

variable "repo_has_issues" {
  description = "Set This boolean on the repository?"
  default     = true
}

variable "repo_has_wiki" {
  description = "Set This boolean on the repository?"
  default     = true
}

variable "repo_has_downloads" {
  description = "Set This boolean on the repository?"
  default     = true
}

variable "repo_has_projects" {
  description = "Set This boolean on the repository?"
  default     = true
}

variable "repo_allow_merge_commit" {
  description = "Set This boolean on the repository?"
  default     = false
}

variable "repo_allow_rebase_merge" {
  description = "Set This boolean on the repository?"
  default     = false
}

variable "repo_allow_squash_merge" {
  description = "Set This boolean on the repository?"
  default     = true
}

variable "repo_auto_init" {
  description = "Set This boolean on the repository?"
  default     = true
}
