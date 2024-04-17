variable "ProgramName" {
  description = "This is the program office that requested the deployment"
  type        = string
  default     = "l3harris"
}

variable "EnvironmentName" {
  description = "This is the environment that the application is deployed"
  type        = string
  default     = "prod"
}

variable "Email" {
  description = "These are the email address that needs to be alerted"
  type        = string
  default     = "dewheart@outlook.com"
}

variable "LinkedAccounts" {
  description = "These are the linked accounts attached to the anomaly monitor"
  type        = string
  default     = ["956931812200"]
}

variable "Total_Impact_Absolute" {
  description = "This is the set amount to alert against, can be budget amount"
  type        = number
  default     = ["100"]
}

variable "Total_Impact_Percentage" {
  description = "This is the percentage against true AWS spend"
  type        = number
  default     = ["10"]
}