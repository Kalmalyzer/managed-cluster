terraform {
  backend "gcs" {
    bucket = "kalms-p4-state"
    prefix = "core"
  }
}
