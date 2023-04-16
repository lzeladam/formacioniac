output "application_subnet_id" {
  value = azurerm_subnet.application.id
}

output "database_subnet_id" {
  value = azurerm_subnet.database.id
}
