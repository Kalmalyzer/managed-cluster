resource "google_project" "app_projects" {
  for_each = toset(var.app_projects)

  name                = each.key
  project_id          = each.key
  billing_account     = var.billing_account

  # Do not create default network in project
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#auto_create_network-1
  auto_create_network = false

  # Allow deleting this project via Terraform actions
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#deletion_policy-1
  deletion_policy = "DELETE"
}

resource "google_storage_bucket" "app_project_state" {
  for_each = toset(var.app_projects)

  name     = "${each.key}-state"
  project  = google_project.app_projects[each.key].project_id
  location = var.region

  # Enable Uniform bucket level access (i.e. rely solely on IAM rules for access control -- disable ACLs)
  # Reference: https://cloud.google.com/storage/docs/uniform-bucket-level-access
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket#uniform_bucket_level_access-1
  uniform_bucket_level_access = true
}
