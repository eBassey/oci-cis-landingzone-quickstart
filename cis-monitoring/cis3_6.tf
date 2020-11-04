module "cis_notification_iam_group_changes" {
  source             = "../modules/monitoring/notifications"
  compartment_id     = var.tenancy_ocid
  rule_display_name  = "${var.service_label}-notify-on-iam-group-changes"    
  rule_description   = "Sends notification when IAM groups are created, updated or deleted."
  rule_is_enabled    = true
  rule_condition     = <<EOT
  {"eventType": 
    ["com.oraclecloud.identityControlPlane.AddUserToGroup",
     "com.oraclecloud.identityControlPlane.CreateGroup",
     "com.oraclecloud.identityControlPlane.DeleteGroup",
     "com.oraclecloud.identityControlPlane.RemoveUserFromGroup",
     "com.oraclecloud.identityControlPlane.UpdateGroup"]
  }
  EOT
  
  rule_actions_actions_action_type = "ONS"
  rule_actions_actions_is_enabled  = true
  rule_actions_actions_description = "Sends notification via ONS"

  topic_id = module.cis_topics.topic_id
}  