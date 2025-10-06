output "automation_account_id" {
  value = azurerm_automation_account.aa.id
}

output "runbook_name" {
  value = azurerm_automation_runbook.rb.name
}

output "webhook_uri" {
  # (Shown here for completeness; generally keep it secret)
  value       = azurerm_automation_webhook.rb_webhook.uri
  sensitive   = true
  description = "Webhook URI that triggers the runbook."
}

output "action_group_id" {
  value = azurerm_monitor_action_group.ag.id
}

output "poweroff_alert_id"   { value = azurerm_monitor_activity_log_alert.vm_poweroff_alert.id }
output "deallocate_alert_id" { value = azurerm_monitor_activity_log_alert.vm_deallocate_alert.id }

