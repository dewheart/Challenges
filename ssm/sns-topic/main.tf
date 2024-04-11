locals {
  default_tag = "${var.ProgramName}-${var.EnvironmentName}"
}

resource "aws_sns_topic" "sns_notify" {
  name              = "${local.default_tag}-snsnotify"
  display_name      = "${local.default_tag}-snsnotify"
  kms_master_key_id = "alias/aws/sns"
  tags = {
    Environment = var.EnvironmentName
  }
}

resource "aws_sns_topic_subscription" "sns_notify_subscription" {
  topic_arn = aws_sns_topic.sns_notify.arn
  protocol  = "email"
  endpoint  = var.TeamEmail
}
