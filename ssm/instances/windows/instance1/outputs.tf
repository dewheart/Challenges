output "webserver_private_ip" {
  description = "This is the private ip of the new server"
  value       = aws_instance.webserver.private_ip
}