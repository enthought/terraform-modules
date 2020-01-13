variable "project-name" {
  description = "The company/project name prepend. Typically a stock ticker."
  default     = "WeNeedAName"
}

variable "project-repositories" {
  description = "An array of repository names to provide oversight for"
  type = "list"
  default = []
}

variable "members" {
  description = "An array of github names to place in the oversight team"
  type = "list"
  default = []
}

variable "permission" {
  description = "Github repository permission for the oversight team."
  default = "push"
}
