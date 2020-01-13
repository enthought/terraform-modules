######################################################
# Set up teams
######################################################

resource "github_team" "overview-team" {
  name        = "${var.project_name}-overview-team"
  description = "${var.project_name} overview team"
  privacy     = "closed"
}

######################################################
# Set up Team Relationships
######################################################

resource "github_team_repository" "overview-team" {
  count      = "${length(var.project-repositories)}"
  team_id    = "${github_team.overview-team.id}"
  repository = "${github_repository.project-repositories[count.index].name}"
  permission = "admin"
}

#######################################################
# Team Memberships
#######################################################

resource "github_team_membership" "overview-team-members" {
  count    = "${length(var.members)}"
  team_id  = "${github_team.overview-team.id}"
  username = "${var.members[count.index]}"
  role     = "member"
}
