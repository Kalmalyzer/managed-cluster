module "infrastructure" {

  source = "./infrastructure"

  project_id             = var.project_id
  build_artifacts_location = var.build_artifacts_location
}
