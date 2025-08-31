terraform {
  backend "gcs" {
    bucket = "kalms-managed-gcp-projects-state"
    prefix = "core"
  }
}
