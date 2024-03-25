output "windows_patchbaseline_name" {
  description = "This is the public ip of the new web server"
  value       = aws_ssm_patch_baseline.windows_patchbaseline.id
}