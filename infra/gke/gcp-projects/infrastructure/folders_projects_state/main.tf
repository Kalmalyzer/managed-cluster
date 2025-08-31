
# Retrieve ancestry of the '${prefix}-managed-gcp-projects' project
# The managed cluster project and the apps folder will be created as sibling to this project
# Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project_ancestry
data "google_project_ancestry" "gcp_projects_ancestry" {
}

locals {

  # Root of all the resources we will create;
  # either
  #   type = "organization", id = <organization ID>
  # or
  #   type = "folder", id = <folder ID>
  # depending on where in the hierarchy the '${prefix}-managed-gcp-projects' project is located
  parent = data.google_project_ancestry.gcp_projects_ancestry.ancestors[1]
}

# Create a GCP folder which will contain all apps' projects
resource "google_folder" "app_folder" {

  # Folder name
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder#display_name-1
  display_name = var.app_folder

  # Parent folder/organization
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder#parent-1
  parent = "${local.parent.type}s/${local.parent.id}"

  # Terraform is not allowed to delete this folder
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder#deletion_protection-1
  deletion_protection = true

  # TODO: consider adding a tag to this, which enables External Secret operator to get a role in the folder
}

locals {
  projects_and_folders = merge(
    {
      # The "cluster project" will reside within the root of the organization
      (var.cluster_project) = local.parent,
    },
    {
      # All app projects will reside within the app folder
      for app_project in var.app_projects :
        app_project => {
          type: "folder",
          id: google_folder.app_folder.id,
        }
    }
  )
}

# Create a GCP project for each of the listed projects
resource "google_project" "projects" {

  for_each = local.projects_and_folders

  # Display name of project
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#name-1
  name                = each.key

  # Project ID
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#project_id-1
  project_id          = each.key

  # Alphanumeric ID of the billing account this project should be connected to
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#billing_account-1
  billing_account     = var.billing_account

  # Numeric ID of the parent organization for this project, or null if it is supposed to be placed within a folder
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#org_id-1
  org_id           = each.value.type == "organization" ? each.value.id : null

  # Numeric ID of the parent folder for this project, or null if it is supposed to be placed directly in an organization
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#folder_id-1
  folder_id           = each.value.type == "folder" ? each.value.id : null

  # Do not create default network in project
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#auto_create_network-1
  auto_create_network = false

  # Allow deleting this project via Terraform actions
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#deletion_policy-1
  deletion_policy = "DELETE"
}

# Create a Storage bucket within each of the listed projects
# The buckets are intended to contain Terraform state
# Each individual project can then have a Terraform stack that expects the project + state bucket to already exist
resource "google_storage_bucket" "app_project_state" {

  for_each = local.projects_and_folders

  name     = "${each.key}-state"
  project  = google_project.projects[each.key].project_id
  location = var.region

  # Enable Uniform bucket level access (i.e. rely solely on IAM rules for access control -- disable ACLs)
  # Reference: https://cloud.google.com/storage/docs/uniform-bucket-level-access
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket#uniform_bucket_level_access-1
  uniform_bucket_level_access = true
}
