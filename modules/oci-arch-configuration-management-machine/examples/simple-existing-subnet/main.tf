# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.





module "ansible" {
  source                = "../../"
  # depends_on      = [ oci_core_network_security_group.test ]

  default_compartment_id = var.default_compartment_id
  vcn_id                = oci_core_vcn.this.id
  vcn_cidr              = oci_core_vcn.this.cidr_block
  default_ssh_auth_keys = var.default_ssh_auth_keys
  default_img_name      = var.default_img_name
  
  create_subnet         = false
  existing_subnet_id    = oci_core_subnet.test.id

  ssh_src_cidrs         = [
    oci_core_vcn.this.cidr_block
  ]
  ssh_dst_cidrs         = [
    oci_core_vcn.this.cidr_block
  ]
}

resource "oci_core_subnet" "test" {
  cidr_block          = "192.168.100.0/24"
  compartment_id      = var.default_compartment_id
  vcn_id              = oci_core_vcn.this.id
  display_name        = "test"
  dns_label           = "test"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_vcn" "this" {
  dns_label             = "temp"
  cidr_block            = "192.168.0.0/16"
  compartment_id        = var.default_compartment_id
  display_name          = "temp"
}
