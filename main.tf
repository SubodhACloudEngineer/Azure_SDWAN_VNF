module "network" {
  source   = "./modules/network"
  for_each = var.sites

  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  name_prefix         = each.value.name_prefix
  vnet_cidr           = each.value.vnet_cidr
  lan_cidr            = each.value.lan_cidr
  wan_cidr            = each.value.wan_cidr

}

module "vm" {
  source   = "./modules/vm"
  for_each = var.sites

  location            = each.value.location
  resource_group_name = module.network[each.key].resource_group_name
  subnet_wan_id       = module.network[each.key].subnet_wan_id
  subnet_lan_id       = module.network[each.key].subnet_lan_id
  vm_admin_username   = var.vm_admin_username
  vm_size             = var.vm_size
  ssh_public_key      = var.ssh_public_key
  name_prefix         = each.value.name_prefix
}

