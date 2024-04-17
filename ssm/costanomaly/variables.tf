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

variable "AWSAccountName" {
  description = "This is the name of the AWS account that cost anomaly is being set for"
  type        = string
  default     = "dewlearning"
}

variable "Email" {
  description = "This is the email of Cloud Architecture Team that will be alerted"
  type        = string
  default     = "dewheart@outlook.com"
}

variable "CustomerEmail" {
  description = "This is the email of the customer that will be alerted"
  type        = string
  default     = "tobawunmi@yahoo.com"
}

variable "LinkedAccounts" {
  description = "These are the linked accounts attached to the anomaly monitor"
  type        = list(string)
  default     = ["956931812200", "063997147317"]
}

variable "Total_Impact_Absolute" {
  description = "This is the set amount to alert against, can be budget amount"
  type        = list(string)
  default     = ["100"]
}

variable "Total_Impact_Percentage" {
  description = "This is the percentage against true AWS spend"
  type        = list(string)
  default     = ["10"]
}