# AWS_CREATE_ORGANIZATION

This module is for creating the AWS child organization and baseline configuration before handing over to developers in the distinct terraform silo.

It is expected to be run from within the enthought "global" silo.

## Variables

|Name|Description|Default|
|silo-product-name|The Customer or Customer/Productname prepend for the silo||
|silo-tags|Tags to apply to the VPC|[]|
|silo-environment|What string is this Organization|dev|
|admin-id|The Admin account ID to assume for this organization.||
|admin-role|The Admin role to assume for this organization.|EnthoughtOrgFullAdminRights|
|aws-region|Which AWS Region to create the resources in?|us-east-1|
|aws-key-pair|AWS keypair value - public_key||
|vpc-name|Name for the Silo VPC||
|vpc-cidr|CIDR block for the vpc||
|vpc-availability-zones|Availability Zones for the VPC|["us-east-1a"]|
|vpc-private-subnets|Private Subnets for the silo VPC|["10.20.1.0/24", "10.20.2.0/24","10.20.3.0/24",]|
|vpc-public-subnets|Public Subnets for the silo VPC|["10.20.101.0/24", "10.20.102.0/24","10.20.103.0/24",]|
|vpc-enable-nat-gateway|Enable the NAT gateway on the VPC|false|
|vpc-enable-vpn-gateway|Enable the VPN gateway on the VPC|false|
|pritnl-ami-id|AMI to use for pritnl instance|ami-0080e4c5bc078760e|
|pritnl-instance-type|What size instance to use for the pritnl|t2.nano|
|pritnl-name-prefix|Pritnl instance name prefix|pritnl|
|pritnl-healthchecks-io-key|Key for healthchecks.io if used.|NNNNNNNN-NNNN-NNNN-NNNN-NNNNNNNNNNN|
|pritnl-whitelist|Array of CIDR blocks to whitelist in pritnl.|["8.8.8.8/32","24.227.217.184/29",]|
}
