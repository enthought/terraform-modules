################################################
# Outputs
################################################

output "vpc-id" {
  value = "${module.silo-vpc.vpc_id}"
}

output "pritunl-private-ip" {
    value = "${module.silo-pritunl.vpn_instance_private_ip_address}"
}

output "pritunl-vpn-ip" {
    value = "${module.silo-pritunl.vpn_management_ui}"
}

output "pritunl-public-ip" {
    value = "${module.silo-pritunl.vpn_public_ip_address}"
}

