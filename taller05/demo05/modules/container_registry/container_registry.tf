data "azurerm_resource_group" "rg" {
  name = var.azurerm_resource_group
}

# Crear un Azure Container Registry básico
resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  sku                      = "Basic"
  admin_enabled            = true
}
