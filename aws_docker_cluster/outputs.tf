output "cluster" {
  value = "${aws_cloudformation_stack.docker_cluster.outputs}"
}

output "name" {
  value = "${var.name}"
}
