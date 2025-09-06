module "google_apis" {
  source = "./google_apis"
}

module "workload_identity" {
  depends_on = [module.google_apis]

  source = "./workload_identity"

  project_id             = var.project_id
  workload_identity_pool = var.workload_identity_pool
}
