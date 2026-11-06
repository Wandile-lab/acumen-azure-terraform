resource "azurerm_resource_group" "acumen" {
  name     = "rg-acumen-infra"
  location = "spaincentral"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-acumen"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.acumen.location
  resource_group_name = azurerm_resource_group.acumen.name
}

resource "azurerm_subnet" "public" {
  name                 = "snet-public-bastion"
  resource_group_name  = azurerm_resource_group.acumen.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private" {
  name                 = "snet-private-cluster"
  resource_group_name  = azurerm_resource_group.acumen.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
