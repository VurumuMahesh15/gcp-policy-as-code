resource "google_container_cluster" "primary" {
  name     = "policy-platform-cluster"
  location = "us-central1-a"

  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {}
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  cluster    = google_container_cluster.primary.name
  location   = "us-central1-a"
  node_count = 1

  node_config {
    machine_type = "e2-small"
    disk_size_gb = 30
    disk_type    = "pd-standard"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
