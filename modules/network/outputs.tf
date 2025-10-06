output "resource_group_name" { value = azurerm_resource_group.rg.name }
output "subnet_wan_id"       { value = azurerm_subnet.wan.id }
output "subnet_lan_id"       { value = azurerm_subnet.lan.id }
