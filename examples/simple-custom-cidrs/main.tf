# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



module "ent_base" {
  source                = "../../"
  
  default_compartment_id = var.default_compartment_id
  default_ssh_auth_keys  = var.default_ssh_auth_keys
  default_img_name       = var.default_img_name

  create_drg = false

  vcn_cidr      = "10.0.0.0/20"
  vcn_dns_label = "entbasetest"
  vcn_name      = "ent_base test"

  bastion_options = {
    subnet_compartment_id   = null
    subnet_name             = "jumpbox"
    subnet_dns_label        = "jumpbox"
    subnet_cidr             = "10.0.0.0/24"
    instance_compartment_id = null
    instance_ad             = 0
    instance_name           = "jumpbox1"
    instance_dns_label      = "jumpbox1"
    instance_shape          = "VM.Standard2.1"
    ssh_auth_keys           = null
    ssh_src_cidrs           = ["0.0.0.0/0"]
    image_name              = null
    image_id                = null
    allow_int_routes        = true
    private_ip              = "10.0.0.7"
    public_ip               = true
    use_default_nsg_rules   = true
    route_table_id          = null
    freeform_tags           = null
    defined_tags            = null
  }

  ansible_options = {
    subnet_compartment_id   = null
    subnet_name             = "cfg"
    subnet_dns_label        = "cfg"
    subnet_cidr             = "10.0.1.0/24"
    instance_compartment_id = null
    instance_ad             = 0
    instance_name           = "cfgmgmt"
    instance_dns_label      = "cfgmgmt"
    instance_shape          = null
    ssh_auth_keys           = null
    ssh_src_cidrs           = ["10.0.0.7/32"]
    image_name              = null
    image_id                = null
    allow_int_routes        = null
    private_ip              = "10.0.1.5"
    public_ip               = false
    use_default_nsg_rules   = true
    route_table_id          = null
    freeform_tags           = null
    defined_tags            = null
  }

  dns_options = {
    subnet_compartment_id   = null
    subnet_name             = "dnsforward"
    subnet_dns_label        = "dnsforward"
    subnet_cidr             = "10.0.2.0/29"
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
    use_default_nsg_rules = true
    route_table_id        = null
    freeform_tags         = null
    defined_tags          = null
  }

  dns_forwarder_1 = {
    ad             = null
    fd             = null
    private_ip     = "10.0.2.2"
    name           = null
    hostname_label = null
    kms_key_id     = null
  }
  dns_forwarder_2 = {
    ad             = null
    fd             = null
    private_ip     = "10.0.2.3"
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
