# aws_docker_cluster

Manage the AWS resources necessary for a full Docker Cluster optionally
integrated with existing network resources.

Manages the following resources:

* An AWS keypair for logging into cluster managers (may also use an existing
keypair)
* A cloudformation stack based on Docker's official template
* An optional peering connection to a specified peer VPC
    * A route from the cluster VPC to the peer VPC
    * A route from the specified VPC to the peer VPC
    * A new security group on the peer VPC for managing cluster rules
* An optional DNS record pointing to the cluster's default DNS target

## Variables

See [variables.tf](variables.tf) for a full listing!

## Outputs

See [outputs.tf](outputs.tf) for a full listing!

## Future Improvements

* Allow specifying multiple VPCs to which to create peering connections
