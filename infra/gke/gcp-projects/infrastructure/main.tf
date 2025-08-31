
module "google_apis" {
  source = "./google_apis"
}

module "folders_projects_state" {
  depends_on = [module.google_apis]

  source = "./folders_projects_state"

  region = var.region
  billing_account = var.billing_account
  cluster_folder_id = var.cluster_folder_id
  cluster_project = var.cluster_project
  app_folder = var.app_folder
  app_projects = var.app_projects
}
