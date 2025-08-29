terraform {
  backend "gcs" {
    bucket = "kalmalyzer-external-secrets-state"
    prefix = "core"
  }
}
