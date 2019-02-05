################################################
# Module variables
################################################

variable "name" {
  description = ""
  default = ""
}

variable "silo-product-name" {
  description = "The Customer or Customer/Productname prepend for the silo."
  default = ""
}

variable "silo-tags" {
  description = "Tags to apply to the VPC"
  default = []
}

variable "silo-environment" {
  description = "What string is this Organization"
  default = "dev"
}

################################################
# AWS Account config
################################################

variable "admin-id" {
  description = "The Admin account ID to assume for this organization."
  default = ""
}

variable "admin-role" {
  description = "The Admin role to assume for this organization."
  default = "EnthoughtOrgFullAdminRights"
}

variable "aws-region" {
  description = "Which AWS Region to create the resources in?"
  default = "us-east-1"
}

variable "aws-key-pair" {
  description   = "AWS keypair value - public_key"
  default = ""
}

################################################
# VPC Configuration
################################################

variable "vpc-name" {
  description = "Name for the Silo VPC"
  default = ""
}

variable "vpc-cidr" {
  description = "CIDR block for the vpc"
  default = "10.20.0.0/16"
}

variable "vpc-availability-zones" {
  description = ""
  default = ["us-east-1a"]
}

variable "vpc-private-subnets" {
  description = "Private Subnets for the silo VPC"
  default = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
}

variable "vpc-public-subnets" {
  description = "Public Subnets for the silo VPC"
  default = ["10.20.101.0/24", "10.20.102.0/24", "10.20.103.0/24"]
}

variable "vpc-enable-nat-gateway" {
  description = "Enable the NAT gateway on the VPC"
  default = false
}
variable "vpc-enable-vpn-gateway" {
  description = "Enable the VPN gateway on the VPC"
  default = false
}

################################################
# Pritnl Configuration
################################################

variable "pritnl-ami-id" {
  description = "AMI to use for pritnl instance"
  default = "ami-0080e4c5bc078760e"
}

variable "pritnl-instance-type" {
  description = "What size instance to use for the pritnl"
  default = "t2.nano"
}

variable "pritnl-name-prefix" {
  description = "Pritnl instance name prefix"
  default = "pritnl"
}

variable "pritnl-healthchecks-io-key" {
  description = "Key for healthchecks.io if used."
  default = "NNNNNNNN-NNNN-NNNN-NNNN-NNNNNNNNNNN"
}

variable "pritnl-whitelist" {
  description = "Array of CIDR blocks to whitelist in pritnl."
  default = [
    "8.8.8.8/32",
    "24.227.217.184/29",
  ]
}
