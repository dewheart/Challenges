output "vm_private_ip" {
  description = "This is the private ip of the new server"
  value       = azurerm_windows_virtual_machine.vm.private_ip_address
}

output "vm_public_ip" {
  description = "This is the public ip of the new server"
  value       = azurerm_windows_virtual_machine.vm.public_ip_address
}