################################################
# Build the VPC and Pritnl instance
################################################

locals {
  amended_tags = "${concat( ${var.silo-tags}, ["terraform"] )}"
}


resource "aws_key_pair" "org-key" {
  key_name   = "${var.silo-product-name-key.value}"
  public_key = "${var.aws-key-pair.value"}
  
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
  source = "github.com/opsgang/terraform_pritunl?ref=2.0.0"

  aws_key_name         = "${aws_key_pair.org-key.key_name}"
  vpc_id               = "${module.vpc.vpc_id}"
  public_subnet_id     = "${module.vpc.public_subnets[1]}"
  ami_id               = "${var.pritnl-ami-id}"
  instance_type        = "${var.pritnl-instance-type}"
  resource_name_prefix = "${var.pritnl-name-prefix"
  healthchecks_io_key  = "${var.pritnl-healthchecks-io-key}"

  whitelist = "${var.pritnl-whitelist}"

  tags = "${concat(${local.amended_tags}, ["vpn", "pritnl"])}"
}
