terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  credentials = file("terraform-key.json")
  project     = "policy-as-code-platform"
  region      = "us-central1"
}
