########################################################################
# aws_secret_store outputs
########################################################################

output "kms_cmk_arns" {
  description = "KMS CMK ARNs for each deployment environment in the given namespace."
  value       = "${zipmap(var.environments, aws_kms_key.environment_keys.*.arn)}"
}

output "kms_cmk_deploy_aliases" {
  description = "The deployment-oriented alias for the KMS CMKs"
  value       = "${zipmap(var.environments, aws_kms_alias.deploy_aliases.*.name)}"
}

output "kms_cmk_standard_aliases" {
  description = "The standard alias for the KMS CMKs"
  value       = "${zipmap(var.environments, aws_kms_alias.standard_aliases.*.name)}"
}

output "s3_secret_bucket_id" {
  description = "The bucket for storing encrypted secrets"
  value       = "${local.s3_bucket_name}"
}

output "iam_secret_retrieval_policies" {
  description = "The ARN of policies allowing retrieval and decryption of secrets"
  value       = "${aws_iam_policy.secret_retrieval_policies.*.arn}"
}
