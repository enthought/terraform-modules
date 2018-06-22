########################################################################
# Docker Cluster Resources
########################################################################

# **********************************************************************
# SSH Keyname Determination
# **********************************************************************

# Validate that one of ssh_public_key or ssh_key is provided
resource "null_resource" "ssh_key_defined" {
  count = "${var.ssh_public_key == "none" && var.ssh_key_name == "none" ? 1 : 0}"

  "ERROR: One of the ssh_public_key or ssh_key_name variables must be set" = true
}

# Validate that not both ssh_public_key and ssh_key were provided
resource "null_resource" "ssh_key_no_dupes" {
  count = "${var.ssh_public_key != "none" && var.ssh_key_name != "none" ? 1 : 0}"

  "ERROR: You may only define one of the ssh_public_key and ssh_key_name variables" = true
}

# Variable ssh_key_name depending on whether it was defined
locals {
  ssh_key_name = "${
        var.ssh_key_name != "none"
            ? var.ssh_key_name
            : "${format("%s-cluster-key", var.name)}"
    }"
}

# If a public key was provided, create an AWS keypair
resource "aws_key_pair" "ssh_keypair" {
  count      = "${var.ssh_public_key != "none" ? 1 : 0}"
  key_name   = "${local.ssh_key_name}"
  public_key = "${var.ssh_public_key}"
}

# Now we have a `local.ssh_key_name` that corresponds either to a freshly
# created AWS keypair or an existing keypair specified by the user.

# **********************************************************************
# Docker Cluster Cloudformation Definition
# **********************************************************************

# For some reason, all of the booleans for this template are yes/no,
# _except_ for EncryptEFS, which is true/false. To expose a consistent
# API, we convert a yes/no into a true/false here.

# Ensure the user specified one of yes/no, since we're just using a ternary
# check on "yes" below
resource "null_resource" "check_enable_efs_encryption" {
  count = "${
    var.enable_efs_encryption != "yes" && var.enable_efs_encryption != "no" ? 1 : 0
  }"

  "ERROR: enable_efs_encryption must be one of yes or no" = true
}

locals {
  enable_efs_encryption = "${var.enable_efs_encryption == "yes" ? "true" : "false"}"
}

resource "aws_cloudformation_stack" "docker_cluster" {
  name               = "${var.name}"
  template_url       = "https://editions-us-east-1.s3.amazonaws.com/aws/stable/Docker.tmpl"
  timeout_in_minutes = "${var.cloudformation_stack_timeout}"

  parameters = {
    ClusterSize          = "${var.worker_count}"
    EnableCloudStorEfs   = "${var.enable_efs}"
    EnableCloudWatchLogs = "${var.enable_cloudwatch_logs}"
    EnableEbsOptimized   = "${var.enable_optimized_ebs}"
    EnableSystemPrune    = "${var.enable_auto_prune}"
    EncryptEFS           = "${local.enable_efs_encryption}"
    InstanceType         = "${var.worker_instance_type}"
    KeyName              = "${local.ssh_key_name}"
    ManagerDiskSize      = "${var.manager_disk_size}"
    ManagerDiskType      = "${var.manager_disk_type}"
    ManagerInstanceType  = "${var.manager_instance_type}"
    ManagerSize          = "${var.manager_count}"
    WorkerDiskSize       = "${var.worker_disk_size}"
    WorkerDiskType       = "${var.worker_disk_type}"
  }

  capabilities = ["CAPABILITY_IAM"]
}

# **********************************************************************
# Routing and Security
# **********************************************************************

# Create a peering connection if requested.
data "aws_vpc" "cluster_vpc" {
  id = "${aws_cloudformation_stack.docker_cluster.outputs["VPCID"]}"
}

data "aws_vpc" "specified_vpc" {
  count = "${var.vpc_peering_configuration["vpc_id"] != "none" ? 1 : 0}"
  id    = "${var.vpc_peering_configuration["vpc_id"]}"
}

resource "aws_vpc_peering_connection" "cluster_to_specified_vpc" {
  count       = "${var.vpc_peering_configuration["vpc_id"] != "none" ? 1 : 0}"
  vpc_id      = "${var.vpc_peering_configuration["vpc_id"]}"
  peer_vpc_id = "${data.aws_vpc.cluster_vpc.id}"
}

data "aws_route_table" "secondary_cluster_table" {
  vpc_id = "${data.aws_vpc.cluster_vpc.id}"

  filter = {
    name   = "association.main"
    values = ["false"]
  }

  tags = {
    "aws:cloudformation:stack-name" = "${aws_cloudformation_stack.docker_cluster.name}"
    Name                            = "${format("%s-RT", var.name)}"
  }
}

resource "aws_route" "cluster_to_specified_vpc" {
  count                     = "${var.vpc_peering_configuration["vpc_id"] != "none" ? 1 : 0}"
  route_table_id            = "${data.aws_route_table.secondary_cluster_table.id}"
  destination_cidr_block    = "${data.aws_vpc.specified_vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.cluster_to_specified_vpc.id}"
}

resource "aws_route" "specified_vpc_to_cluster" {
  count                     = "${var.vpc_peering_configuration["vpc_id"] != "none" ? 1 : 0}"
  route_table_id            = "${var.vpc_peering_configuration["route_table_id"]}"
  destination_cidr_block    = "${data.aws_vpc.cluster_vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.cluster_to_specified_vpc.id}"
}

locals {
  peer_vpc_sg_name = "${
    var.vpc_peering_configuration["vpc_id"] != "none"
      ? format("%s-peer-vpc-sg", var.name)
      : "none"
  }"
}

resource "aws_security_group" "cluster_group_on_specified_vpc" {
  count       = "${var.vpc_peering_configuration["vpc_id"] != "none" ? 1 : 0}"
  name        = "${local.peer_vpc_sg_name}"
  description = "Security group for the '${var.name}' docker cluster"
  vpc_id      = "${var.vpc_peering_configuration["vpc_id"]}"
}

resource "aws_route53_record" "cluster_dns_record" {
  count   = "${var.dns_configuration["name"] != "none" ? 1 : 0}"
  name    = "${var.dns_configuration["name"]}"
  zone_id = "${var.dns_configuration["zone_id"]}"
  type    = "${var.dns_record_type}"
  ttl     = "${var.dns_record_ttl}"

  records = [
    "${aws_cloudformation_stack.docker_cluster.outputs["DefaultDNSTarget"]}",
  ]
}

# **********************************************************************
# Extra Data Sources for Outputs
# **********************************************************************

data "aws_instances" "cluster_managers" {
  filter {
    name   = "instance.group-id"
    values = ["${aws_cloudformation_stack.docker_cluster.outputs["ManagerSecurityGroupID"]}"]
  }
}

data "aws_instances" "cluster_workers" {
  filter {
    name   = "instance.group-id"
    values = ["${aws_cloudformation_stack.docker_cluster.outputs["NodeSecurityGroupID"]}"]
  }
}

data "aws_instance" "first_manager" {
  instance_id = "${data.aws_instances.cluster_managers.ids[0]}"
}

data "aws_instance" "first_worker" {
  instance_id = "${data.aws_instances.cluster_workers.ids[0]}"
}

data "aws_iam_instance_profile" "manager_profile" {
  name = "${data.aws_instance.first_manager.iam_instance_profile}"
}

data "aws_iam_instance_profile" "worker_profile" {
  name = "${data.aws_instance.first_worker.iam_instance_profile}"
}

data "aws_iam_role" "manager_profile_role" {
  name = "${data.aws_iam_instance_profile.manager_profile.role_name}"
}

data "aws_iam_role" "worker_profile_role" {
  name = "${data.aws_iam_instance_profile.worker_profile.role_name}"
}
