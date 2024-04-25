variable "azure_subscription_id" {
  description = "The id of the Azure subscription."
  default     = "00a29ffd-4c49-4d08-853b-2ea92e461a41"
}

variable "azure_resource_group" {
  description = "The Azure subscription resource group."
  default     = "cit-poc-rg"
}

variable "azure_resource_group_id" {
  description = "The id of the Azure subscription resource group."
  default     = "/subscriptions/00a29ffd-4c49-4d08-853b-2ea92e461a41/resourceGroups/cit-poc-rg"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "eastus2"
  #  default     = "East US 2"
}

variable "ProgramName" {
  description = "This is the program office that requested the deployment"
  type        = string
  default     = "cit"
}

variable "EnvironmentName" {
  description = "This is the environment that the application is deployed"
  type        = string
  default     = "poc"
}

variable "OS" {
  description = "This is the operating system environment"
  type        = string
  default     = "Windows"
}

variable "patch_classifications" {
  description = "This is the operating system environment"
  type        = list(string)
  default     = ["Critical", "Security"]
}