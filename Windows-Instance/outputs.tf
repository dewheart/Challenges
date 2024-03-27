output "webserver_private_ip" {
  description = "This is the public ip of the new web server"
  value       = aws_instance.webserver.private_ip
}