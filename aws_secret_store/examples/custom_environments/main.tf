########################################################################
# Standard Usage of aws_secret_store
########################################################################

# An AWS secret store for the best app
module "bestapp_secret_store" {
  source       = "git::git@github.com:enthought/terraform-modules.git//aws_secret_store?ref=v0.0.1"
  namespace    = "bestapp"
  environments = ["testing", "qa", "production"]
}

# Use the policy outputs to allow secret retrieval for the "deploy" roles.
# - note: you could also do this more fancified using locals and counts, but
#         this is kept simple for the sake of the example.

data "aws_iam_role" "deploy_role_testing" {
  name = "bestcompany_deploy_role_testing"
}

data "aws_iam_role" "deploy_role_qa" {
  name = "bestcompany_deploy_role_qa"
}

data "aws_iam_role" "deploy_role_production" {
  name = "bestcompany_deploy_role_production"
}

resource "aws_iam_role_policy_attachment" "deploy_dev_secret_policy" {
  role   = "${data.aws_iam_role.deploy_role_dev}"
  policy = "${module.bestapp_secret_store.iam_secret_retrieval_policies["dev"]}"
}

resource "aws_iam_role_policy_attachment" "deploy_qa_secret_policy" {
  role   = "${data.aws_iam_role.deploy_role_qa}"
  policy = "${module.bestapp_secret_store.iam_secret_retrieval_policies["qa"]}"
}

resource "aws_iam_role_policy_attachment" "deploy_production_secret_policy" {
  role   = "${data.aws_iam_role.deploy_role_production}"
  policy = "${module.bestapp_secret_store.iam_secret_retrieval_policies["production"]}"
}
