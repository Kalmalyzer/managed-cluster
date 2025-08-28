terraform {
  backend "gcs" {
    bucket = "kalmalyzer-argocd-state"
    prefix = "core"
  }
}
