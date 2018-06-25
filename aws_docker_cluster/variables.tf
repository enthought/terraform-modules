########################################################################
# aws_docker_cluster variables
########################################################################

# **********************************************************************
# Cluster Settings
# **********************************************************************

# Note that the default cluster settings are somewhere in between
# "dev-only minimal cluster" and "full fledged production cluster". You
# will probably want to tweak the number of instances and instance types
# especially to match your cluster's use-case.

# The stack name is used to generate the names of a number of resources.
# It should be short but descriptive. If creating a deploy-environment-specific
# cluster, the environment should be included in the name, e.g.
# "enthought-dev" or "brood-prod"
variable "name" {
  description = "A short, descriptive name for the cluster"
  type        = "string"
}

# Either an SSH public key or the name of an EC2 keypair must be provided.
# In the former case, an EC2 keypair will be created with the provided public
# key. In either case, the public key will be associated with Docker manager
# nodes to allow users to login via SSH.
variable "ssh_public_key" {
  description = "The public key to associate with manager nodes. Either this or `ssh_key_name` must be provided."
  type        = "string"
  default     = "none"
}

variable "ssh_key_name" {
  description = "An existing AWS-managed private/public keypair name to associate with manager nodes. Either this or `ssh_public_key` must be provided."
  type        = "string"
  default     = "none"
}

# The integer number of managers present in the cluster. The lowest this
# should be for any production workload is 3, allowing the managers to be
# balanced across availability zones. Should be one of 1, 3, or 5. Be
# aware that decreasing this number will result in the destruction of
# instances.
variable "manager_count" {
  description = "The number of manager nodes in the cluster."
  type        = "string"
  default     = "3"
}

# The integer number of workers present in the cluster. This may be anywhere
# from 1 to 1000. Be aware that cecreasing this number will result in the
# destruction of instances.
variable "worker_count" {
  description = "The number of worker nodes in the cluster."
  type        = "string"
  default     = "2"
}

# Manager nodes will be created with the specified instance type
# (e.g. t2.micro). In general, manager should be a bit beefier than workers,
# as they have management tasks to attend to in addition to cluster workloads.
variable "manager_instance_type" {
  description = "The AWS instance type for manager nodes."
  type        = "string"
  default     = "t2.small"
}

# Worker nodes will be created with the specified instance type.
variable "worker_instance_type" {
  description = "The AWS instance type for worker nodes."
  type        = "string"
  default     = "t2.micro"
}

# Whether or not the EFS driver should be made available to the cluster.
# This allows the creation and use of EFS-backed volumes that may be shared
# across the cluster. If this is disabled, shared volumes must use EBS and
# must specify a size up-front.
# Should be one of "yes" or "no".
variable "enable_efs" {
  description = "Allow the use of EFS storage volumes."
  type        = "string"
  default     = "yes"
}

# SHould be one of "yes" or "no"
variable "enable_efs_encryption" {
  description = "Encrypt any EFS volumes"
  type        = "string"
  default     = "no"
}

# Enable automatic redirection of all container logs to CloudWatch. If this is
# enabled, viewing container logs from a manager node is not supported.
# If this is enabled, the use of other logging manager dependent on logs
# being written to the Docker socket will not function as intended.
# Should be one of "yes" or "no"
variable "enable_cloudwatch_logs" {
  description = "Automatically direct all container logs to CloudWatch."
  type        = "string"
  default     = "no"
}

# Should be one of "yes" or "no"
variable "enable_optimized_ebs" {
  description = "Whether the launch configuration is optimized for EBS I/O."
  type        = "string"
  default     = "no"
}

# `docker system prune` removes unused volumes, images, containers, and
# networks. Enabling this option causes `system prune` to be run daily
# around 1 AM, staggered so that all nodes are not running simultaneously.
# Should be one of "yes" or "no"
variable "enable_auto_prune" {
  description = "Whether `system prune` should be run daily on the cluster."
  type        = "string"
  default     = "no"
}

variable "manager_disk_size" {
  description = "Manager disk size in GiB."
  type        = "string"
  default     = "20"
}

# Should be one of "standard" or "gp2"
variable "manager_disk_type" {
  description = "Volume type for manager ephemeral storage."
  type        = "string"
  default     = "standard"
}

variable "worker_disk_size" {
  description = "Worker disk size in GiB."
  type        = "string"
  default     = "20"
}

# Should be one of "standard" or "gp2"
variable "worker_disk_type" {
  description = "Volume type for worker ephemeral storage."
  type        = "string"
  default     = "standard"
}

variable "cloudformation_stack_timeout" {
  description = "How long to wait before timing out when applying cloudformation stack changes."
  type        = "string"
  default     = "60"
}

# **********************************************************************
# Network Configuration
# **********************************************************************

variable "vpc_peering_configuration" {
  description = <<EOF
If provided, VPC and Route Table IDs to which a peering connection and
route should be stablished from the cluster VPC. The provided route table
should be associated with the provided VPC. In addition, a security group
will be created in the provided VPC to allow the specification of
ingress/egress rules.

If not provided, the cluster VPC will remain isolated.
EOF

  type = "map"

  default = {
    vpc_id         = "none"
    route_table_id = "none"
  }
}

variable "dns_configuration" {
  description = <<EOF
If provided, a DNS record will be created with a record pointing to the
primary DNS target of the cluster (the cluster load balancer). By
default, a CNAME record with a ttl of 300 seconds will be created. These
values can be customized via their respective variables.
EOF

  type = "map"

  default = {
    zone_id = "none"
    name    = "none"
  }
}

variable "dns_record_type" {
  description = "The type of DNS record to create if `dns_configuration` is specified."
  type        = "string"
  default     = "CNAME"
}

variable "dns_record_ttl" {
  description = "The ttl for the DNS record created if `dns_configuration` is specified."
  type        = "string"
  default     = "300"
}
