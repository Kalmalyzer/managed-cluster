# All nodes in GKE cluster will operate using this service account
resource "google_service_account" "node_pool_service_account" {
  account_id   = "${var.cluster_name}-node"
  display_name = "Node in GKE Core Services pool"
}

# Allow nodes to send log messages to Cloud Logging
resource "google_project_iam_member" "controller_cloud_logging_write_access" {

  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}

# Allow nodes to send events to Cloud Monitoring
resource "google_project_iam_member" "controller_cloud_monitoring_write_access" {

  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}

# Allow nodes to pull images from artifact repository
resource "google_artifact_registry_repository_iam_member" "container_images_read_access" {
  location   = var.region
  repository = var.container_images_repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}
