module "infrastructure" {

  source = "./infrastructure"

  project_id = var.project_id
  region     = var.region

  billing_account     = var.billing_account
  managed_folder      = var.managed_folder
  projects            = var.projects
  github_organization = var.github_organization
}
