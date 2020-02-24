# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



variable "default_compartment_id" {
  type                = string
  description         = "The OCID of the default compartment that should be used (unless otherwise indicated)."
}
variable "vcn_id" {
  type                = string
  description         = "The OCID of the VCN where the Ansible control machine and all related resources should be placed."
}
variable "vcn_cidr" {
  type                = string
  description         = "The CIDR of the VCN."
}
variable "default_defined_tags" {
  type                = map(string)
  description         = "The different defined tags that are applied to each object by default."
  default             = {}
}
variable "default_freeform_tags" {
  type                = map(string)
  description         = "The different freeform tags that are applied to each object by default."
  default             = {}
}
variable "default_ssh_auth_keys" {
  type                  = list(string)
  description           = "The different authorized keys that are used (unless otherwise indicated on compute instances)."
  default               = null
}
variable "default_img_id" {
  type                  = string
  description           = "The image OCID that should be used, unless defined elsewhere."
  default               = null
}
variable "default_img_name" {
  type                  = string
  description           = "The name of the image that should be used, unless defined elsewhere."
  default               = null
}

# subnet-specific variables
variable "create_subnet" {
  type                = bool
  description         = "Whether or not a subnet should be created for the Ansible control machine."
  default             = true
}
variable "subnet_options" {
  type                = object({
    name              = string,
    compartment_id    = string,
    defined_tags      = map(string),
    freeform_tags     = map(string),
    dynamic_cidr      = bool,
    cidr              = string,
    cidr_len          = number,
    cidr_num          = number,
    enable_dns        = bool,
    dns_label         = string,
    private           = bool,
    ad                = number,
    dhcp_options_id   = string,
    route_table_id    = string,
    security_list_ids = list(string)
  })
  description         = "Parameters for each subnet to be created/managed."
  default             = {
    name              = null
    compartment_id    = null
    defined_tags      = null
    freeform_tags     = null
    dynamic_cidr      = null
    cidr              = null
    cidr_len          = null
    cidr_num          = null
    enable_dns        = null
    dns_label         = null
    private           = null
    ad                = null
    dhcp_options_id   = null
    route_table_id    = null
    security_list_ids = null
  }
}

variable "existing_subnet_id" {
  type                = string
  description         = "The OCID of the subnet where the Ansible control machine should be placed."
  default             = null
}

# NSG-specific variables
variable "create_nsg" {
  type                = bool
  description         = "Whether or not a new NSG should be created for the Ansible control machine."
  default             = true
}

variable "nsg_options" {
  type                = object({
    name              = string,
    compartment_id    = string,
    defined_tags      = map(string),
    freeform_tags     = map(string)
  })
  description         = "Different parameters for customizing the NSG that is created (when create_nsg is true)."
  default             = null
}

variable "existing_nsg_id" {
  type                = string
  description         = "The OCID of the existing NSG that should be used to configure NSG rules on."
  default             = null
}

variable "nsg_ids_to_associate" {
  type                = list(string)
  description         = "The OCIDs of the NSGs that should be associated with the Ansible control machine vNIC."
  default             = null
}

variable "ssh_src_cidrs" {
  type                = list(string)
  description         = "The CIDRs that are permitted inbound to this instance via SSH (tcp/22), added as NSG rules to the ansible NSG."
  default             = []
}
variable "ssh_dst_cidrs" {
  type                = list(string)
  description         = "The CIDRs that this Ansible control machine is permitted to connect to via SSH (tcp/22), added as NSG rules to the ansible NSG."
  default             = []
}

variable "ssh_src_nsg_ids" {
  type                = list(string)
  description         = "The NSG OCIDs that are permitted inbound to this instance via SSH (tcp/22), added as NSG rules to the ansible NSG."
  default             = []
}
variable "ssh_dst_nsg_ids" {
  type                = list(string)
  description         = "The NSG OCIDs that this Ansible control machine is permitted to connect to via SSH (tcp/22), added as NSG rules to the ansible NSG."
  default             = []
}

# compute-specific variables
variable "create_compute" {
  type                = bool
  description         = "Whether or not the compute should be created for the ansible."
  default             = true
}

#   see https://docs.cloud.oracle.com/iaas/images/ for OCI images
variable "compute_options" {
  type                = object({
    compartment_id    = string,
    ad                = number,
    fd                = string,
    shape             = string,
    public_ip         = bool,
    private_ip        = string,
    defined_tags      = map(string),
    freeform_tags     = map(string),
    vnic_defined_tags = map(string),
    vnic_freeform_tags = map(string),
    name              = string,
    hostname_label    = string,
    ssh_auth_keys     = list(string),
    user_data         = string,
    boot_vol_img_name = string,
    boot_vol_img_id   = string,
    boot_vol_size     = number,
    kms_key_id        = string
  })
  description         = "The various options available to customize for the Ansible control machine compute instance."
  default             = {
    compartment_id    = null
    ad                = null
    fd                = null
    shape             = null
    public_ip         = null
    private_ip        = null
    defined_tags      = null
    freeform_tags     = null
    vnic_defined_tags = null
    vnic_freeform_tags = null
    name              = null
    hostname_label    = null
    ssh_auth_keys     = null
    user_data         = null
    boot_vol_img_name = null
    boot_vol_img_id   = null
    boot_vol_size     = null
    kms_key_id        = null
  }
}
