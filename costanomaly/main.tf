resource "aws_ce_anomaly_monitor" "anomaly_monitor" {
  name         = "${var.AWSAccountName}-AWSAnomalyMonitor"
  monitor_type = "CUSTOM"
  monitor_specification = jsonencode({
    And            = null
    CostCategories = null
    Dimensions = {
      Key          = "LINKED_ACCOUNT"
      MatchOptions = null
      Values       = var.LinkedAccounts
    }
    Not = null
    Or  = null
  })
}

resource "aws_ce_anomaly_subscription" "anomaly_alert_subscription" {
  name      = "${var.AWSAccountName}-AWSAnomalyAlertSubscription"
  frequency = "WEEKLY"

  monitor_arn_list = [
    aws_ce_anomaly_monitor.anomaly_monitor.arn,
  ]

  subscriber {
    type    = "EMAIL"
    address = var.Email
  }

  subscriber {
    type    = "EMAIL"
    address = var.CustomerEmail
  }

  threshold_expression {
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
        match_options = ["GREATER_THAN_OR_EQUAL"]
        values        = var.Total_Impact_Absolute
      }
    }
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
        match_options = ["GREATER_THAN_OR_EQUAL"]
        values        = var.Total_Impact_Percentage
      }
    }
  }
}