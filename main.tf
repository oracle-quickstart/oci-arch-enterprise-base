# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


locals {
  dhcp_option_types = {
    "vcn"    = "VcnLocalPlusInternet"
    "custom" = "CustomDnsServer"
  }

  vcn_options = {
    display_name   = var.vcn_name != null ? var.vcn_name : "ent_base"
    cidr           = var.vcn_cidr != null ? var.vcn_cidr : "192.168.0.0/20"
    enable_dns     = var.vcn_options != null ? var.vcn_options.enable_dns : true
    dns_label      = var.vcn_dns_label != null ? var.vcn_dns_label : "entbase"
    compartment_id = var.vcn_options != null ? var.vcn_options.compartment_id : null
    defined_tags   = var.vcn_options != null ? var.vcn_options.defined_tags : {}
    freeform_tags  = var.vcn_options != null ? var.vcn_options.freeform_tags : {}
  }

  svcgw_options_defaults = {
    display_name   = null
    compartment_id = null
    defined_tags   = null
    freeform_tags  = null
    services = [
      module.oci_network.svcgw_services.0.id
    ]
  }

  internal_drg_routes = [for i in(var.internal_drg_routes != null && local.create_drg == true ? var.internal_drg_routes : []) :
    {
      dst         = i
      dst_type    = "CIDR_BLOCK"
      next_hop_id = module.oci_network.drg.drg.id
    }
  ]

  default_route_rules = {
    internal = concat(
      local.create_svcgw == true ? [
        {
          dst         = module.oci_network.svcgw_services.0.cidr_block
          dst_type    = "SERVICE_CIDR_BLOCK"
          next_hop_id = module.oci_network.svcgw.id
        }
      ] : [],
      local.create_natgw == true ? [
        {
          dst         = "0.0.0.0/0"
          dst_type    = "CIDR_BLOCK"
          next_hop_id = module.oci_network.natgw.id
        }
      ] : []
    ),
    internal_public = concat(
      local.create_svcgw == true ? [
        {
          dst         = module.oci_network.svcgw_services.0.cidr_block
          dst_type    = "SERVICE_CIDR_BLOCK"
          next_hop_id = module.oci_network.svcgw.id
        }
      ] : [],
      local.create_igw == true ? [
        {
          dst         = "0.0.0.0/0"
          dst_type    = "CIDR_BLOCK"
          next_hop_id = module.oci_network.igw.id
        }
      ] : []
    ),
    external = concat(
      local.create_natgw == true ? [
        {
          dst         = "0.0.0.0/0"
          dst_type    = "CIDR_BLOCK"
          next_hop_id = module.oci_network.igw.id
        }
      ] : []
    )
  }

  route_rules = {
    internal        = var.internal_rt_rule_overrides == null ? concat(local.default_route_rules.internal, local.internal_drg_routes) : var.internal_rt_rule_overrides
    internal_public = var.internal_public_rt_rule_overrides == null ? concat(local.default_route_rules.internal_public, local.internal_drg_routes) : var.internal_public_rt_rule_overrides
    external        = var.external_rt_rule_overrides == null ? local.default_route_rules.external : var.external_rt_rule_overrides
  }

  vcn_wide_sl_options_defaults = {
    # this is enabled by default, namely to allow access to repos (install needed software)... users may override this as-needed
    allow_http_egress  = true
    allow_https_egress = true
  }
  create_egress_http_vcn_wide_rules  = var.vcn_wide_sl_options != null ? (var.vcn_wide_sl_options.allow_http_egress != null ? var.vcn_wide_sl_options.allow_http_egress : local.vcn_wide_sl_options_defaults.allow_http_egress) : local.vcn_wide_sl_options_defaults.allow_http_egress
  create_egress_https_vcn_wide_rules = var.vcn_wide_sl_options != null ? (var.vcn_wide_sl_options.allow_https_egress != null ? var.vcn_wide_sl_options.allow_https_egress : local.vcn_wide_sl_options_defaults.allow_https_egress) : local.vcn_wide_sl_options_defaults.allow_https_egress

  default_vcn_sl_egress_rules = {
    http = local.create_egress_http_vcn_wide_rules ? [
      {
        stateless = false
        protocol  = "6"
        dst       = "0.0.0.0/0"
        dst_type  = "CIDR_BLOCK"
        src_port  = null
        dst_port = {
          min = 80
          max = 80
        }
        icmp_type = null
        icmp_code = null
      }
    ] : [],
    https = local.create_egress_https_vcn_wide_rules ? [
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
    ] : [],
    dns = var.create_dns == true ? [
      {
        stateless = false
        protocol  = "17"
        dst       = local.dns_subnet_cidr
        dst_type  = "CIDR_BLOCK"
        src_port  = null
        dst_port = {
          min = 53
          max = 53
        }
        icmp_type = null
        icmp_code = null
      }
    ] : [],
    icmp = concat([for i in(var.internal_drg_routes != null ? var.internal_drg_routes : []) :
      {
        stateless = true
        protocol  = "1"
        dst       = i
        dst_type  = "CIDR_BLOCK"
        src_port  = null
        dst_port  = null
        icmp_type = "3"
        icmp_code = "4"
      }
      ], [
      {
        stateless = true
        protocol  = "1"
        dst       = var.vcn_cidr
        dst_type  = "CIDR_BLOCK"
        src_port  = null
        dst_port  = null
        icmp_type = "3"
        icmp_code = "4"
      }
    ])
  }
  default_vcn_sl_ingress_rules = {
    bastion = var.create_bastion == true ? [
      {
        stateless = false
        protocol  = "6"
        src       = var.bastion_subnet_cidr # local.bastion_subnet_cidr
        src_type  = "CIDR_BLOCK"
        src_port  = null
        dst_port = {
          min = 22
          max = 22
        }
        icmp_type = null
        icmp_code = null
      }
    ] : [],
    icmp = concat([for i in(var.internal_drg_routes != null ? var.internal_drg_routes : []) :
      {
        stateless = true
        protocol  = "1"
        src       = i
        src_type  = "CIDR_BLOCK"
        src_port  = null
        dst_port  = null
        icmp_type = "3"
        icmp_code = "4"
      }
      ], [
      {
        stateless = true
        protocol  = "1"
        src       = var.vcn_cidr
        src_type  = "CIDR_BLOCK"
        src_port  = null
        dst_port  = null
        icmp_type = "3"
        icmp_code = "4"
      }
    ])
  }
  vcn_sl_ingress_rules = concat(local.default_vcn_sl_ingress_rules.bastion, local.default_vcn_sl_ingress_rules.icmp)
  vcn_sl_egress_rules  = concat(local.default_vcn_sl_egress_rules.dns, local.default_vcn_sl_egress_rules.icmp, local.default_vcn_sl_egress_rules.http, local.default_vcn_sl_egress_rules.https)
  vcn_wide_sl = var.create_vcn_wide_sl != true ? {} : {
    vcn = {
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      ingress_rules  = var.use_default_vcn_wide_rules == true ? concat(local.vcn_sl_ingress_rules, (var.additional_vcn_wide_rules != null ? var.additional_vcn_wide_rules.ingress_rules : [])) : (var.additional_vcn_wide_rules != null ? var.additional_vcn_wide_rules.ingress_rules : null)
      egress_rules   = var.use_default_vcn_wide_rules == true ? concat(local.vcn_sl_egress_rules, (var.additional_vcn_wide_rules != null ? var.additional_vcn_wide_rules.egress_rules : [])) : (var.additional_vcn_wide_rules != null ? var.additional_vcn_wide_rules.egress_rules : null)
    }
  }

  bastion_subnet_cidr = var.create_bastion == true ? (var.bastion_options != null ? (var.bastion_options.subnet_cidr != null ? var.bastion_options.subnet_cidr : local.bastion_options_defaults.subnet_cidr) : local.bastion_options_defaults.subnet_cidr) : local.bastion_options_defaults.subnet_cidr

  ansible_subnet_cidr = var.create_ansible == true ? (var.ansible_options != null ? (var.ansible_options.subnet_cidr != null ? var.ansible_options.subnet_cidr : local.ansible_options_defaults.subnet_cidr) : local.ansible_options_defaults.subnet_cidr) : local.ansible_options_defaults.subnet_cidr

  dns_subnet_cidr    = var.create_dns == true ? (var.dns_options != null ? (var.dns_options.subnet_cidr != null ? var.dns_options.subnet_cidr : local.dns_options_defaults.subnet_cidr) : local.dns_options_defaults.subnet_cidr) : local.dns_options_defaults.subnet_cidr
  num_dns_forwarders = var.create_dns == true ? (var.dns_forwarder_1 != null && var.dns_forwarder_2 != null && var.dns_forwarder_3 != null ? 3 : (var.dns_forwarder_1 != null && var.dns_forwarder_2 != null ? 2 : (var.dns_forwarder_1 != null ? 1 : 0))) : var.existing_dns_forwarder_ips != null ? length(var.existing_dns_forwarder_ips) : 0
  dns_forwarder_ips  = var.create_dns == true ? (var.dns_forwarder_1 != null && var.dns_forwarder_2 != null && var.dns_forwarder_3 != null) ? [var.dns_forwarder_1.private_ip, var.dns_forwarder_2.private_ip, var.dns_forwarder_3.private_ip] : ((local.num_dns_forwarders > 1 && var.dns_forwarder_1 != null && var.dns_forwarder_2 != null) ? [var.dns_forwarder_1.private_ip, var.dns_forwarder_2.private_ip] : ((local.num_dns_forwarders > 2 && var.dns_forwarder_1 != null) ? [var.dns_forwarder_1.private_ip] : null)) : (var.existing_dns_forwarder_ips != null ? (length(var.existing_dns_forwarder_ips) > 0 ? var.existing_dns_forwarder_ips : null) : null)
  dns_forwarder_ip_1 = local.dns_forwarder_ips != null ? (length(local.dns_forwarder_ips) > 0 ? local.dns_forwarder_ips[0] : null) : null
  dns_forwarder_ip_2 = local.dns_forwarder_ips != null ? (length(local.dns_forwarder_ips) > 1 ? local.dns_forwarder_ips[1] : null) : null
  dns_forwarder_ip_3 = local.dns_forwarder_ips != null ? (length(local.dns_forwarder_ips) > 2 ? local.dns_forwarder_ips[2] : null) : null

  rt_external_id        = module.oci_network != null ? (module.oci_network.route_tables != null && length(module.oci_network.route_tables) > 0 ? (module.oci_network.route_tables.external != null ? module.oci_network.route_tables.external.id : null) : null) : null
  rt_internal_id        = module.oci_network != null ? (module.oci_network.route_tables != null && length(module.oci_network.route_tables) > 0 ? (module.oci_network.route_tables.internal != null ? module.oci_network.route_tables.internal.id : null) : null) : null
  rt_internal_public_id = module.oci_network != null ? (module.oci_network.route_tables != null && length(module.oci_network.route_tables) > 0 ? (module.oci_network.route_tables.internal_public != null ? module.oci_network.route_tables.internal_public.id : null) : null) : null

  create_igw   = var.create_igw != null ? var.create_igw : true
  create_svcgw = var.create_svcgw != null ? var.create_svcgw : true
  create_natgw = var.create_natgw != null ? var.create_natgw : true
  create_drg   = var.create_drg != null ? var.create_drg : true
}

module "oci_network" {
  source                = "github.com/oracle/terraform-oci-tdf-network.git?ref=v0.9.7"

  default_compartment_id = var.default_compartment_id
  default_defined_tags   = var.default_defined_tags
  default_freeform_tags  = var.default_freeform_tags

  vcn_options = local.vcn_options

  drg_options   = var.drg_options != null ? var.drg_options : null
  natgw_options = var.natgw_options != null ? var.natgw_options : null
  igw_options   = var.igw_options != null ? var.igw_options : null
  svcgw_options = var.svcgw_options != null ? merge(local.svcgw_options_defaults, var.svcgw_options) : local.svcgw_options_defaults

  create_igw   = local.create_igw
  create_svcgw = local.create_svcgw
  create_natgw = local.create_natgw
  create_drg   = local.create_drg

  route_tables = {
    internal = {
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      route_rules    = local.route_rules.internal
    },
    internal_public = {
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      route_rules    = local.route_rules.internal_public
    },
    external = {
      compartment_id = null
      defined_tags   = null
      freeform_tags  = null
      route_rules    = local.route_rules.external
    }
  }

  dhcp_options = {
    dns_forwarders = {
      compartment_id     = null
      server_type        = local.dhcp_option_types["vcn"]
      forwarder_1_ip     = null
      forwarder_2_ip     = null
      forwarder_3_ip     = null
      search_domain_name = module.oci_network.vcn.vcn_domain_name
    }
    internal = {
      compartment_id     = null
      server_type        = local.dns_forwarder_ips != null ? local.dhcp_option_types["custom"] : local.dhcp_option_types["vcn"]
      forwarder_1_ip     = local.dns_forwarder_ip_1
      forwarder_2_ip     = local.dns_forwarder_ip_2
      forwarder_3_ip     = local.dns_forwarder_ip_3
      search_domain_name = module.oci_network.vcn.vcn_domain_name
    }
  }
}

# this manages provisioning the VCN-wide Security List (if desired)
module "oci_network_security_policies" {
  source                = "github.com/oracle/terraform-oci-tdf-network-security.git?ref=v0.9.7"

  default_compartment_id = var.default_compartment_id
  default_defined_tags   = var.default_defined_tags
  default_freeform_tags  = var.default_freeform_tags
  vcn_id                 = module.oci_network.vcn.id

  security_lists = var.create_vcn_wide_sl == true ? local.vcn_wide_sl : {}
}

# this is for clearing the default Security List
resource "oci_core_default_security_list" "this" {
  count = var.empty_default_security_list == true ? 1 : 0

  manage_default_resource_id = module.oci_network.vcn.default_security_list_id
}

locals {
  bastion_options_defaults = {
    subnet_compartment_id   = var.default_compartment_id
    subnet_name             = "bastion"
    subnet_dns_label        = "bastion"
    subnet_cidr             = "192.168.0.8/29"
    instance_compartment_id = var.default_compartment_id
    instance_ad             = 0
    instance_name           = "bastion"
    instance_dns_label      = "bastion"
    instance_shape          = "VM.Standard2.1"
    ssh_auth_keys           = var.bastion_options != null ? (var.bastion_options.ssh_auth_keys != null ? var.bastion_options.ssh_auth_keys : var.default_ssh_auth_keys) : var.default_ssh_auth_keys
    ssh_src_cidrs           = []
    image_name              = var.default_img_name
    image_id                = var.default_img_id
    allow_int_routes        = true
    private_ip              = null
    public_ip               = false
    use_default_nsg_rules   = true
    # route_table_id      = contains( keys( ( module.oci_network != null ? module.oci_network.route_tables : [] ) ), "external" ) == true ? module.oci_network.route_tables.external.id : null
    freeform_tags = var.default_freeform_tags
    defined_tags  = var.default_defined_tags
  }
}

module "bastion" {
  source                = "github.com/oracle-quickstart/oci-arch-bastion.git?ref=v0.1.6"

  default_compartment_id = var.default_compartment_id

  vcn_cidr = module.oci_network.vcn.cidr_block
  vcn_id   = module.oci_network.vcn.id

  create_compute = var.create_bastion
  create_nsg     = var.create_bastion
  create_subnet  = var.create_bastion

  ssh_src_cidrs = var.bastion_options != null ? (var.bastion_options.ssh_src_cidrs != null ? var.bastion_options.ssh_src_cidrs : local.bastion_options_defaults.ssh_src_cidrs) : local.bastion_options_defaults.ssh_src_cidrs
  ssh_dst_cidrs = var.bastion_options != null ? (var.bastion_options.use_default_nsg_rules == true ? [
    module.oci_network.vcn.cidr_block
  ] : []) : (local.bastion_options_defaults.use_default_nsg_rules == true ? [module.oci_network.vcn.cidr_block] : [])

  compute_options = {
    compartment_id     = var.bastion_options != null ? (var.bastion_options.instance_compartment_id != null ? var.bastion_options.instance_compartment_id : local.bastion_options_defaults.instance_compartment_id) : local.bastion_options_defaults.instance_compartment_id
    ad                 = var.bastion_options != null ? (var.bastion_options.instance_ad != null ? var.bastion_options.instance_ad : local.bastion_options_defaults.instance_ad) : local.bastion_options_defaults.instance_ad
    fd                 = null
    shape              = var.bastion_options != null ? (var.bastion_options.instance_shape != null ? var.bastion_options.instance_shape : local.bastion_options_defaults.instance_shape) : local.bastion_options_defaults.instance_shape
    public_ip          = var.bastion_options != null ? (var.bastion_options.public_ip != null ? var.bastion_options.public_ip : local.bastion_options_defaults.public_ip) : local.bastion_options_defaults.public_ip
    private_ip         = var.bastion_options != null ? (var.bastion_options.private_ip != null ? var.bastion_options.private_ip : local.bastion_options_defaults.private_ip) : local.bastion_options_defaults.private_ip
    defined_tags       = var.bastion_options != null ? (var.bastion_options.defined_tags != null ? var.bastion_options.defined_tags : local.bastion_options_defaults.defined_tags) : local.bastion_options_defaults.defined_tags
    freeform_tags      = var.bastion_options != null ? (var.bastion_options.freeform_tags != null ? var.bastion_options.freeform_tags : local.bastion_options_defaults.freeform_tags) : local.bastion_options_defaults.freeform_tags
    vnic_defined_tags  = var.bastion_options != null ? (var.bastion_options.defined_tags != null ? var.bastion_options.defined_tags : local.bastion_options_defaults.defined_tags) : local.bastion_options_defaults.defined_tags
    vnic_freeform_tags = var.bastion_options != null ? (var.bastion_options.freeform_tags != null ? var.bastion_options.freeform_tags : local.bastion_options_defaults.freeform_tags) : local.bastion_options_defaults.freeform_tags
    name               = var.bastion_options != null ? (var.bastion_options.instance_name != null ? var.bastion_options.instance_name : local.bastion_options_defaults.instance_name) : local.bastion_options_defaults.instance_name
    hostname_label     = var.bastion_options != null ? (var.bastion_options.instance_dns_label != null ? var.bastion_options.instance_dns_label : local.bastion_options_defaults.instance_dns_label) : local.bastion_options_defaults.instance_dns_label
    ssh_auth_keys      = var.bastion_options != null ? (var.bastion_options.ssh_auth_keys != null ? var.bastion_options.ssh_auth_keys : local.bastion_options_defaults.ssh_auth_keys) : local.bastion_options_defaults.ssh_auth_keys
    user_data          = null
    boot_vol_img_name  = var.bastion_options != null ? (var.bastion_options.image_name != null ? var.bastion_options.image_name : local.bastion_options_defaults.image_name) : local.bastion_options_defaults.image_name
    boot_vol_img_id    = var.bastion_options != null ? (var.bastion_options.image_id != null ? var.bastion_options.image_id : local.bastion_options_defaults.image_id) : local.bastion_options_defaults.image_id
    boot_vol_size      = null
    kms_key_id         = null
  }

  subnet_options = {
    name            = var.bastion_options != null ? (var.bastion_options.subnet_name != null ? var.bastion_options.subnet_name : local.bastion_options_defaults.subnet_name) : local.bastion_options_defaults.subnet_name
    compartment_id  = var.bastion_options != null ? (var.bastion_options.subnet_compartment_id != null ? var.bastion_options.subnet_compartment_id : local.bastion_options_defaults.subnet_compartment_id) : local.bastion_options_defaults.subnet_compartment_id
    defined_tags    = var.bastion_options != null ? (var.bastion_options.defined_tags != null ? var.bastion_options.defined_tags : local.bastion_options_defaults.defined_tags) : local.bastion_options_defaults.defined_tags
    freeform_tags   = var.bastion_options != null ? (var.bastion_options.freeform_tags != null ? var.bastion_options.freeform_tags : local.bastion_options_defaults.freeform_tags) : local.bastion_options_defaults.freeform_tags
    dynamic_cidr    = false
    cidr            = local.bastion_subnet_cidr
    cidr_len        = null
    cidr_num        = null
    enable_dns      = true
    dns_label       = var.bastion_options != null ? (var.bastion_options.subnet_dns_label != null ? var.bastion_options.subnet_dns_label : local.bastion_options_defaults.subnet_dns_label) : local.bastion_options_defaults.subnet_dns_label
    private         = var.bastion_options != null ? (var.bastion_options.public_ip != null ? ! var.bastion_options.public_ip : ! local.bastion_options_defaults.public_ip) : ! local.bastion_options_defaults.public_ip
    ad              = null
    dhcp_options_id = module.oci_network != null ? (module.oci_network.dhcp_options != null && length(module.oci_network.dhcp_options) > 0 ? (module.oci_network.dhcp_options.internal != null ? module.oci_network.dhcp_options.internal.id : null) : null) : null
    /* logic for selecting the route_table_id... here's what the following one-line does (broken out into separate lines so it can be readable):
route_table_id = var.bastion_options != null ? (
  var.bastion_options.route_table_id != null ? 
    var.bastion_options.route_table_id 
  : ( 
    var.bastion_options.public_ip != null && var.bastion_options.allow_int_routes != null ?
      var.bastion_options.public_ip == true && var.bastion_options.allow_int_routes == true ?
        local.rt_internal_public_id
      : (
        var.bastion_options.public_ip == true && var.bastion_options.allow_int_routes == false ?
          local.rt_external_id
        :
          local.rt_internal_id
      )
    : (
      local.bastion_options_defaults.public_ip == true && local.bastion_options_defaults.allow_int_routes == true ?
        local.rt_internal_public_id
      : (
        local.bastion_options_defaults.public_ip == true && local.bastion_options_defaults.allow_int_routes == false ?
          local.rt_external_id
        :
          local.rt_internal_id
      )
    )
  )  
) : (
  local.bastion_options_defaults.public_ip == true && local.bastion_options_defaults.allow_int_routes == true ?
    local.rt_internal_public_id
  : (
    local.bastion_options_defaults.public_ip == true && local.bastion_options_defaults.allow_int_routes == false ?
      local.rt_external_id
    :
      local.rt_internal_id
  )
)
    */
    route_table_id    = var.bastion_options != null ? (var.bastion_options.route_table_id != null ? var.bastion_options.route_table_id : (var.bastion_options.public_ip != null && var.bastion_options.allow_int_routes != null ? var.bastion_options.public_ip == true && var.bastion_options.allow_int_routes == true ? local.rt_internal_public_id : (var.bastion_options.public_ip == true && var.bastion_options.allow_int_routes == false ? local.rt_external_id : local.rt_internal_id) : (local.bastion_options_defaults.public_ip == true && local.bastion_options_defaults.allow_int_routes == true ? local.rt_internal_public_id : (local.bastion_options_defaults.public_ip == true && local.bastion_options_defaults.allow_int_routes == false ? local.rt_external_id : local.rt_internal_id)))) : (local.bastion_options_defaults.public_ip == true && local.bastion_options_defaults.allow_int_routes == true ? local.rt_internal_public_id : (local.bastion_options_defaults.public_ip == true && local.bastion_options_defaults.allow_int_routes == false ? local.rt_external_id : local.rt_internal_id))
    security_list_ids = var.create_vcn_wide_sl == true ? (module.oci_network_security_policies != null ? (module.oci_network_security_policies.security_lists != null && length(module.oci_network_security_policies.security_lists) > 0 ? (module.oci_network_security_policies.security_lists.vcn != null ? [module.oci_network_security_policies.security_lists.vcn.id] : null) : null) : null) : null
  }
}

locals {
  dns_options_defaults = {
    subnet_compartment_id   = var.default_compartment_id
    subnet_name             = "dns"
    subnet_dns_label        = "dns"
    subnet_cidr             = "192.168.0.0/29"
    instance_compartment_id = var.default_compartment_id
    instance_ad             = 0
    instance_name           = "dns"
    instance_dns_label      = "dns"
    instance_shape          = "VM.Standard2.1"
    ssh_auth_keys           = var.dns_options != null ? (var.dns_options.ssh_auth_keys != null ? var.dns_options.ssh_auth_keys : var.default_ssh_auth_keys) : var.default_ssh_auth_keys
    dns_src_cidrs           = var.allow_vcn_cidr_ingress_dns_forwarders == true ? [var.vcn_cidr] : []
    dns_dst_cidrs           = []
    image_name              = var.default_img_name
    image_id                = var.default_img_id
    allow_int_routes        = true
    private_ip              = null
    public_ip               = false
    use_default_nsg_rules   = true
    freeform_tags = var.default_freeform_tags
    defined_tags  = var.default_defined_tags
  }
}


module "dns" {
  source                = "github.com/oracle-quickstart/oci-arch-hybrid-dns.git?ref=v0.0.8"

  default_compartment_id = var.default_compartment_id
  default_defined_tags   = var.default_defined_tags
  default_freeform_tags  = var.default_freeform_tags
  default_img_id         = var.default_img_id
  default_img_name       = var.default_img_name

  vcn_cidr = module.oci_network.vcn.cidr_block
  vcn_id   = module.oci_network.vcn.id

  create_compute = var.create_dns
  create_nsg     = var.create_dns
  create_subnet  = var.create_dns

  num_dns_forwarders = local.num_dns_forwarders

  dns_src_cidrs = var.dns_options != null ? (var.dns_options.dns_src_cidrs != null ? (var.allow_vcn_cidr_ingress_dns_forwarders == true ? concat([var.vcn_cidr], var.dns_options.dns_src_cidrs) : var.dns_options.dns_src_cidrs) : local.dns_options_defaults.dns_src_cidrs) : local.dns_options_defaults.dns_src_cidrs
  dns_dst_cidrs = var.dns_options != null ? (var.dns_options.dns_dst_cidrs != null ? var.dns_options.dns_dst_cidrs : local.dns_options_defaults.dns_dst_cidrs) : local.dns_options_defaults.dns_dst_cidrs

  compute_options = {
    compartment_id     = var.dns_options != null ? (var.dns_options.instance_compartment_id != null ? var.dns_options.instance_compartment_id : local.dns_options_defaults.instance_compartment_id) : local.dns_options_defaults.instance_compartment_id
    defined_tags       = var.dns_options != null ? (var.dns_options.defined_tags != null ? var.dns_options.defined_tags : local.dns_options_defaults.defined_tags) : local.dns_options_defaults.defined_tags
    freeform_tags      = var.dns_options != null ? (var.dns_options.freeform_tags != null ? var.dns_options.freeform_tags : local.dns_options_defaults.freeform_tags) : local.dns_options_defaults.freeform_tags
    shape              = var.dns_options != null ? (var.dns_options.instance_shape != null ? var.dns_options.instance_shape : local.dns_options_defaults.instance_shape) : local.dns_options_defaults.instance_shape
    ssh_auth_keys      = var.dns_options != null ? (var.dns_options.ssh_auth_keys != null ? var.dns_options.ssh_auth_keys : local.dns_options_defaults.ssh_auth_keys) : local.dns_options_defaults.ssh_auth_keys
    user_data          = null
    boot_vol_img_name  = var.dns_options != null ? (var.dns_options.image_name != null ? var.dns_options.image_name : local.dns_options_defaults.image_name) : local.dns_options_defaults.image_name
    boot_vol_img_id    = var.dns_options != null ? (var.dns_options.image_id != null ? var.dns_options.image_id : local.dns_options_defaults.image_id) : local.dns_options_defaults.image_id
    boot_vol_size      = null
    vnic_defined_tags  = var.dns_options != null ? (var.dns_options.defined_tags != null ? var.dns_options.defined_tags : local.dns_options_defaults.defined_tags) : local.dns_options_defaults.defined_tags
    vnic_freeform_tags = var.dns_options != null ? (var.dns_options.freeform_tags != null ? var.dns_options.freeform_tags : local.dns_options_defaults.freeform_tags) : local.dns_options_defaults.freeform_tags
    public_ip          = var.dns_options != null ? (var.dns_options.public_ip != null ? var.dns_options.public_ip : local.dns_options_defaults.public_ip) : local.dns_options_defaults.public_ip
  }

  dns_namespace_mappings = var.dns_namespace_mappings
  reverse_dns_mappings   = var.reverse_dns_mappings

  dns_forwarder_1 = var.dns_forwarder_1
  dns_forwarder_2 = var.dns_forwarder_2
  dns_forwarder_3 = var.dns_forwarder_3
  
  subnet_options = {
    name            = var.dns_options != null ? (var.dns_options.subnet_name != null ? var.dns_options.subnet_name : local.dns_options_defaults.subnet_name) : local.dns_options_defaults.subnet_name
    compartment_id  = var.dns_options != null ? (var.dns_options.subnet_compartment_id != null ? var.dns_options.subnet_compartment_id : local.dns_options_defaults.subnet_compartment_id) : local.dns_options_defaults.subnet_compartment_id
    defined_tags    = var.dns_options != null ? (var.dns_options.defined_tags != null ? var.dns_options.defined_tags : local.dns_options_defaults.defined_tags) : local.dns_options_defaults.defined_tags
    freeform_tags   = var.dns_options != null ? (var.dns_options.freeform_tags != null ? var.dns_options.freeform_tags : local.dns_options_defaults.freeform_tags) : local.dns_options_defaults.freeform_tags
    dynamic_cidr    = false
    cidr            = local.dns_subnet_cidr
    cidr_len        = null
    cidr_num        = null
    enable_dns      = true
    dns_label       = var.dns_options != null ? (var.dns_options.subnet_dns_label != null ? var.dns_options.subnet_dns_label : local.dns_options_defaults.subnet_dns_label) : local.dns_options_defaults.subnet_dns_label
    private         = var.dns_options != null ? (var.dns_options.public_ip != null ? ! var.dns_options.public_ip : ! local.dns_options_defaults.public_ip) : ! local.dns_options_defaults.public_ip
    ad              = null
    dhcp_options_id = module.oci_network != null ? (module.oci_network.dhcp_options != null && length(module.oci_network.dhcp_options) > 0 ? (module.oci_network.dhcp_options.dns_forwarders != null ? module.oci_network.dhcp_options.dns_forwarders.id : null) : null) : null

    # this is the same logic as used above for the bastion...
    route_table_id    = var.dns_options != null ? (var.dns_options.route_table_id != null ? var.dns_options.route_table_id : (var.dns_options.public_ip != null && var.dns_options.allow_int_routes != null ? var.dns_options.public_ip == true && var.dns_options.allow_int_routes == true ? local.rt_internal_public_id : (var.dns_options.public_ip == true && var.dns_options.allow_int_routes == false ? local.rt_external_id : local.rt_internal_id) : (local.dns_options_defaults.public_ip == true && local.dns_options_defaults.allow_int_routes == true ? local.rt_internal_public_id : (local.dns_options_defaults.public_ip == true && local.dns_options_defaults.allow_int_routes == false ? local.rt_external_id : local.rt_internal_id)))) : (local.dns_options_defaults.public_ip == true && local.dns_options_defaults.allow_int_routes == true ? local.rt_internal_public_id : (local.dns_options_defaults.public_ip == true && local.dns_options_defaults.allow_int_routes == false ? local.rt_external_id : local.rt_internal_id))
    security_list_ids = var.create_vcn_wide_sl == true ? (module.oci_network_security_policies != null ? (module.oci_network_security_policies.security_lists != null && length(module.oci_network_security_policies.security_lists) > 0 ? (module.oci_network_security_policies.security_lists.vcn != null ? [module.oci_network_security_policies.security_lists.vcn.id] : null) : null) : null) : null
  }
}

locals {
  ansible_options_defaults = {
    subnet_compartment_id   = var.default_compartment_id
    subnet_name             = "ansible"
    subnet_dns_label        = "ansible"
    subnet_cidr             = "192.168.0.252/30"
    instance_compartment_id = var.default_compartment_id
    instance_ad             = 0
    instance_name           = "ansible"
    instance_dns_label      = "ansible"
    instance_shape          = "VM.Standard2.1"
    ssh_auth_keys           = var.ansible_options != null ? (var.ansible_options.ssh_auth_keys != null ? var.ansible_options.ssh_auth_keys : var.default_ssh_auth_keys) : var.default_ssh_auth_keys
    ssh_src_cidrs           = []
    image_name              = var.default_img_name
    image_id                = var.default_img_id
    allow_int_routes        = true
    private_ip              = null
    public_ip               = false
    use_default_nsg_rules   = true
    freeform_tags           = var.default_freeform_tags
    defined_tags            = var.default_defined_tags
  }
}

module "ansible" {
  source                = "github.com/oracle-quickstart/oci-arch-enterprise-base.git?ref=v0.0.4//modules/oci-arch-configuration-management-machine"

  default_compartment_id = var.default_compartment_id

  vcn_cidr = module.oci_network.vcn.cidr_block
  vcn_id   = module.oci_network.vcn.id

  create_compute = var.create_ansible
  create_nsg     = var.create_ansible
  create_subnet  = var.create_ansible

  ssh_src_cidrs = var.ansible_options != null ? (var.ansible_options.ssh_src_cidrs != null ? var.ansible_options.ssh_src_cidrs : local.ansible_options_defaults.ssh_src_cidrs) : local.ansible_options_defaults.ssh_src_cidrs
  ssh_dst_cidrs = var.ansible_options != null ? (var.ansible_options.use_default_nsg_rules == true ? [
    module.oci_network.vcn.cidr_block
  ] : []) : (local.ansible_options_defaults.use_default_nsg_rules == true ? [module.oci_network.vcn.cidr_block] : [])

  compute_options = {
    compartment_id     = var.ansible_options != null ? (var.ansible_options.instance_compartment_id != null ? var.ansible_options.instance_compartment_id : local.ansible_options_defaults.instance_compartment_id) : local.ansible_options_defaults.instance_compartment_id
    ad                 = var.ansible_options != null ? (var.ansible_options.instance_ad != null ? var.ansible_options.instance_ad : local.ansible_options_defaults.instance_ad) : local.ansible_options_defaults.instance_ad
    fd                 = null
    shape              = var.ansible_options != null ? (var.ansible_options.instance_shape != null ? var.ansible_options.instance_shape : local.ansible_options_defaults.instance_shape) : local.ansible_options_defaults.instance_shape
    public_ip          = var.ansible_options != null ? (var.ansible_options.public_ip != null ? var.ansible_options.public_ip : local.ansible_options_defaults.public_ip) : local.ansible_options_defaults.public_ip
    private_ip         = var.ansible_options != null ? (var.ansible_options.private_ip != null ? var.ansible_options.private_ip : local.ansible_options_defaults.private_ip) : local.ansible_options_defaults.private_ip
    defined_tags       = var.ansible_options != null ? (var.ansible_options.defined_tags != null ? var.ansible_options.defined_tags : local.ansible_options_defaults.defined_tags) : local.ansible_options_defaults.defined_tags
    freeform_tags      = var.ansible_options != null ? (var.ansible_options.freeform_tags != null ? var.ansible_options.freeform_tags : local.ansible_options_defaults.freeform_tags) : local.ansible_options_defaults.freeform_tags
    vnic_defined_tags  = var.ansible_options != null ? (var.ansible_options.defined_tags != null ? var.ansible_options.defined_tags : local.ansible_options_defaults.defined_tags) : local.ansible_options_defaults.defined_tags
    vnic_freeform_tags = var.ansible_options != null ? (var.ansible_options.freeform_tags != null ? var.ansible_options.freeform_tags : local.ansible_options_defaults.freeform_tags) : local.ansible_options_defaults.freeform_tags
    name               = var.ansible_options != null ? (var.ansible_options.instance_name != null ? var.ansible_options.instance_name : local.ansible_options_defaults.instance_name) : local.ansible_options_defaults.instance_name
    hostname_label     = var.ansible_options != null ? (var.ansible_options.instance_dns_label != null ? var.ansible_options.instance_dns_label : local.ansible_options_defaults.instance_dns_label) : local.ansible_options_defaults.instance_dns_label
    ssh_auth_keys      = var.ansible_options != null ? (var.ansible_options.ssh_auth_keys != null ? var.ansible_options.ssh_auth_keys : local.ansible_options_defaults.ssh_auth_keys) : local.ansible_options_defaults.ssh_auth_keys
    user_data          = null
    boot_vol_img_name  = var.ansible_options != null ? (var.ansible_options.image_name != null ? var.ansible_options.image_name : local.ansible_options_defaults.image_name) : local.ansible_options_defaults.image_name
    boot_vol_img_id    = var.ansible_options != null ? (var.ansible_options.image_id != null ? var.ansible_options.image_id : local.ansible_options_defaults.image_id) : local.ansible_options_defaults.image_id
    boot_vol_size      = null
    kms_key_id         = null
  }

  subnet_options = {
    name            = var.ansible_options != null ? (var.ansible_options.subnet_name != null ? var.ansible_options.subnet_name : local.ansible_options_defaults.subnet_name) : local.ansible_options_defaults.subnet_name
    compartment_id  = var.ansible_options != null ? (var.ansible_options.subnet_compartment_id != null ? var.ansible_options.subnet_compartment_id : local.ansible_options_defaults.subnet_compartment_id) : local.ansible_options_defaults.subnet_compartment_id
    defined_tags    = var.ansible_options != null ? (var.ansible_options.defined_tags != null ? var.ansible_options.defined_tags : local.ansible_options_defaults.defined_tags) : local.ansible_options_defaults.defined_tags
    freeform_tags   = var.ansible_options != null ? (var.ansible_options.freeform_tags != null ? var.ansible_options.freeform_tags : local.ansible_options_defaults.freeform_tags) : local.ansible_options_defaults.freeform_tags
    dynamic_cidr    = false
    cidr            = local.ansible_subnet_cidr
    cidr_len        = null
    cidr_num        = null
    enable_dns      = true
    dns_label       = var.ansible_options != null ? (var.ansible_options.subnet_dns_label != null ? var.ansible_options.subnet_dns_label : local.ansible_options_defaults.subnet_dns_label) : local.ansible_options_defaults.subnet_dns_label
    private         = var.ansible_options != null ? (var.ansible_options.public_ip != null ? ! var.ansible_options.public_ip : ! local.ansible_options_defaults.public_ip) : ! local.ansible_options_defaults.public_ip
    ad              = null
    dhcp_options_id = module.oci_network != null ? (module.oci_network.dhcp_options != null && length(module.oci_network.dhcp_options) > 0 ? (module.oci_network.dhcp_options.internal != null ? module.oci_network.dhcp_options.internal.id : null) : null) : null
    # same logic as that for the ansible RT selection
    route_table_id    = var.ansible_options != null ? (var.ansible_options.route_table_id != null ? var.ansible_options.route_table_id : (var.ansible_options.public_ip != null && var.ansible_options.allow_int_routes != null ? var.ansible_options.public_ip == true && var.ansible_options.allow_int_routes == true ? local.rt_internal_public_id : (var.ansible_options.public_ip == true && var.ansible_options.allow_int_routes == false ? local.rt_external_id : local.rt_internal_id) : (local.ansible_options_defaults.public_ip == true && local.ansible_options_defaults.allow_int_routes == true ? local.rt_internal_public_id : (local.ansible_options_defaults.public_ip == true && local.ansible_options_defaults.allow_int_routes == false ? local.rt_external_id : local.rt_internal_id)))) : (local.ansible_options_defaults.public_ip == true && local.ansible_options_defaults.allow_int_routes == true ? local.rt_internal_public_id : (local.ansible_options_defaults.public_ip == true && local.ansible_options_defaults.allow_int_routes == false ? local.rt_external_id : local.rt_internal_id))
    security_list_ids = var.create_vcn_wide_sl == true ? (module.oci_network_security_policies != null ? (module.oci_network_security_policies.security_lists != null && length(module.oci_network_security_policies.security_lists) > 0 ? (module.oci_network_security_policies.security_lists.vcn != null ? [module.oci_network_security_policies.security_lists.vcn.id] : null) : null) : null) : null
  }
}
