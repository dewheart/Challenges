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

variable "VpcIdentity" {
  description = "This is the VPC environment that the application is deployed"
  type        = string
  default     = "vpc-0f9268c00504efe80"
}

variable "NIHCidr" {
  description = "This is the IP used for RDP and HTTP access"
  type        = list(string)
  default     = ["10.242.0.0/18"]
}

variable "AnyIP" {
  description = "This is the IP used to access anything in the world wide web"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}