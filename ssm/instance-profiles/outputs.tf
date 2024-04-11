output "ssmpatch_profile_name" {
  description = "This is the name of the new SSM patch profile"
  value       = aws_iam_instance_profile.ssmpatch_profile.id
}