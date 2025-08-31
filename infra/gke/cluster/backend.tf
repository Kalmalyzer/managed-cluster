terraform {
  backend "gcs" {
    bucket = "kalms-managed-cluster-state"
    prefix = "core"
  }
}
