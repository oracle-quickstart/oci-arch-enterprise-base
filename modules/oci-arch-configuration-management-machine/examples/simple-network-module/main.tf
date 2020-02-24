# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# in this example, TF isn't smart enough to handle the multiple dependencies... you need to run terraform apply -target=oci_core_network_security_group.test first, then terraform apply

module "oci_network" {
  source = "github.com/oracle/terraform-oci-tdf-network.git?ref=v0.9.7"

  default_compartment_id = var.default_compartment_id

  vcn_options = {
    display_name   = "simple test"
    cidr           = "192.168.0.0/19"
    enable_dns     = true
    dns_label      = "simpletest"
    compartment_id = null
    defined_tags   = null
    freeform_tags  = null
  }
}

module "ansible" {
  source = "../../"

  default_compartment_id = var.default_compartment_id
  vcn_id                 = module.oci_network.vcn.id
  vcn_cidr               = module.oci_network.vcn.cidr_block
  default_ssh_auth_keys  = var.default_ssh_auth_keys
  default_img_name       = var.default_img_name

  ssh_src_cidrs = [
    module.oci_network.vcn.cidr_block
  ]
  ssh_dst_cidrs = [
    module.oci_network.vcn.cidr_block
  ]
}
