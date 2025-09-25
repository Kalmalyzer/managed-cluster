# Retrieve ancestry of the '${prefix}-managed-gcp-projects' project
# The managed-projects folder will be created as sibling to this project
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

locals {

  project_ancestors = {
    for project, project_values in var.projects :
    project =>
    # All managed projects will reside within the folder
    {
      type : "folder",
      id : google_folder.managed_folder.id
    }
  }
}

# Create a GCP project for each of the listed projects
resource "google_project" "projects" {

  for_each = var.projects

  # Display name of project
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#name-1
  name = each.key

  # Project ID
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#project_id-1
  project_id = each.key

  # Alphanumeric ID of the billing account this project should be connected to
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#billing_account-1
  billing_account = var.billing_account

  # Numeric ID of the parent organization for this project, or null if it is supposed to be placed within a folder
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#org_id-1
  org_id = local.project_ancestors[each.key].type == "organization" ? local.project_ancestors[each.key].id : null

  # Numeric ID of the parent folder for this project, or null if it is supposed to be placed directly in an organization
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#folder_id-1
  folder_id = local.project_ancestors[each.key].type == "folder" ? local.project_ancestors[each.key].id : null

  # Do not create default network in project
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#auto_create_network-1
  auto_create_network = false

  # Allow deleting this project via Terraform actions
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project#deletion_policy-1
  deletion_policy = "DELETE"
}
