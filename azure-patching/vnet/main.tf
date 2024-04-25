locals {
  default_tag = "${var.ProgramName}-${var.EnvironmentName}"
}

resource "azurerm_resource_group" "azure_resource_group" {
  name     = "${local.default_tag}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "azure_vnet" {
  name                = "${local.default_tag}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.azure_resource_group.name
}

resource "azurerm_subnet" "public_subnet" {
  name                 = "${local.default_tag}-public-subnet"
  resource_group_name  = azurerm_resource_group.azure_resource_group.name
  virtual_network_name = azurerm_virtual_network.azure_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "${local.default_tag}-private-subnet"
  resource_group_name  = azurerm_resource_group.azure_resource_group.name
  virtual_network_name = azurerm_virtual_network.azure_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "azure_nsg" {
  name                = "${local.default_tag}-rdp-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.azure_resource_group.name

  security_rule {
    name                       = "RdpPort"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.source_address_prefix
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "azure_nsg_association" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.azure_nsg.id
}