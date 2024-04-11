output "windows_patchbaseline_name" {
  description = "This is the id for Windows patch baseline"
  value       = aws_ssm_patch_baseline.windows_patchbaseline.id
}

output "windows_patch_scan_window" {
  description = "This is the maintenance windows to scan for Windows patches"
  value       = aws_ssm_maintenance_window.scan_window.id
}

output "windows_patch_install_window" {
  description = "This is the maintenance windows to install Windows patches"
  value       = aws_ssm_maintenance_window.install_window.id
}