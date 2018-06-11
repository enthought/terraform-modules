## inputs:
# cluster name
# cluster settings
# connect to existing vpc?
# vpc id
# dns to cluster?
## outputs:
# instances
# instance profile
########################################################################
# Docker Cluster Resources
########################################################################

# **********************************************************************
# SSH Keyname Determination
# **********************************************************************

# Validate that one of ssh_public_key or ssh_key is provided
resource "null_resource" "ssh_key_defined" {
  count = "${vars.ssh_public_key == "none" && vars.ssh_key_name == "none" ? 1 : 0}"

  "ERROR: One of the ssh_public_key or ssh_key_name variables must be set" = true
}

# Validate that not both ssh_public_key and ssh_key were provided
resource "null_resource" "ssh_key_no_dupes" {
  count = "${vars.ssh_public_key != "none" && vars.ssh_key_name != "none" ? 1 : 0}"

  "ERROR: You may only define one of the ssh_public_key and ssh_key_name variables" = true
}

# Variable ssh_key_name depending on whether it was defined
locals {
  ssh_key_name = "${
        vars.ssh_key_name != "none"
            ? vars.ssh_key_name
            : "${format("%s-cluster-key", vars.name)}"
    }"
}

# If a public key was provided, create an AWS keypair
resource "aws_key_pair" "ssh_keypair" {
  count      = "${vars.ssh_public_key != "none" ? 1 : 0}"
  key_name   = "${local.ssh_key_name}"
  public_key = "${vars.ssh_public_key}"
}

# Now we have a `local.ssh_key_name` that corresponds either to a freshly
# created AWS keypair or an existing keypair specified by the user.

# **********************************************************************
# Docker Cluster Cloudformation Definition
# **********************************************************************

resource "aws_cloudformation_stack" "docker_cluster" {
  name               = "${vars.name}"
  template_url       = "https://editions-us-east-1.s3.amazonaws.com/aws/stable/Docker.tmpl"
  timeout_in_minutes = "${vars.cloudformation_stack_timeout}"

  parameters = {
    ClusterSize          = "${vars.worker_count}"
    EnableCloudStorEfs   = "${vars.enable_efs}"
    EnableCloudWatchLogs = "${vars.enable_cloudwatch_logs}"
    EnableEbsOptimized   = "${vars.enable_optimized_ebs}"
    EnableSystemPrune    = "${vars.enable_auto_prune}"
    EncryptEFS           = "${vars.enable_efs_encryption}"
    InstanceType         = "${vars.worker_instance_type}"
    KeyName              = "${local.ssh_key_name}"
    ManagerDiskSize      = "${vars.manager_disk_size}"
    ManagerDiskType      = "${vars.manager_disk_type}"
    ManagerInstanceType  = "${vars.manager_instance_type}"
    ManagerSize          = "${vars.manager_count}"
    WorkerDiskSize       = "${vars.worker_disk_size}"
    WorkerDiskType       = "${vars.worker_disk_type}"
  }

  capabilities = ["CAPABILITY_IAM"]
}
