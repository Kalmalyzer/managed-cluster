terraform {
  backend "s3" {
    bucket = "kalms-managed-accounts-state"
    key    = "core"
    region = "eu-north-1"
  }
}
