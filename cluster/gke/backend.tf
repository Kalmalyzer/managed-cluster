terraform {
  backend "gcs" {
    bucket = "kalmalyzer-managed-cluster-state"
    prefix = "core"
  }
}
