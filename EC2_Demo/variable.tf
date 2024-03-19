variable "EnvName" {
  description = "This is the environment that the application is deployed"
  type        = string
  default     = "Test Environment"
}

variable "EC2Name" {
  description = "This is the environment that the application is deployed"
  type        = string
  default     = "Webserver1"
}

variable "pLinuxKey" {
  description = "This is the environment that the application is deployed"
  type        = string
  default     = "LinuxKey"
}

variable "VpcIdentity" {
  description = "This is the environment that the application is deployed"
  type        = string
  default     = ""
}

variable "PublicSubnet" {
  description = "This is the environment that the application is deployed"
  type        = string
  default     = ""
}

variable "InstanceType" {
  description = "This is the environment that the application is deployed"
  type        = string
  default     = "t2.micro"
}

variable "InstanceAMI" {
  description = "This is the environment that the application is deployed"
  type        = string
  default     = "ami-0889a44b331db0194"
}

variable "Volume1" {
  description = "This is the environment that the application is deployed"
  type        = string
  default     = "8"
}

variable "MyIP" {
  description = "This is the environment that the application is deployed"
  type        = list(string)
  default     = ["96.241.156.40/32"]
}

variable "AnyIP" {
  description = "This is the environment that the application is deployed"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}