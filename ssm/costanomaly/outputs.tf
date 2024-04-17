output "patchS3bucket_arn" {
  description = "This is the arn for the created S3 bucket"
  value       = aws_s3_bucket.patchS3bucket.arn
}