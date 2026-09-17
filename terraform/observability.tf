resource "google_project_service" "monitoring" {
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "logging" {
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudtrace" {
  service            = "cloudtrace.googleapis.com"
  disable_on_destroy = false
}

resource "google_monitoring_alert_policy" "high_cpu" {
  display_name = "SRE - High CPU Utilization"

  combiner = "OR"

  conditions {
    display_name = "GKE node CPU utilization above 80%"

    condition_threshold {
      filter = "metric.type=\"kubernetes.io/node/cpu/allocatable_utilization\" resource.type=\"k8s_node\""

      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      duration        = "300s"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  documentation {
    content = "GKE node CPU utilization has remained above 80% for 5 minutes. Investigate the affected node and workloads."
  }

  alert_strategy {
    auto_close = "1800s"
  }
}
