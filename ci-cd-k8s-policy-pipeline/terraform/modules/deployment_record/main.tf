resource "local_file" "deployment_record" {
  filename = "deployment-record-${var.environment}.txt"
  content  = "Deployed to: ${var.environment}"
}