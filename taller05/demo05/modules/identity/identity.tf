data "azurerm_resource_group" "rg" {
  name = var.azurerm_resource_group
}

# Identidad asignada por usuario de AZURE
# En términos simples, una identidad de usuario en Azure es un objeto que representa a un usuario 
# o a una aplicación en una instancia de Azure
resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  name = var.identity_name
}
# Asignación de rol de AZURE (contribuyente de red)
resource "azurerm_role_assignment" "network" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

# Asignación de rol de AZURE (contribuyente de zona DNS privada)
resource "azurerm_role_assignment" "dns" {
  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}