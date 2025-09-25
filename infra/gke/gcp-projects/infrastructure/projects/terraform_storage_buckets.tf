# Create a Storage bucket within each of the listed projects
# The buckets are intended to contain Terraform state
# Each individual project can then have a Terraform stack that expects the project + state bucket to already exist
resource "google_storage_bucket" "project_state" {

  for_each = var.projects

  name     = each.value.terraform_state_bucket_id
  project  = google_project.projects[each.key].project_id
  location = var.region

  # Enable Uniform bucket level access (i.e. rely solely on IAM rules for access control -- disable ACLs)
  # Reference: https://cloud.google.com/storage/docs/uniform-bucket-level-access
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket#uniform_bucket_level_access-1
  uniform_bucket_level_access = true
}
