locals {
  name_suffix = "${var.resource_tags["ProgramName"]}-${var.resource_tags["EnvironmentName"]}"
}


resource "aws_s3_bucket" "patchS3bucket" {
  bucket = "${local.name_suffix}-${account_id}-patchlogs" 

  tags = {
    Name        = aws_s3_bucket.patchS3bucket.bucket 
    Environment = var.EnvironmentName
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3BucketKey" {
  bucket = aws_s3_bucket.patchS3bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

