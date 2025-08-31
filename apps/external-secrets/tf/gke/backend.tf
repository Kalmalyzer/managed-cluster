terraform {
  backend "gcs" {
    bucket = "kalms-external-secrets-state"
    prefix = "core"
  }
}
