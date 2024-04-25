variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "eastus2"
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

variable "source_address_prefix" {
  description = "This is the source address to the nsg"
  type        = string
  default     = "96.231.58.125/32"
}
