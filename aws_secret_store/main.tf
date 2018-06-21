########################################################################
# aws_secret_store resources
########################################################################

locals {
  s3_bucket_name = "${
    var.existing_s3_bucket_name != "none"
      ? var.existing_s3_bucket_name
      : format("%s-secrets", var.namespace)
  }"
}

# An enccrypted bucket for storing secrets
resource "aws_s3_bucket" "secret_bucket" {
  count = "${var.existing_s3_bucket_name == "none" ? 1 : 0}"

  # bucket = "${var.namespace}-secrets"
  bucket = "${local.s3_bucket_name}"
  acl    = "private"

  tags {
    application   = "${var.namespace}"
    ProvisionedBy = "terraform"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# A KMS master key for each environment, used to generate data keys for
# object encryption
resource "aws_kms_key" "environment_keys" {
  count       = "${length(var.environments)}"
  description = "Key for ${var.namespace}/${var.environments[count.index]}"

  tags = {
    environment   = "${var.environments[count.index]}"
    product       = "${var.namespace}"
    ProvisionedBy = "terraform"
  }
}

resource "aws_kms_alias" "deploy_aliases" {
  count         = "${length(var.environments)}"
  name          = "alias/enthought/${var.namespace}/deploy/${var.environments[count.index]}"
  target_key_id = "${aws_kms_key.environment_keys.*.id[count.index]}"
}

resource "aws_kms_alias" "standard_aliases" {
  count         = "${length(var.environments)}"
  name          = "alias/enthought/${var.namespace}/${var.environments[count.index]}/secrets"
  target_key_id = "${aws_kms_key.environment_keys.*.id[count.index]}"
}

# A policy allowing the retrieval of encrypted secrets for a given environment
data "aws_iam_policy_document" "secret_retrieval_policy_doc" {
  count = "${length(var.environments)}"

  statement {
    sid    = "${var.namespace}_${var.environments[count.index]}_secret_policy"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "kms:Decrypt",
    ]

    resources = [
      # We build the ARN dynamically here b/c there's to my knowledge no way
      # to use _either_ an existing data source or a new resource (because
      # one or the other will not exist, and ternary syntax evaluates both
      # branches at the moment)
      "${format("arn:aws:s3:::%s/%s", local.s3_bucket_name, var.environments[count.index])}",

      "${aws_kms_key.environment_keys.*.arn[count.index]}",
    ]
  }
}

resource "aws_iam_policy" "secret_retrieval_policies" {
  count  = "${length(var.environments)}"
  name   = "${var.namespace}-${var.environments[count.index]}-secret_retrieval"
  policy = "${data.aws_iam_policy_document.secret_retrieval_policy_doc.*.json[count.index]}"
}
