variable "location" {
  type        = string
  description = "Azure region for the Automation Account."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group where the VM lives (and where AA will be created)."
}

variable "vm_id" {
  type        = string
  description = "Resource ID of the target VM to self-heal."
}

variable "vm_name" {
  type        = string
  description = "Name of the target VM."
}

variable "alert_name" {
  type        = string
  default     = "vm-selfheal-alert"
  description = "Name of the activity log alert."
}

variable "aa_name" {
  type        = string
  default     = "aa-sdwan-selfheal"
  description = "Automation Account name."
}

variable "runbook_name" {
  type        = string
  default     = "Restart-VM"
  description = "Runbook name."
}

variable "action_group_name" {
  type        = string
  default     = "ag-vm-selfheal"
  description = "Action Group name."
}

variable "tags" {
  type        = map(string)
  default     = {}
}
