output "container_image_uploader_service_account_email" {
  value = google_service_account.container_image_uploader.email
}

output "container_image_uploader_service_account_private_key" {
  value = google_service_account_key.container_image_uploader.private_key
  sensitive = true
}

output "container_images_url" {
  value = "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.container_images.name}"
}

output "container_images_repository_id" {
  value = google_artifact_registry_repository.container_images.name
}
