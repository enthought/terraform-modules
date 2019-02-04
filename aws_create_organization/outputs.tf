################################################
# Outputs
################################################

output "vpc-id" {
  value = "${module.silo-vpc.vpc_id}"
}

output "pritnl-public-ip" {
    value = "${module.silo-pritnl.vpn_public_ip_address}"
}

output "pritnl-public-ip" {
    value = "${module.silo-pritnl.vpn_instance_private_ip_address}"
}

output "pritnl-public-ip" {
    value = "${module.silo-pritnl.vpn_management_ui}"
}