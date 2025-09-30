terraform {
  backend "s3" {
    bucket  = "kalms-managed-accounts-state"
    key     = "accounts"
    region  = "eu-north-1"
    profile = "AdministratorAccess-managed-accounts-state"
  }
}
