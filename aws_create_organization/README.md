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
|pritunl-ami-id|AMI to use for pritunl instance|ami-0080e4c5bc078760e|
|pritunl-instance-type|What size instance to use for the pritunl|t2.nano|
|pritunl-name-prefix|pritunl instance name prefix|pritunl|
|pritunl-healthchecks-io-key|Key for healthchecks.io if used.|NNNNNNNN-NNNN-NNNN-NNNN-NNNNNNNNNNN|
|pritunl-whitelist|Array of CIDR blocks to whitelist in pritunl.|["8.8.8.8/32","24.227.217.184/29",]|
}

Note that we are not **yet** using Healthchecks.io but it is backed into the module currently being used. If it beciomes an issue we will need to fork it out.

## Usage

1. Create an AWS Project Organization per guidelines. Currently [here.](https://docs.google.com/document/d/16-1Wz22i6O2S5mj398rifWotIJB-AB9gLv8U04g50Ck/edit)
2. Create a new terraform file with a module block as below.
3. Plan and Apply with the new terraform file.

## Module Block

```
module "<Siloname>" {
    source = "github.com/enthought/terraform-modules.git//aws_create_organization?ref=v1.0.2"
    silo-product-name = "<Siloname>"
    silo-tags = []
    silo-environment = ""
    admin-id = <AWS Account Number from step 1>
    admin-role = EnthoughtOrgFullAdminRights
    aws-region = "us-east-1"
    aws-key-pair = "<SSH Public Key Unique to account>"
    vpc-name = "<Siloname>"
    vpc-cidr = "10.20.0.0/16"
    vpc-availability-zones = ["us-east-1a"]|
    vpc-private-subnets = ["10.20.1.0/24", "10.20.2.0/24","10.20.3.0/24",]|
    vpc-public-subnets = ["10.20.101.0/24", "10.20.102.0/24","10.20.103.0/24",]|
    vpc-enable-nat-gateway = false
    vpc-enable-vpn-gateway = false
    pritunl-ami-id = "ami-0080e4c5bc078760e"
    pritunl-instance-type = "t2.nano"
    pritunl-name-prefix = "pritunl"
    pritunl-whitelist = ["8.8.8.8/32","24.227.217.184/29",]|
}
```