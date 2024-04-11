output "ssn_notify_id" {
  description = "This is the id of the sns topic"
  value       = aws_sns_topic.sns_notify.id
}