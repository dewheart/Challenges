output "azure_patching_schedule" {
  description = "This is the id of the patching schedule"
  value       = azurerm_maintenance_configuration.azure_patch_schedule.id
}