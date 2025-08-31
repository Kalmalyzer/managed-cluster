terraform {
  backend "gcs" {
    bucket = "kalms-argocd-state"
    prefix = "core"
  }
}
