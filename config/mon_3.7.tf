# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "cis_notification_iam_policy_changes" {
  source             = "../modules/monitoring/notifications"
  compartment_id     = module.compartments.compartments[local.security_compartment_name].id
  rule_display_name  = "${var.service_label}-notify-on-iam-policy-changes"    
  rule_description   = "Sends notification when IAM policies are created, updated or deleted."
  rule_is_enabled    = true
  rule_condition     = <<EOT
  {"eventType":
    ["com.oraclecloud.identityControlPlane.CreatePolicy",
     "com.oraclecloud.identityControlPlane.DeletePolicy",
     "com.oraclecloud.identityControlPlane.UpdatePolicy"]
  }
  EOT

  rule_actions_actions_action_type = "ONS"
  rule_actions_actions_is_enabled  = true
  rule_actions_actions_description = "Sends notification via ONS"

  topic_id = module.cis_security_topic.topic_id
}  