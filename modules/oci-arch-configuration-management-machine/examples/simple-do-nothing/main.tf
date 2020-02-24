# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# in this example, TF isn't smart enough to handle the multiple dependencies... you need to run terraform apply -target=oci_core_network_security_group.test first, then terraform apply

module "ansible" {
  source                  = "../../"
  
  default_compartment_id  = var.default_compartment_id
  vcn_id          = oci_core_vcn.this.id
  vcn_cidr        = oci_core_vcn.this.cidr_block
  default_ssh_auth_keys = var.default_ssh_auth_keys
  default_img_name = var.default_img_name

  create_nsg      = false
  create_compute  = false
  create_subnet   = false
}

resource "oci_core_vcn" "this" {
  dns_label      = "temp"
  cidr_block     = "192.168.0.0/16"
  compartment_id = var.default_compartment_id
  display_name   = "temp"
}
