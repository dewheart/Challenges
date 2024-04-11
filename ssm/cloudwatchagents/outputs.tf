output "cloudwatchagent_install_window" {
  description = "This is the maintenance windows to install cloudwatch agents"
  value       = aws_ssm_maintenance_window.install_cloudwatchagent.id
}