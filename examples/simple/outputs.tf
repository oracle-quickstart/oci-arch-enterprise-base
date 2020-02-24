# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



/*
output "vcn" {
  description = "VCN"
  value       = module.ent_base.vcn
}
*/

output "bastion_priv_ip" {
  value = module.ent_base.bastion_instance != null ? module.ent_base.bastion_instance.private_ip : null
}

output "bastion_pub_ip" {
  value = module.ent_base.bastion_instance != null ? module.ent_base.bastion_instance.public_ip : null
}

output "dns_1_priv_ip" {
  value = module.ent_base.dns_instances != null ? (length(module.ent_base.dns_instances) > 0 ? values(module.ent_base.dns_instances)[0].private_ip : null) : null
}
output "dns_2_priv_ip" {
  value = module.ent_base.dns_instances != null ? (length(module.ent_base.dns_instances) > 1 ? values(module.ent_base.dns_instances)[1].private_ip : null) : null
}
output "dns_3_priv_ip" {
  value = module.ent_base.dns_instances != null ? (length(module.ent_base.dns_instances) > 2 ? values(module.ent_base.dns_instances)[2].private_ip : null) : null
}

# output "dns_instances" {
#   value = module.ent_base.dns_instances
# }

output "ansible_priv_ip" {
  value = module.ent_base.ansible_instance != null ? module.ent_base.ansible_instance.private_ip : null
}


# output "bastion_nsg" {
#   value       = module.ent_base.bastion_nsg
# }

# output "dns_cloud_init_data" {
#   value = module.ent_base.dns_cloud_init_data
# }

/*
output "bastion_nsg_rules" {
  value       = module.ent_base.bastion_nsg_rules
}

output "vcn_wide_sl" {
  value       = module.ent_base.vcn_wide_sl
}
*/
