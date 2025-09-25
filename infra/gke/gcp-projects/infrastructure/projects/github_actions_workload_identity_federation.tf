# Create service account for GitHub Actions impersonation
# This service account will be used by CI jobs in GitHub Actions to access the corresponding Google Cloud project
# Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "github_actions" {

  for_each = var.projects

  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account#account_id-1
  account_id = "github-actions"

  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account#display_name-1
  display_name = "GitHub Actions"

  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account#project-1
  project = google_project.projects[each.key].project_id
}

# Create a Workload Identity Pool which GitHub Actions can use to access the corresponding Google Cloud project
# Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool
resource "google_iam_workload_identity_pool" "github_actions" {

  for_each                  = var.projects
  project                   = each.key
  workload_identity_pool_id = each.value.github_actions_workload_identity_pool_id
  description               = "GitHub Actions access to project ${each.key}"
}

# Create a Workload Identity Pool Provider which GitHub Actions can use to access the corresponding Google Cloud project
# Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider
resource "google_iam_workload_identity_pool_provider" "github_actions" {

  for_each                           = var.projects
  project                            = each.key
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions[each.key].workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"

  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workforce_pool_provider#nested_oidc
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  # Map attributes in the external identity provider's assertions to Google Cloud attributes
  # Reference: https://github.com/google-github-actions/auth/blob/main/README.md#workload-identity-federation-through-a-service-account
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workforce_pool_provider#attribute_mapping-1
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  # Ensure that only our GitHub Organization is allowed to use this Workload Identity Pool Provider
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workforce_pool_provider#attribute_condition-1
  attribute_condition = "assertion.repository_owner == '${var.github_organization}'"
}

# Grant each Workload Identity Pool access to the corresponding Service Account
# Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam#google_service_account_iam_member
resource "google_service_account_iam_member" "workload_identity_pool_access_to_service_account" {

  for_each           = var.projects
  service_account_id = google_service_account.github_actions[each.key].id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions[each.key].name}/attribute.repository/${var.github_organization}/${each.value.github_repository}"
}
