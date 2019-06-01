################################################
# Build the VPC and pritunl instance
################################################

locals {
  terraform-tag = {
    "terraform" = "true"
  }

  pritunl-tag = {
    "role" = "vpn",
  }

  amended_tags = "${merge( var.silo-tags, local.terraform-tag )}"
}

resource "aws_key_pair" "org-key" {
  key_name   = "${var.silo-product-name}-key"
  public_key = "${var.aws-key-pair}"
  
}

module "silo-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.vpc-name}"
  cidr = "${var.vpc-cidr}"

  azs             = "${var.vpc-availability-zones}"
  private_subnets = "${var.vpc-private-subnets}"
  public_subnets  = "${var.vpc-public-subnets}"

  enable_nat_gateway = "${var.vpc-enable-nat-gateway}"
  enable_vpn_gateway = "${var.vpc-enable-vpn-gateway}"

  tags = "${local.amended_tags}"
}

module "silo-pritunl" {
  source = "github.com/opsgang/terraform_pritunl?ref=2.3.0"

  aws_key_name         = "${aws_key_pair.org-key.key_name}"
  vpc_id               = "${module.silo-vpc.vpc_id}"
  public_subnet_id     = "${module.silo-vpc.public_subnets[1]}"
  ami_id               = "${var.pritunl-ami-id}"
  instance_type        = "${var.pritunl-instance-type}"
  resource_name_prefix = "${var.pritunl-name-prefix}"
  healthchecks_io_key  = "${var.pritunl-healthchecks-io-key}"

  whitelist = "${var.pritunl-whitelist}"

  tags = "${merge(local.amended_tags, local.pritunl-tag)}"
}
