output "ssmpatch_profile_name" {
  description = "This is the public ip of the new web server"
  value       = aws_iam_instance_profile.ssmpatch_profile_name.id
}