locals {
  account_id  = data.aws_caller_identity.current.account_id
  default_tag = "${var.ProgramName}-${var.EnvironmentName}"
}

resource "aws_ssm_patch_baseline" "windows_patchbaseline" {
  name        = "${local.default_tag}-windowsos-baseline"
  description = "Patch Baseline For ${var.OS} Server OS ${var.EnvironmentName} Environment"
  #  approved_patches = ["KB123456", "KB456789"]
  #  rejected_patches = ["KB987654"]
  operating_system = var.OS

  approval_rule {
    approve_after_days = 1 #Change rule to 7 or 14 days or specify a date
    compliance_level   = "HIGH"

    patch_filter {
      key    = "PRODUCT"
      values = var.product_versions
    }

    patch_filter {
      key    = "CLASSIFICATION"
      values = var.patch_classification
    }

    patch_filter {
      key    = "MSRC_SEVERITY"
      values = var.patch_severity
    }
  }

  approval_rule {
    approve_after_days = 7
    compliance_level   = "MEDIUM"

    patch_filter {
      key    = "PATCH_SET"
      values = ["APPLICATION"]
    }

    patch_filter {
      key    = "PRODUCT_FAMILY"
      values = ["Office", "PowerShell"]
    }

    patch_filter {
      key    = "PRODUCT"
      values = var.application_product_versions
    }
    patch_filter {
      key    = "CLASSIFICATION"
      values = ["FeaturePacks", "SecurityUpdates"]
    }

    patch_filter {
      key    = "MSRC_SEVERITY"
      values = ["Critical", "Important", "Moderate"]
    }
  }

  tags = {
    Environment = var.EnvironmentName
  }
}

resource "aws_ssm_patch_group" "scan_patchgroup" {
  count       = length(var.scan_patch_groups)
  baseline_id = aws_ssm_patch_baseline.windows_patchbaseline.id
  patch_group = element(var.scan_patch_groups, count.index)
}

resource "aws_ssm_patch_group" "install_patchgroup" {
  count       = length(var.install_patch_groups)
  baseline_id = aws_ssm_patch_baseline.windows_patchbaseline.id
  patch_group = element(var.install_patch_groups, count.index)
}

resource "aws_ssm_maintenance_window" "scan_window" {
  name     = "${local.default_tag}-patch-maintenance-scan"
  schedule = var.scan_maintenance_window_schedule
  duration = var.maintenance_window_duration
  cutoff   = var.maintenance_window_cutoff
}

resource "aws_ssm_maintenance_window" "install_window" {
  name     = "${local.default_tag}-patch-maintenance-install"
  schedule = var.install_maintenance_window_schedule
  duration = var.maintenance_window_duration
  cutoff   = var.maintenance_window_cutoff
}

resource "aws_ssm_maintenance_window_target" "target_scan" {
  count         = length(var.scan_patch_groups)
  window_id     = aws_ssm_maintenance_window.scan_window.id
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Patch Group"
    values = ["${element(var.scan_patch_groups, count.index)}"]
  }
}

resource "aws_ssm_maintenance_window_task" "task_scan_patches" {
  window_id        = aws_ssm_maintenance_window.scan_window.id
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-ApplyPatchBaseline"
  priority         = 1
  service_role_arn = "arn:aws:iam::${local.account_id}:role/${local.default_tag}-ssmpatchrole"
  max_concurrency  = var.max_concurrency
  max_errors       = var.max_errors

  targets {
    key    = "WindowTargetIds"
    values = aws_ssm_maintenance_window_target.target_scan[*].id
  }

  task_invocation_parameters {
    run_command_parameters {
      output_s3_bucket = "${local.default_tag}-${local.account_id}-patchlogs"
      #      output_s3_key_prefix = "output"

      parameter {
        name   = "Operation"
        values = ["Scan"]
      }
    }
  }
}

resource "aws_ssm_maintenance_window_target" "target_install" {
  window_id     = aws_ssm_maintenance_window.install_window.id
  resource_type = "INSTANCE"
  count         = length(var.scan_patch_groups)

  targets {
    key    = "tag:Patch Group"
    values = ["${element(var.install_patch_groups, count.index)}"]
  }
}

resource "aws_ssm_maintenance_window_task" "task_install_patches" {
  window_id        = aws_ssm_maintenance_window.install_window.id
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-ApplyPatchBaseline"
  priority         = 1
  service_role_arn = "arn:aws:iam::${local.account_id}:role/${local.default_tag}-ssmpatchrole"
  max_concurrency  = var.max_concurrency
  max_errors       = var.max_errors

  targets {
    key    = "WindowTargetIds"
    values = aws_ssm_maintenance_window_target.target_scan[*].id
  }

  task_invocation_parameters {
    run_command_parameters {
      output_s3_bucket = "${local.default_tag}-${local.account_id}-patchlogs"
      #      output_s3_key_prefix = "output"

      parameter {
        name   = "Operation"
        values = ["Install"]
      }
    }
  }
}