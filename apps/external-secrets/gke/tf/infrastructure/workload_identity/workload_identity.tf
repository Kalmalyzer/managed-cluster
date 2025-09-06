locals {
  namespace                       = "external-secrets"
  kubernetes_service_account_name = "external-secrets"
}

# Create a GCP Service Account, that will be linked to the K8s Service Account with matching name
resource "google_service_account" "cluster_service_account" {
  account_id   = "external-secrets"
  disabled     = false
  display_name = "GCP SA bound to K8S SA ${var.project_id}[${local.namespace}/${local.kubernetes_service_account_name}]"
  project      = var.project_id
}

# Allow the GCP Service Account to be used for Workload Identity by the K8s Service Account
resource "google_service_account_iam_member" "workload_identity_user" {
  member             = "serviceAccount:${var.workload_identity_pool}.svc.id.goog[${local.namespace}/${local.kubernetes_service_account_name}]"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.cluster_service_account.id
}

# Retrieve ancestry of the '${prefix}-external-secrets' project
# This should be a folder
# Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project_ancestry
data "google_project_ancestry" "project_ancestry" {
}

# Grant read access for all apps' Secrets to External Secret Operator
# Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder_iam#google_folder_iam_member
resource "google_folder_iam_member" "secret_accessor" {

  # Locate the folder that contains all apps within the managed cluster
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder_iam#folder-1
  folder = "folders/${data.google_project_ancestry.project_ancestry.ancestors[1].id}"

  # Grant capability to read secrets
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder_iam#role-1
  # Reference: https://cloud.google.com/iam/docs/roles-permissions/secretmanager
  role   = "roles/secretmanager.secretAccessor"

  # Grant it to External Secret Operator's Service Account
  # Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder_iam#member/members-1
  member = "serviceAccount:${google_service_account.cluster_service_account.email}"
}
