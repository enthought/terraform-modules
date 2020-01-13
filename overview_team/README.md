# Overview Team
2019-01-16 David Bolack
## Purpose

This module is for creating a unified overview team that is used for management
of multiple repositories in a single project/company.

## What does it do?

This module creates a new team, associates it with a set of
repositories and a set of github users.

## Variables

### project_name

This is the common prefix for all of the repositories associated with this
project and/or company.

### project-repositories

This is an array of the projects this overview team will be watching. As it is
expected that this will be managed_repository based repositories, you will
need to use the github slug name instead of interpolation.  You can use
interpolation for repositories NOT managed via module.

### members

This is an array of github usernames to add to the overview team.

### permission

This is the permission to assign to the overview team. Defaults to push

### Example

module "nukla-cola" {
  source = "github.com/enthought/terraform-modules.git//overview_team?ref=v1.0.2"

  project_name         = "nukla-cola"
  project-repositories = [
    "new_flavor",
    "improved_flavor",
    "classic_flavor",
  ]
  members = [
    "${github_user.bob.username}",
    "${github_user.judy.username}",
  ]
  permission = "push"
}



## Known weaknesses

* Until the next terraform release this module is susceptible to the looping
through lists for user memberships problem.
