# Create service account for uploading container images
# This service account will be used by various CI jobs to upload images to container image registries
resource "google_service_account" "container_image_uploader" {
  account_id   = "container-image-uploader"
  display_name = "Container image uploader"
}

# Create a key for accessing service account
# This key will be embedded within CI job configurations
resource "google_service_account_key" "container_image_uploader" {
  service_account_id = google_service_account.container_image_uploader.name
}
