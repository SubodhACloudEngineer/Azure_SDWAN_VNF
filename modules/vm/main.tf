locals {
  effective_admin = var.vm_admin_username != "" ? var.vm_admin_username : var.admin_username

  effective_custom_path = (
    var.custom_data_path != "" ? var.custom_data_path :
    (var.custom_data != "" ? var.custom_data : "")
  )

  custom_data_b64 = local.effective_custom_path != "" ? filebase64(local.effective_custom_path) : null
}

# Public IP for WAN NIC
resource "azurerm_public_ip" "pip" {
  name                = "${var.name_prefix}-sdwan-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    app  = "sdwan-sim"
    site = var.name_prefix
    role = "edge"
  }
}

# WAN NIC (binds the public IP)
resource "azurerm_network_interface" "wan" {
  name                = "${var.name_prefix}-nic-wan"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_wan_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags = {
    app  = "sdwan-sim"
    site = var.name_prefix
    role = "edge-wan"
  }
}

# LAN NIC
resource "azurerm_network_interface" "lan" {
  name                = "${var.name_prefix}-nic-lan"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_lan_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    app  = "sdwan-sim"
    site = var.name_prefix
    role = "edge-lan"
  }
}

# The VM with both NICs attached
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.name_prefix}-vm-sdwan-Juniper"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size

  network_interface_ids = [
    azurerm_network_interface.wan.id,
    azurerm_network_interface.lan.id,
  ]

  admin_username                  = local.effective_admin
  disable_password_authentication = true

  admin_ssh_key {
    username   = local.effective_admin
    public_key = var.ssh_public_key
  }

  # Only set when provided (null is allowed)
  custom_data = local.custom_data_b64

  os_disk {
    name                 = "${var.name_prefix}-sdwan-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    app  = "sdwan-sim"
    site = var.name_prefix
    role = "edge-vm"
  }
}
