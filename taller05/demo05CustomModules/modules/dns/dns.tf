data "azurerm_resource_group" "rg" {
  name = var.azurerm_resource_group
}

resource "azurerm_private_dns_zone" "main" {
  name                = var.private_dns_zone_name
  resource_group_name = data.azurerm_resource_group.rg.name
}
