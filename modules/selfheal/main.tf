locals {
  # Resource IDs we’ll reference
  subscription_id = data.azurerm_client_config.current.subscription_id
}

data "azurerm_client_config" "current" {}

# 1) Automation Account with System-Assigned Identity
resource "azurerm_automation_account" "aa" {
  name                = var.aa_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# 2) Grant the AA identity rights to start the VM (RG-scoped Virtual Machine Contributor)
resource "azurerm_role_assignment" "aa_vm_contrib" {
  scope                = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_automation_account.aa.identity[0].principal_id
}

# 3) Ensure Az modules exist in AA (Accounts + Compute)
resource "azurerm_automation_module" "az_accounts" {
  name                    = "Az.Accounts"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.aa.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Az.Accounts/2.13.3"
  }
}

resource "azurerm_automation_module" "az_compute" {
  name                    = "Az.Compute"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.aa.name
  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/Az.Compute/6.4.1"
  }
  depends_on = [azurerm_automation_module.az_accounts]
}

# 4) Automation variables: target RG + VM name
resource "azurerm_automation_variable_string" "vm_rg_var" {
  name                    = "TargetResourceGroup"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.aa.name
  value                   = var.resource_group_name
}

resource "azurerm_automation_variable_string" "vm_name_var" {
  name                    = "TargetVmName"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.aa.name
  value                   = var.vm_name
}

# 5) Runbook that (re)starts the VM
resource "azurerm_automation_runbook" "rb" {
  name                    = var.runbook_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.aa.name
  log_verbose             = true
  log_progress            = true
  description             = "Starts the target VM when stopped/deallocated."
  runbook_type            = "PowerShell"
  content                 = <<-PS1
    param(
      [object]$WebhookData
    )

    Write-Output "Self-heal runbook triggered."

    # Connect using the AA's managed identity
    try {
      Connect-AzAccount -Identity | Out-Null
      Write-Output "Connected to Azure using Managed Identity."
    } catch {
      Write-Error "Failed to Connect-AzAccount -Identity: $_"
      throw
    }

    $rgName = Get-AutomationVariable -Name 'TargetResourceGroup'
    $vmName = Get-AutomationVariable -Name 'TargetVmName'
    Write-Output "Target VM: $rgName / $vmName"

    try {
      $vm = Get-AzVM -ResourceGroupName $rgName -Name $vmName -Status
      $powerState = ($vm.Statuses | Where-Object { $_.Code -like "PowerState*" }).DisplayStatus
      Write-Output "Current power state: $powerState"

      if ($powerState -eq "VM deallocated" -or $powerState -eq "VM stopped") {
        Write-Output "Starting VM..."
        Start-AzVM -ResourceGroupName $rgName -Name $vmName -NoWait
      } else {
        Write-Output "VM is already running (no action)."
      }
    } catch {
      Write-Error "Error in (re)starting VM: $_"
      throw
    }
  PS1

  depends_on = [
    azurerm_automation_module.az_compute,
    azurerm_automation_variable_string.vm_rg_var,
    azurerm_automation_variable_string.vm_name_var
  ]
}

# 6) Webhook to invoke the runbook (used by Action Group)
resource "azurerm_automation_webhook" "rb_webhook" {
  name                    = "${var.runbook_name}-webhook"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.aa.name
  runbook_name            = azurerm_automation_runbook.rb.name
  enabled                 = true
  expiry_time             = timeadd(timestamp(), "8760h") # ~1 year

  # Optional: pass payload to runbook (runbook reads the AA variables anyway)
  parameters = {
    WebhookData = "{}"
  }
}

# 7) Action Group that invokes the Runbook via webhook
resource "azurerm_monitor_action_group" "ag" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = "selfheal"

  automation_runbook_receiver {
    name                    = "restartVM"
    automation_account_id   = azurerm_automation_account.aa.id
    runbook_name            = azurerm_automation_runbook.rb.name
    # Some provider versions require service_uri, others accept webhook_resource_id.
    # Supplying BOTH is harmless and maximizes compatibility.
    service_uri             = azurerm_automation_webhook.rb_webhook.uri
    webhook_resource_id     = azurerm_automation_webhook.rb_webhook.id
    is_global_runbook       = false
    use_common_alert_schema = true
  }
}

# 8a) Activity Log Alert: VM powerOff
resource "azurerm_monitor_activity_log_alert" "vm_poweroff_alert" {
  name                = "${var.alert_name}-poweroff"
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Auto-restart VM when powered off"
  scopes              = [var.vm_id]
  enabled             = true

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Compute/virtualMachines/powerOff/action"
    level          = "Informational"
    status         = "Succeeded"
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }
}

# 8b) Activity Log Alert: VM deallocate
resource "azurerm_monitor_activity_log_alert" "vm_deallocate_alert" {
  name                = "${var.alert_name}-deallocate"
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Auto-restart VM when deallocated"
  scopes              = [var.vm_id]
  enabled             = true

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Compute/virtualMachines/deallocate/action"
    level          = "Informational"
    status         = "Succeeded"
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }
}
