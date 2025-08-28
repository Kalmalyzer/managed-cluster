output "container_image_uploader_service_account_email" {
  value = module.artifact_registries.container_image_uploader_service_account_email
}

output "container_image_uploader_service_account_private_key" {
  value = module.artifact_registries.container_image_uploader_service_account_private_key
  sensitive = true
}

output "container_images_url" {
  value = module.artifact_registries.container_images_url
}
