# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



module "ent_base" {
  source                = "../../"
  
  default_compartment_id = var.default_compartment_id
  default_ssh_auth_keys  = var.default_ssh_auth_keys
  # default_img_id        = var.default_img_id
  default_img_name = var.default_img_name

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
    allow_int_routes        = true
    private_ip              = null
    public_ip               = true
    use_default_nsg_rules   = true
    route_table_id          = null
    freeform_tags           = null
    defined_tags            = null
  }

  ansible_options = {
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
    ssh_src_cidrs           = ["192.168.0.8/29"]
    image_name              = null
    image_id                = null
    allow_int_routes        = null
    private_ip              = null
    public_ip               = false
    use_default_nsg_rules   = true
    route_table_id          = null
    freeform_tags           = null
    defined_tags            = null
  }

  dns_options = {
    subnet_compartment_id   = null
    subnet_name             = null
    subnet_dns_label        = null
    subnet_cidr             = null
    instance_compartment_id = null
    instance_shape          = null
    ssh_auth_keys           = null
    image_id                = null
    image_name              = null
    public_ip               = null
    allow_int_routes        = null
    dns_src_cidrs           = null
    dns_dst_cidrs = [
      "10.1.2.3/32",
      "172.16.3.2/32"
    ]
    use_default_nsg_rules = null
    route_table_id        = null
    freeform_tags         = null
    defined_tags          = null
  }

  dns_forwarder_1 = {
    ad             = null
    fd             = null
    private_ip     = "192.168.0.2"
    name           = null
    hostname_label = null
    kms_key_id     = null
  }
  dns_forwarder_2 = {
    ad             = null
    fd             = null
    private_ip     = "192.168.0.3"
    name           = null
    hostname_label = null
    kms_key_id     = null
  }

  dns_namespace_mappings = [
    {
      namespace = "anothervcn.oraclevcn.com."
      server    = "10.1.2.3"
    },
    {
      namespace = "onprem.local."
      server    = "172.16.3.2"
    }
  ]
  reverse_dns_mappings = [
    {
      cidr   = "10.0.0.0/16"
      server = "10.1.2.3"
    },
    {
      cidr   = "172.16.0.0/12"
      server = "172.16.3.2"
    }
  ]

}

