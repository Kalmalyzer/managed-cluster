# This repository will contain any custom-built container images that get deployed
# These container images will be retained perpetually
resource "google_artifact_registry_repository" "container_images" {
  location = var.location
  repository_id = "container-images"
  description = "GKE Core Services Container image artifacts"
  format = "DOCKER"

  docker_config {
    # Tags can be created, but not modified, moved or deleted
    # This ensures that an image, once pushed to the repository, will never disappear or be replaced by another image
    # Reference: https://cloud.google.com/artifact-registry/docs/docker/names
    immutable_tags = true
  } 
}

# Image uploader service account is allowed to pull images from repository
resource "google_artifact_registry_repository_iam_member" "container_image_uploader_read_access" {
  location = google_artifact_registry_repository.container_images.location
  repository = google_artifact_registry_repository.container_images.name
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.container_image_uploader.email}"
}

# Image uploader service account is allowed to push images to repository
resource "google_artifact_registry_repository_iam_member" "container_image_uploader_write_access" {
  location = google_artifact_registry_repository.container_images.location
  repository = google_artifact_registry_repository.container_images.name
  role   = "roles/artifactregistry.writer"
  member = "serviceAccount:${google_service_account.container_image_uploader.email}"
}
