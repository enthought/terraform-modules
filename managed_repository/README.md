# Managed Repository
2018-12-10 David Bolack
## Purpose

This is intended to simplify managing most of our project repository
configurations. Using one block we can provision and manage a set of
repositories through much a single smaller and more easily maintained
configuration block.

## What does it do?

At a minimal level, the module will create a single repository without branch
management and create a set of teams and team relationships for push, pull, and
admin repository privileges.

If it is provided existing github teams for push, pull, and/or admin
privileges, it will create the repository team associations needed.

If provided list(s) of github users for push, pull, and/or admin privileges
it will add them to the appropriate team.

If a list of external collaborators with push or pull privileges is provided
it will add them to the project.

You man also set the following repository configurations:
```
repo_private
has_issues
has_wiki
has_downloads
has_projects
allow_merge_commit
allow_rebase_merge
allow_squash_merge
auto_init
topics
```
## Example

```
module "MyReop" {
  source                      = "github.com/enthought/terraform-modules.git//managed_repository"
  project_name                = "MyRepo"
  project_description         = "This is a test of the managedrepo module"
  branch_protection           = true
  admin_teams_external        = ["itops"]
  pull_teams_local            = ["dbolack"]
  pull_teams_external         = ["enthought"]
  push_teams_local            = ["cholton"]
  push_teams_external         = ["terraformers"]
  external_collaborators_push = ["dbolacksn"]
  external_collaborators_pull = ["dbolackthroaway"]
  has_wiki                    = false
  has_projects                = false
  auto_init                   = true

  topics = [
    "Godzilla",
    "Mothra",
  ]

  ci_options = [
    "${local.travis_check}",
    "${local.ci_appveyor_pr}",
  ]
}
```

## Known weaknesses

* Until the next terraform release this module is susceptible to the looping
through lists for user memberships problem.
* topic names must be lower case. The error thrown does not indicate this is
the problem.

## Additional Workflow Notes

This CANNOT completely set up Travis-CI and APpVeyor. 
Add: 
* The AppVeyor Project
* The HATCHER_TOKEN environment variable(s)
  