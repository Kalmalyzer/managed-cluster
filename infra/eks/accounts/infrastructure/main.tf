module "accounts" {

  source = "./accounts"

  region = var.region

  managed_organizational_unit = var.managed_organizational_unit
  accounts                    = var.accounts

  providers = {
    aws.root = aws.root
  }
}
