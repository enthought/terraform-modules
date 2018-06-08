########################################################################
# aws_secret_store variables
########################################################################
variable "namespace" {
  description = "The secret namespace, e.g. an application name"
}

variable "environments" {
  description = "The deploy environments to support, e.g. ['staging', 'prod']"
  type        = "list"
  default     = ["dev", "staging", "prod"]
}

variable "existing_s3_bucket_name" {
  description = "The name of an existing S3 bucket to use"
  default     = "none"
}
