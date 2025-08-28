module "infrastructure" {

  source = "./infrastructure"

  project_id             = var.project_id
  workload_identity_pool = var.workload_identity_pool
}
