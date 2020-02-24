# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



module "ent_base" {
  source                = "../../"
  
  default_compartment_id = var.default_compartment_id
  default_ssh_auth_keys  = var.default_ssh_auth_keys
  default_img_name       = var.default_img_name

  create_bastion = false
  create_ansible = false
  create_dns     = false

  use_default_vcn_wide_rules = true
  additional_vcn_wide_rules = {
    ingress_rules = [
      {
        stateless = false
        protocol  = "6"
        src       = "192.168.0.0/20"
        src_type  = "CIDR_BLOCK"
        src_port  = null
        dst_port = {
          min = 443
          max = 443
        }
        icmp_type = null
        icmp_code = null
      }
    ],
    egress_rules = [
      {
        stateless = false
        protocol  = "6"
        dst       = "0.0.0.0/0"
        dst_type  = "CIDR_BLOCK"
        src_port  = null
        dst_port = {
          min = 443
          max = 443
        }
        icmp_type = null
        icmp_code = null
      }
    ]
  }

  bastion_options = {
    subnet_compartment_id   = null
    subnet_name             = null
    subnet_dns_label        = null
    subnet_cidr             = null
    instance_compartment_id = null
    instance_ad             = null
    instance_name           = null
    instance_dns_label      = null
    instance_shape          = null
    ssh_auth_keys           = null
    ssh_src_cidrs           = ["0.0.0.0/0"]
    image_name              = null
    image_id                = null
    allow_int_routes        = false
    private_ip              = null
    public_ip               = true
    use_default_nsg_rules   = true
    route_table_id          = null
    freeform_tags           = null
    defined_tags            = null
  }
}

