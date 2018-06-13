########################################################################
# Docker Cluster Outputs
########################################################################

# See https://editions-us-east-1.s3.amazonaws.com/aws/stable/Docker.tmpl for
# outputs and definitions
output "stack" {
  description = "Outputs from the cloudformation stack template"
  value       = "${aws_cloudformation_stack.docker_cluster.outputs}"
}

output "name" {
  description = "The name of the cluster"
  value       = "${var.name}"
}

output "ssh_key_pair" {
  description = "The name of the SSH keypair associated with the cluster."
  value       = "${local.ssh_key_name}"
}

output "cluster_vpc_id" {
  description = "The ID of the cluster's VPC"
  value       = "${data.aws_vpc.cluster_vpc.id}"
}

output "peer_vpc_id" {
  description = "The ID of the VPC to which the cluster is peered, if applicable."
  value       = "${var.vpc_peering_configuration["vpc_id"]}"
}

# See https://github.com/hashicorp/terraform/issues/16726 for the source
# of this crazy syntax.
output "peer_vpc_sg_id" {
  description = "The ID of the seucrity group on the peer VPC used for cluster-related rules"
  value       = "${element(concat(aws_security_group.cluster_group_on_specified_vpc.*.id, list("")), 0)}"
}

output "manager_instance_ids" {
  description = "A list of EC2 instance IDs for cluster managers"
  value       = "${data.aws_instances.cluster_managers.ids}"
}

output "worker_instance_ids" {
  description = "A list of EC2 instance IDs for cluster workers"
  value       = "${data.aws_instances.cluster_workers.ids}"
}

output "manager_iam_instance_profile" {
  description = "The AWS IAM Instance Profile associated with manager nodes"

  value = {
    name = "${data.aws_iam_instance_profile.manager_profile.name}"
    arn  = "${data.aws_iam_instance_profile.manager_profile.arn}"
  }
}

output "worker_iam_instance_profile" {
  description = "The AWS IAM Instance Profile associated with worker nodes"

  value = {
    name = "${data.aws_iam_instance_profile.worker_profile.name}"
    arn  = "${data.aws_iam_instance_profile.worker_profile.arn}"
  }
}

output "manager_iam_instance_profile_role" {
  description = "The IAM role associated with the manager IAM instance profile"

  value = {
    name = "${data.aws_iam_role.manager_profile_role.id}"
    arn  = "${data.aws_iam_role.manager_profile_role.arn}"
    path = "${data.aws_iam_role.manager_profile_role.path}"
  }
}

output "worker_iam_instance_profile_role" {
  description = "The IAM role associated with the worker IAM instance profile"

  value = {
    name = "${data.aws_iam_role.worker_profile_role.id}"
    arn  = "${data.aws_iam_role.worker_profile_role.arn}"
    path = "${data.aws_iam_role.worker_profile_role.path}"
  }
}
