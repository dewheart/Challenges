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

#    variable "account_id" {
#      description = "This is the AWS account where the resource will be deployed"
#      type        = string
#      default     = "063997147317"
#    }
