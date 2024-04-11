output "windows_admin_sg" {
  description = "This is the id for Windows Admin security group"
  value       = aws_security_group.windows_sg.id
}

output "linux_admin_sg" {
  description = "This is the id for Linux Admin security group"
  value       = aws_security_group.linux_sg.id
}