# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



module "ent_base" {
  source                = "../../"
  
  default_compartment_id = var.default_compartment_id
  default_ssh_auth_keys  = var.default_ssh_auth_keys
  default_img_name       = var.default_img_name

  create_bastion = false
  create_dns     = false
  create_ansible = false

  empty_default_security_list = false
}

