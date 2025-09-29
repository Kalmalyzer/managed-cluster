module "infrastructure" {

  source = "./infrastructure"

  region = var.region

  managed_organizational_unit = var.managed_organizational_unit
  accounts                    = var.accounts
  github_organization         = var.github_organization
}
