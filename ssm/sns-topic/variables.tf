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

variable "TeamEmail" {
  description = "This is the email used for the sns subscription"
  type        = string
  default     = "adewunmi.ibironke@nih.gov"
}