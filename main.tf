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

  location            = var.sites[each.key].location
  resource_group_name = module.network[each.key].resource_group_name
  name_prefix         = var.sites[each.key].name_prefix

  subnet_wan_id = module.network[each.key].subnet_wan_id
  subnet_lan_id = module.network[each.key].subnet_lan_id

  ssh_public_key    = var.ssh_public_key
  vm_admin_username = var.vm_admin_username
  custom_data_path  = var.custom_data_path
  vm_size           = var.vm_size
}
