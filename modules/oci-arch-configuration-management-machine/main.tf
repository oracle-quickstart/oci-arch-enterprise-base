# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



locals {
  # subnet-specific stuff
  subnet_name = var.subnet_options != null ? (var.subnet_options.name != null ? var.subnet_options.name : "ansible") : "ansible"
  # subnet_id             = var.create_subnet == true ? ( module.oci_subnets.subnets != null && length(module.oci_subnets.subnets) > 0 ? module.oci_subnets.subnets[local.subnet_name].id : var.existing_subnet_id ) : var.existing_subnet_id
  subnet_id = var.create_subnet == true ? oci_core_subnet.this[0].id : var.existing_subnet_id
  subnet_options_defaults = {
    compartment_id    = var.default_compartment_id
    defined_tags      = var.default_defined_tags
    freeform_tags     = var.default_freeform_tags
    dynamic_cidr      = false
    cidr              = "192.168.0.252/30"
    cidr_len          = null
    cidr_num          = null
    enable_dns        = true
    dns_label         = "ansible"
    private           = false
    ad                = null
    dhcp_options_id   = null
    route_table_id    = null
    security_list_ids = null
  }

  vcn_id   = var.vcn_id   # var.network_module != null ? var.network_module.vcn.id : var.vcn_id
  vcn_cidr = var.vcn_cidr # var.network_module != null ? var.network_module.vcn.cidr_block : var.vcn_cidr
}

resource "oci_core_subnet" "this" {
  count = var.create_subnet == true ? 1 : 0

  vcn_id                     = local.vcn_id
  cidr_block                 = var.subnet_options != null ? (var.subnet_options.cidr != null ? var.subnet_options.cidr : local.subnet_options_defaults.cidr) : local.subnet_options_defaults.cidr
  compartment_id             = var.subnet_options != null ? (var.subnet_options.compartment_id != null ? var.subnet_options.compartment_id : local.subnet_options_defaults.compartment_id) : local.subnet_options_defaults.compartment_id
  defined_tags               = var.subnet_options != null ? (var.subnet_options.defined_tags != null ? var.subnet_options.defined_tags : local.subnet_options_defaults.defined_tags) : local.subnet_options_defaults.defined_tags
  freeform_tags              = var.subnet_options != null ? (var.subnet_options.freeform_tags != null ? var.subnet_options.freeform_tags : local.subnet_options_defaults.freeform_tags) : local.subnet_options_defaults.freeform_tags
  display_name               = local.subnet_name
  prohibit_public_ip_on_vnic = var.subnet_options != null ? (var.subnet_options.private != null ? var.subnet_options.private : local.subnet_options_defaults.private) : local.subnet_options_defaults.private
  dns_label                  = var.subnet_options != null ? (var.subnet_options.dns_label != null ? var.subnet_options.dns_label : local.subnet_options_defaults.dns_label) : local.subnet_options_defaults.dns_label
  availability_domain        = var.subnet_options != null ? (var.subnet_options.ad != null ? var.subnet_options.ad : local.subnet_options_defaults.ad) : local.subnet_options_defaults.ad
  dhcp_options_id            = var.subnet_options != null ? (var.subnet_options.dhcp_options_id != null ? var.subnet_options.dhcp_options_id : local.subnet_options_defaults.dhcp_options_id) : local.subnet_options_defaults.dhcp_options_id
  route_table_id             = var.subnet_options != null ? (var.subnet_options.route_table_id != null ? var.subnet_options.route_table_id : local.subnet_options_defaults.route_table_id) : local.subnet_options_defaults.route_table_id
  security_list_ids          = var.subnet_options != null ? (var.subnet_options.security_list_ids != null ? var.subnet_options.security_list_ids : local.subnet_options_defaults.security_list_ids) : local.subnet_options_defaults.security_list_ids
}

/*
module "oci_subnets" {
  source                = "../../core/sdf-oci-core-subnet"
  
  default_compartment_id  = var.default_compartment_id
  vcn_id                = local.vcn_id
  vcn_cidr              = local.vcn_cidr
  
  subnets = var.create_subnet != true ? {} : {
    "${local.subnet_name}" = {
      compartment_id    = var.subnet_options != null ? ( var.subnet_options.compartment_id != null ? var.subnet_options.compartment_id : local.subnet_options_defaults.compartment_id ) : local.subnet_options_defaults.compartment_id
      defined_tags      = var.subnet_options != null ? ( var.subnet_options.defined_tags != null ? var.subnet_options.defined_tags : local.subnet_options_defaults.defined_tags ) : local.subnet_options_defaults.defined_tags
      freeform_tags     = var.subnet_options != null ? ( var.subnet_options.freeform_tags != null ? var.subnet_options.freeform_tags : local.subnet_options_defaults.freeform_tags ) : local.subnet_options_defaults.freeform_tags
      dynamic_cidr      = var.subnet_options != null ? ( var.subnet_options.dynamic_cidr != null ? var.subnet_options.dynamic_cidr : local.subnet_options_defaults.dynamic_cidr ) : local.subnet_options_defaults.dynamic_cidr
      cidr              = var.subnet_options != null ? ( var.subnet_options.cidr != null ? var.subnet_options.cidr : local.subnet_options_defaults.cidr ) : local.subnet_options_defaults.cidr
      cidr_len          = var.subnet_options != null ? ( var.subnet_options.cidr_len != null ? var.subnet_options.cidr_len : local.subnet_options_defaults.cidr_len ) : local.subnet_options_defaults.cidr_len
      cidr_num          = var.subnet_options != null ? ( var.subnet_options.cidr_num != null ? var.subnet_options.cidr_num : local.subnet_options_defaults.cidr_num ) : local.subnet_options_defaults.cidr_num
      enable_dns        = var.subnet_options != null ? ( var.subnet_options.enable_dns != null ? var.subnet_options.enable_dns : local.subnet_options_defaults.enable_dns ) : local.subnet_options_defaults.enable_dns
      dns_label         = var.subnet_options != null ? ( var.subnet_options.dns_label != null ? var.subnet_options.dns_label : local.subnet_options_defaults.dns_label ) : local.subnet_options_defaults.dns_label
      private           = var.subnet_options != null ? ( var.subnet_options.private != null ? var.subnet_options.private : local.subnet_options_defaults.private ) : local.subnet_options_defaults.private
      ad                = var.subnet_options != null ? ( var.subnet_options.ad != null ? var.subnet_options.ad : local.subnet_options_defaults.ad ) : local.subnet_options_defaults.ad
      dhcp_options_id   = var.subnet_options != null ? ( var.subnet_options.dhcp_options_id != null ? var.subnet_options.dhcp_options_id : local.subnet_options_defaults.dhcp_options_id ) : local.subnet_options_defaults.dhcp_options_id
      route_table_id    = var.subnet_options != null ? ( var.subnet_options.route_table_id != null ? var.subnet_options.route_table_id : local.subnet_options_defaults.route_table_id ) : local.subnet_options_defaults.route_table_id
      security_list_ids = var.subnet_options != null ? ( var.subnet_options.security_list_ids != null ? var.subnet_options.security_list_ids : local.subnet_options_defaults.security_list_ids ) : local.subnet_options_defaults.security_list_ids
    }
  }
}
*/

locals {
  # NSG rules (for when a ansible NSG is created)
  nsg_ingress_rules = concat([for i in var.ssh_src_cidrs :
    {
      description = "Allow SSH from ${i}"
      stateless   = false
      protocol    = "6"
      src_type    = "CIDR_BLOCK"
      src         = i
      dst_port = {
        min = "22"
        max = "22"
      }
      src_port  = null
      icmp_type = null
      icmp_code = null
    }
    ], [for i in var.ssh_src_nsg_ids :
    {
      description = "Allow SSH from NSG OCID ${i}"
      stateless   = false
      protocol    = "6"
      src_type    = "NETWORK_SECURITY_GROUP"
      src         = i
      dst_port = {
        min = "22"
        max = "22"
      }
      src_port  = null
      icmp_type = null
      icmp_code = null
    }
  ])
  nsg_egress_rules = concat([for i in var.ssh_dst_cidrs :
    {
      description = "Allow SSH to ${i}"
      stateless   = false
      protocol    = "6"
      dst_type    = "CIDR_BLOCK"
      dst         = i
      dst_port = {
        min = "22"
        max = "22"
      }
      src_port  = null
      icmp_type = null
      icmp_code = null
    }
    ], [for i in var.ssh_dst_nsg_ids :
    {
      description = "Allow SSH to NSG OCID ${i}"
      stateless   = false
      protocol    = "6"
      dst_type    = "NETWORK_SECURITY_GROUP"
      dst         = i
      dst_port = {
        min = "22"
        max = "22"
      }
      src_port  = null
      icmp_type = null
      icmp_code = null
    }
  ])

  # standalone NSG rules
  nsg_standalone_ingress_rules = var.existing_nsg_id == null ? [] : concat([for i in var.ssh_src_cidrs :
    {
      description = "Allow SSH from ${i}"
      nsg_id      = var.existing_nsg_id
      stateless   = false
      protocol    = "6"
      src_type    = "CIDR_BLOCK"
      src         = i
      dst_port = {
        min = "22"
        max = "22"
      }
      src_port  = null
      icmp_type = null
      icmp_code = null
    }
    ], [for i in var.ssh_src_nsg_ids :
    {
      description = "Allow SSH from NSG OCID ${i}"
      nsg_id      = var.existing_nsg_id
      stateless   = false
      protocol    = "6"
      src_type    = "NETWORK_SECURITY_GROUP"
      src         = i
      dst_port = {
        min = "22"
        max = "22"
      }
      src_port  = null
      icmp_type = null
      icmp_code = null
    }
  ])
  nsg_standalone_egress_rules = var.existing_nsg_id == null ? [] : concat([for i in var.ssh_dst_cidrs :
    {
      description = "Allow SSH to ${i}"
      nsg_id      = var.existing_nsg_id
      stateless   = false
      protocol    = "6"
      dst_type    = "CIDR_BLOCK"
      dst         = i
      dst_port = {
        min = "22"
        max = "22"
      }
      src_port  = null
      icmp_type = null
      icmp_code = null
    }
    ], [for i in var.ssh_dst_nsg_ids :
    {
      description = "Allow SSH to NSG OCID ${i}"
      nsg_id      = var.existing_nsg_id
      stateless   = false
      protocol    = "6"
      dst_type    = "NETWORK_SECURITY_GROUP"
      dst         = i
      dst_port = {
        min = "22"
        max = "22"
      }
      src_port  = null
      icmp_type = null
      icmp_code = null
    }
  ])

  nsg_options_defaults = {
    name           = "ansible"
    compartment_id = null
    defined_tags   = null
    freeform_tags  = null
  }

  created_nsg_name = var.nsg_options != null ? (var.nsg_options.name != null ? var.nsg_options.name : local.nsg_options_defaults.name) : local.nsg_options_defaults.name
}

module "network_security_policies" {
  source = "github.com/oracle/terraform-oci-tdf-network-security.git?ref=v0.9.7"

  default_compartment_id = var.default_compartment_id
  vcn_id                 = local.vcn_id

  nsgs = var.create_nsg != true ? {} : {
    "${local.created_nsg_name}" = {
      compartment_id = var.nsg_options != null ? (var.nsg_options.compartment_id != null ? var.nsg_options.compartment_id : var.default_compartment_id) : var.default_compartment_id
      defined_tags   = var.nsg_options != null ? (var.nsg_options.defined_tags != null ? var.nsg_options.defined_tags : var.default_defined_tags) : var.default_defined_tags
      freeform_tags  = var.nsg_options != null ? (var.nsg_options.freeform_tags != null ? var.nsg_options.freeform_tags : var.default_freeform_tags) : var.default_freeform_tags
      ingress_rules  = local.nsg_ingress_rules
      egress_rules   = local.nsg_egress_rules
    }
  }

  standalone_nsg_rules = var.create_nsg == true ? {
    ingress_rules = []
    egress_rules  = []
    } : {
    ingress_rules = local.nsg_standalone_ingress_rules != null ? local.nsg_standalone_ingress_rules : []
    egress_rules  = local.nsg_standalone_egress_rules != null ? local.nsg_standalone_egress_rules : []
  }
}

locals {
  compute_options_defaults = {
    ad                 = 0
    compartment_id     = null
    shape              = "VM.Standard2.1"
    assign_public_ip   = false
    vnic_defined_tags  = {}
    vnic_freeform_tags = {}
    vnic_display_name  = "ansible"
    nsg_ids            = [],
    private_ip         = null
    public_ip          = false
    defined_tags       = {}
    name               = "ansible"
    fd                 = null
    freeform_tags      = {}
    hostname_label     = "ansible"
    ssh_auth_keys      = var.default_ssh_auth_keys
    user_data          = var.create_compute != true ? null : base64encode(file("${path.module}/scripts/ansible.tpl"))
    image_name         = null
    source_id          = null
    source_type        = null
    boot_vol_img_id    = var.default_img_id
    boot_vol_img_name  = var.default_img_name
    boot_vol_size      = 60
    kms_key_id         = null
    sec_vnics          = {}
    block_volumes      = []
  }
  compute_name     = var.compute_options != null ? (var.compute_options.name != null ? var.compute_options.name : local.compute_options_defaults.name) : local.compute_options_defaults.name
  compute_dns_name = var.compute_options != null ? (var.compute_options.hostname_label != null ? var.compute_options.hostname_label : local.compute_options_defaults.hostname_label) : local.compute_options_defaults.hostname_label
  # compute_nsg_ids       = var.create_nsg == true ? ( module.network_security_policies.nsgs != null && length(module.network_security_policies.nsgs) > 0 ? ( concat([ module.network_security_policies.nsgs["${local.created_nsg_name}"].id ], local.compute_associated_nsg_ids) : concat([ var.existing_nsg_id ], local.compute_associated_nsg_ids) ) : concat([ var.existing_nsg_id ], local.compute_associated_nsg_ids) ) : concat([ var.existing_nsg_id ], local.compute_associated_nsg_ids)
  existing_nsg               = concat([var.existing_nsg_id], local.compute_associated_nsg_ids)
  compute_nsg_ids            = var.create_nsg == true ? (module.network_security_policies.nsgs != null && length(module.network_security_policies.nsgs) > 0 ? concat([module.network_security_policies.nsgs["${local.created_nsg_name}"].id], local.compute_associated_nsg_ids) : local.existing_nsg) : local.existing_nsg
  compute_associated_nsg_ids = var.nsg_ids_to_associate != null ? var.nsg_ids_to_associate : []
}

module "oci_instances" {
  source = "github.com/oracle-terraform-modules/terraform-oci-tdf-compute-instance.git?ref=v0.10.2"

  default_compartment_id = var.default_compartment_id

  instances = var.create_compute != true ? {} : {
    "${local.compute_name}" = {
      ad                     = var.compute_options != null ? (var.compute_options.ad != null ? var.compute_options.ad : local.compute_options_defaults.ad) : local.compute_options_defaults.ad
      compartment_id         = var.compute_options != null ? (var.compute_options.compartment_id != null ? var.compute_options.compartment_id : null) : null
      shape                  = var.compute_options != null ? (var.compute_options.shape != null ? var.compute_options.shape : local.compute_options_defaults.shape) : local.compute_options_defaults.shape
      subnet_id              = local.subnet_id
      is_monitoring_disabled = null
      assign_public_ip       = var.compute_options != null ? (var.compute_options.public_ip != null ? var.compute_options.public_ip : local.compute_options_defaults.public_ip) : local.compute_options_defaults.public_ip
      vnic_defined_tags      = var.compute_options != null ? (var.compute_options.vnic_defined_tags != null ? var.compute_options.vnic_defined_tags : local.compute_options_defaults.vnic_defined_tags) : local.compute_options_defaults.vnic_defined_tags
      vnic_display_name      = local.compute_name
      vnic_freeform_tags     = var.compute_options != null ? (var.compute_options.vnic_freeform_tags != null ? var.compute_options.vnic_freeform_tags : local.compute_options_defaults.vnic_freeform_tags) : local.compute_options_defaults.vnic_freeform_tags
      nsg_ids                = local.compute_nsg_ids
      private_ip             = var.compute_options != null ? (var.compute_options.private_ip != null ? var.compute_options.private_ip : local.compute_options_defaults.private_ip) : local.compute_options_defaults.private_ip
      skip_src_dest_check    = false
      defined_tags           = var.compute_options != null ? (var.compute_options.defined_tags != null ? var.compute_options.defined_tags : local.compute_options_defaults.defined_tags) : local.compute_options_defaults.defined_tags
      display_name           = local.compute_name
      extended_metadata      = null
      fault_domain           = var.compute_options != null ? (var.compute_options.fd != null ? var.compute_options.fd : local.compute_options_defaults.fd) : local.compute_options_defaults.fd
      freeform_tags          = var.compute_options != null ? (var.compute_options.freeform_tags != null ? var.compute_options.freeform_tags : local.compute_options_defaults.freeform_tags) : local.compute_options_defaults.freeform_tags
      hostname_label         = local.compute_dns_name
      ipxe_script            = null
      pv_encr_trans_enabled  = null
      ssh_authorized_keys    = var.compute_options != null ? (var.compute_options.ssh_auth_keys != null ? var.compute_options.ssh_auth_keys : local.compute_options_defaults.ssh_auth_keys) : local.compute_options_defaults.ssh_auth_keys
      ssh_private_keys       = []
      user_data              = var.compute_options != null ? (var.compute_options.user_data != null ? var.compute_options.user_data : local.compute_options_defaults.user_data) : local.compute_options_defaults.user_data
      // See https://docs.cloud.oracle.com/iaas/images/ for image OCIDs and names
      image_name           = var.compute_options != null ? (var.compute_options.boot_vol_img_name != null ? var.compute_options.boot_vol_img_name : local.compute_options_defaults.boot_vol_img_name) : local.compute_options_defaults.boot_vol_img_name
      source_id            = var.compute_options != null ? (var.compute_options.boot_vol_img_id != null ? var.compute_options.boot_vol_img_id : local.compute_options_defaults.boot_vol_img_id) : local.compute_options_defaults.boot_vol_img_id
      source_type          = null
      mkp_image_name         = null
      mkp_image_name_version = null
      boot_vol_size_gbs    = var.compute_options != null ? (var.compute_options.boot_vol_size != null ? var.compute_options.boot_vol_size : local.compute_options_defaults.boot_vol_size) : local.compute_options_defaults.boot_vol_size
      kms_key_id           = var.compute_options != null ? (var.compute_options.kms_key_id != null ? var.compute_options.kms_key_id : local.compute_options_defaults.kms_key_id) : local.compute_options_defaults.kms_key_id
      preserve_boot_volume = null
      instance_timeout     = null
      sec_vnics            = {}
      block_volumes        = []
      mount_blk_vols       = false
      cons_conn_create     = false
      cons_conn_def_tags   = {}
      cons_conn_free_tags  = {}
      bastion_ip           = null
    }
  }
}
