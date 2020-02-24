# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



output "subnet" {
  # value       = module.oci_subnets != null ? ( module.oci_subnets.subnets != null ? ( length( module.oci_subnets.subnets ) > 0 ? values( module.oci_subnets.subnets )[0] : null ) : null ) : null
  value       = oci_core_subnet.this != null && length(oci_core_subnet.this) > 0 ? oci_core_subnet.this[0] : null
  description = "The subnet that was created."
}

output "nsg" {
  value       = length( module.network_security_policies.nsgs ) > 0 ? values( module.network_security_policies.nsgs )[0] : null
  description = "The NSG that was created."
}

output "nsg_rules" {
  value       = module.network_security_policies.nsg_rules
  description = "The NSG Rules that have been created."
}

output "instance" {
  value       = length( module.oci_instances.instance ) > 0 ? values( module.oci_instances.instance )[0] : null
  description = "The compute instance that has been created."
}
