terraform {
  backend "s3" {
    bucket  = "kalms-managed-accounts-state"
    key     = "resources-within-accounts"
    region  = "eu-north-1"
    profile = "Administrator-managed-accounts-state"
  }
}
