########################################################################
# Usage of aws_secret_store with Existing Bucket
########################################################################

# A custom bucket to use for secrets
resource "aws_s3_bucket" "bestbucket" {
  bucket = "best_s3_bucket"
  acl    = "private"

  tags = {
    customTag = "best-encrypted-bucket"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# An AWS secret store for the best app
module "bestapp_secret_store" {
  source                  = "git::git@github.com:enthought/terraform-modules.git//aws_secret_store?ref=v0.0.1"
  namespace               = "bestapp"
  existing_s3_bucket_name = "best_s3_bucket"
}

# Use the policy outputs to allow secret retrieval for the "deploy" roles.
# - note: you could also do this more fancified using locals and counts, but
#         this is kept simple for the sake of the example.

data "aws_iam_role" "deploy_role_dev" {
  name = "bestcompany_deploy_role_dev"
}

data "aws_iam_role" "deploy_role_staging" {
  name = "bestcompany_deploy_role_staging"
}

data "aws_iam_role" "deploy_role_prod" {
  name = "bestcompany_deploy_role_prod"
}

resource "aws_iam_role_policy_attachment" "deploy_dev_secret_policy" {
  role   = "${data.aws_iam_role.deploy_role_dev}"
  policy = "${module.bestapp_secret_store.iam_secret_retrieval_policies["dev"]}"
}

resource "aws_iam_role_policy_attachment" "deploy_staging_secret_policy" {
  role   = "${data.aws_iam_role.deploy_role_staging}"
  policy = "${module.bestapp_secret_store.iam_secret_retrieval_policies["staging"]}"
}

resource "aws_iam_role_policy_attachment" "deploy_prod_secret_policy" {
  role   = "${data.aws_iam_role.deploy_role_prod}"
  policy = "${module.bestapp_secret_store.iam_secret_retrieval_policies["prod"]}"
}
