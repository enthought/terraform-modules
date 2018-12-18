#####################################################
# Set up the respository
#####################################################

resource "github_repository" "managed_repository" {
  name               = "${var.project_name}"
  description        = "${var.project_description}"
  private            = "${var.repo_private}"
  has_issues         = "${var.repo_has_issues}"
  has_wiki           = "${var.repo_has_wiki}"
  has_projects       = "${var.repo_has_projects}"
  has_downloads      = "${var.repo_has_downloads}"
  allow_merge_commit = "${var.repo_allow_merge_commit}"
  allow_squash_merge = "${var.repo_allow_squash_merge}"
  allow_rebase_merge = "${var.repo_allow_rebase_merge}"
  auto_init          = "${var.repo_auto_init}"
  topics             = "${var.topics}"
}

resource "github_branch_protection" "managed_repository-master_branch_protection" {
  count          = "${var.branch_protection}"
  repository     = "${github_repository.managed_repository.id}"
  branch         = "master"
  enforce_admins = "${var.branch_enforce_admins}"

  required_pull_request_reviews {
    dismiss_stale_reviews = "${var.branch_dismiss_stale_reviews}"
  }

  required_status_checks {
    strict = "${var.branch_strict_status_checks}"

    contexts = "${var.ci_options}"
  }
}

######################################################
# Set up teams
######################################################

resource "github_team" "managed_repository-internal_admins" {
  count       = "${length(var.admin_teams_local)}"
  name        = "${var.project_name}_local_admins"
  description = "${var.project_name} internal admin team"
  privacy     = "closed"
}

resource "github_team" "managed_repository-external_admins" {
  count       = "${length(var.push_teams_external)}"
  name        = "${var.project_name}_external_admins"
  description = "${var.project_name} external admin team"
  privacy     = "closed"
}

resource "github_team" "managed_repository-internal_pull" {
  count       = "${length(var.pull_teams_local)}"
  name        = "${var.project_name}_local_pull"
  description = "${var.project_name} internal pull access team"
  privacy     = "closed"
}

resource "github_team" "managed_repository-external_pull" {
  count       = "${length(var.push_teams_external)}"
  name        = "${var.project_name}_external_pull"
  description = "${var.project_name} external pull access team"
  privacy     = "closed"
}

resource "github_team" "managed_repository-internal_push" {
  count       = "${length(var.push_teams_local)}"
  name        = "${var.project_name}_local_push"
  description = "${var.project_name} internal push access team"
  privacy     = "closed"
}

resource "github_team" "managed_repository-external_push" {
  count       = "${length(var.push_teams_external)}"
  name        = "${var.project_name}_external_push"
  description = "${var.project_name} external push access team"
  privacy     = "closed"
}

######################################################
# Set up Team Relationships
######################################################

resource "github_team_repository" "managed_repository-external_admins" {
  count      = "${length(var.admin_teams_external)}"
  team_id    = "${var.admin_teams_external[count.index]}"
  repository = "${github_repository.managed_repository.name}"
  permission = "admin"
}

resource "github_team_repository" "managed_repository-internal_admins" {
  count      = "${length(var.admin_teams_local)}"
  team_id    = "${github_team.managed_repository_internal_admins.id}"
  repository = "${github_repository.managed_repository.name}"
  permission = "admin"
}

resource "github_team_repository" "managed_repository-external_pull" {
  count      = "${length(var.pull_teams_external)}"
  team_id    = "${var.pull_teams_external[count.index]}"
  repository = "${github_repository.managed_repository.name}"
  permission = "pull"
}

resource "github_team_repository" "managed_repository-internal_pull" {
  count      = "${length(var.pull_teams_local)}"
  team_id    = "${github_team.managed_repository_internal_pull.id}"
  repository = "${github_repository.managed_repository.name}"
  permission = "pull"
}

resource "github_team_repository" "managed_repository-external_push" {
  count      = "${length(var.push_teams_external)}"
  team_id    = "${var.push_teams_external[count.index]}"
  repository = "${github_repository.managed_repository.name}"
  permission = "push"
}

resource "github_team_repository" "managed_repository-internal_push" {
  count      = "${length(var.push_teams_local)}"
  team_id    = "${github_team.managed_repository_internal_push.id}"
  repository = "${github_repository.managed_repository.name}"
  permission = "push"
}

#######################################################
# Team Memberships
#######################################################

resource "github_team_membership" "managed_repository-admin" {
  count    = "${length(var.admin_teams_local)}"
  team_id  = "${github_team.managed_repository_internal_admins.id}"
  username = "${var.admin_teams_local[count.index]}"
  role     = "member"
}

resource "github_team_membership" "managed_repository-pull" {
  count    = "${length(var.pull_teams_local)}"
  team_id  = "${github_team.managed_repository_internal_pull.id}"
  username = "${var.pull_teams_local[count.index]}"
  role     = "member"
}

resource "github_team_membership" "managed_repository-push" {
  count    = "${length(var.push_teams_local)}"
  team_id  = "${github_team.managed_repository_internal_push.id}"
  username = "${var.push_teams_local[count.index]}"
  role     = "member"
}

#######################################################
# Collaborators
#######################################################

resource "github_repository_collaborator" "managed_repository-collab_push" {
  count      = "${length(var.external_collaborators_push)}"
  repository = "${github_repository.managed_repository.id}"
  username   = "${var.external_collaborators_push[count.index]}"
  permission = "push"
}

resource "github_repository_collaborator" "managed_repository-collab_pull" {
  count      = "${length(var.external_collaborators_pull)}"
  repository = "${github_repository.managed_repository.id}"
  username   = "${var.external_collaborators_pull[count.index]}"
  permission = "pull"
}
