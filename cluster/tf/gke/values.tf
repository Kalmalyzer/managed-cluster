output "container_image_uploader_service_account_email" {
  value = module.infrastructure.container_image_uploader_service_account_email
}

output "container_image_uploader_service_account_private_key" {
  value = module.infrastructure.container_image_uploader_service_account_private_key
  sensitive = true
}

output "container_images_url" {
  value = module.infrastructure.container_images_url
}
