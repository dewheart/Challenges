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

variable "OS" {
  description = "This label will be added to the SSM baseline description"
  type        = string
  default     = "Windows"
}

variable "install_maintenance_window_schedule" {
  description = "The schedule of the install Maintenance Window in the form of a cron or rate expression"
  type        = string
  default     = "cron(0/30 * * * ? *)"
}

variable "maintenance_window_duration" {
  description = "The duration of the maintenence windows (hours)"
  type        = string
  default     = "3"
}

variable "maintenance_window_cutoff" {
  description = "The number of hours before the end of the Maintenance Window that Systems Manager stops scheduling new tasks for execution"
  type        = string
  default     = "1"
}

variable "max_concurrency" {
  description = "The maximum amount of concurrent instances of a task that will be executed in parallel"
  type        = string
  default     = "20"
}

variable "max_errors" {
  description = "The maximum amount of errors that instances of a task will tollerate before being de-scheduled"
  type        = string
  default     = "5"
}