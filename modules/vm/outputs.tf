output "vm_id"      { value = azurerm_linux_virtual_machine.vm.id }
output "vm_name"    { value = azurerm_linux_virtual_machine.vm.name }
output "public_ip"  { value = azurerm_public_ip.pip.ip_address }
output "wan_nic_id" { value = azurerm_network_interface.wan.id }
output "lan_nic_id" { value = azurerm_network_interface.lan.id }
