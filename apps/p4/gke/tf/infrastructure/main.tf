module "google_apis" {
  source = "./google_apis"
}

module "docker_build_artifacts" {
  depends_on = [module.google_apis]

  source = "./docker_build_artifacts"

  project_id = var.project_id
  location   = var.build_artifacts_location
}
