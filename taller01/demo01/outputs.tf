output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "virtual_machine_id" {
  value = azurerm_virtual_machine.vm.id
}