output "patchS3bucket_arn" {
  description = "This is the public ip of the new web server"
  value       = aws_s3_bucket.patchS3bucket.arn
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}