# aws_secret_store

Manage the AWS resources necessary to store secrets for a given application.

Given a namespace (e.g.) the name of an application, and a list of deploy
environments (defaulting to "dev", "staging", and "prod"), creates the
following resources:

* An S3 bucket for storing secrets, encrypted server-side with automatic
AES256 encryption, versioning, a private ACL, and a tag corresponding to the
provided namespace
* A KMS CMK (Customer Master Key) for each namespace-environment combination,
with tags corresponding to both the environment and the namespace
* Aliases for each CMK for programmatic access. There are two aliases for
each CMK, one called a "deploy alias" and another called a "standard alias".
The deploy alias is present for backwards compatibility and will be removed
in a future release. Generally, the standard alias should be used.
* IAM policies, one for each namespace-environment combination, allowing the
retrieval and decryption of secrets for that namespace an deploy environment

Optionally, an existing S3 bucket name may be provided, in which case the
secret bucket will not be created, and the other resources will be created
referring to the existing bucket.

It is designed to be used in conjunction with the ``secrets.py`` module
found in the [brood repo](https://github.com/enthought/brood/blob/master/deploy/docker/stack/secrets.py)
and soon to be distributed as a standalone package.

## Variables

* **namespace:** the resource namespace (generally the name of an application)
* **environments:** (optional) the deploy environments for which resources should
be created (default `["dev", "staging", "prod"]`)
* **existing_s3_bucket_name:** (optional) the name of an existing S3 bucket to
use as the secret bucket. If this is not provided, a new bucket will be created.

## Outputs

* **kms_cmk_arns:** a map of CMK ARNs, whose keys are the provided or default
deploy environments
* **kms_cmk_deploy_aliases:** a map of CMK deploy aliases, whose keys are the
provided or default deploy environments
* **kms_cmk_standard_aliases:** a map of CMK standard aliases, whose keys are
the provided or default deploy environments
* **s3_secret_bucket_id:** the bucket name/id of the secret bucket. This is
either a newly created bucket or the same bucket name passed in to the
`existing_s3_bucket_name` variable
* **iam_secret_retrieval_policies:** a map of ARNs for policies allowing
secret retrieval and decryption, whose keys are the provided or default deploy
environments
