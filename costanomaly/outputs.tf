output "output_anomaly_monitor" {
  description = "This is id of the anomaly monitor"
  value       = aws_ce_anomaly_monitor.anomaly_monitor.id
}

output "output_anomaly_alert_subscription" {
  description = "This is id of the anomaly alert subscription"
  value       = aws_ce_anomaly_subscription.anomaly_alert_subscription.id
}