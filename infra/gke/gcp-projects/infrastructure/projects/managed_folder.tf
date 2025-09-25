# Create a GCP folder which will contain all managed projects
resource "google_folder" "managed_folder" {

  # Folder name
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder#display_name-1
  display_name = var.managed_folder

  # Parent folder/organization
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder#parent-1
  parent = "${local.parent.type}s/${local.parent.id}"

  # Terraform is allowed to delete this folder
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder#deletion_protection-1
  deletion_protection = false
}
