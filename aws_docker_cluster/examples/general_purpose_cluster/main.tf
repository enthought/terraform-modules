########################################################################
# aws_docker_cluster general purpose example
########################################################################

# The VPC where the database lives
data "aws_vpc" "main_vpc" {
  tags = {
    Name = "com.mycompany.vpc"
  }
}

data "aws_route_table" "main_vpc_main_table" {
  vpc_id = "${data.aws_vpc.main_vpc.id}"

  filter = {
    name   = "association.main"
    values = ["true"]
  }
}

data "aws_route53_zone" "org_wildcard" {
  name = "mycompany.org."
}

module "prod_cluster" {
  source                = "git::git@github.com:enthought/terraform-modules.git//aws_docker_cluster?ref=v0.0.1"
  name                  = "prod_cluster"
  ssh_public_key        = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSUGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3Pbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XAt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/EnmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbxNrRFi9wrf+M7Q== foo_user@mylaptop.local"
  manager_count         = "5"
  worker_count          = "10"
  manager_instance_type = "t2.large"
  worker_instance_type  = "t2.small"

  vpc_peering_configuration = {
    vpc_id         = "${data.aws_vpc.main_vpc.id}"
    route_table_id = "${data.aws_route_table.main_vpc_main_table.id}"
  }

  dns_configuration = {
    zone_id = "${data.aws_route53_zone.org_wildcard.id}"
    name    = "cluster.mycompany.org"
  }
}

# Add security group rule to allow communication from cluster nodes via the
# postgres port (5432) to the main VPC
resource "aws_security_group_rule" "db_ingress" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  security_group_id        = "${module.prod_cluster.peer_vpc_sg_id}"
  source_security_group_id = "${module.prod_cluster.stack["SwarmWideSecurityGroupID"]}"
}

# Associate an additional policy with the instance role associated with
# cluster nodes.
# In this case, we are ensuring nodes can access a "static bucket" via
# the standard S3 interface, without requiring additional credentials

data "aws_iam_policy_document" "static_bucket_access" {
  statement {
    sid    = "prod_cluster_static_bucket_access"
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::mycompany-prod-static-bucket/*",
    ]
  }
}

resource "aws_iam_policy" "static_bucket_access" {
  name   = "prod_cluster_static_bucket_access"
  policy = "${data.aws_iam_policy_document.static_bucket_access.json}"
}

# Now we just attach the policy to the manager and worker instance roles
resource "aws_iam_role_policy_attachment" "manager_static_bucket_access" {
  role       = "${module.prod_cluster.manager_iam_instance_profile_role["name"]}"
  policy_arn = "${aws_iam_policy.static_bucket_access.arn}"
}

resource "aws_iam_role_policy_attachment" "worker_static_bucket_access" {
  role       = "${module.prod_cluster.worker_iam_instance_profile_role["name"]}"
  policy_arn = "${aws_iam_policy.static_bucket_access.arn}"
}
