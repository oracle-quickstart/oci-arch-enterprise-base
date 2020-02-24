# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Global variables
variable "default_compartment_id" {
  type        = string
  description = "The default compartment OCID to use for resources (unless otherwise specified)."
}
variable "default_defined_tags" {
  type        = map(string)
  description = "The different defined tags that are applied to each object by default."
  default     = {}
}
variable "default_freeform_tags" {
  type        = map(string)
  description = "The different freeform tags that are applied to each object by default."
  default     = {}
}

variable "default_img_id" {
  type        = string
  description = "The default image OCID to use for compute resources (unless otherwise specified)."
  default     = null
}
variable "default_img_name" {
  type        = string
  description = "The default image OCID to use for compute resources (unless otherwise specified)."
  default     = null
}
variable "default_ssh_auth_keys" {
  type        = list(string)
  description = "The default SSH public key(s) that should be set as authorized SSH keys (unless otherwise specified)."
}

variable "internal_drg_routes" {
  type        = list(string)
  description = "The different routes that are to be added to the internal Route Table, sending the routes to the DRG."
  default     = []
}

variable "internal_rt_rule_overrides" {
  type        = any
  description = "(optional) If the default internal Route Table entries are not desired, provide your own entries here (reference the sdf-core-network module for the format of Route Table rules)."
  default     = null
}
variable "internal_public_rt_rule_overrides" {
  type        = any
  description = "(optional) If the default internal public Route Table entries are not desired, provide your own entries here (defaults to using the same rules as the internal route, except that the default (0.0.0.0/0) route points to an IGW)."
  default     = null
}
variable "external_rt_rule_overrides" {
  type        = any
  description = "(optional) If the default external Route Table entries are not desired, provide your own entries here (reference the sdf-core-network module for the format of Route Table rules)."
  default     = null
}

variable "create_vcn_wide_sl" {
  type        = bool
  description = "Whether or not a VCN-wide Security List should be created."
  default     = true
}
variable "use_default_vcn_wide_rules" {
  type        = bool
  description = "Whether or not the default rules for the VCN-wide Security List should be used."
  default     = true
}
variable "vcn_wide_sl_options" {
  type = object({
    allow_http_egress  = bool,
    allow_https_egress = bool
  })
  description = "Settings that change default rules that are populated in the VCN-wide Security List."
  default     = null
}
variable "additional_vcn_wide_rules" {
  type = object({
    ingress_rules = list(object({
      stateless = bool,
      protocol  = string,
      src       = string,
      src_type  = string,
      src_port = object({
        min = number,
        max = number
      }),
      dst_port = object({
        min = number,
        max = number
      }),
      icmp_type = number,
      icmp_code = number
    })),
    egress_rules = list(object({
      stateless = bool,
      protocol  = string,
      dst       = string,
      dst_type  = string,
      src_port = object({
        min = number,
        max = number
      }),
      dst_port = object({
        min = number,
        max = number
      }),
      icmp_type = number,
      icmp_code = number
    }))
  })
  description = "(optional) If there are additional Security List rules that should be added to the VCN-wide Security List, add them here (see the sdf-core-network-security module documentation for the format of the rules)."
  default     = null
}

variable "empty_default_security_list" {
  type        = bool
  description = "Whether or not the default Security List should be emptied of all rules (so it can effectively become a blackhole)."
  default     = true
}

# VCN-specific
variable "vcn_cidr" {
  type        = string
  description = "The desired CIDR of the new VCN."
  default     = "192.168.0.0/20"
}
variable "vcn_dns_label" {
  type        = string
  description = "The desired DNS label of the new VCN."
  default     = null
}
variable "vcn_name" {
  type        = string
  description = "The desired name of the new VCN."
  default     = null
}
variable "vcn_options" {
  type = object({
    compartment_id = string,
    defined_tags   = map(string),
    freeform_tags  = map(string),
    enable_dns     = bool
  })
  description = "Optional parameters for customizing the VCN."
  default     = null
}

variable "create_igw" {
  type        = bool
  description = "Whether or not to create a IGW in the VCN (default: true)."
  default     = true
}
variable "create_natgw" {
  type        = bool
  description = "Whether or not to create a NAT Gateway in the VCN (default: true)."
  default     = true
}
variable "create_svcgw" {
  type        = bool
  description = "Whether or not to create a Service Gateway in the VCN (default: true)."
  default     = true
}
variable "create_drg" {
  type        = bool
  description = "Whether or not to create a Dynamic Routing Gateway in the VCN (default: true)."
  default     = true
}
variable "igw_options" {
  type        = any
  description = "Optional customization of the IGW (see the sdf-oci-core-network module for more documentation on the format of this input attribute)."
  default     = null
}
variable "natgw_options" {
  type        = any
  description = "Optional customization of the NATGW (see the sdf-oci-core-network module for more documentation on the format of this input attribute)."
  default     = null
}
variable "svcgw_options" {
  type        = any
  description = "Optional customization of the SVCGW (see the sdf-oci-core-network module for more documentation on the format of this input attribute)."
  default     = null
}
variable "drg_options" {
  type        = any
  description = "Optional customization of the DRG (see the sdf-oci-core-network module for more documentation on the format of this input attribute)."
  default     = null
}

# bastion-specific
variable "create_bastion" {
  type        = bool
  description = "Whether or not a bastion and all of its resources (subnet/NSG/compute instance) should be created."
  default     = true
}
variable "bastion_subnet_cidr" {
  type        = string
  description = "The CIDR of the bastion subnet (if it is to be created)."
  default     = "192.168.0.8/29"
}
variable "bastion_options" {
  type = object({
    subnet_compartment_id   = string,
    subnet_name             = string,
    subnet_dns_label        = string,
    subnet_cidr             = string,
    instance_compartment_id = string,
    instance_ad             = number,
    instance_name           = string,
    instance_dns_label      = string,
    instance_shape          = string,
    ssh_auth_keys           = list(string),
    ssh_src_cidrs           = list(string),
    image_name              = string,
    image_id                = string,
    private_ip              = string,
    allow_int_routes        = bool,
    public_ip               = bool,
    use_default_nsg_rules   = bool,
    route_table_id          = string,
    freeform_tags           = map(string),
    defined_tags            = map(string)
  })
  description = "The optional customizations available for the bastion."
  default     = null
}

# ansible-specific
variable "create_ansible" {
  type        = bool
  description = "Whether or not an Ansible control machine and all of its resources (subnet/NSG/compute instance) should be created."
  default     = true
}
variable "ansible_subnet_cidr" {
  type        = string
  description = "The CIDR to use for the Ansible subnet that is to be created."
  default     = null
}
variable "ansible_options" {
  type = object({
    subnet_compartment_id   = string,
    subnet_name             = string,
    subnet_dns_label        = string,
    subnet_cidr             = string,
    instance_compartment_id = string,
    instance_ad             = number,
    instance_name           = string,
    instance_dns_label      = string,
    instance_shape          = string,
    ssh_auth_keys           = list(string),
    ssh_src_cidrs           = list(string),
    image_name              = string,
    image_id                = string,
    private_ip              = string,
    allow_int_routes        = bool,
    public_ip               = bool,
    use_default_nsg_rules   = bool,
    route_table_id          = string,
    freeform_tags           = map(string),
    defined_tags            = map(string)
  })
  description = "The optional customizations available for the Ansible control machine."
  default     = null
}

# Hybrid DNS
variable "create_dns" {
  type        = bool
  description = "Whether or not DNS forwarders and all of their resources (subnet/NSG/compute instance) should be created."
  default     = true
}
variable "existing_dns_forwarder_ips" {
  type        = list(string)
  description = "If DNS forwarders are not to be created, but existing ones used, provide these here."
  default     = null
}
variable "allow_vcn_cidr_ingress_dns_forwarders" {
  type        = bool
  description = "Whether or not the DNS forwarders NSG should have the VCN CIDR permitted ingress on udp/53."
  default     = true
}
variable "dns_namespace_mappings" {
  type = list(object({
    namespace = string
    server    = string
  }))
  description = "The DNS namespaces and servers that respond to these namespaces."
  default     = null
}
variable "reverse_dns_mappings" {
  type = list(object({
    cidr   = string
    server = string
  }))
  description = "The reverse DNS namespaces and servers that respond to these reverse namespaces."
  default     = null
}
variable "dns_options" {
  type = object({
    subnet_compartment_id   = string,
    subnet_name             = string,
    subnet_dns_label        = string,
    subnet_cidr             = string,
    instance_compartment_id = string,
    instance_shape          = string,
    ssh_auth_keys           = list(string),
    image_id                = string,
    image_name              = string,
    public_ip               = bool,
    allow_int_routes        = bool,
    dns_src_cidrs           = list(string),
    dns_dst_cidrs           = list(string),
    use_default_nsg_rules   = bool,
    route_table_id          = string,
    freeform_tags           = map(string),
    defined_tags            = map(string)
  })
  description = "The optional customizations available for the hybrid DNS resources."
  default     = null
}

variable "dns_forwarder_1" {
  type = object({
    ad             = number,
    fd             = string,
    private_ip     = string,
    name           = string,
    hostname_label = string,
    kms_key_id     = string
  })
  description = "Settings specific to DNS forwarder #1."
  default     = null
}

variable "dns_forwarder_2" {
  type = object({
    ad             = number,
    fd             = string,
    private_ip     = string,
    name           = string,
    hostname_label = string,
    kms_key_id     = string
  })
  description = "Settings specific to DNS forwarder #2."
  default     = null
}

variable "dns_forwarder_3" {
  type = object({
    ad             = number,
    fd             = string,
    private_ip     = string,
    name           = string,
    hostname_label = string,
    kms_key_id     = string
  })
  description = "Settings specific to DNS forwarder #3."
  default     = null
}
