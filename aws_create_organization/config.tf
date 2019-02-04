########################################################################
# Configuration for the asahi_kasei Account
########################################################################

# create a dynamodb table for locking the state file
resource "aws_dynamodb_table" "dynamodb-terraform-prod-locking" {
  name           = "terraform_prod_locking"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name = "DynamoDB Terraform State Lock Table"
  }
}

# **********************************************************************
# Terraform config
# **********************************************************************

terraform {
  required_version = "~> 0.10"

  backend "s3" {
    bucket     = "devops.enthought"
    key        = "dev/asahi_kasei.tfstate"
    encrypt    = true
    region     = "us-east-1"
    kms_key_id = "arn:aws:kms:us-east-1:438106514358:key/65d3aa32-7c21-4783-8d37-98654e14ada5"
    profile    = "saml"
  }
}

# **********************************************************************
# Account config
# **********************************************************************

locals {
  "asahi_kasei_account_id" = "049897692857"
  "asahi_kasei_admin_role" = "EnthoughtOrgFullAdminRights"
}

provider "aws" {
  region  = "us-east-1"
  profile = "saml"

  # Restrict the usage of the provider to the id of the child account on AWS
  allowed_account_ids = ["${local.asahi_kasei_account_id}"]

  assume_role {
    role_arn = "arn:aws:iam::${local.asahi_kasei_account_id}:role/${local.asahi_kasei_admin_role}"
  }
}
