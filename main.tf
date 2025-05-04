provider "azurerm" {
  features = {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-main"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-main"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "gogs-vm"
  resource_group_name   = azurerm_resource_group.main.name
  location              = var.location
  size                  = "Standard_B1s"
  admin_username        = var.vm_admin_user
  admin_password        = var.vm_admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-lts"
    version   = "latest"
  }

  disable_password_authentication = false
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "gogs-db-${random_id.mysql_suffix.hex}"
  location               = var.location
  resource_group_name    = azurerm_resource_group.main.name
  administrator_login    = var.mysql_user
  administrator_password = var.mysql_password
  sku_name               = "B_Standard_B1ms"
  version                = "8.0"

  storage_mb           = 32768
  delegated_subnet_id  = null
  zone                 = "1"
}

resource "random_id" "mysql_suffix" {
  byte_length = 4
}
