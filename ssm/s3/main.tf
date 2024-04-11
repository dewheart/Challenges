locals {
  account_id  = data.aws_caller_identity.current.account_id
  default_tag = "${var.ProgramName}-${var.EnvironmentName}"
}

resource "aws_s3_bucket" "patchS3bucket" {
  bucket        = "${local.default_tag}-${local.account_id}-patchlogs"
  force_destroy = false

  tags = {
    Environment = var.EnvironmentName
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3BucketKey" {
  bucket = aws_s3_bucket.patchS3bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

