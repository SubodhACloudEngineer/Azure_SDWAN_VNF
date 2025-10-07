variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "name_prefix" {
  type = string
}

# Subnet IDs coming from modules/network outputs
variable "subnet_wan_id" {
  type = string
}

variable "subnet_lan_id" {
  type = string
}

# VM basics
variable "ssh_public_key" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

# Keep your chosen root input name
variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

# Backward-compat (optional; root can pass either)
variable "admin_username" {
  type    = string
  default = "azureuser"
}

# Optional cloud-init: path to file (we base64 it)
variable "custom_data_path" {
  type    = string
  default = ""
}

# Optional alt var name for the same (path)
variable "custom_data" {
  type    = string
  default = ""
}
