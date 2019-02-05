########################################################################
# Provider alias for the org
########################################################################

# **********************************************************************
# Account config
# **********************************************************************

locals {
  "silo-account-id" = "${var.admin-id.value}"
  "silo-admin-role" = "${var.admin-role.value}"
}

provider "aws" {
  alias = "${var.silo-product-name.value}"
  region  = "${var.aws-region.value}"
  profile = "saml"

  # Restrict the usage of the provider to the id of the child account on AWS
  allowed_account_ids = ["${local.silo-account-id}"]

  assume_role {
    role_arn = "arn:aws:iam::${local.silo-account-id}:role/${local.silo-admin-role}"
  }
}
