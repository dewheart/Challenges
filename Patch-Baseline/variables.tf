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
  default     = "WINDOWS"
}

variable "aws_region" {
  description = "The AWS region to create this SSM resource in"
  type        = string
  default     = "us-east-1"
}

## Patch baseline vars
variable "approved_patches" {
  description = "The list of approved patches for the SSM baseline"
  type        = list(string)
  default     = []
}

variable "rejected_patches" {
  description = "The list of rejected patches for the SSM baseline"
  type        = list(string)
  default     = []
}

variable "product_versions" {
  description = "The list of product versions for the SSM baseline"
  type        = list(string)
  default     = ["WindowsServer2019", "WindowsServer2022"]
}

variable "application_product_versions" {
  description = "The list of application product versions for the SSM baseline"
  type        = list(string)
  default     = ["Office 2016", "PowerShell - x64", "Microsoft 365 Apps/Office 2019/Office LTSC"]
}

variable "patch_classification" {
  description = "The list of patch classifications for the SSM baseline"
  type        = list(string)
  default     = ["CriticalUpdates", "SecurityUpdates"]
}

variable "patch_severity" {
  description = "The list of patch severities for the SSM baseline"
  type        = list(string)
  default     = ["Critical", "Important"]
}

## Maintenance window vars
variable "scan_maintenance_window_schedule" {
  description = "The schedule of the scan Maintenance Window in the form of a cron or rate expression"
  type        = string
  default     = "cron(0 0 18 ? * THU *)"
}

variable "install_maintenance_window_schedule" {
  description = "The schedule of the install Maintenance Window in the form of a cron or rate expression"
  type        = string
  default     = "cron(0 0 21 ? * FRI *)"
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

variable "scan_patch_groups" {
  description = "The list of scan patching groups, one target will be created per entry in this list"
  type        = list(string)
  default     = ["poc", "development"]
}

variable "install_patch_groups" {
  description = "The list of install patching groups, one target will be created per entry in this list"
  type        = list(string)
  default     = ["poc", "development"]
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