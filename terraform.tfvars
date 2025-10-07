ssh_public_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEkEDL8Pns04uZ9CSzA7HpViCMeR7lkUaTHLy4aBrSiO subodh.kashyap@global.ntt"
vm_admin_username = "azureuser"
vm_size           = "Standard_B1s"

sites = {
  east = {
    location            = "eastus"
    resource_group_name = "rg-sdwan-east"
    name_prefix         = "east"
    vnet_cidr           = "10.0.0.0/16"
    wan_cidr            = "10.0.1.0/24"
    lan_cidr            = "10.0.2.0/24"
  }
  west = {
    location            = "westus"
    resource_group_name = "rg-sdwan-west"
    name_prefix         = "west"
    vnet_cidr           = "10.1.0.0/16"
    wan_cidr            = "10.1.1.0/24"
    lan_cidr            = "10.1.2.0/24"
  }
}
