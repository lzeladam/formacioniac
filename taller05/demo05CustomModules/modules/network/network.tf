data "azurerm_resource_group" "rg" {
  name = var.azurerm_resource_group
}

resource "azurerm_virtual_network" "demo04_vn" {
  address_space       = ["10.52.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  name                = "demo04-vn"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "application" {
  address_prefixes                          = ["10.52.0.0/24"]
  name                                      = "application-sn"
  resource_group_name                       = data.azurerm_resource_group.rg.name
  virtual_network_name                      = azurerm_virtual_network.demo04_vn.name
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_subnet" "database" {
  address_prefixes                          = ["10.52.1.0/24"]
  name                                      = "database-sn"
  resource_group_name                       = data.azurerm_resource_group.rg.name
  virtual_network_name                      = azurerm_virtual_network.demo04_vn.name
  private_endpoint_network_policies_enabled = true
}
