locals {
  account_id  = data.aws_caller_identity.current.account_id
  default_tag = "${var.ProgramName}-${var.EnvironmentName}"
}

resource "aws_iam_instance_profile" "ssmpatch_profile" {
  name = "${local.default_tag}-ssmpatchprofile"
  role = aws_iam_role.ssmpatch_role.name
  tags = {
#    QSConfigId-quick-setup-configuration-id = quick-setup-configuration-id
    Environment = var.EnvironmentName
  }
}

resource "aws_iam_role_policy_attachment" "ssmpolicy_attachment" {
  role       = aws_iam_role.ssmpatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "ssmpatchiam_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

  statement {
#    principals {
#      type        = "AWS"
#      identifiers = "${local.account_id}"
#    }

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


resource "aws_iam_role" "ssmpatch_role" {
  name               = "${local.default_tag}-ssmpatchrole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ssmpatchiam_policy.json
}