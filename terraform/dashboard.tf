resource "google_monitoring_dashboard" "sre_dashboard" {
  dashboard_json = jsonencode({
    displayName = "SRE Infrastructure Dashboard"

    gridLayout = {
      columns = "2"

      widgets = [
        {
          title = "GKE Node CPU Utilization"

          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"kubernetes.io/node/cpu/allocatable_utilization\" resource.type=\"k8s_node\""

                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_MEAN"
                    }
                  }
                }

                plotType = "LINE"
              }
            ]

            yAxis = {
              label = "Y1"
              scale = "LINEAR"
            }
          }
        },
        {
          title = "GKE Container CPU Utilization"

          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"kubernetes.io/container/cpu/core_usage_time\" resource.type=\"k8s_container\""

                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_RATE"
                    }
                  }
                }

                plotType = "LINE"
              }
            ]

            yAxis = {
              label = "Y1"
              scale = "LINEAR"
            }
          }
        }
      ]
    }
  })
}
