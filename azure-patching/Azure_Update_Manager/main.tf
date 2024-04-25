locals {
  default_tag = "${title(var.ProgramName)}-${title(var.EnvironmentName)}"
}

resource "azurerm_maintenance_configuration" "azure_patch_schedule" {
  name                     = "${local.default_tag}-${var.OS}-Patch_Schedule"
  location                 = var.location
  resource_group_name      = var.azure_resource_group
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"

  window {
    start_date_time = "2024-04-25 18:00"
    duration        = "03:00"
    time_zone       = "Eastern Standard Time"
    recur_every     = "Day"
    #check how to add offset time
  }

  install_patches {
    reboot = "IfRequired"

    windows {
      classifications_to_include = var.patch_classifications
      kb_numbers_to_exclude      = []
      kb_numbers_to_include      = []
    }
  }

  tags = {
    Environment = var.EnvironmentName
  }
}

resource "azapi_resource" "azure_dynamic_scope" {
  type      = "Microsoft.Maintenance/configurationAssignments@2023-04-01"
  name      = "${local.default_tag}-${var.OS}-DynamicScope"
  parent_id = "/subscriptions/${var.azure_subscription_id}"
  body = jsonencode({
    properties = {
      filter = {
        locations      = [var.location]
        osTypes        = [var.OS]
        resourceGroups = [var.azure_resource_group]
        resourceTypes  = ["Microsoft.Compute/virtualMachines"]
        tagSettings = {
          filterOperator = "All"
          tags = {
            Environment = [var.EnvironmentName]
          }
        }
      }
      maintenanceConfigurationId = azurerm_maintenance_configuration.azure_patch_schedule.id
      resourceId                 = "/subscriptions/${var.azure_subscription_id}"
    }
  })
}