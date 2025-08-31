module "infrastructure" {

  source = "./infrastructure"

  project_id = var.project_id
  region     = var.region

  billing_account = var.billing_account
  cluster_folder_id = var.cluster_folder_id
  cluster_project = var.cluster_project
  app_folder = var.app_folder
  app_projects = var.app_projects
}
