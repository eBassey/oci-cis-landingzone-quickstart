locals {
  
  top_compartment_parent_id  = length(var.existing_enclosing_compartments_parent_ocid) > 0 ? var.existing_enclosing_compartments_parent_ocid : var.tenancy_ocid
  enclosing_compartments     = length(var.enclosing_compartment_names) > 0 ? {for c in var.enclosing_compartment_names : "${var.unique_prefix}-${c}" => {parent_id: local.top_compartment_parent_id, description: "Landing Zone enclosing compartment"}} : {"${var.unique_prefix}-top-cmp": {parent_id: local.top_compartment_parent_id, description: "Landing Zone enclosing compartment"}}
  provisioning_group_names   = {for k in keys(local.enclosing_compartments) : k => {group_name: var.use_existing_provisioning_group == false ? "${k}-prov-group" : var.existing_provisioning_group_name}}
  provisioning_group_names_t = var.use_existing_provisioning_group == false ? {for k in keys(local.enclosing_compartments) : k => {group_name:"${k}-prov-group"}} : {"root" : {group_name: var.existing_provisioning_group_name}}
  lz_group_names             = var.use_existing_lz_groups == false ? {for k in keys(local.enclosing_compartments) : k => {group_name_prefix:"${k}-"}} : {"root": {group_name_prefix: ""}}

  iam_admin_group_name_suffix           = var.use_existing_lz_groups == false ? "iam-admin-group" : var.existing_iam_admin_group_name
  cred_admin_group_name_suffix          = var.use_existing_lz_groups == false ? "cred-admin-group" : var.existing_iam_admin_group_name
  network_admin_group_name_suffix       = var.use_existing_lz_groups == false ? "network-admin-group" : var.existing_iam_admin_group_name
  security_admin_group_name_suffix      = var.use_existing_lz_groups == false ? "security-admin-group" : var.existing_iam_admin_group_name
  appdev_admin_group_name_suffix        = var.use_existing_lz_groups == false ? "appdev-admin-group" : var.existing_iam_admin_group_name
  database_admin_group_name_suffix      = var.use_existing_lz_groups == false ? "database-admin-group" : var.existing_iam_admin_group_name
  auditor_group_name_suffix             = var.use_existing_lz_groups == false ? "auditor-group" : var.existing_iam_admin_group_name
  announcement_reader_group_name_suffix = var.use_existing_lz_groups == false ? "announcement-reader-group" : var.existing_iam_admin_group_name
}