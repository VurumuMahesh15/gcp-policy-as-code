resource "google_storage_bucket" "test" {
  name     = "policy-as-code-platform-test-bucket"
  location = "US"
}
