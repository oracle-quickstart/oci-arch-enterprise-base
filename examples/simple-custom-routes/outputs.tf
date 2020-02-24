# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



/*
output "vcn" {
  description = "VCN"
  value       = module.ent_base.vcn
}
*/

output "bastion_priv_ip" {
  value = module.ent_base.bastion_instance.private_ip
}

output "bastion_pub_ip" {
  value = module.ent_base.bastion_instance.public_ip
}

# output "bastion_nsg" {
#   value       = module.ent_base.bastion_nsg
# }

/*
output "bastion_nsg_rules" {
  value       = module.ent_base.bastion_nsg_rules
}

output "vcn_wide_sl" {
  value       = module.ent_base.vcn_wide_sl
}
*/
