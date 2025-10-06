resource "azurerm_public_ip" "pip" {
  name                = "${var.name_prefix}-sdwan-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic_wan" {
  name                = "${var.name_prefix}-nic-wan"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_wan_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

}

resource "azurerm_network_interface" "nic_lan" {
  name                = "${var.name_prefix}-nic-lan"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_lan_id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.name_prefix}-vm-sdwan"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username

  network_interface_ids = [
    azurerm_network_interface.nic_wan.id,
    azurerm_network_interface.nic_lan.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.name_prefix}-vm-sdwan-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # If using cloud-init, uncomment and ensure the path is correct:
  # custom_data = filebase64("${path.module}/../../cloud-init/init.yml")
}
