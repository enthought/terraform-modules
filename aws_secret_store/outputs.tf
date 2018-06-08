########################################################################
# aws_secret_store outputs
########################################################################

output "kms_master_key_arn" {
  description = "The ARN of the store's master key"
  value       = "${aws_kms_key.key.*.arn}"
}

# output "kms_master_key_deploy_alias" {
#   description = "The deployment-oriented alias for the master key"

#   value = {
#     arn   = "${aws_kms_alias.deploy_alias.arn}"
#     alias = "${local.kms_deploy_alias}"
#   }
# }

# output "kms_master_key_standard_alias" {
#   description = "The standard alias for the master key"

#   value = {
#     arn   = "${aws_kms_alias.standard_alias.arn}"
#     alias = "${local.kms_standard_alias}"
#   }
# }

output "s3_secret_bucket_id" {
  description = "The bucket for storing encrypted secrets"
  value       = "${local.s3_bucket_name}"
}

output "iam_secret_retrieval_policy_arn" {
  description = "The ARN of a policy allowing retrieval and decryption of secrets"
  value       = "${aws_iam_policy.secret_retrieval_policy.*.arn}"
}
