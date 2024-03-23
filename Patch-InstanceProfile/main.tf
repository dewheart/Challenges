locals {
  account_id  = data.aws_caller_identity.current.account_id
  default_tag = "${var.ProgramName}-${var.EnvironmentName}"
}

resource "aws_iam_instance_profile" "ssmpatch_profile" {
  name = "${local.default_tag}-ssmpatchprofile"
  #  path = "/"
  role = aws_iam_role.ssmpatch_role.name
  #  tags = {
  #    QSConfigId-quick-setup-configuration-id = quick-setup-configuration-id
  #    Environment = var.EnvironmentName
  #  }
}

resource "aws_iam_role_policy_attachment" "ssmpolicy_attachment1" {
  role       = aws_iam_role.ssmpatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssmpolicy_attachment2" {
  role       = aws_iam_role.ssmpatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}


data "aws_iam_policy_document" "ssmpatchiam_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ssmpatchiam_policy2" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetEncryptionConfiguration",
    ]

    resources = [
      "arn:aws:s3:::${local.default_tag}-${local.account_id}-patchlogs",
      "arn:aws:s3:::${local.default_tag}-${local.account_id}-patchlogs/*",
    ]
  }
}

resource "aws_iam_policy" "patchS3Bucket_policy" {
  name        = "${local.default_tag}-s3patchbucket-policy"
  description = "This is the inline policy for the s3 bucket used to log patch manager"
  policy      = data.aws_iam_policy_document.ssmpatchiam_policy2.json
}

resource "aws_iam_role" "ssmpatch_role" {
  name                = "${local.default_tag}-ssmpatchrole"
  description         = "This is the role used for SSM patch instance profile"
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.ssmpatchiam_policy.json
  managed_policy_arns = [aws_iam_policy.patchS3Bucket_policy.arn]
}