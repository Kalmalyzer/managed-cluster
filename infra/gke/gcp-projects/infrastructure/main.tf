
module "google_apis" {
  source = "./google_apis"
}

module "projects" {
  depends_on = [module.google_apis]

  source = "./projects"

  region              = var.region
  billing_account     = var.billing_account
  managed_folder      = var.managed_folder
  projects            = var.projects
  github_organization = var.github_organization
}
