# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# network-specific
output "vcn" {
  description = "VCN"
  value       = module.oci_network.vcn
}

output "igw" {
  description = "IGW"
  value       = module.oci_network.igw
}

output "svcgw" {
  description = "SVCGW"
  value       = module.oci_network.svcgw
}

output "svcgw_services" {
  description = "SVCGW Services"
  value       = module.oci_network.svcgw_services
}

output "natgw" {
  description = "NATGW"
  value       = module.oci_network.natgw
}

output "drg" {
  description = "DRG"
  value       = module.oci_network.drg
}

output "dhcp_options" {
  value = module.oci_network.dhcp_options
}

output "route_tables" {
  value = module.oci_network.route_tables
}

output "vcn_wide_sl" {
  value = length(module.oci_network_security_policies.security_lists) > 0 ? values(module.oci_network_security_policies.security_lists)[0] : null
}

output "default_sl" {
  value = oci_core_default_security_list.this
}

# bastion-specific
output "bastion_subnet" {
  value       = module.bastion.subnet
  description = "The bastion subnet that was created."
}

output "bastion_nsg" {
  value       = module.bastion.nsg
  description = "The bastion NSG that was created."
}

output "bastion_nsg_rules" {
  value       = module.bastion.nsg_rules
  description = "The bastion NSG Rules that have been created."
}

output "bastion_instance" {
  value       = module.bastion.instance
  description = "The bastion compute instance that has been created."
}

# DNS-specific
output "dns_cloud_init_data" {
  value = module.dns.cloud_init_data
}

output "dns_instances" {
  value       = module.dns.instances
  description = "The DNS compute instance(s) that have been created."
}

# ansible-specific
output "ansible_instance" {
  value       = module.ansible.instance
  description = "The Ansible compute instance that has been created."
}
