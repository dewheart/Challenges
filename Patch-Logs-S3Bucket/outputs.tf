output "patchS3bucket_arn" {
  description = "This is the public ip of the new web server"
  value       = aws_s3_bucket.patchS3bucket.arn
}