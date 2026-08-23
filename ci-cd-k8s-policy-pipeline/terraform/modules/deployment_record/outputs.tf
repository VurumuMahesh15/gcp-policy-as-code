output "created_filename" {
  value = local_file.deployment_record.filename
}

output "environment_used" {
  value = var.environment
}