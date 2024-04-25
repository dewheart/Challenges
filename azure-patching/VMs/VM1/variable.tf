variable "azurerm_resource_group" {
  description = "The name of the resource group to provision resources"
  default     = "cit-poc-rg"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "eastus2"
}

variable "Subnet_Id" {
  description = "The name of the subnet for the VM"
  default     = "/subscriptions/00a29ffd-4c49-4d08-853b-2ea92e461a41/resourceGroups/cit-poc-rg/providers/Microsoft.Network/virtualNetworks/cit-poc-vnet/subnets/cit-poc-public-subnet"
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

variable "VM_Name" {
  description = "This is the name of the EC2 instance"
  type        = string
  default     = "AZSERV1"
}

variable "VM_Size" {
  description = "This is the size of the VM"
  type        = string
  default     = "Standard_B2s_v2"
}

variable "VM_Disk1_Size" {
  description = "This is the size of the first VM disk"
  type        = number
  default     = "127"
}

variable "VM_LocalAdmins" {
  description = "This is the local admin account for CIT POC Cloud team members"
  type        = string
  default     = "CITPOCAdmins"
}

variable "VM_LocalAdminsFullName" {
  description = "This is the full name of the local admin user account for CIT POC Cloud team members"
  type        = string
  default     = "CIT POC Admins"
}

variable "VM_Password" {
  description = "This is the password used to access the admin user account"
  type        = string
  sensitive   = true
  default     = "Ade12wib"
}