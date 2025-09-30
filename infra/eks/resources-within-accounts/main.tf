module "infrastructure" {

  source = "./infrastructure"

  region = var.region

  accounts            = var.accounts
  github_organization = var.github_organization
}
