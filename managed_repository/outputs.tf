output "name" {
    description = "Name of the repository"
    value = "${github_repository.managed_repository.name}"
}