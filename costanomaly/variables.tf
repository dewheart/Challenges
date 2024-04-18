variable "AWSAccountName" {
  description = "This is the name of the AWS account that cost anomaly is being set for"
  type        = string
#  default     = ""
}

variable "Email" {
  description = "This is the email of Cloud Architecture Team that will be alerted"
  type        = string
#  default     = ""
}

variable "CustomerEmail" {
  description = "This is the email of the customer that will be alerted"
  type        = string
#  default     = ""
}

variable "LinkedAccounts" {
  description = "These are the linked accounts attached to the anomaly monitor"
  type        = list(string)
#  default     = [""]
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