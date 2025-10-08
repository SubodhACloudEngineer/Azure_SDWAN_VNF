variable "location" {
  type    = string
  default = "East US"
}

variable "resource_group_name" {
  type    = string
  default = "rg-sdwan-vnf"
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "ssh_public_key" {
  type = string
}

variable "custom_data_path" {
  type    = string
  default = ""
}

variable "sites" {
  description = "Per-site settings"
  type = map(object({
    location            = string
    resource_group_name = string
    name_prefix         = string
    vnet_cidr           = string
    wan_cidr            = string
    lan_cidr            = string
    # add more per-site fields if your modules expect them (e.g., vm_size)
  }))
}