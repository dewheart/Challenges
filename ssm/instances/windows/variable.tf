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

variable "EC2Name" {
  description = "This is the name of the EC2 instance"
  type        = string
#  default     = "Websrv2"
}

variable "WindowsKey" {
  description = "This is the name of the EC2 instance keypair"
  type        = string
  default     = "WindowsKey"
}

variable "EC2LocalAdmins" {
  description = "This is the local admin account for CIT POC Cloud team members"
  type        = string
  default     = "CITPOCAdmins"
}

variable "EC2LocalAdminsFullName" {
  description = "This is the full name of the local admin user account for CIT POC Cloud team members"
  type        = string
  default     = "CIT POC Admins"
}

#    variable "EC2Password" {
#      description = "This is the password used to access the admin user account"
#      type        = string
#      sensitive   = true
#      #  default     = ""
#    }

variable "VpcIdentity" {
  description = "This is the VPC environment that the application is deployed"
  type        = string
  default     = "vpc-0f9268c00504efe80"
}

variable "AppSubnet" {
  description = "This is the subnet for the instance that is deployed"
  type        = string
  default     = "subnet-031cb64328cec43c0"
}

variable "AppSG" {
  description = "This is the subnet for the instance that is deployed"
  type        = string
  default     = "sg-085c5b4955bc42d2e"
}

variable "InstanceType" {
  description = "This is the instance type for the instance that is deployed"
  type        = string
  default     = "t3.medium"
}

variable "InstanceAMI" {
  description = "This is the ami being used for the new instance"
  type        = string
  default     = "ami-033b12a44ba15448b" # Windows_Server-2022-English-Full-Base-2024.02.14
}

variable "Volume1" {
  description = "This is the root volume of the EC2 instance"
  type        = string
  default     = "50"
}

variable "Volume2" {
  description = "This is the second volume attached to the EC2 instance"
  type        = string
  default     = "10"
}