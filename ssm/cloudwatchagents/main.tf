locals {
  account_id  = data.aws_caller_identity.current.account_id
  default_tag = "${var.ProgramName}-${var.EnvironmentName}"
  region      = data.aws_region.current.name
}

resource "aws_ssm_maintenance_window" "install_cloudwatchagent" {
  name              = "${local.default_tag}-cloudwatchagent-install"
  description       = "This is the maintenance window for installing Cloudwatch agents on instances"
  schedule          = var.install_maintenance_window_schedule
  schedule_timezone = "US/Eastern"
  duration          = var.maintenance_window_duration
  cutoff            = var.maintenance_window_cutoff
}

resource "aws_ssm_maintenance_window_target" "agent_install" {
  window_id     = aws_ssm_maintenance_window.install_cloudwatchagent.id
  resource_type = "INSTANCE"
  targets {
    key    = "tag:OS"
    values = [var.OS]
  }
}

resource "aws_ssm_maintenance_window_task" "task_install_agent" {
  description      = "This task is used to install Cloudwatch agents on instances"
  window_id        = aws_ssm_maintenance_window.install_cloudwatchagent.id
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-ConfigureAWSPackage"
  priority         = 2
  service_role_arn = "arn:aws:iam::${local.account_id}:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM"
  max_concurrency  = var.max_concurrency
  max_errors       = var.max_errors

  targets {
    key    = "WindowTargetIds"
    values = aws_ssm_maintenance_window_target.agent_install[*].id
  }

  task_invocation_parameters {
    run_command_parameters {
      output_s3_bucket     = "${local.default_tag}-${local.account_id}-patchlogs"
      output_s3_key_prefix = "Logs/CloudwatchAgents-Install"
      service_role_arn     = "arn:aws:iam::${local.account_id}:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM"
      document_version     = "$LATEST"

      parameter {
        name   = "action"
        values = ["Install"]
      }

      #      parameter {
      #        name   = "installationType"
      #        values = ["Uninstall and reinstall"]
      #      }

      parameter {
        name   = "name"
        values = ["AmazonCloudWatchAgent"]
      }

      notification_config {
        notification_arn    = "arn:aws:sns:${local.region}:${local.account_id}:${local.default_tag}-snsnotify"
        notification_events = ["All"]
        notification_type   = "Command"
      }
    }
  }
}