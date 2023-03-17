output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "linux_vm_private_ip" {
  value = azurerm_linux_virtual_machine.linux_vm.private_ip_address
}

output "virtual_machine_id" {
  value = azurerm_linux_virtual_machine.linux_vm.id
}