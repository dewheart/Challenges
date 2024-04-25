output "azure_resource_group_name" {
  description = "This is the name of the Azure resource group"
  value       = azurerm_resource_group.azure_resource_group.name
}

output "azure_vnet_name" {
  description = "This is the name virtual network"
  value       = azurerm_virtual_network.azure_vnet.name
}

output "public_subnet_id" {
  description = "This is the id of the public subnet"
  value       = azurerm_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "This is the id of the private subnet"
  value       = azurerm_subnet.private_subnet.id
}