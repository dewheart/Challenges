locals {
  account_id  = data.aws_caller_identity.current.account_id
  default_tag = "${var.ProgramName}-${var.EnvironmentName}"
  region      = data.aws_region.current.name
}

resource "aws_ce_anomaly_monitor" "anomaly_monitor" {
  name              = "AWSAnomalyMonitor"
  monitor_type      = "CUSTOM"
  monitor_specification = jsonencode({
    And            = null
    CostCategories = null
    Dimensions     = {
      Key          = "LINKED_ACCOUNT"
      MatchOptions = null
      Values = var.LinkedAccounts
    }
    Not            = null
    Or             = null
  })
}

resource "aws_ce_anomaly_subscription" "test" {
  name      = "AWSAnomalyAlertSubscription"
  frequency = "WEEKLY"

  monitor_arn_list = [
    aws_ce_anomaly_monitor.anomaly_monitor.arn,
  ]

  subscriber {
    type    = "EMAIL"
    address = var.Email
  }

  threshold_expression {
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
        match_options = ["GREATER_THAN_OR_EQUAL"]
        values        = ["100"]
      }
    }
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
        match_options = ["GREATER_THAN_OR_EQUAL"]
        values        = ["10"]
      }
    }
  }
}